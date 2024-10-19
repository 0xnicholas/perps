# Perps

Exploration of crypto derivatives, perps and synthetic assets.

衍生品有两个用途: hedging and speculation.

相比现货,交易者使用它主要有两个原因,无法获得标的资产和杠杆。高摩擦的现货市场创造了对流动性衍生品市场的需求,交易衍生品的资本效率更高,(本质是)可使用杠杆;同时允许用户对冲/投机更难获取的资产。

## 产品说明
> 早期版本为"缝合怪实验"

- On-chain Derivative [yes]
- No Credit Risk [yes]
- Leverage [150x]
- Trading pairs [>10]
- PnL Trading, no spot trading

LP
- LP: stablecoin (include stablecoin swap LP)
- LP market risk: Market Neutral
- LP PnL: Trading fee - Trading PnL
- LP Mint/Burn: Low fee
- Passive yield: stablecoin

- Borrow fee: None

- Oracle: Decentralized (Chainlink + Pyth and other agg..)

Incentives
> incentive target: upper-lv users, rather than all users equally.

- Project token yield: es___

### 风险控制
> 从LP侧和trader侧考虑其核心问题

| Risk | Control |
|----|----|
| 预言机价格操纵 | 使场外操纵价格的成本始终高于在场内的盈利 |
| 单边敞口过大, 资金池失衡 | 价格波动和多空比决定持仓成本 |
| 流动性不足 | |

#### Trade

##### Price impact/spread

Spread 是开仓时需要付出的额外滑点，基于预言机定价时，其滑点应该根据预言机来源的交易对深度而动态调整。使得在场外操纵价格的成本始终高于在场内的盈利， Spread 正相关开仓规模和场内OI影响，而负相关于场外现货深度。

Spread会影响交易者开关仓成本，应尽量实现0价差。

spread机制风险管理：
- Cumulative Volume Windows: 15分钟累计交易窗口更新，即每15分钟重置价格影响。
- Long positions
    - Open spread: Uses open long & close short volume
    - Close spread: Uses close long & open short volume
- Short positions
    - Open spread: Uses open short & close long volume
    - Close spread: Uses close short & open long volume
> close spread 是订单簿深度反向函数
- Protection factor: 针对价格操纵，适用于开仓不到15分钟且PnL为正的close spread交易。
- Depth multiplier: 价格影响的分母

*Spread formula*
```math
Spread = (traderVolumeInLast15Mins + (positionSize / 2)) * protectionFactorIfPosivePnlAndOpenLessThan15Mins / (multiplier * depth)
```

##### Rollover Fee / Funding Fee

**Rollover fee**根据近期波动性计算，展期费用多空均要缴纳，在frenzied bull时，波动性和多空比的加大将会让多方支付的费用快速上涨，以此回补作为对手方的损失以及控制多空比。

*计算*

```math
RolloverFee = (CurrentBlock - tradeOpenBlock) * rolloverFeePerBlock\% * tradeCollateral
```

*参数设置*

参数设置将取决于货币对的波动性，使用 ATR（average true range）来衡量：
```math
\tag{x=1.25, y=20} RolloverFeePerBlock \% = \frac{(ATR4WeekAverage\%)^x * 52}{y}
```

*示例*

**Funding fee**旨在尽量缩小多空OI(Open Interest)之间的差距，以防止在任何交易对中仅在一方产生非常大的风险敞口。

*计算*

```math
AccumulatedFundingFeePerOI(long) += \frac{(LongOI - ShortOI) * blocksElapsed * FundingFeePerBlock\%}{LongOI} \\

AccumulatedFundingFeePerOI(short) += \frac{(ShortOI - LongOI) * blocksElapsed * FundingFeePerBlock\%}{ShortOI}
```

当交易开启时，我们存储初始累计的funding fee值，并在每次OI变化时更新。

要计算当前交易应该产生多少funding fee，则计算
```math
FundingFee = (CurrentAccumulatedFundingFeePerOI - InitialAccumulatedFundingFeePerOI) * TradeCollateral * TradeLeverage
```

如果该值为负数，则像正 PnL 一样将其添加到交易价值中，并使清算价格进一步远离。如果该值为正数，则像负 PnL 一样将其从交易价值中移除，并使清算价格更加接近。

*参数设置*
和Rollover fee类似，参数设置取决于交易对的波动性，使用 ATR（average true range）来衡量：
```math
\tag{x=1.25, y=50} FundingFeePerBlock\% = \frac{ATR4WeekAverage\%^x * 52}{y}
```

*示例*



#### LP



---
# 附

## 市场竞争因素简评

### *vs* CEX
- 性能鸿沟

DEX应该永远不会在性能上取胜,在99.9%的时间里DEX的性能总是低于CEX,DEX只有可能在黑天鹅事件期间更具弹性用来支撑市场。

- 功能迭代

创建与 CEX 功能相当的永续合约 DEX 难度更大。对于永续合约来说,由于涉及多个功能部分(例如管理margin、cross-margin、rate、leverage、oracle等),创建同样的 DEX 的难度要大几个数量级。

- 竞争激烈

perps 基本就是是CEX的摇钱树,因此竞争非常激烈。DEX 不仅要赶上 CEX,还必须跟上多个中心化实体对 perps 进行创新和改进的速度。

*切入点*

DEX需要通过在CEX无法竞争的领域来进行渗透,我们需要强化只有DEX才能提供的价值主张:
- 可组合性,这是DeFi原生特性,是DEX竞争的主要因素。其他 DeFi 项目可以插入 perps DEX 以创建新的部分,或者perps利用其他流动性池等
- 去中心化带来的特性,如透明度,无需许可,任意合适资产,24/7流动性等。

总之,DEX 最需要通过采用 CEX 在结构上无法模仿的策略和运营模式来展开竞争。

### 流动性基础
在众多竞争因素(如下表)中,流动性是最关键的,所有其他因素都能有助于提高exchange的流动性。

| | | |
| :---- | :---- | :---- |
| Lquidity / flows | | |
| Capital costs / efficiency | | |


## Perps设计简述

Perps DEX 流动性模型设计思路主要就是两个方向,
- Orderbook ( _CLOB / hybrid orderbook-AMM )
- Pools ( Multi-asset pool or single-asset pool )

| *优缺点*| | | |
| :---- | :---- | :---- | :---- |
| **CLOB** | dYdX, Drift | Pros| 最高资本效率;不依赖其他地方的mark price,从而更好促进价格发现; |
| | | Cons| 复杂性更高,启动流动性更加困难;处理要求更高 |
| **Pools** | GMX, Synthetix  | Pros| 用于DeFi的可组合LP代币;在某些情况下可能更好的滑点/更低的成本;降低复杂性;更适合区块链环境|
| | | Cons| 资本效率较低受LP规模限制;依赖价格预言机限于预言机支持的pair;容易受到预言机漏洞的攻击|


### Pools设计核心
在资金池设计中,交易者的收益往往是以流动性提供者的损失为代价的,反之亦然(如GMX)。协议的成功和可持续性取决于"*the house always wins.*"

我们考虑一些极端情况(beating the house):

1. 如果协议只吸引精明的交易者(sharp traders),亏损的交易者都退出,同时没有新的交易者加入。那么协议的LP就会成为精明交易者的交易对手,而所谓sharp trades只有在有利可图时才与LP交易。
2. 有毒流动(toxic flow)是由于信息不对称而具有高概率短期交易获利的订单,比如front-running price oracles。交易者也可以利用*low-liquidity event*,在 DEX 上购买大量永续合约头寸,然后操纵基础资产的价格,使永续合约头寸获利。或者,与多个交易所有*well-connected*的交易者也可以从统计上预测短期价格变动的可能性,并使用 DEX 永续合约获利。
3. "long crypto",大多数加密货币参与者往往是net long,以 USDC 计价的单一资产池特别容易受到这种现象的影响,因为对应的,LP 将承担交易的另一侧(net short)。因此在trending bull market中,LP可能会遭受长期损失,这可能会引发"death spiral", *LPs pull liquidity -> reducing available liquidity -> deterring users to trade -> LPs withdraw liquidity -> ...* 相比之下,多资产池更容易管理,因为池本身自然也是long crypto。处理这一点的关键是激励交易者在另一侧交易和/或增加挤兑交易的成本。(如Synthetix 的动态融资率)

*小结*
> 实现内生价格(endogenous price)发现的交易所几乎都会成为Orderbook式的交易所

基于池的 DEX 在 perps 垂直领域肯定占有一席之地,因为它们为交易所供需双方提供了有吸引力的功能。在供应方面,它们通过有效地允许流动性提供者将价格发现外包给其他市场,在一定程度上创造了公平的竞争环境。散户和机构 LP 都为交易者提供相同的报价。在需求方面,它们可以为交易者提供有竞争力的价格执行。

尽管如此,基于Pool的DEX最终价值会受到限制,因为价格发现总是发生在其他场所,它们的增长受到预言机支持和流动性提供者效率低下的瓶颈。

领先的衍生品交易所将是能够实现内生价格发现的交易所,这几乎肯定会成为 CLOB 式的交易所。CLOB 实现了市场内生价格发现,为交易者提供了最佳的资本效率和表达偏好的最有效方式。

混合 CLOB(订单匹配在链下进行,但结算在链上)是一种适当的权衡。

### 参考案例

#### GMX
> 可组合,多种可能的玩法; 相对可靠的收益; 更适合小鱼。

在v1中,GMX 创建了 GLP 池,作为所有交易者的交易对手,GLP 池包含所有可在 GMX 上交易的资产。用户可以通过mint $GLP将这些资产的任何一种存入池中,然后,交易者将其用于流动性,不会有滑点也不会对市场产生影响。$GLP 持有者还可获得 70% 的协议收入,其中包括从 GLP 存入/提取的费用(动态加权以激励维持每项资产的特定百分比)、开仓/平仓交易的费用以及未平仓头寸收取的每小时借款费。

这种模式随后创造了加密货币领域收益最高的资产之一。GMX 的费用始终高于其他协议,使得整个子生态系统的项目都建立在 GLP 之上,以利用实际收益。这使得 GMX 相对来说是一个流动性相当强的选择,因为所有不同的方都向 GLP 存款。GLP 创新之所以如此有效,是因为它创造了强大的可持续收益来源,这反过来又使其成为流动性最强的链上 perp dex 之一。

在v2中,流动性通过自动的 GLV 池和单独的 GM 池提供。流动性提供者从杠杆交易、借款费用和掉期中赚取费用。v2通过调整费用和提高资本效率实现了更可持续的系统。由于GLP依靠traders的净亏损来运作,因此在v1时并没有考虑他们获胜后会发生什么(the house always wins.),v2试图在解决这个问题。


#### dYdX
> 低(bridge)费用,很多交易对

dYdX使用orderbook和混合去/中心化系统,用户在链上提交订单,这些订单与链下订单簿(通常由做市商、大型交易商和 dYdX 管理)匹配,从而防止抢先交易并能即时更新余额,同时保留一定程度的去中心化。

orderbook模型依赖于成熟度做市商,而不是像Pools那样,用户只是与资产池进行交易。这就是为什么 dYdX 上定期产生如此多交易量的原因,做市商在这里的运营利润比其他任何地方都高。dYdX从一开始的目标就是创建一种让普通加密货币高级用户和机构做市商都感觉用户友好的产品。

在保持吞吐量的同时实现去中心化是v4转变的首要考虑因素。v4 based on Cosmmos SDK and CometBFT构建自己的主权L1,这意味着他们将拥有自己的验证器网络以及完全可定制的链基础设施,通过这种方法,验证器在链下运行订单簿,以便任何人都可以加入并为 dex 提供基础设施,同时获得网络奖励。


#### Synthetix/Kwenta
> 最直接的交易激励 + 作为各种资产的通用解决方案。不过不是每个人都热衷于合成资产

Synthetix是流动性层,为衍生品交易提供基础设施。Kwenta 几乎占据了 Synthetix 上的全部交易量,因此我们主要将 Synthetix 的所有 perp 数据也视为 Kwenta 的。

Synthetix 以合成资产(synths)debt pool开展业务,用户可以stake SNX并earn fees + emissions, 通过price_oracle mint 反映底层资产价格的合成资产。需要满足一定的抵押比率(C-ratio),用户才能在其stake的SNX上领取奖励,保持健康的债务。

从本质上讲,Synthetix 与 GMX 类似,不同之处在于使用合成资产作为 SNX 代币的债务, Synthetix 能够提供更多种类的资产,但由于需要满足一定比率,因此资本效率较低 (在 GMX 中,可以使用 100% 的 GLP 池)Synthetix 要求整个池子有一定的 C-ratio,因此在任何给定时刻只能使用约 85%。不过,两者都依赖于所述资产的定价预言机,这使得它们彼此更相似,而不是像使用订单簿的 dYdX 那样。

Kwenta 是一个使用 Synthetix 协议在 Optimism 上构建的现货/perp dex,其账户通过其专有保证金引擎使用 sUSD 进行保证金支付。这个系统的运作方式有点复杂,但本质上可以归结为让不同的操作更加离散,因此用户在开仓/平仓时有更多创造性的选择,从而为用户带来更好的执行和融资利率。KWENTA 代币管理协议并在stake时获得emissions。

#### Drift
> 只在Solana上交易是个不错的选择(速度快廉价(-*如果没宕机*)),但Solana<>EVM的桥接成本效率是个问题

Drift 的流动性特性来源是其 JIT 流动性做市商池。每笔市价单都会触发 5 秒的dutch auction,做市商可以在给定的价格区间内(从预言机价格开始)完成订单。这为用户创造了获得更好成交的机会,也为做市商创造了抢先执行订单簿 + DAMM 的机会。

Decentralized Limit Orderbook/Keeper Network,只有市价单会通过JIT进行路由。限价单首先会被放置在DLOB里,该DLOB由其Keeper网络管理(类似dYdX v3做的),限价单在链上提交,由Keeper bots跟踪,在链下构建orderbooks。然后,这些订单要么相互执行,要么与下一个liquidity source - Drift AMM执行。

Drift AMM (DAMM) 的来自Perpetual Protocol 的(virtual) vAMM。vAMM并没有维持经典xy=k的比率,
而是所有collateral都在一起支撑AMM,这样没有明确的LP来提供流动性,因为所有的traders都在为彼此提供流动性。

DAMM 允许外部 LP 补充流动性(与传统 AMM 相比- 单边、没有无常损失)、可调整的价格乘数、费用、流动性深度 + 调整,以及在交易前可编程更新动态价差 (dynamic spread)。动态调整定价不平衡和多空不平衡,以维持健康的市场。另外DAMM 是交易的最后一个可能的流动性来源(先是JIT),因此对用户来说具有最不理想的执行价格。


#### _Others
**gTrade**

gTrade 使用与 Synthetix 类似的合成架构。关键区别在于,Synthetix 仅使用 $SNX 代币来铸造资产,而 gTrade 主要使用由 $GNS 代币支持的 $DAI。所有交易均通过 gDAI vault以 $DAI 抵押品开立,该vault使用ERC-4626 标准,可提供更强大的功能和可组合性 - 这意味着可以交易你的 $gDAI 并在 defi 中使用它。

LP 质押 $DAI 以铸造 $gDAI(用户可以选择通过锁定长达一年或在抵押率接近 100% 时铸造来获得折扣,最高可达 5%),随着费用和交易者的 PnL 的累积,其价格相对于 $DAI 上涨。从保险库中提款需要 3-9 天的解锁期,具体取决于c-ratio。


**Level Finance**

类似于传统金融中资产证券化的优先级和次级的分层设计,Level 的流动性供应方法(称为流动性提供者风险管理,或 RMLP)涉及将 LP 分成 3 个不同的部分(高级、夹层和初级),风险和随后的预期收益依次递增。类似GMX中有3个不同的GLP,每个GLP风险/收益程序各不相同。当用户开仓时,流动性将根据资产的波动性按比例从 3 个部分中提取(费用按比例分配)。


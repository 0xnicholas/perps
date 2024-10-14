# Perps

> Exploration of crypto derivatives, perps and synthetic assets.

衍生品有两个用途：hedging and speculation.

相比现货，交易者使用它主要有两个原因，无法获得标的资产和杠杆。高摩擦的现货市场创造了对流动性衍生品市场的需求，交易衍生品的资本效率更高，可使用杠杆；同时允许用户对冲/投机更难获取的资产。

## 市场竞争因素简评

*难点*
- 性能鸿沟

DEX应该永远不会在性能上取胜，在99.9%的时间里DEX的性能总是低于CEX，DEX只有可能在黑天鹅事件期间更具弹性用来支撑市场。

- 功能迭代

创建与 CEX 功能相当的永续合约 DEX 难度更大。对于永续合约来说，由于涉及多个功能部分（例如管理margin、cross-margin、rate、leverage、oracle等），创建同样的 DEX 的难度要大几个数量级。

- 竞争激烈

perps 基本就是是CEX的摇钱树，因此竞争非常激烈。DEX 不仅要赶上 CEX，还必须跟上多个中心化实体对 perps 进行创新和改进的速度。

*切入点*

DEX需要通过在CEX无法竞争的领域来进行渗透，我们需要强化只有DEX才能提供的价值主张：
- 可组合性，这是DeFi原生特性，是DEX竞争的主要因素。其他 DeFi 项目可以插入 perps DEX 以创建新的部分，或者perps利用其他流动性池等
- 去中心化带来的特性，如透明度，无需许可，任意合适资产，24/7流动性等。

总之，DEX 最需要通过采用 CEX 在结构上无法模仿的策略和运营模式来展开竞争。

### 以流动性为核心思考
在众多竞争因素（如下表）中，流动性是最关键的，所有其他因素都能有助于提高exchange的流动性。

| | | |
| :---- | :---- | :---- |
| Lquidity / flows | | |
| Capital costs / efficiency | | |




## Perps设计简述

Perps DEX 流动性模型设计思路主要就是两个方向，
- Orderbook(_CLOB / AMM(vAMM)_)
- Pools(Multi-asset pool or single-asset pool)

*优缺点*

| | | | |
| :---- | :---- | :---- | :---- |
| CLOB | dYdX| Pros| 最高资本效率；不依赖其他地方的mark price，从而更好促进价格发现； |
| | | Cons| 复杂性更高，启动流动性更加困难；处理要求更高，不太适配当然区块链环境|
| Pools | GMX, Synthetix  | Pros| 用于DeFi的可组合LP代币；在某些情况下可能更好的滑点/更低的成本；降低复杂性；更适合区块链环境|
| | | Cons| 资本效率较低受LP规模限制；依赖价格预言机限于预言机支持的pair；容易受到预言机漏洞的攻击|
| | | | |


### Pools设计核心
在资金池设计中，交易者的收益往往是以流动性提供者的损失为代价的，反之亦然（如GMX）。协议的成功和可持续性取决于"*the house always wins.*"

我们考虑一些极端情况(beating the house)，

1. 如果协议只吸引精明的交易者(sharp traders)，亏损的交易者都退出，同时没有新的交易者加入。那么协议的LP就会成为精明交易者的交易对手，而所谓sharp trades只有在有利可图时才与LP交易。
2. 有毒流动(toxic flow)是由于信息不对称而具有高概率短期交易获利的订单，比如front-running price oracles。交易者也可以利用*low-liquidity event*，在 DEX 上购买大量永续合约头寸，然后操纵基础资产的价格，使永续合约头寸获利。或者，与多个交易所有*well-connected*的交易者也可以从统计上预测短期价格变动的可能性，并使用 DEX 永续合约获利。
3. "long crypto"，大多数加密货币参与者往往是net long，以 USDC 计价的单一资产池特别容易受到这种现象的影响，因为对应的，LP 将承担交易的另一侧（net short）。因此在trending bull market中，LP可能会遭受长期损失，这可能会引发"death spiral"，*LPs pull liquidity -> reducing available liquidity -> deterring users to trade -> LPs withdraw liquidity -> ...* 相比之下，多资产池更容易管理，因为池本身自然也是long crypto。处理这一点的关键是激励交易者在另一侧交易和/或增加挤兑交易的成本。(如Synthetix 的动态融资率)

*小结*
> 实现内生价格发现的交易所几乎都会成为Orderbook式的交易所

基于池的 DEX 在 perps 垂直领域肯定占有一席之地，因为它们为交易所供需双方提供了有吸引力的功能。在供应方面，它们通过有效地允许流动性提供者将价格发现外包给其他市场，在一定程度上创造了公平的竞争环境。散户和机构 LP 都为交易者提供相同的报价。在需求方面，它们可以为交易者提供有竞争力的价格执行。

尽管如此，基于Pool的DEX最终价值会受到限制，因为价格发现总是发生在其他场所，它们的增长受到预言机支持和流动性提供者效率低下的瓶颈。

领先的衍生品交易所将是能够实现内生价格发现的交易所，这几乎肯定会成为 CLOB 式的交易所。CLOB 实现了市场内生价格发现，为交易者提供了最佳的资本效率和表达偏好的最有效方式。

混合 CLOB（订单匹配在链下进行，但结算在链上）是一种适当的权衡。

### 参考案例
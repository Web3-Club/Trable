<h1 align="center">
  <span style="font-size: 32px;">Trable</span>
</h1>

<h2 align="center">
  Enable pay in travel without trouble.
</h2>


<h1 align="center">
  <img src="https://github.com/Web3-Club/Trable/assets/76860915/7e5a55f1-1486-4de6-a28e-7080e046f19d" alt="25461702219436_ pic" style="width: 50%; display: block; margin: 0 auto;">
</h1>

### [English]((https://github.com/Web3-Club/Trable/blob/main/docs/README.md)) | 中文


## 前言


随着Web3生态的不断壮大，越来越多的人跻身Web3行业，自然有越来越多的人使用加密货币进行产品和服务的支付。

但如今想要走完购买的全流程非常繁琐（尤其涉及到境外产品时），中间需经历数次的资产置换。

这个过程不仅耗时，还会对用户原先的资产产生多次消耗，成本高昂。

### 传统crypto支付境外旅游产品过程

#### 链上-DEX-CEX-法币-非本国法币支付

##### 弊端

- ❌ DEX转换磨损
   
- ❌ CEX交易手续费  
   
- ❌ 出金汇率磨损
  
- ❌ 非本国发币支付货币转换费


#### 流程图演示

<h1 align="center">
  <img src="https://github.com/Web3-Club/Trable/assets/76860915/b89cd0bd-34f7-404d-b0de-8ff321357266" alt="25461702219436_ pic" style="width: 50%; display: block; margin: 0 auto;">
</h1>


#### Trable想要做到的

- ✅ 一步签名即到位 仅收取较少费用

<h1 align="center">
  <img src="https://github.com/Web3-Club/Trable/assets/76860915/5fa6728f-26fa-4a68-8980-ee6e73b78dff" alt="25461702219436_ pic" style="width: 50%; display: block; margin: 0 auto;">
</h1>

对此我们的项目提出解决方案，优化资产转换流程，提升用户在Web3的体验。

并且后疫情时代，旅游业蓬勃发展，Trable进入这个庞大的市场，旨在提供独特的价值主张。



### 项目介绍

Trable是一款针对加密货币支付的境外旅游产品Dapp应用。

此应用通过集成Uniswap V4 等技术，依靠Polkadot生态中的Acala平台,有效地简化了用户使用加密货币订购境外旅游产品的流程，缩减消费者的所需时间 及降低DEX/CEX货币转换的成本。

用户仅需选择所需的支付加密货币并完成签名，即可轻松在本Dapp预订境外旅游产品。我们解决了个人外汇额度限制和支付工具不足的问题，提供了必要的法币支付支持。同时，我们在链上实时监控资金流向，确保资金安全。在整个过程中，只会收取一次手续费，为用户的订购体验提供全面保障。

<br>

### 基本技术架构

#### Uniswap V4

在Uniswap V3中，给每个流动性资金池部署单独的合约，这样创建资金池和执行多池兑换的成本更高。

Uniswap V4将所有资金池都存储在一个合约中，从而节省了大量的燃料成本，因为兑换将不再需要在不同的合约中的资金池之间转移代币。

> <img width="320" alt="截屏2023-12-18 下午4 25 48" src="https://github.com/Web3-Club/Trable/assets/76860915/1c5708e4-c08d-4a94-a190-9f49646b0f2b">
> Uniswap V4 白皮书

## Acala

我们团队一直在研究如何简化不同链上虚拟资产的交易流程，发现uniswap v4中讲所有的资金池部署在一个合约的方案具有优势，因此主要的思想还是基于uniswap v4。

但由于uniswap V4 现阶段使用的Bussiness license的4年商用限制问题，现阶段采用unswap v3的改进版进行代币质押兑换。

由于acala multi chain routing的特质很好的满足了团队的这一需求

因此团队技术正在逐步学习研究acala router，并且后续会在acala evm上开展更多的测试，并在本次黑客松期间尝试跑通整套流程

现阶段的痛点可以用acala multichain router解决

由于 uniswap v4现在的技术方案经过测试还有些不成熟，并且商业license也没有到达按期开放的时间节点，

所以团队前期采用自研的uniswap v3 trable，目前正在将合约部分迁移到acala multichain router。

我们由此希望去在本次黑客松 

主要使用 Asset Router 的 LST 集成协议 允许用户通过类似于 一笔交易将 DOT等多链token 从 Polkadot 发送到 Acala 并交换到，将 XCM 交换到另一个平行链的方式 来尝试对比我们的uniswap trable方案 来完成构建在polkadot生态上的trable的跨链及swap交互实验


#### Solidity
为了是项目构建在Uniswap V3上 实现未来对于Uniswap V4的支持 我们在项目合约上使用了Solidity语言 对项目进行了构建

### 前端

项目前端仓库:[Trable-froutend](https://github.com/Web3-Club/Trable-frontend)

#### Javascript 

### Key Dapp Features

- 支持法币支付

确保旅游产品跨境crypto直接支付的便利性

- 随时随地、快速交易

简化虚拟货币转移过程（多链资产转换）

- 省时省力、更低损耗

结合Uniswap V4 降低多种token的swap成本，减少不必要的原始资产的转换和支付磨损

- 无需考虑个人外汇限制

不受传统银行外汇限额的影响，更流畅的旅行体验

### 项目demo





## 测试

项目包含了针对合约功能的测试用例，确保了各项功能的正确性和安全性。




## 队员信息

GitHub:
[@yanboishere](https://github.com/yanboishere)
[@s7iter](https://github.com/s7iter)
[@Jerry](https://github.com/Web3-Jerry)

WeChat:
@ZZJZZJ9248

## 联系我们

[![Twitter](https://img.shields.io/badge/@Web3Club-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/Web3ClubCN)
[![Telegram](https://img.shields.io/badge/@Web3Club-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Web3ClubCN)
[![Mail](https://img.shields.io/badge/web3clubCN@outlook.com-0078D4?style=for-the-badge&logo=microsoft-outlook&logoColor=white)](mailto:web3clubCN@outlook.com)


<h1 align="center">
  <span style="font-size: 32px;">Trable</span>
</h1>

<h1 align="center">
  <img src="https://github.com/Web3-Club/Trable/assets/76860915/a48c8fa5-4deb-474c-a9d5-f5cda2cadff0" alt="25461702219436_ pic" style="width: 50%; display: block; margin: 0 auto;">
</h1>

<h2 align="center">
  Enable pay in travel without trouble.
</h2>


<h1 align="center">
  <img src="https://github.com/Web3-Club/Trable/assets/76860915/7e5a55f1-1486-4de6-a28e-7080e046f19d" alt="25461702219436_ pic" style="width: 50%; display: block; margin: 0 auto;">
</h1>




### English | [中文](https://github.com/Web3-Club/Trable/blob/main/docs/README_CN.md)


## Introduction

With the growing Web3 ecosystem, more and more people are entering the Web3 industry, leading to an increasing number of individuals using cryptocurrencies for payments of products and services. However, the process of completing a purchase has become cumbersome, especially when it involves overseas products, requiring multiple asset conversions. This process is time-consuming and incurs high costs.

Traditional crypto payment process for overseas travel products:

    Cryptocurrency - DEX - CEX - Fiat currency - Foreign fiat currency payment


### Flowchart Demo


```mermaid
graph TD
  subgraph Multi-chain Token
    A1[main network]
    A2[Layer2 Token]
    A3[other Tokens]
  end

  B[Cross-chain Bridge]

  subgraph DEX/CEX
    C1[DEX1]
    C2[CEX1]
    C3[DEX2]
  end

  subgraph Monetary Conversion
    D[c2c domestic currency deposit and withdrawal]
    D1[Conversion of various legal currencies.]
  end

  E[Credit Card<br>visa/mastercard/China UnionPay/JCB/American Express]
  F[Payment for Overseas Products]

  A1 -->|Asset Replacement| B -->|gas consumption<br>Waiting for the payment to be credited.| C1 -->|Asset Transfer| C2 
  A2 -->|Asset Replacement| B -->|gas consumption<br>Waiting for the payment to be credited.| C2 -->|Asset Transfer| D
  A3 -->|Asset Replacement| B -->|gas consumption<br>Waiting for the payment to be credited.| C3 -->|Asset Transfer| D -->|Rate Discount| D1 --> E
  E --> |Currency Conversion Fee| F
```


### Drawbacks:
- ❌ DEX conversion friction costs
- ❌ CEX transaction fees
- ❌ Currency conversion loss during withdrawal
- ❌ Currency conversion fees for foreign money payments


Trable's Objective:
- ✅ One-step signing, minimal fees



```mermaid
graph TD
  C[The user has explicitly paid for the product.]
  subgraph User Action
    A1[main networdk]
    A2[Layer2 Token]
    A3[Multi-chain Token]
  end
  subgraph  Trable
    B[Signature confirmation]
    F[Stablecoin]
    Z[uniswap V4<br>hook pool]
    D[Payment Successful]
  end

C --> A1 --> B
C --> A2 --> B
C --> A3 --> B 
B --> Z -->F --> D
```



To address these challenges, our project proposes a solution that optimizes the asset conversion process and enhances users' Web3 experience. In the post-pandemic era, the travel industry is thriving, and Trable aims to enter this vast market by offering unique value propositions.


### Project Introduction

Trable is an overseas travel product Dapp application for cryptocurrency payment.

This application integrates Uniswap V4 and other technologies and relies on the Acala and Moonbean platforms in the Polkadot ecosystem to effectively simplify the process for users to order overseas travel products using cryptocurrency, shorten the time required for consumers and reduce the cost of DEX/CEX currency conversion. .

Users only need to select the required payment password and complete the signature to easily book overseas travel products on this Dapp. We have solved the problems of personal foreign exchange limit limits and insufficient payment tools, and provided necessary legal currency payment support. At the same time, we monitor the flow of funds in real time on the chain to ensure the safety of funds. During the entire process, only one handling fee will be charged, providing comprehensive protection for users’ ordering experience.

<br>

### Basic technical architecture

#### Uniswap V4


In Uniswap V3, each liquidity pool is deployed with its own individual contract, resulting in higher costs for creating pools and executing multi-pool exchanges.

Uniswap V4 consolidates all liquidity pools into a single contract, thereby saving significant gas costs. This is because exchanges will no longer require the transfer of tokens between pools in different contracts.


<h1 align="center">
  <img src="https://github.com/Web3-Club/Trable/assets/76860915/410be736-3518-47ec-af66-78ce7683740e" alt="25461702219436_ pic" style="width: 200%; display: block; margin: 0 auto;">
</h1>




### Solidity

- The project is built on Uniswap V3 to ensure future support for Uniswap V4. We utilized the Solidity for the project's smart contracts.


###  Frontend

Project frontend repository:[Trable-froutend](https://github.com/Web3-Club/Trable-frontend)

[Demo](https://trable-fe.vercel.app/)

## Key Dapp Features

- Support for fiat currency payments


- Fast transactions anytime, anywhere


- Save time and effort, lower loss


- No need to consider personal foreign exchange restrictions






## Testing
The project includes test cases for contract functionality, ensuring the correctness and security of each feature.


## Project demo

### Video
https://youtu.be/ujFpy4i8USQ




## Member

GitHub:
[@yanboishere](https://github.com/yanboishere)
[@s7iter](https://github.com/s7iter)
[@Jerry](https://github.com/Web3-Jerry)
[@zijin79](https://github.com/zijin79)

## Contect

[![Twitter](https://img.shields.io/badge/@Web3Club-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/Web3ClubCN)
[![Telegram](https://img.shields.io/badge/@Web3Club-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Web3ClubCN)
[![Mail](https://img.shields.io/badge/web3clubCN@outlook.com-0078D4?style=for-the-badge&logo=microsoft-outlook&logoColor=white)](mailto:web3clubCN@outlook.com)


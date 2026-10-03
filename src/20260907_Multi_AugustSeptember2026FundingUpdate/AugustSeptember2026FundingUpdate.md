---
title: "August/September 2026 Funding Update"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597"
---

## Simple Summary

This publication presents the August/September Funding Update, consisting of the following key activities:

- Acquire GHO to support the runway;
- Create Allowances to support Operations;
- Fund initial Asset Backed Private Credit trial deployments; and
- Activate the PoolExposureSteward on Monad and Plasma.

## Motivation

This publication addresses near-term operational requirements, consolidates asset holdings, and refreshes the MainnetSwapSteward's Allowances to support operations and future growth opportunities.

The MainnetSwapSteward and Aave Finance Committee (AFC) will continue executing a rolling GHO acquisition strategy to maintain adequate runway and preserve sufficient budget to fund ongoing growth initiatives.

### Reimburse Audit Costs

Reimburse TokenLogic for costs incurred in facilitating a second audit of the GHO ↔ sGHO two-way swap layer of the Aave V4 Reinvestment Controller. The audits performed by Trail of Bits and ChainSecurity cost 25,000 and 44,939.27 respectively, for a total of 69,939.27 aEthLidoGHO.

The reimbursement of 1,818,102 to Aave Labs for the Aave V4 audit, Aave App audit and rsETH related legal expenses is executed by the Aave Finance Committee through a DAI transfer from its Safe on Avalanche, and is therefore not part of this payload.

### Asset Backed Private Credit

Asset-backed private credit represents a potential growth opportunity for GHO and the Aave ecosystem. TokenLogic will support the assessment, implementation, monitoring and reporting of these arrangements, in coordination with Aave Labs and within the authority and parameters established through the applicable governance process. Specialist third parties will originate and service the underlying assets.

### Aave Liquidity Committee

The Aave Liquidity Committee has operated for the past twelve months on the Phase VII budget of 2,500,000 GHO approved in September 2025. Measured liquidity incentive spend is now approximately $125,000 per thirty day period. This publication renews the ALC budget over a six month period, sized to the current measured run rate.

### Growth Initiatives

Several Aave V4 instances are approved or in preparation, and each requires a bootstrap window during which supply side liquidity and time limited incentives establish functioning markets. This publication creates the allowances needed to support the next instance launches, funded from a combination of Collector Allowances, USDC already held on the Aave Finance Committee Safe, and limited borrowing against assets held on the Ahab Safe.

## Specification

### Ethereum

#### Runway

Deposit idle ETH on the Collector into the Aave v3 Core instance on Ethereum.

Use the MainnetSwapSteward to acquire 4M of GHO to be deposited into the Prime instance.

#### Refresh MainnetSwapSteward Allowances

To support the acquisition of GHO, wETH and AAVE, replenish token budgets on the MainnetSwapSteward to the absolute values listed in the table below.

| Token | Budget |
| ----- | ------ |
| ETH   | 5k     |
| USDC  | 10M    |
| USDT  | 10M    |
| USDe  | 2M     |
| USDS  | 0.2M   |
| DAI   | 0.2M   |
| rlUSD | 0.2M   |
| pyUSD | 0.2M   |

Upon implementation, the budgets for each token will be as shown above; any higher budgets will be marked lower, and any lower budgets will be increased to reflect the values presented in the table.

#### Asset Backed Private Credit

To prepare for creating an asset backed Private Credit Investment Mandate, this publication enables the Aave Finance Committee (AFC) to allocate funds to initial pilot-stage deployments. The AFC will use the existing wETH allowance in the Ahab Safe and assets held on the AFC or Ahab Safe(s) to source the liquidity supporting the initial allocations. The initial phase is expected to result in between $5M and $10M allocated to pilot-stage deployments of asset-backed private credit products.

#### Aave Liquidity Committee

Create an Allowance enabling the ALC to withdraw 750,000 aEthLidoGHO from the Prime instance, covering a six-month period.

Network: Ethereum
Asset: aEthLidoGHO `0x18eFE565A5373f430e2F809b97De30335B3ad96A`
Amount: 750,000
Spender: ALC `0xA1c93D2687f7014Aaf588c764E3Ce80aF016229b`

#### Growth Allowances

Create the following Allowances to support forthcoming Aave V4 instance launches.

Network: Ethereum
Asset: aEthUSDC `0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c`
Amount: 1,500,000
Spender: Aave Finance Committee `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

Network: Ethereum
Asset: aEthUSDC `0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c`
Amount: 850,000
Spender: Incentive Budget Safe `0x66Ac7223048037826e12cef9a848199e31AEFabE`

The AFC will combine the Allowances above with the USDC already held on the AFC Safe and up to 2,000,000 USDC borrowed against assets held on the Ahab Safe, for a total supply-side allocation of up to 5,250,000 USDC.

#### Reimbursements

Reimburse 69,939.27 aEthLidoGHO to TokenLogic for the second GHO ↔ sGHO two-way swap layer and Aave V4 Reinvestment Controller audit expenses incurred.

Network: Ethereum
Asset: aEthLidoGHO `0x18eFE565A5373f430e2F809b97De30335B3ad96A`
Amount: 69,939.27
Spender: TokenLogic `0xAA088dfF3dcF619664094945028d44E779F19894`

Cancel/Remove the following Allowance:

Network: Ethereum
Asset: aEthLidoWETH `0xfa1fdbbd71b0aa16162d76914d69cd8cb3ef92da`
Spender: Ahab `0xAA2461f0f0A3dE5fEAF3273eAe16DEF861cf594e`

### Base

Create the following Allowance to support forthcoming Aave V4 instance launches.

Network: Base
Asset: aBasUSDC `0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB`
Amount: 443,000
Spender: Aave Finance Committee `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

### Monad

Grant the `FUNDS_ADMIN` role on the Aave V3 Monad Collector to the newly deployed PoolExposureSteward, enabling the steward to manage Collector liquidity across the instance.

Steward: `0x72EAfbD4331dD482f5c8135fF0452d97da6F77B0`

### Plasma

Grant the `FUNDS_ADMIN` role on the Aave V3 Plasma Collector to the newly deployed PoolExposureSteward, enabling the steward to manage Collector liquidity across the instance.

Steward: `0xB5c5D35553826d681F3f3CC5Bae6cfA0446dE706`

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Base_AugustSeptember2026FundingUpdate_20260907.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Monad_AugustSeptember2026FundingUpdate_20260907.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Base_AugustSeptember2026FundingUpdate_20260907.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Monad_AugustSeptember2026FundingUpdate_20260907.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

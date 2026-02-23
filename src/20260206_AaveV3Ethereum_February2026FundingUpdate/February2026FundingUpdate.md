---
title: "February 2026 - Funding Update"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-february-2026-funding-update/24030"
---

## Simple Summary

This publication presents the **February Funding Update**, consisting of the following key activities:

- **Runway**: Acquire GHO to support operational runway.
- **GHO liquidity**: Expand Ahab & AFC SAFEs remit to support GHO liquidity.
- **Operations**: Create allowances to support ongoing operations.

## Motivation

This publication addresses near-term operational requirements, consolidates asset holdings, and renews allowances to the `MainnetSwapSteward` to optimise the DAO’s stablecoin management.

The `MainnetSwapSteward` will continue executing a rolling GHO acquisition strategy to maintain adequate runway and support AAVE buybacks, while preserving sufficient budget to fund ongoing growth initiatives.

Additionally, this publication initiates a process to reduce DEX and CEX GHO liquidity expenses by providing liquidity directly and indirectly across multiple pools.

## Specification

### Runway

Using the `MainnetSwapSteward` and a portion of the ETH received from recent liquidation volume to acquire **2M GHO**, to be deposited into the **Prime** instance.

### Idle ETH

Deposits idle ETH held on the Ethereum Collector, received from recent liquidation volume, into the Aave v3 Core instance. The resulting aWETH is then used to fund the Ahab and Liquidity allowances detailed below.

### Operations

Create allowances for the following assets to be transferred from the Treasury to the **AFC**:

- **Asset**: `AAVE` (`0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9`)
- **Amount**: `100,000`
- **Spender**: `AFC` SAFE (`0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`)
- **Method**: `approve()` AAVE on the Aave Collector contract to the AFC address

This allowance enables the AAVE acquired via buybacks to be held on the AFC SAFE. The allowance is larger than the current balance to facilitate future buybacks and minimise governance overhead.

### Extend Ahab Capacity

Extends Ahab allowances to support upcoming business initiatives and recent asset price changes. The aWETH allowance is sourced from the idle ETH deposited into Aave v3 Core above, where it is to be used as collateral to fund incentive programs via GHO debt:

- **Asset**: `aEthWETH` (`0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8`), **Amount**: `4,000`
- **Asset**: `aEthwstETH` (`0x0B925eD163218f6662a35e0f0371Ac234f9E9371`), **Amount**: `1,100`
- **Spender**: `Ahab` SAFE (`0xAA2461f0f0A3dE5fEAF3273eAe16DEF861cf594e`)

### Extend AAVE/wETH Liquidity

Create allowances for the Aave Liquidity SAFE to deploy AAVE and wETH liquidity across DEXs:

- **Asset**: `AAVE` (`0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9`), **Amount**: `40,000` (from Ecosystem Reserve)
- **Asset**: `aEthWETH` (`0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8`), **Amount**: `1,500` (from Aave Collector)
- **Spender**: Aave Liquidity SAFE (`0xAAA973Fe8A6202947e21D0a3a43d8E83ABE35C23`)

### GHO CEX Liquidity

Create a USDe allowance to provide inventory for supporting USDT/GHO liquidity across centralised exchanges:

- **Asset**: `USDe` (`0x4c9EDD5852cd905f086C759E8383e09bff1E68B3`), **Amount**: `6,000,000`
- **Spender**: `CEX Earn` SAFE (`0xAA12BAd4a501d45A5b771e49C2Fd415BA8BFc79d`)

The Finance Steward will be used to withdraw USDe from the protocol to fund this allowance. The allowance exceeds the Collector's current USDe balance to accommodate the withdrawal and support future operations.

### MainnetSwapSteward Allowances

Replenish allowances on the `MainnetSwapSteward` to support continued AAVE and GHO buybacks:

| Token | Budget    |
| ----- | --------- |
| ETH   | 3,000     |
| USDC  | 5,000,000 |
| USDT  | 5,000,000 |
| USDe  | 5,000,000 |
| USDS  | 2,000,000 |
| DAI   | 2,000,000 |

### Reimbursements

- Reimburse **1.470836210916653291 aEthWETH** to ACI (`0xac140648435d03f784879cd789130F22Ef588Fcd`) for expenses incurred supporting Aave DAO governance and incentive campaigns.
- Reimburse **26,000 aEthLidoGHO** to TokenLogic (`0xAA088dfF3dcF619664094945028d44E779F19894`) for audit expenses incurred.

## References

- **MainnetSwapSteward ARFC**: <https://governance.aave.com/t/arfc-steward-deployment-mainnetswapsteward-and-rewardssteward/23070>
- **Implementation**: [AaveV3Ethereum payload](https://github.com/aave-dao/aave-proposals-v3/blob/b66a068cde174714319a486c3d811b34f8387989/src/20260206_AaveV3Ethereum_February2026FundingUpdate/AaveV3Ethereum_February2026FundingUpdate_20260206.sol)
- **Tests**: [AaveV3Ethereum tests](https://github.com/aave-dao/aave-proposals-v3/blob/b66a068cde174714319a486c3d811b34f8387989/src/20260206_AaveV3Ethereum_February2026FundingUpdate/AaveV3Ethereum_February2026FundingUpdate_20260206.t.sol)
- **Snapshot**: Direct-to-AIP
- **Discussion**: <https://governance.aave.com/t/direct-to-aip-february-2026-funding-update/24030>

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

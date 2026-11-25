---
title: "November 2026 Funding Update"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312"
---

## Simple Summary

This publication presents the November Funding Update, consisting of the following key activities:

- Acquire GHO to support the runway;
- Consolidate assets held on other networks onto Ethereum;
- Expand the MainnetSwapSteward;
- Deposit the ETH held by the Collector into Aave;
- Recover Merkl rewards held by the GSMs on Plasma and Monad;
- Bug bounty payment; and,
- Create and update Allowances to support Operations.

## Motivation

This publication addresses near-term operational requirements, consolidates asset holdings across networks, and expands the MainnetSwapSteward to support the runway.

The MainnetSwapSteward and Aave Finance Committee (AFC) will continue executing a rolling GHO acquisition strategy to maintain adequate runway and preserve sufficient budget to fund ongoing growth initiatives.

### Asset Consolidation

The GHO held by the Collectors on Plasma, Monad, and Arbitrum, around 1.38M, will be bridged to Ethereum to support the runway. Idle assets on Mantle, Gnosis and Sonic are also to be bridged to Ethereum, where they can be managed by the PoolExposureSteward and MainnetSwapSteward.

### Expand MainnetSwapSteward

The Collector holds around 1.3M of USDtb, USDG, EURC and sUSDe that the MainnetSwapSteward cannot currently swap. Adding these tokens enables them to be converted to GHO.

### Collector ETH

The Collector holds around 292 ETH that is not earning yield. This publication wraps it into WETH and deposits it into the Core instance.

### GSM Merkl Rewards

The GHO GSMs on Plasma and Monad have accrued Merkl rewards, 613k WXPL and 1.46M WMON. Once claimed, these rewards sit on the GSM contracts and can only be moved by governance. This publication transfers them to the AFC, where they will be sold.

### Incentive Campaigns

The 350k USDC held on Ahab will fund incentives for specific campaigns supporting targeted growth.

### Bug Bounty Payouts

This month's funding update includes one 1,000 USDC bug bounty payment to a security researcher and the associated 100 USDC fee payment to Immunefi.

### Update

The V4 Base USDC supply from the August/September Funding Update was funded with USDC held on the AFC and GHO borrowed on Ahab; the growth allowances were not drawn. The private credit pilots will use Ahab's existing wETH collateral, as the aEthLidoWETH allowance was cancelled. 100k USDC was bridged to the Incentive Budget Safe on Arc.

## Specification

### Ethereum

#### Runway

Use the [MainnetSwapSteward](https://governance.aave.com/t/arfc-steward-deployment-mainnetswapsteward-and-rewardssteward/23070) and the already-approved Allowances to acquire 2.7M GHO and deposit it into the Prime instance.

#### Bug Bounty Payments

The following bug bounty payments are to be processed to the researcher and Immunefi. As the Collector holds almost no idle USDC, the payments are funded from its aEthUSDC, withdrawn to USDC for each recipient.

Asset: USDC `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
Amount: 1,000
Recipient: Researcher `0x0DDE46b923eB74F1860727914f179e82b9eE47B9`

Asset: USDC `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
Amount: 100
Recipient: Immunefi `0x7119f398b6C06095c6E8964C1f58e7C1BAa79E18`

#### Deposit ETH

Wrap the ETH held by the Collector into WETH and deposit it into the Core instance on the Collector's behalf.

Asset: ETH, wrapped into WETH `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
Amount: the Collector's ETH balance at execution (292.35 at the time of writing)
Destination: Aave V3 Core, aEthWETH held by the Collector

#### Expand MainnetSwapSteward

Add the following tokens to the `MainnetSwapSteward` with GHO as the acquirable asset. Each token uses its Aave V3 Ethereum Core price feed.

| Token | Budget | Acquirable Asset |
| ----- | ------ | ---------------- |
| USDtb | 625k   | GHO              |
| USDG  | 385k   | GHO              |
| EURC  | 175k   | GHO              |
| sUSDe | 125k   | GHO              |

#### Allowances

Refresh the existing aEthLidoGHO Allowance to the Aave V4 audit Safe down to 250k.

Asset: aEthLidoGHO `0x18eFE565A5373f430e2F809b97De30335B3ad96A`
Amount: 250k
Spender: Aave V4 audit Safe `0xAAf400e4Bbc38B5E2136C1a36946Bf841A357307`

**Cancel the following Allowance:**

Asset: aEthGHO `0x00907f9921424583e7ffBfEdf84F92B7B2Be4977`
Spender: Ahab `0xAA2461f0f0A3dE5fEAF3273eAe16DEF861cf594e`

### Plasma

Create GHO and aPlaGHO Allowances for the AFC to bridge the GHO held on the Collector to Ethereum via CCIP. Part of the Collector's GHO is supplied to the pool as aPlaGHO, and there is no PoolExposureSteward on Plasma, so the AFC withdraws it before bridging.

Asset: GHO `0xb77E872A68C62CfC0dFb02C067Ecc3DA23B4bbf3`
Amount: 1.1M
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

Asset: aPlaGHO `0xAd571979b4245E163A7E2119EB4dFd94AfDaebC5`
Amount: 1.1M
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

On the GHO USDT GSM `0xd06114F714beCD6f373e5cE94E07278eF46eBF37`:

1. Grant `TOKEN_RESCUER_ROLE` to the Plasma Executor Lvl 1 `0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A`.
2. Call `rescueTokens(WXPL, AFC, amount)`, with amount equal to the GSM's WXPL balance at execution (613,220 at the time of writing). Recipient: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`.
3. Revoke `TOKEN_RESCUER_ROLE` from the Plasma Executor.

### Monad

Create GHO and aMonGHO Allowances for the AFC to bridge the GHO held on the Collector to Ethereum via CCIP. Part of the Collector's GHO is supplied to the pool as aMonGHO, and there is no PoolExposureSteward on Monad, so the AFC withdraws it before bridging.

Asset: GHO `0xfc421aD3C883Bf9E7C4f42dE845C4e4405799e73`
Amount: 300k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

Asset: aMonGHO `0x4586face17B0e3D4d51EcABb4B4EBC2354b61b0D`
Amount: 300k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

The AFC has claimed the Merkl rewards on behalf of the GHO USDC GSM `0x3Cf3779EEf770931543ACd2C7f6ECd1b37E35caB`. On the GSM:

1. Grant `TOKEN_RESCUER_ROLE` to the Monad Executor Lvl 1 `0xa9d0EAFF48cE1DF468f9eAeb7e628c413343F6A2`.
2. Call `rescueTokens(WMON, AFC, amount)`, with WMON `0x3bd359C1119dA7Da1D913D1C4D2B7c461115433A` and amount equal to the GSM's WMON balance at execution (1,458,970 at the time of writing). Recipient: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`.
3. Revoke `TOKEN_RESCUER_ROLE` from the Monad Executor.

The payload reverts if the GSM holds no WMON.

### Arbitrum

Create a GHO Allowance for the AFC to bridge the GHO held on the Collector to Ethereum via CCIP.

Asset: GHO `0x7dfF72693f6A4149b17e7C6314655f6A9F7c8B33`
Amount: 100k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

### Mantle

Create the following Allowances for the AFC to bridge the assets to Ethereum.

Asset: aManUSDT0 `0x7053bAD224F0C021839f6AC645BdaE5F8b585b69`
Amount: 570k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

Asset: aManWETH `0xeAC30Ed8609F564aE65C809C4bf42dB2fF426D2C`
Amount: 59
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

### Gnosis

Create the following Allowances for the AFC to bridge the assets to Ethereum. The AFC will process the bridge claims on Ethereum.

Asset: aGnoWXDAI `0xd0Dd6cEF72143E22cCED4867eb0d5F2328715533`
Amount: 305k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

Asset: aGnoUSDC `0xc6B7AcA6DE8a6044E0e32d0c841a89244A10D284`
Amount: 90k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

Asset: aGnoUSDCe `0xC0333cb85B59a788d8C7CAe5e1Fd6E229A3E5a65`
Amount: 41k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

### Sonic

Create an Allowance for the AFC to bridge the asset to Ethereum. The AFC will process the bridge claim on Ethereum.

Asset: aSonUSDC `0x578Ee1ca3a8E1b54554Da1Bf7C583506C4CD11c6`
Amount: 100k
Spender: AFC `0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Ethereum_November2026FundingUpdate_20261118.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Plasma_November2026FundingUpdate_20261118.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Monad_November2026FundingUpdate_20261118.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Arbitrum_November2026FundingUpdate_20261118.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Mantle_November2026FundingUpdate_20261118.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Gnosis_November2026FundingUpdate_20261118.sol), [AaveV3Sonic](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Sonic_November2026FundingUpdate_20261118.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Ethereum_November2026FundingUpdate_20261118.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Plasma_November2026FundingUpdate_20261118.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Monad_November2026FundingUpdate_20261118.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Arbitrum_November2026FundingUpdate_20261118.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Mantle_November2026FundingUpdate_20261118.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Gnosis_November2026FundingUpdate_20261118.t.sol), [AaveV3Sonic](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261118_Multi_November2026FundingUpdate/AaveV3Sonic_November2026FundingUpdate_20261118.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

---
title: "Onboard Native BTC as Collateral to Aave V4 via Babylon Trustless Bitcoin Vaults"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/arfc-onboard-native-btc-as-collateral-to-aave-v4-via-babylon-trustless-bitcoin-vaults/25845"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0x83f578d707966014cd4ef7c7972f4af89c14964970f3f7088c688c07a6d915c0"
---

## Simple Summary

This proposal activates the Babylon market on Aave V4 Ethereum, which lets users borrow against native BTC locked in Babylon Trustless Bitcoin Vaults. It connects the Babylon Spoke to the new Babylon Hub and to the Core Hub, connects four Tokenization Spokes on the Babylon Hub, opens a WBTC credit line for BTCVaultSwap, and sets the roles that govern these contracts.

## Motivation

Native BTC is the largest crypto asset, and today it can only be used on Aave through custodial or bridged wrappers. Babylon Trustless Bitcoin Vaults lock BTC on the Bitcoin network and represent it on Ethereum as vaultBTC, a transfer-restricted token whose supply equals the BTC locked. The Babylon Spoke accepts vaultBTC as its only collateral, so users can borrow stablecoins and WBTC against native BTC with no custodian, wrapper or bridge.

Vaults cannot be partially seized and BTC redemption settles on Bitcoin over several days. Liquidations therefore go through Babylon's AaveAdapter, and BTCVaultSwap can pay the liquidator immediately in WBTC drawn from the Core Hub, which the vault keepers registered with Babylon later repay when they buy the escrowed vault.

Babylon plans to launch as a private beta, with a permissioned set of depositors and a 20 BTC total cap. The caps below follow that launch size and are expected to grow with it.

## Specification

The Babylon Hub, the Babylon Spoke and the Tokenization Spokes were deployed and configured ahead of this proposal, then handed over to the Aave V4 AccessManager on Ethereum, with their ProxyAdmins owned by the V4 Security Council. The payload reverts unless that handover is complete. Their reserves, price feeds and interest rate curves are already set. No spoke is connected to a Hub before this proposal executes, except the Treasury Spoke as fee receiver of the Babylon Hub assets.

| Contract                         | Address                                                                                                                 |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Babylon Hub                      | [`0xAd0fd800cbaF41a4Ced1BEa3a4f90aA18CfBC49d`](https://etherscan.io/address/0xAd0fd800cbaF41a4Ced1BEa3a4f90aA18CfBC49d) |
| Babylon Spoke                    | [`0x093d0d3bD44054155bae8C445C6832c762063278`](https://etherscan.io/address/0x093d0d3bD44054155bae8C445C6832c762063278) |
| Babylon USDT Tokenization Spoke  | [`0x6fE08B5AC181bbd67FE39039320B3eFCE786ec01`](https://etherscan.io/address/0x6fE08B5AC181bbd67FE39039320B3eFCE786ec01) |
| Babylon USDC Tokenization Spoke  | [`0xaD9433F9256849AD67E0D4C09F722bF63b72BEbd`](https://etherscan.io/address/0xaD9433F9256849AD67E0D4C09F722bF63b72BEbd) |
| Babylon GHO Tokenization Spoke   | [`0x23dBcde82Aac61Ebb36D36687F48BD57dA6D2F8b`](https://etherscan.io/address/0x23dBcde82Aac61Ebb36D36687F48BD57dA6D2F8b) |
| Babylon WBTC Tokenization Spoke  | [`0xb9C2d84578bD1a6548781d7793342E390E9B6eE7`](https://etherscan.io/address/0xb9C2d84578bD1a6548781d7793342E390E9B6eE7) |
| vaultBTC (Native BTC Collateral) | [`0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341`](https://etherscan.io/address/0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341) |
| AaveAdapter (Babylon)            | [`0xadca531564f3B26d0aAF48a044d741fD6cD571Ea`](https://etherscan.io/address/0xadca531564f3B26d0aAF48a044d741fD6cD571Ea) |
| BTCVaultSwap (Babylon)           | [`0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9`](https://etherscan.io/address/0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9) |
| BTCVaultSwap 2-of-3 Safe         | [`0x828AA986e31D60Eb07EFC1543FF9297835f4A9f7`](https://etherscan.io/address/0x828AA986e31D60Eb07EFC1543FF9297835f4A9f7) |

### Spoke Parameters

These are already configured on the Babylon Spoke and are not changed by this proposal.

| Chain    | Hub         | Spoke         | Reserve               | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee |
| -------- | ----------- | ------------- | --------------------- | ----------------- | --------------------- | ---------- | --------------- | --------------- |
| Ethereum | Babylon Hub | Babylon Spoke | Native BTC Collateral | 78%               | 5.55%                 | FALSE      | 0               | 0%              |
| Ethereum | Babylon Hub | Babylon Spoke | USDT                  | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Babylon Hub | Babylon Spoke | USDC                  | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Babylon Hub | Babylon Spoke | GHO                   | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Babylon Hub | Babylon Spoke | WBTC                  | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Core Hub    | Babylon Spoke | USDT                  | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Core Hub    | Babylon Spoke | USDC                  | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Core Hub    | Babylon Spoke | GHO                   | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Core Hub    | Babylon Spoke | USDG                  | 0%                | -                     | TRUE       | 0               | -               |
| Ethereum | Core Hub    | Babylon Spoke | RLUSD                 | 0%                | -                     | TRUE       | 0               | -               |

The Spoke's liquidation fee on Native BTC Collateral is zero because a vault cannot be partially seized. Babylon's AaveAdapter charges 10% of the liquidator's bonus instead. It is paid to Babylon's fee recipient, and its split with the Aave DAO follows the revenue-sharing agreement.

The dynamic liquidation bonus uses a liquidation bonus factor of 90% and a health factor for max bonus of 0.90.

### Add and Draw Caps

Set by this proposal. Every spoke is added as active, with a risk premium threshold of 0.

| Chain    | Hub         | Spoke                           | Reserve               | Add Cap   | Draw Cap |
| -------- | ----------- | ------------------------------- | --------------------- | --------- | -------- |
| Ethereum | Babylon Hub | Babylon Spoke                   | Native BTC Collateral | 20        | 0        |
| Ethereum | Babylon Hub | Babylon Spoke                   | USDT                  | 5,000,000 | 250,000  |
| Ethereum | Babylon Hub | Babylon Spoke                   | USDC                  | 5,000,000 | 250,000  |
| Ethereum | Babylon Hub | Babylon Spoke                   | GHO                   | 1,000,000 | 100,000  |
| Ethereum | Babylon Hub | Babylon Spoke                   | WBTC                  | 100       | 20       |
| Ethereum | Babylon Hub | Babylon USDT Tokenization Spoke | USDT                  | 1,000,000 | 0        |
| Ethereum | Babylon Hub | Babylon USDC Tokenization Spoke | USDC                  | 1,000,000 | 0        |
| Ethereum | Babylon Hub | Babylon GHO Tokenization Spoke  | GHO                   | 1,000,000 | 0        |
| Ethereum | Babylon Hub | Babylon WBTC Tokenization Spoke | WBTC                  | 10        | 0        |

### Credit Lines

Set by this proposal. Credit lines are draw-only.

| Chain    | Origin Hub | Target Spoke  | Reserve | Add Cap | Draw Cap |
| -------- | ---------- | ------------- | ------- | ------- | -------- |
| Ethereum | Core Hub   | Babylon Spoke | USDT    | 0       | 500,000  |
| Ethereum | Core Hub   | Babylon Spoke | USDC    | 0       | 500,000  |
| Ethereum | Core Hub   | Babylon Spoke | USDG    | 0       | 250,000  |
| Ethereum | Core Hub   | Babylon Spoke | GHO     | 0       | 100,000  |
| Ethereum | Core Hub   | Babylon Spoke | RLUSD   | 0       | 100,000  |
| Ethereum | Core Hub   | BTCVaultSwap  | WBTC    | 0       | 20       |

### Interest Rate Curves

Already configured on the Babylon Hub and not changed by this proposal.

| Chain    | Hub         | Asset | Base  | Slope 1 | Slope 2 | Uoptimal | Liquidity Fee |
| -------- | ----------- | ----- | ----- | ------- | ------- | -------- | ------------- |
| Ethereum | Babylon Hub | USDT  | 0%    | 4.50%   | 20%     | 90%      | 10%           |
| Ethereum | Babylon Hub | USDC  | 0%    | 4.50%   | 20%     | 90%      | 10%           |
| Ethereum | Babylon Hub | GHO   | 0%    | 4.50%   | 20%     | 90%      | 10%           |
| Ethereum | Babylon Hub | WBTC  | 0.25% | 4%      | 60%     | 80%      | 20%           |

### Roles

The proposal maps the restricted functions of the Babylon Hub and the Babylon Spoke to the same roles as every other Aave V4 Hub and Spoke on Ethereum, so the HubConfigurator, the SpokeConfigurator and the Risk Steward govern them as they govern the rest of the instance.

It also creates two roles for BTCVaultSwap on the Aave V4 AccessManager:

| Role | Label                          | Functions                                   | Members                                                                                         | Execution delay |
| ---- | ------------------------------ | ------------------------------------------- | ----------------------------------------------------------------------------------------------- | --------------- |
| 2001 | `BTC_VAULT_SWAP_FEE_ROLE`      | `setSwapFeeBps`                             | The Aave Labs, Babylon and LlamaRisk 2-of-3 Safe                                                | 5 days          |
| 2002 | `BTC_VAULT_SWAP_GUARDIAN_ROLE` | `pause`, `unpause`, `freeze` and `unfreeze` | The 2-of-3 Safe, the V4 Security Council, the V4 Security Council executor and Executor Level 1 | None            |

Role 2002 is the guardian of role 2001, so any of its members can cancel a scheduled fee change during the 5 days. Both roles are administered through the AccessManager by its admins, Executor Level 1 and the V4 Security Council, which can change their members.

### Price feed Recommendation

Native BTC Collateral is priced with the [Chainlink BTC/USD SVR feed](https://etherscan.io/address/0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A). The other reserves reuse the price sources already in use on Aave V4 Ethereum. All are already configured.

## References

- Implementation: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119.sol)
- Tests: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x83f578d707966014cd4ef7c7972f4af89c14964970f3f7088c688c07a6d915c0)
- [Discussion](https://governance.aave.com/t/arfc-onboard-native-btc-as-collateral-to-aave-v4-via-babylon-trustless-bitcoin-vaults/25845)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

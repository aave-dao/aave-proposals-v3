---
title: "Add X Layer Loop Tool & Margin Trading to FlashBorrowers"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-add-x-layer-loop-tool-margin-trading-to-flashborrowers/25551"
---

## Simple Summary

This AIP adds the X Layer Loop Tool contract and the X Layer Margin Trading contract to the Aave V3 X Layer FlashBorrowers whitelist, allowing them to access flash liquidity without incurring the Aave Flashloan Fee.

## Motivation

X Layer has developed a Loop Tool to simplify position management and looping activity on the Aave V3 X Layer instance. The tool will be integrated into OKX Wallet as a user facing product, allowing users to create leveraged positions on Aave without manually performing multiple supply, borrow and re-supply transactions.

X Layer has also requested that a separate contract supporting its margin trading product be added to the FlashBorrowers whitelist. This contract differs from the Loop Tool contract and supports retail margin trading activity on X Layer through OKX Wallet.

Certain transactions performed through the Loop Tool and margin trading product rely on Aave flash liquidity to execute the required position changes. Whitelisting the contracts as FlashBorrowers removes the Flashloan Fee from these transactions, reducing execution costs for users and encouraging greater usage of Aave V3 on X Layer.

The X Layer team has confirmed that the whitelisted contracts will not be used by OKX's / X Layer's own liquidation bots; they are intended solely to support user facing looping and position management activity. This proposal provides a Flashloan Fee waiver only to the two specified contracts and does not change any reserve or risk parameters of the Aave V3 X Layer instance.

## Specification

The payload calls `addFlashBorrower` on the Aave V3 X Layer `ACL_MANAGER` for the following contracts:

| Contract               | Address                                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| X Layer Loop Tool      | [0x714A871d3B471FF7Ee6A1896B16c5f55884fd910](https://www.oklink.com/x-layer/address/0x714A871d3B471FF7Ee6A1896B16c5f55884fd910) |
| X Layer Margin Trading | [0x18a6704775570afA8dB0D3FC0242515D90d120C0](https://www.oklink.com/x-layer/address/0x18a6704775570afA8dB0D3FC0242515D90d120C0) |

Once whitelisted, the contracts are exempt from Flashloan Fees on the Aave V3 X Layer instance.

## References

- Implementation: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/6968563e6326a7961b9724d2186cf020f95554da/src/20260821_AaveV3XLayer_WhitelistXLayerFlashBorrower/AaveV3XLayer_WhitelistXLayerFlashBorrower_20260821.sol)
- Tests: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/6968563e6326a7961b9724d2186cf020f95554da/src/20260821_AaveV3XLayer_WhitelistXLayerFlashBorrower/AaveV3XLayer_WhitelistXLayerFlashBorrower_20260821.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-add-x-layer-loop-tool-margin-trading-to-flashborrowers/25551)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

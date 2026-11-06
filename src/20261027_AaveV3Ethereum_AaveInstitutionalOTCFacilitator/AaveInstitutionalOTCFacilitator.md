---
title: "Aave Institutional GHO Facilitator"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/arfc-aave-institutional/25692"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0x194bd11500117aa7e0940bd0886a421a7658888af2cd04d82e07848afb8e3b79"
---

## Simple Summary

This AIP registers a new GHO facilitator for Aave Institutional on Ethereum with an initial bucket capacity of 25M GHO, places it under the GHO Bucket Steward, and grants the GHO Stewards the right to mint and burn GHO through it.

## Motivation

Aave Institutional is the DAO's offchain over-collateralised lending business. It lends USDC and USDT to institutional borrowers against BTC and ETH held at qualified custodians, at a typical 60% to 75% loan-to-value. Borrowers pay 6.0% to 8.0% APR against a funding cost of approximately 4.5%, and the full net interest margin of 1.50% to 3.50% accrues to the DAO.

The ARFC approved two funding sources running in parallel: a new GHO facilitator with an initial bucket capacity of 25M GHO managed by the GHO Stewards, and DAO balance-sheet assets pledged as collateral to borrow up to $25M of USDC or USDT. Every funding authorisation requires approval from the GHO Stewards, a 2-of-3 multisig between Aave Labs, TokenLogic and LlamaRisk, and every conversion between GHO and the lending currency is routed and executed jointly with TokenLogic.

## Specification

### GHO facilitator

The facilitator is a new, immutable instance of `GhoDirectFacilitator` from aave-dao/gho-origin. TokenLogic deployed it with the Governance V3 Level 1 executor as admin.

| Parameter                                        | Value                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| Network                                          | Ethereum                                                                                                              |
| Facilitator                                      | [0x647bf6b636ED76cE44d33eebF9C86d96Dfd004E9](https://etherscan.io/address/0x647bf6b636ED76cE44d33eebF9C86d96Dfd004E9) |
| Label                                            | Aave Institutional - OTC Facilitator                                                                                  |
| Initial bucket capacity                          | 25,000,000 GHO                                                                                                        |
| GHO Stewards Safe (`MINTER_ROLE`, `BURNER_ROLE`) | [0x8513e6F37dBc52De87b166980Fa3F50639694B60](https://etherscan.io/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60) |
| GHO Bucket Steward                               | [0x46Aa1063e5265b43663E81329333B47c517A5409](https://etherscan.io/address/0x46Aa1063e5265b43663E81329333B47c517A5409) |

1. `GhoToken.addFacilitator(facilitator, "Aave Institutional - OTC Facilitator", 25_000_000e18)`.
2. `GhoBucketSteward.setControlledFacilitator([facilitator], true)`.
3. `facilitator.grantRole(MINTER_ROLE, GHO Stewards Safe)`.
4. `facilitator.grantRole(BURNER_ROLE, GHO Stewards Safe)`.

The executor keeps `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `BURNER_ROLE` on the facilitator and can revoke the GHO Stewards' roles.

### Bucket capacity

The GHO Stewards can raise the bucket capacity through the GHO Bucket Steward, by at most 100% of the current capacity per update and no more than once every 24 hours. The GHO Bucket Steward cannot lower capacity, so a reduction, including to zero, requires a governance proposal. Removing the facilitator requires a governance proposal and a bucket level of zero, so removal waits until the GHO issued against outstanding loans has been returned and burned.

### Mint and burn

GHO is minted on demand when a loan is funded, with nothing minted upfront: the GHO Stewards mint to a recipient Safe held 2-of-3 by Aave Labs, LlamaRisk and TokenLogic, whose address will be published before the first mint. At repayment, the recipient Safe returns the GHO to the facilitator and the GHO Stewards burn it, reducing the bucket level. The facilitator has no fee, pause or rescue functions.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261027_AaveV3Ethereum_AaveInstitutionalOTCFacilitator/AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261027_AaveV3Ethereum_AaveInstitutionalOTCFacilitator/AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x194bd11500117aa7e0940bd0886a421a7658888af2cd04d82e07848afb8e3b79)
- [Discussion](https://governance.aave.com/t/arfc-aave-institutional/25692)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

---
title: "[AIP] Onboard PAXG to Aave V4 Global Dollar Hub"
author: "@AaveLabs"
date: "2026-09-04"
discussions: "https://governance.aave.com/t/arfc-onboard-paxg-to-the-global-dollar-hub-in-aave-v4-ethereum/25340"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0x65be5cb5922bc73d14ba16b13d4e7ee5eaae2c6d9518c27b7ab9721fd2f637b1"
---

## Simple Summary

This proposal onboards Pax Gold (PAXG) to the Aave V4 Global Dollar Hub on Ethereum. It deploys and configures the PAXG Gold Spoke, where PAXG is collateral only and USDG is borrowable, and enables native USDG as a borrowable reserve on the Pendle Spoke with a 4,000,000 USDG Draw Cap.

## Motivation

PAXG is an ERC-20 token issued by Paxos Trust Company. Each unit represents one fine troy ounce of a London Good Delivery gold bar held in professional vaults. Redemption and custody are administered by the regulated issuer, and holdings are subject to periodic third party attestations.

Onboarding PAXG to the Global Dollar Hub:

- Introduces an asset backed by gold to the Aave V4 Ethereum instance, broadening the range of collateral and liquidity beyond dollar denominated exposures.
- Gives users access to a regulated representation of physical gold within the Aave ecosystem, supporting demand from institutional participants and DeFi protocols seeking commodity exposure.
- Complements the Global Dollar Hub's existing composition by adding an asset with limited correlation for diversified liquidity strategies.

## Specification

This proposal adds PAXG to the Aave V4 Global Dollar Hub on Ethereum, configures PAXG and USDG reserves on the PAXG Gold Spoke, and enables USDG on the Pendle Spoke.

**PAXG**: [`0x45804880De22913dAFE09f4980848ECE6EcbAf78`](https://etherscan.io/address/0x45804880De22913dAFE09f4980848ECE6EcbAf78)

The PAXG Gold Spoke is deployed at [`0xAD75cE6354f87F3135cE10621d385d8D1e2562C2`](https://etherscan.io/address/0xAD75cE6354f87F3135cE10621d385d8D1e2562C2#code). The payload wires this deployment to the Ethereum AccessManager and configures it with the PAXG and USDG reserves below.

**Spoke configuration**

| Hub               | Spoke           | Reserve | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee | riskPremiumThreshold | receiveShares |
| ----------------- | --------------- | ------- | ----------------: | --------------------: | ---------- | --------------: | --------------: | -------------------: | ------------- |
| Global Dollar Hub | PAXG Gold Spoke | PAXG    |            75.00% |                 6.50% | FALSE      |               0 |          10.00% |                    0 | TRUE          |
| Global Dollar Hub | PAXG Gold Spoke | USDG    |             0.00% |                     - | TRUE       |               - |               - |                    0 | TRUE          |
| Global Dollar Hub | Pendle Spoke    | USDG    |             0.00% |                     - | TRUE       |               - |               - |                    0 | TRUE          |

`riskPremiumThreshold` is set to 0 for all reserves, in line with other assets across V4, as risk premiums are not currently in use. `receiveShares` is enabled for all reserves. For required onchain fields, the dash values in the table resolve to zero.

**Dynamic liquidation configuration**

| Parameter               | Value |
| ----------------------- | ----: |
| targetHealthFactor      |  1.20 |
| healthFactorForMaxBonus |  0.90 |
| liquidationBonusFactor  |  0.80 |

As a noncrypto open market spoke, the PAXG Gold Spoke uses more conservative liquidation restoration parameters. Draw Caps are set conservatively to reflect the PAXG Gold Spoke's developing liquidity for borrowing.

**Caps**

| Hub               | Spoke           | Reserve |   Add Cap |  Draw Cap |
| ----------------- | --------------- | ------- | --------: | --------: |
| Global Dollar Hub | PAXG Gold Spoke | PAXG    |      2500 |         0 |
| Global Dollar Hub | PAXG Gold Spoke | USDG    | 5,000,000 | 9,500,000 |
| Global Dollar Hub | Pendle Spoke    | USDG    |         - | 4,000,000 |

PAXG is also registered with the Tokenization Spoke with an Add Cap of 0.

**Oracle configuration**

PAXG is listed against the Chainlink [XAU/USD price feed](https://etherscan.io/address/0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6), pricing the token at underlying gold spot with no CAPO growth ceiling wrapper. PAXG carries no monotonic exchange rate growth for a cap to bound, so a CAPO adapter is not recommended. The accepted risks are a sustained dislocation in the token price, priced at full gold spot, and the feed's weekend staleness. The liquidation parameters set when collateral is enabled in a future phase must absorb that envelope rather than assume a continuously updating reference.

## Disclaimer

This proposal was prepared by Aave Labs in its capacity as a contributor to the Aave ecosystem. Aave Labs has no financial relationship with Paxos Trust Company or any of its affiliates and has not received compensation from Paxos in connection with this proposal.

## References

- Implementation: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/042f37598ae862b054b632e518e37b432ef643ca/src/20260824_AaveV4Ethereum_OnboardPAXGGlobalDollarHub/AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824.sol)
- Tests: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/042f37598ae862b054b632e518e37b432ef643ca/src/20260824_AaveV4Ethereum_OnboardPAXGGlobalDollarHub/AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824.t.sol)
- [Discussion](https://governance.aave.com/t/arfc-onboard-paxg-to-the-global-dollar-hub-in-aave-v4-ethereum/25340)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x65be5cb5922bc73d14ba16b13d4e7ee5eaae2c6d9518c27b7ab9721fd2f637b1)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

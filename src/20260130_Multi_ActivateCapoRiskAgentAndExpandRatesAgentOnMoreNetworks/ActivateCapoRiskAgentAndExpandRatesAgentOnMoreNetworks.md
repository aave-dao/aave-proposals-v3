---
title: "Activate Capo Risk Agent and expand Rates Agent on more networks"
author: "BGD Labs (@bgdlabs)"
discussions: "https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d"
---

## Simple Summary

This proposal activates the new CAPO Risk Agent on Ethereum and expands the existing Slope2 Interest Rates Agent (live on Ethereum Core, Linea) to Avalanche, Arbitrum, and Base networks. Additionally, it aligns the Slope2 Interest Rates Agent constraints on Ethereum Core and Linea with the new networks.

## Motivation

Following the successful [migration of the AGRS (Risk Stewards) infrastructure to Risk Agents](https://vote.onaave.com/proposal/?proposalId=432), which activated the Slope2 Interest Rates Agent on Ethereum Core, Linea, it feels natural to expand the Rates Agent on more networks and introduce the new CAPO agent type.

Both initiatives have been suggested by the Risk Service providers on the forum—[Slope2 RatesAgent expansion](https://governance.aave.com/t/arfc-automation-of-the-slope2-parameter-via-risk-oracles/22919/9) and [new CapoAgent addition](https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601/7)—along with the latest assets, networks, and constraints for the agents.

### CAPO Agent (new)

The CAPO system provides critical price safeguards for yield-bearing assets by defining upper bounds on exchange rates. However, when CAPO parameters remain static for extended periods, the derived maximum ratio can become increasingly detached from real-world exchange rate dynamics, creating vulnerability to price manipulations. By activating the CAPO Risk Agent on Ethereum, parameters like `snapshotRatio` and `maxYearlyRatioGrowthPercent` can be dynamically calibrated through the Risk Oracle, maintaining tight and responsive protection for yield-bearing collateral assets without requiring manual governance intervention. More details can be found on the forum post [here](https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601).

### Slope2 Rates Agent (expansion on more networks)

Additionally, extending the Interest Rates Agent to Avalanche, Arbitrum, and Base networks allows for automated adjustment of the `variableRateSlope2` parameter on high-utilization assets, ensuring interest rates remain responsive to market conditions across these networks. As part of this expansion, the constraints on Ethereum Core and Linea are updated from 4% to 2% for stablecoins and 1.5% for WETH, aligning them with the new networks. More details can be found on the forum post [here](https://governance.aave.com/t/arfc-automation-of-the-slope2-parameter-via-risk-oracles/22919).

## Specification

The proposal activates the [AaveCapoAgent](https://github.com/bgd-labs/aave-risk-agents/blob/c09d73bc4080a7d14114957dc30cbdfe0b4cb326/src/contracts/agent/AaveCapoAgent.sol) and [AaveRatesAgent](https://github.com/bgd-labs/aave-risk-agents/blob/c09d73bc4080a7d14114957dc30cbdfe0b4cb326/src/contracts/agent/AaveRatesAgent.sol) with the following params using the [chaos-agents](https://github.com/ChaosLabsInc/chaos-agents) infra:

### CAPO Agent

| Network  | Assets                                                                                          | Parameter                   | Constraint                         |
| -------- | ----------------------------------------------------------------------------------------------- | --------------------------- | ---------------------------------- |
| Ethereum | wstETH, weETH, rsETH, osETH, ezETH, cbETH, rETH, tETH, ETHx, LBTC, eBTC, sUSDe, syrupUSDT, sDAI | snapshotRatio               | Max 3% relative change per 3 days  |
| Ethereum | wstETH, weETH, rsETH, osETH, ezETH, cbETH, rETH, tETH, ETHx, LBTC, eBTC, sUSDe, syrupUSDT, sDAI | maxYearlyRatioGrowthPercent | Max 10% relative change per 3 days |

### Rates Agent

| Network   | Assets     | Parameter          | Constraint                           |
| --------- | ---------- | ------------------ | ------------------------------------ |
| Avalanche | USDC, USDt | variableRateSlope2 | Max 2% absolute change per 8 hours   |
| Avalanche | WETH.e     | variableRateSlope2 | Max 1.5% absolute change per 8 hours |
| Arbitrum  | USDC, USDT | variableRateSlope2 | Max 2% absolute change per 8 hours   |
| Arbitrum  | WETH       | variableRateSlope2 | Max 1.5% absolute change per 8 hours |
| Base      | USDC       | variableRateSlope2 | Max 2% absolute change per 8 hours   |
| Base      | WETH       | variableRateSlope2 | Max 1.5% absolute change per 8 hours |

### Rates Agent Constraint Alignment (Ethereum Core & Linea)

To align the `variableRateSlope2` constraints on Ethereum Core and Linea with the new networks:

| Network       | Assets           | Parameter          | New Constraint                       | Previous Constraint                |
| ------------- | ---------------- | ------------------ | ------------------------------------ | ---------------------------------- |
| Ethereum Core | USDC, USDT, USDe | variableRateSlope2 | Max 2% absolute change per 8 hours   | Max 4% absolute change per 8 hours |
| Ethereum Core | WETH             | variableRateSlope2 | Max 1.5% absolute change per 8 hours | Max 4% absolute change per 8 hours |
| Linea         | USDC, USDT       | variableRateSlope2 | Max 2% absolute change per 8 hours   | Max 4% absolute change per 8 hours |
| Linea         | WETH             | variableRateSlope2 | Max 1.5% absolute change per 8 hours | Max 4% absolute change per 8 hours |

The payload does the following actions:

- Register new agents on the AgentHub contract by calling `registerAgent()`
- Configure constrained ranges on the RangeValidationModule to strictly bound the risk param update from the Chaos Risk Oracle. For Ethereum Core and Linea instances we update the constraints to align with the new networks (2% for stablecoins, 1.5% for WETH).
- Give `RISK_ADMIN` role to the AgentContract which will be called by the Chaos Agent system to inject updates onto the Aave protocol.
- Register new Chainlink automation on the AgentHub Automation wrapper contract for the agents.
- Reimburse BGD Labs with 108 LINK by withdrawing aLINK from the Collector on Ethereum. BGD Labs previously funded Chainlink automation on Base out of pocket, as the Collector did not hold LINK on that network. The reimbursement also covers costs related to governance automation actions.

**Please note: On Ethereum, the following price feeds are shared across both Core and Prime instances: wstETH, rsETH, ezETH, tETH, sUSDe so changes on the capo feed params will be applied to both instances. Since the CAPO feeds use the ACL Manager of both instances, we give the `RISK_ADMIN` role to the agent contract from both Core and Prime instances.**

## References

- Implementation: [AaveV3EthereumPart1](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol), [AaveV3EthereumPart2](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol), [AaveV3Avalanche](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol), [AaveV3Arbitrum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol), [AaveV3Base](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol), [AaveV3Linea](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Linea_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol)
- Tests: [AaveV3EthereumPart1](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol), [AaveV3EthereumPart2](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol), [AaveV3Avalanche](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol), [AaveV3Arbitrum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol), [AaveV3Base](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol), [AaveV3Linea](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3Linea_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol)
- [Snapshot](https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d)
- [Discussion](https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601)
- Github: [Chaos Agents](https://github.com/ChaosLabsInc/chaos-agents), [Aave Risk Agents](https://github.com/bgd-labs/aave-risk-agents)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

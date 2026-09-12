// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4Ethereum} from 'aave-address-book/AaveV4Ethereum.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {AaveV4ConfiguratorRoles} from './AaveV4ConfiguratorRoles.sol';

/**
 * @title AaveV4RiskStewardsActivation
 * @author Aave Labs
 * - Snapshot: TODO
 * - Discussion: https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510
 */
contract AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807 is IProposalGenericExecutor {
  // https://etherscan.io/address/0x6f48d9Cdb8EE6E17c96B2d8Aec128af426A295c1
  address public constant RISK_STEWARD = 0x6f48d9Cdb8EE6E17c96B2d8Aec128af426A295c1;

  function execute() external override {
    AaveV4ConfiguratorRoles.breakDownDomainAdminRoles(
      AaveV4Ethereum.ACCESS_MANAGER,
      AaveV4Ethereum.HUB_CONFIGURATOR,
      AaveV4Ethereum.SPOKE_CONFIGURATOR
    );
    _grantRoles();
    IRiskStewardV4(RISK_STEWARD).setConfig(_riskStewardConfig());
  }

  /// @dev The steward only needs risk management to run its own entrypoints; emergency is granted
  /// alongside it so it can also de-risk without a new proposal.
  function _grantRoles() internal {
    AaveV4Ethereum.ACCESS_MANAGER.grantRole({
      roleId: AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE,
      account: RISK_STEWARD,
      executionDelay: 0
    });
    AaveV4Ethereum.ACCESS_MANAGER.grantRole({
      roleId: AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_EMERGENCY_ROLE,
      account: RISK_STEWARD,
      executionDelay: 0
    });
    AaveV4Ethereum.ACCESS_MANAGER.grantRole({
      roleId: AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE,
      account: RISK_STEWARD,
      executionDelay: 0
    });
    AaveV4Ethereum.ACCESS_MANAGER.grantRole({
      roleId: AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_EMERGENCY_ROLE,
      account: RISK_STEWARD,
      executionDelay: 0
    });
    // the CAPO adapters behind the v4 price sources gate setCapParameters on the v3 ACL manager
    AaveV3Ethereum.ACL_MANAGER.addRiskAdmin(RISK_STEWARD);
  }

  function _riskStewardConfig() internal pure returns (IRiskStewardV4.Config memory) {
    return
      IRiskStewardV4.Config({
        hub: IRiskStewardV4.HubConfig({
          configurator: AaveV4Ethereum.HUB_CONFIGURATOR,
          rate: IRiskStewardV4.HubRateConfig({
            optimalUsageRatio: IRiskStewardV4.RiskParamConfig({
              minDelay: 36 hours,
              maxPercentChange: 3_00,
              isChangeRelative: false
            }),
            baseDrawnRate: IRiskStewardV4.RiskParamConfig({
              minDelay: 36 hours,
              maxPercentChange: 3_00,
              isChangeRelative: false
            }),
            rateGrowthBeforeOptimal: IRiskStewardV4.RiskParamConfig({
              minDelay: 36 hours,
              maxPercentChange: 3_00,
              isChangeRelative: false
            }),
            rateGrowthAfterOptimal: IRiskStewardV4.RiskParamConfig({
              minDelay: 36 hours,
              maxPercentChange: 20_00,
              isChangeRelative: false
            })
          }),
          cap: IRiskStewardV4.HubCapConfig({
            addCap: IRiskStewardV4.RiskParamConfig({
              minDelay: 36 hours,
              maxPercentChange: 100_00,
              isChangeRelative: true
            }),
            drawCap: IRiskStewardV4.RiskParamConfig({
              minDelay: 36 hours,
              maxPercentChange: 100_00,
              isChangeRelative: true
            })
          })
        }),
        spoke: IRiskStewardV4.SpokeConfig({
          configurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
          collateralRisk: IRiskStewardV4.RiskParamConfig({
            minDelay: 36 hours,
            maxPercentChange: 300_00,
            isChangeRelative: false
          }),
          dynamicUpdate: IRiskStewardV4.SpokeDynamicConfig({
            collateralFactor: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 50,
              isChangeRelative: false
            }),
            maxLiquidationBonus: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 50,
              isChangeRelative: false
            })
          }),
          dynamicAdd: IRiskStewardV4.SpokeDynamicConfig({
            collateralFactor: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 5_00,
              isChangeRelative: false
            }),
            maxLiquidationBonus: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 50,
              isChangeRelative: false
            })
          }),
          liquidation: IRiskStewardV4.SpokeLiquidationConfig({
            targetHealthFactor: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 5_00,
              isChangeRelative: true
            }),
            healthFactorForMaxBonus: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 5_00,
              isChangeRelative: true
            }),
            liquidationBonusFactor: IRiskStewardV4.RiskParamConfig({
              minDelay: 72 hours,
              maxPercentChange: 5_00,
              isChangeRelative: false
            })
          })
        }),
        oracle: IRiskStewardV4.OracleConfig({
          priceCapLst: IRiskStewardV4.RiskParamConfig({
            minDelay: 72 hours,
            maxPercentChange: 5_00,
            isChangeRelative: true
          }),
          priceCapStable: IRiskStewardV4.RiskParamConfig({
            minDelay: 72 hours,
            maxPercentChange: 50,
            isChangeRelative: true
          }),
          discountRatePendle: IRiskStewardV4.RiskParamConfig({
            minDelay: 48 hours,
            maxPercentChange: 0.025e18,
            isChangeRelative: false
          })
        })
      });
  }
}

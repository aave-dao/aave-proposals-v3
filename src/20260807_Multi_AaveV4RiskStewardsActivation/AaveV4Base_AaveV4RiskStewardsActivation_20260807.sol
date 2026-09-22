// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';
import {AaveV4Base} from 'aave-address-book/AaveV4Base.sol';
import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';

/**
 * @title AaveV4RiskStewardsActivation
 * @author Aave Labs
 * - Snapshot: TODO
 * - Discussion: https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510
 */
contract AaveV4Base_AaveV4RiskStewardsActivation_20260807 is IProposalGenericExecutor {
  function execute() external override {
    AaveV4Base.ACCESS_MANAGER.grantRole({
      roleId: Roles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      account: AaveV4Base.RISK_STEWARD,
      executionDelay: 0
    });
    AaveV4Base.ACCESS_MANAGER.grantRole({
      roleId: Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      account: AaveV4Base.RISK_STEWARD,
      executionDelay: 0
    });
    // the CAPO adapters behind the v4 price sources gate setCapParameters on the v3 ACL manager
    AaveV3Base.ACL_MANAGER.addRiskAdmin(AaveV4Base.RISK_STEWARD);

    IRiskStewardV4(AaveV4Base.RISK_STEWARD).setConfig(_riskStewardConfig());
  }

  function _riskStewardConfig() internal pure returns (IRiskStewardV4.Config memory) {
    return
      IRiskStewardV4.Config({
        hub: IRiskStewardV4.HubConfig({
          configurator: AaveV4Base.HUB_CONFIGURATOR,
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
          configurator: AaveV4Base.SPOKE_CONFIGURATOR,
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

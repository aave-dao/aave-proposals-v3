// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHubConfigurator, ISpokeConfigurator} from 'aave-address-book/AaveV4.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';

/**
 * @title RiskStewardV4Config
 * @author Aave Labs
 * @notice Default bounds and cooldowns config for the Aave V4 Risk Steward, identical on
 *         every network it is activated on.
 */
library RiskStewardV4Config {
  function defaultConfig(
    IHubConfigurator hubConfigurator,
    ISpokeConfigurator spokeConfigurator
  ) internal pure returns (IRiskStewardV4.Config memory) {
    return
      IRiskStewardV4.Config({
        hub: IRiskStewardV4.HubConfig({
          configurator: hubConfigurator,
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
          configurator: spokeConfigurator,
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

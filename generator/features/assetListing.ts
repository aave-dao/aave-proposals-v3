import {CodeArtifact, FEATURE, FeatureModule, PoolIdentifier} from '../types';
import {fetchBorrowUpdate} from './borrowsUpdates';
import {fetchRateStrategyParamsV3} from './rateUpdates';
import {fetchCollateralUpdate} from './collateralsUpdates';
import {fetchCapsUpdate} from './capsUpdates';
import {Listing, ListingWithCustomImpl, TokenImplementations} from './types';
import {CHAIN_TO_CHAIN_ID, getPoolChain, getExplorerLink} from '../common';
import {getContract, isAddress} from 'viem';
import {confirm} from '@inquirer/prompts';
import {testExecuteProposal} from '../utils/constants';
import {addressPrompt, translateJsAddressToSol} from '../prompts/addressPrompt';
import {stringPrompt} from '../prompts/stringPrompt';
import {translateJsBoolToSol} from '../prompts/boolPrompt';
import {transformNumberToPercent, translateJsPercentToSol} from '../prompts/percentPrompt';
import {transformNumberToHumanReadable, translateJsNumberToSol} from '../prompts/numberPrompt';
import {getClient, IERC20Metadata_ABI} from '@bgd-labs/toolbox';

async function fetchListing(pool: PoolIdentifier): Promise<Listing> {
  const asset = await addressPrompt({
    message: 'Enter the address of the asset you want to list',
    required: true,
  });

  const chain = getPoolChain(pool);
  const erc20 = getContract({
    abi: IERC20Metadata_ABI,
    client: getClient(CHAIN_TO_CHAIN_ID[chain], {}),
    address: asset,
  });
  let symbol = '';
  try {
    symbol = await erc20.read.symbol();
  } catch (e) {
    console.log('could not fetch the symbol - this is likely an error');
    console.log(e);
  }
  const decimals = await erc20.read.decimals();

  return {
    assetSymbol: await stringPrompt({
      message: 'Enter the asset symbol',
      required: true,
      defaultValue: symbol,
    }),
    decimals,
    priceFeed: await addressPrompt({message: 'PriceFeed address', required: true}),
    ...(await fetchCollateralUpdate(pool, true)),
    ...(await fetchBorrowUpdate(true)),
    ...(await fetchCapsUpdate(true)),
    rateStrategyParams: await fetchRateStrategyParamsV3(true),
    asset,
    admin: await addressPrompt({message: 'Emission admin address (optional)', required: false}),
  };
}

async function fetchCustomImpl(): Promise<TokenImplementations> {
  return {
    aToken: await addressPrompt({message: 'aToken implementation', required: true}),
    vToken: await addressPrompt({message: 'vToken implementation', required: true}),
    sToken: await addressPrompt({message: 'sToken implementation', required: true}),
  };
}

function generateAssetListingSol(cfg: Listing) {
  return `asset: ${cfg.assetSymbol},
  assetSymbol: "${cfg.assetSymbol}",
  priceFeed: ${translateJsAddressToSol(cfg.priceFeed)},
  enabledToBorrow: ${translateJsBoolToSol(cfg.enabledToBorrow)},
  borrowableInIsolation: ${translateJsBoolToSol(cfg.borrowableInIsolation)},
  withSiloedBorrowing: ${translateJsBoolToSol(cfg.withSiloedBorrowing)},
  flashloanable: ${translateJsBoolToSol(cfg.flashloanable)},
  ltv: ${translateJsPercentToSol(cfg.ltv)},
  liqThreshold: ${translateJsPercentToSol(cfg.liqThreshold)},
  liqBonus: ${translateJsPercentToSol(cfg.liqBonus)},
  reserveFactor: ${translateJsPercentToSol(cfg.reserveFactor)},
  supplyCap: ${translateJsNumberToSol(cfg.supplyCap)},
  borrowCap (must be 1 for asset not borrowable): ${translateJsNumberToSol(cfg.borrowCap)},
  debtCeiling (must be 0 for asset out of isolation): ${translateJsNumberToSol(cfg.debtCeiling)},
  liqProtocolFee: ${translateJsPercentToSol(cfg.liqProtocolFee)},
  rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
     optimalUsageRatio: ${translateJsPercentToSol(cfg.rateStrategyParams.optimalUtilizationRate)},
     baseVariableBorrowRate: ${translateJsPercentToSol(
       cfg.rateStrategyParams.baseVariableBorrowRate,
     )},
     variableRateSlope1: ${translateJsPercentToSol(cfg.rateStrategyParams.variableRateSlope1)},
     variableRateSlope2: ${translateJsPercentToSol(cfg.rateStrategyParams.variableRateSlope2)}
  })`;
}

export const assetListing: FeatureModule<Listing[]> = {
  value: FEATURE.ASSET_LISTING,
  description: 'newListings (listing a new asset)',
  async cli({pool}) {
    const response: Listing[] = [];
    console.log(`Fetching information for Assets assets on ${pool}`);
    let more: boolean = true;
    while (more) {
      response.push(await fetchListing(pool));
      more = await confirm({message: 'Do you want to list another asset?', default: false});
    }
    return response;
  },
  build({pool, cfg}) {
    const response: CodeArtifact = {
      code: {
        constants: cfg.map((cfg) => {
          let listingConstant = `address public constant ${cfg.assetSymbol} = ${translateJsAddressToSol(cfg.asset)};\n`;
          listingConstant += `uint256 public constant ${cfg.assetSymbol}_SEED_AMOUNT = 1e${cfg.decimals};\n`;
          if (isAddress(cfg.admin)) {
            listingConstant += `address public constant ${cfg.assetSymbol}_LM_ADMIN = ${translateJsAddressToSol(cfg.admin)};\n`;
          }
          return listingConstant;
        }),
        execute: cfg.map((cfg) => {
          let listingExe = `_supplyAndConfigureLMAdmin(${cfg.assetSymbol},${cfg.assetSymbol}_SEED_AMOUNT,${isAddress(cfg.admin) ? `${cfg.assetSymbol}_LM_ADMIN` : 'address(0)'});\n`;
          return listingExe;
        }),
        fn: [
          `function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
          IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](${
            cfg.length
          });

          ${cfg
            .map(
              (cfg, ix) => `listings[${ix}] = IAaveV3ConfigEngine.Listing({
               ${generateAssetListingSol(cfg)}
             });`,
            )
            .join('\n')}

          return listings;
        }`,
          `function _supplyAndConfigureLMAdmin(address asset, uint256 seedAmount, address lmAdmin) internal {
          IERC20(asset).forceApprove(address(${pool}.POOL), seedAmount);
          ${pool}.POOL.supply(asset, seedAmount, address(${pool}.DUST_BIN), 0);

          if (lmAdmin != address(0)) {
            address aToken = ${pool}.POOL.getReserveAToken(asset);
            address vToken = ${pool}.POOL.getReserveVariableDebtToken(asset);
            IEmissionManager(${pool}.EMISSION_MANAGER).setEmissionAdmin(asset, lmAdmin);
            IEmissionManager(${pool}.EMISSION_MANAGER).setEmissionAdmin(aToken, lmAdmin);
            IEmissionManager(${pool}.EMISSION_MANAGER).setEmissionAdmin(vToken, lmAdmin);
	  }
        }`,
        ],
      },
      test: {
        fn: cfg.map((cfg) => {
          let listingTest = `function test_dustBinHas${cfg.assetSymbol}Funds() public {
            ${testExecuteProposal(pool)}
            address aTokenAddress = ${pool}.POOL.getReserveAToken(proposal.${cfg.assetSymbol}());
            assertGe(IERC20(aTokenAddress).balanceOf(address(${pool}.DUST_BIN)), 10 ** ${cfg.decimals});
          }\n`;
          if (isAddress(cfg.admin)) {
            listingTest += `\nfunction test_${cfg.assetSymbol}Admin() public {
	      ${testExecuteProposal(pool)}
              address a${cfg.assetSymbol} = ${pool}.POOL.getReserveAToken(proposal.${cfg.assetSymbol}());
	      assertEq(IEmissionManager(${pool}.EMISSION_MANAGER).getEmissionAdmin(proposal.${cfg.assetSymbol}()), proposal.${cfg.assetSymbol}_LM_ADMIN());
	      assertEq(IEmissionManager(${pool}.EMISSION_MANAGER).getEmissionAdmin(a${cfg.assetSymbol}), proposal.${cfg.assetSymbol}_LM_ADMIN());
	    }\n`;
          }
          return listingTest;
        }),
      },
      aip: {
        specification: cfg.map((cfg) => {
          let listingTemplate = `The table below illustrates the configured risk parameters for **${cfg.assetSymbol}**\n\n`;
          listingTemplate += `| Parameter | Value |\n`;
          listingTemplate += `| --- | --: |\n`;
          listingTemplate += `| Isolation Mode | ${cfg.debtCeiling !== '0'} |\n`;
          listingTemplate += `| Borrowable | ${cfg.enabledToBorrow} |\n`;
          listingTemplate += `| Collateral Enabled | ${!!cfg.liqThreshold} |\n`;
          listingTemplate += `| Supply Cap (${cfg.assetSymbol}) | ${transformNumberToHumanReadable(
            cfg.supplyCap,
          )} |\n`;
          listingTemplate += `| Borrow Cap (${cfg.assetSymbol}) | ${transformNumberToHumanReadable(
            cfg.borrowCap,
          )} |\n`;
          listingTemplate += `| Debt Ceiling | USD ${transformNumberToHumanReadable(
            cfg.debtCeiling,
          )} |\n`;
          listingTemplate += `| LTV | ${transformNumberToPercent(cfg.ltv)} |\n`;
          listingTemplate += `| LT | ${transformNumberToPercent(cfg.liqThreshold)} |\n`;
          listingTemplate += `| Liquidation Bonus	| ${transformNumberToPercent(cfg.liqBonus)} |\n`;
          listingTemplate += `| Liquidation Protocol Fee | ${transformNumberToPercent(
            cfg.liqProtocolFee,
          )} |\n`;
          listingTemplate += `| Reserve Factor | ${transformNumberToPercent(
            cfg.reserveFactor,
          )} |\n`;
          listingTemplate += `| Base Variable Borrow Rate	| ${transformNumberToPercent(
            cfg.rateStrategyParams.baseVariableBorrowRate,
          )} |\n`;
          listingTemplate += `| Variable Slope 1 | ${transformNumberToPercent(
            cfg.rateStrategyParams.variableRateSlope1,
          )} |\n`;
          listingTemplate += `| Variable Slope 2 | ${transformNumberToPercent(
            cfg.rateStrategyParams.variableRateSlope2,
          )} |\n`;
          listingTemplate += `| Uoptimal | ${transformNumberToPercent(
            cfg.rateStrategyParams.optimalUtilizationRate,
          )} |\n`;
          listingTemplate += `| Flashloanable	| ${cfg.flashloanable} |\n`;
          listingTemplate += `| Siloed Borrowing	| ${cfg.withSiloedBorrowing} |\n`;
          listingTemplate += `| Borrowable in Isolation | ${cfg.borrowableInIsolation} |\n`;
          listingTemplate += `| Oracle | ${cfg.priceFeed} |\n`;
          if (isAddress(cfg.admin)) {
            listingTemplate += `\nAdditionally [${cfg.admin}](${getExplorerLink(CHAIN_TO_CHAIN_ID[getPoolChain(pool)], cfg.admin)}) has been set as the emission admin for ${cfg.assetSymbol} and the corresponding aToken.\n`;
          }
          return listingTemplate;
        }),
      },
    };
    return response;
  },
};

export const assetListingCustom: FeatureModule<ListingWithCustomImpl[]> = {
  value: FEATURE.ASSET_LISTING_CUSTOM,
  description: 'newListingsCustom (listing a new asset, with custom implementations)',
  async cli({pool}) {
    const response: ListingWithCustomImpl[] = [];
    let more: boolean = true;
    while (more) {
      response.push({base: await fetchListing(pool), implementations: await fetchCustomImpl()});
      more = await confirm({message: 'Do you want to list another asset?', default: false});
    }
    return response;
  },
  build({pool, cfg}) {
    const response: CodeArtifact = {
      code: {
        constants: cfg.map(
          (cfg) =>
            `address public constant ${cfg.base.assetSymbol} = ${translateJsAddressToSol(
              cfg.base.asset,
            )};`,
        ),
        execute: cfg.map(
          (cfg) =>
            `IERC20(${cfg.base.assetSymbol}).forceApprove(address(${pool}.POOL), 10 ** ${cfg.base.decimals});
            ${pool}.POOL.supply(${cfg.base.assetSymbol}, 10 ** ${cfg.base.decimals}, ${pool}.DUST_BIN, 0);`,
        ),
        fn: [
          `function newListingsCustom() public pure override returns (IAaveV3ConfigEngine.ListingWithCustomImpl[] memory) {
          IAaveV3ConfigEngine.ListingWithCustomImpl[] memory listings = new IAaveV3ConfigEngine.ListingWithCustomImpl[](${
            cfg.length
          });

          ${cfg
            .map(
              (cfg, ix) => `listings[${ix}] = IAaveV3ConfigEngine.ListingWithCustomImpl(
                IAaveV3ConfigEngine.Listing({
                  ${generateAssetListingSol(cfg.base)},
                  IAaveV3ConfigEngine.TokenImplementations({
                    aToken: ${translateJsAddressToSol(cfg.implementations.aToken)},
                    vToken: ${translateJsAddressToSol(cfg.implementations.vToken)},
                    sToken: ${translateJsAddressToSol(cfg.implementations.sToken)}
                  })
                })
             );`,
            )
            .join('\n')}

          return listings;
        }`,
        ],
      },
      test: {
        fn: cfg.map(
          (cfg) => `function test_dustBinHas${cfg.base.assetSymbol}Funds() public {
            ${testExecuteProposal(pool)}
            address aTokenAddress = ${pool}.POOL.getReserveAToken(proposal.${cfg.base.assetSymbol}());
            assertGte(IERC20(aTokenAddress).balanceOf(${pool}.DUST_BIN), 10 ** ${cfg.base.decimals});
          }`,
        ),
      },
    };
    return response;
  },
};

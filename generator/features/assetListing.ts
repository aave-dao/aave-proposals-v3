import {CodeArtifact, FEATURE, FeatureModule, MarketIdentifier} from '../types';
import {fetchBorrowUpdate} from './borrowsUpdates';
import {fetchRateStrategyParamsV3} from './rateUpdates';
import {fetchCollateralUpdate} from './collateralsUpdates';
import {fetchCapsUpdate} from './capsUpdates';
import {Listing, ListingWithCustomImpl, TokenImplementations} from './types';
import {CHAIN_TO_CHAIN_ID, getMarketChain, getExplorerLink, toSolidityIdentifier} from '../common';
import {getContract, isAddress} from 'viem';
import {confirm} from '@inquirer/prompts';
import {testExecuteProposal} from '../utils/constants';
import {addressPrompt, translateJsAddressToSol} from '../prompts/addressPrompt';
import {stringPrompt} from '../prompts/stringPrompt';
import {translateJsBoolToSol} from '../prompts/boolPrompt';
import {transformNumberToPercent, translateJsPercentToSol} from '../prompts/percentPrompt';
import {transformNumberToHumanReadable, translateJsNumberToSol} from '../prompts/numberPrompt';
import {getClient, IERC20Metadata_ABI} from '@aave-dao/toolbox';

async function fetchListing(market: MarketIdentifier): Promise<Listing> {
  const asset = await addressPrompt({
    message: 'Enter the address of the asset you want to list',
    required: true,
  });

  const chain = getMarketChain(market);
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
    assetSymbol: toSolidityIdentifier(
      await stringPrompt({
        message: 'Enter the asset symbol',
        required: true,
        defaultValue: symbol,
      }),
    ),
    decimals,
    priceFeed: await addressPrompt({message: 'PriceFeed address', required: true}),
    ...(await fetchCollateralUpdate(market, true)),
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
  };
}

// Relax address fields because rendered Solidity may use variable names instead of literal addresses.
type RenderableListing = Omit<Listing, 'asset' | 'priceFeed'> & {
  asset: string;
  priceFeed: string;
};

function renderListingSol(cfg: RenderableListing) {
  return `asset: ${cfg.asset},
  assetSymbol: "${cfg.assetSymbol}",
  priceFeed: ${cfg.priceFeed},
  enabledToBorrow: ${translateJsBoolToSol(cfg.enabledToBorrow)},
  flashloanable: ${translateJsBoolToSol(cfg.flashloanable)},
  ltv: ${translateJsPercentToSol(cfg.ltv)},
  liqThreshold: ${translateJsPercentToSol(cfg.liqThreshold)},
  liqBonus: ${translateJsPercentToSol(cfg.liqBonus)},
  reserveFactor: ${translateJsPercentToSol(cfg.reserveFactor)},
  supplyCap: ${translateJsNumberToSol(cfg.supplyCap)},
  borrowCap: ${translateJsNumberToSol(cfg.borrowCap)},
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

function generateAssetListingSol(cfg: Listing) {
  return renderListingSol({
    ...cfg,
    asset: cfg.assetSymbol,
    priceFeed: `${cfg.assetSymbol}_PRICE_FEED`,
  });
}

function listingOverrides(cfgs: Listing[], fnName: string): string[] {
  return [
    `function ${fnName}() internal pure override returns (ExpectedListing[] memory listings) {
      listings = new ExpectedListing[](${cfgs.length});

      ${cfgs
        .map(
          (cfg, ix) => `listings[${ix}] = ExpectedListing({
                 listing: IAaveV3ConfigEngine.Listing({
                   ${renderListingSol({
                     ...cfg,
                     asset: translateJsAddressToSol(cfg.asset),
                     priceFeed: translateJsAddressToSol(cfg.priceFeed),
                   })}
                 }),
                 decimals: ${cfg.decimals}
               });`,
        )
        .join('\n')}
    }`,
  ];
}

export const assetListing: FeatureModule<Listing[]> = {
  value: FEATURE.ASSET_LISTING,
  description: 'newListings (listing a new asset)',
  async cli({market}) {
    const response: Listing[] = [];
    console.log(`Fetching information for Assets assets on ${market}`);
    let more: boolean = true;
    while (more) {
      response.push(await fetchListing(market));
      more = await confirm({message: 'Do you want to list another asset?', default: false});
    }
    return response;
  },
  build({market, cfg}) {
    const listingTests = cfg.map((cfg) => {
      let listingTest = `function test_dustBinHas${cfg.assetSymbol}Funds() public {
            ${testExecuteProposal(market)}
            address aTokenAddress = ${market}.POOL.getReserveAToken(proposal.${cfg.assetSymbol}());
            assertGe(IERC20(aTokenAddress).balanceOf(address(${market}.DUST_BIN)), ${cfg.seedAmount ? `proposal.${cfg.assetSymbol}_SEED_AMOUNT()` : `10 ** ${cfg.decimals}`});
          }\n`;
      if (isAddress(cfg.admin)) {
        listingTest += `\nfunction test_${cfg.assetSymbol}Admin() public {
	      ${testExecuteProposal(market)}
              address a${cfg.assetSymbol} = ${market}.POOL.getReserveAToken(proposal.${cfg.assetSymbol}());
	      assertEq(IEmissionManager(${market}.EMISSION_MANAGER).getEmissionAdmin(proposal.${cfg.assetSymbol}()), proposal.${cfg.assetSymbol}_LM_ADMIN());
	      assertEq(IEmissionManager(${market}.EMISSION_MANAGER).getEmissionAdmin(a${cfg.assetSymbol}), proposal.${cfg.assetSymbol}_LM_ADMIN());
	    }\n`;
      }
      return listingTest;
    });
    const response: CodeArtifact = {
      code: {
        constants: cfg.map((cfg) => {
          const chainId = CHAIN_TO_CHAIN_ID[getMarketChain(market)];
          let listingConstant = `// ${getExplorerLink(chainId, cfg.asset)}\n`;
          listingConstant += `address public constant ${cfg.assetSymbol} = ${translateJsAddressToSol(cfg.asset)};\n`;
          listingConstant += `uint256 public constant ${cfg.assetSymbol}_SEED_AMOUNT = ${cfg.seedAmount || `1e${cfg.decimals}`};\n`;
          if (isAddress(cfg.priceFeed)) {
            listingConstant += `// ${getExplorerLink(chainId, cfg.priceFeed)}\n`;
          }
          listingConstant += `address public constant ${cfg.assetSymbol}_PRICE_FEED = ${translateJsAddressToSol(cfg.priceFeed)};\n`;
          if (isAddress(cfg.admin)) {
            listingConstant += `// ${getExplorerLink(chainId, cfg.admin)}\n`;
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
          IERC20(asset).forceApprove(address(${market}.POOL), seedAmount);
          ${market}.POOL.supply(asset, seedAmount, address(${market}.DUST_BIN), 0);

          if (lmAdmin != address(0)) {
            address aToken = ${market}.POOL.getReserveAToken(asset);
            address vToken = ${market}.POOL.getReserveVariableDebtToken(asset);
            IEmissionManager(${market}.EMISSION_MANAGER).setEmissionAdmin(asset, lmAdmin);
            IEmissionManager(${market}.EMISSION_MANAGER).setEmissionAdmin(aToken, lmAdmin);
            IEmissionManager(${market}.EMISSION_MANAGER).setEmissionAdmin(vToken, lmAdmin);
	  }
        }`,
        ],
      },
      test: {
        fn: [...listingTests, ...listingOverrides(cfg, '_expectedListings')],
      },
      aip: {
        specification: cfg.map((cfg) => {
          let listingTemplate = `The table below illustrates the configured risk parameters for **${cfg.assetSymbol}**\n\n`;
          listingTemplate += `| Parameter | Value |\n`;
          listingTemplate += `| --- | --: |\n`;
          listingTemplate += `| Borrowable | ${cfg.enabledToBorrow} |\n`;
          listingTemplate += `| Collateral Enabled | ${!!cfg.liqThreshold} |\n`;
          listingTemplate += `| Supply Cap (${cfg.assetSymbol}) | ${transformNumberToHumanReadable(
            cfg.supplyCap,
          )} |\n`;
          listingTemplate += `| Borrow Cap (${cfg.assetSymbol}) | ${transformNumberToHumanReadable(
            cfg.borrowCap,
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
          listingTemplate += `| Oracle | ${cfg.priceFeed} |\n`;
          if (isAddress(cfg.admin)) {
            listingTemplate += `\nAdditionally [${cfg.admin}](${getExplorerLink(CHAIN_TO_CHAIN_ID[getMarketChain(market)], cfg.admin)}) has been set as the emission admin for ${cfg.assetSymbol} and the corresponding aToken.\n`;
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
  async cli({market}) {
    const response: ListingWithCustomImpl[] = [];
    let more: boolean = true;
    while (more) {
      response.push({base: await fetchListing(market), implementations: await fetchCustomImpl()});
      more = await confirm({message: 'Do you want to list another asset?', default: false});
    }
    return response;
  },
  build({market, cfg}) {
    const listingTests = cfg.map(
      (cfg) => `function test_dustBinHas${cfg.base.assetSymbol}Funds() public {
            ${testExecuteProposal(market)}
            address aTokenAddress = ${market}.POOL.getReserveAToken(proposal.${cfg.base.assetSymbol}());
            assertGe(IERC20(aTokenAddress).balanceOf(${market}.DUST_BIN), 10 ** ${cfg.base.decimals});
          }`,
    );
    const response: CodeArtifact = {
      code: {
        constants: cfg.map((cfg) => {
          const chainId = CHAIN_TO_CHAIN_ID[getMarketChain(market)];
          let listingConstant = `// ${getExplorerLink(chainId, cfg.base.asset)}\n`;
          listingConstant += `address public constant ${cfg.base.assetSymbol} = ${translateJsAddressToSol(cfg.base.asset)};\n`;
          if (isAddress(cfg.base.priceFeed)) {
            listingConstant += `// ${getExplorerLink(chainId, cfg.base.priceFeed)}\n`;
          }
          listingConstant += `address public constant ${cfg.base.assetSymbol}_PRICE_FEED = ${translateJsAddressToSol(cfg.base.priceFeed)};\n`;
          return listingConstant;
        }),
        execute: cfg.map(
          (cfg) =>
            `IERC20(${cfg.base.assetSymbol}).forceApprove(address(${market}.POOL), 10 ** ${cfg.base.decimals});
            ${market}.POOL.supply(${cfg.base.assetSymbol}, 10 ** ${cfg.base.decimals}, ${market}.DUST_BIN, 0);`,
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
                  ${generateAssetListingSol(cfg.base)}
                }),
                IAaveV3ConfigEngine.TokenImplementations({
                  aToken: ${translateJsAddressToSol(cfg.implementations.aToken)},
                  vToken: ${translateJsAddressToSol(cfg.implementations.vToken)}
                })
             );`,
            )
            .join('\n')}

          return listings;
        }`,
        ],
      },
      test: {
        fn: [
          ...listingTests,
          ...listingOverrides(
            cfg.map((cfg) => cfg.base),
            '_expectedCustomListings',
          ),
        ],
      },
    };
    return response;
  },
};

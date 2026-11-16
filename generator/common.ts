import * as addressBook from '@aave-dao/aave-address-book';
import {
  Options,
  MarketIdentifier,
  MarketIdentifierV3,
  V2_MARKETS,
  V3_MARKETS,
  V4_MARKETS,
  VOTING_NETWORK,
  VotingNetwork,
} from './types';
import {
  arbitrum,
  avalanche,
  mainnet,
  metis,
  optimism,
  polygon,
  base,
  bsc,
  gnosis,
  scroll,
  zkSync,
  linea,
  celo,
  sonic,
  soneium,
  ink,
  plasma,
  mantle,
  megaeth,
  xLayer,
  monad,
} from 'viem/chains';
import {Hex, getAddress} from 'viem';
import {getClient} from '@aave-dao/toolbox';

export const AVAILABLE_CHAINS = [
  'Ethereum',
  'Optimism',
  'Arbitrum',
  'Polygon',
  'Avalanche',
  'Fantom',
  'Harmony',
  'Metis',
  'Base',
  'BNB',
  'Gnosis',
  'Scroll',
  'ZkSync',
  'Linea',
  'Celo',
  'Sonic',
  'Soneium',
  'Ink',
  'Plasma',
  'Mantle',
  'MegaEth',
  'XLayer',
  'Monad',
] as const;

export function getAssets(market: MarketIdentifier): string[] {
  const assets = addressBook[market].ASSETS;
  return Object.keys(assets);
}

// map the complex type to a string as used in the sol libs
export function toEModeName(label: string) {
  return label
    .replace(/\s*\/\s*/g, '__') // a / b
    .replace(/[^\w\ ]/gi, ' ') //  replaces all non-alphanumeric with empty string
    .replace(/ +/gi, '_'); //  Convert spaces to dashes
}

export function getEModes(market: MarketIdentifierV3): {value: string; id: number}[] {
  return Object.keys(addressBook[market].E_MODES).map((key) => ({
    value: toEModeName(addressBook[market].E_MODES[key].label),
    id: key as unknown as number,
  }));
}

export function isV2Market(market: MarketIdentifier) {
  return V2_MARKETS.includes(market as any);
}

export function isV3Market(market: MarketIdentifier) {
  return V3_MARKETS.includes(market as any);
}

export function isV4Market(market: MarketIdentifier) {
  return V4_MARKETS.includes(market as any);
}

export function isWhitelabelMarket(market: MarketIdentifier) {
  return market.toLowerCase().includes('whitelabel');
}

export function getVersion(market: MarketIdentifier) {
  if (isV2Market(market)) return 'V2';
  if (isV3Market(market)) return 'V3';
  if (isV4Market(market)) return 'V4';
  throw new Error(`unknown market version for ${market}`);
}

export function getTestBase(market: MarketIdentifier): {v4: boolean; testBase: string} {
  if (isV2Market(market)) return {v4: false, testBase: 'ProtocolV2TestBase'};
  if (isV3Market(market)) return {v4: false, testBase: 'ProtocolV3TestBase'};
  if (isV4Market(market))
    return {v4: true, testBase: `ProtocolV4TestBase${getMarketChain(market)}`};
  throw new Error(`unknown market version for ${market}`);
}

export function getMarketChain(market: MarketIdentifier) {
  const chain = AVAILABLE_CHAINS.find((chain) => market.indexOf(chain) !== -1);
  if (!chain) throw new Error('cannot find chain for market');
  return chain;
}

export function getExplorerLink(chainId: number, address: Hex) {
  const client = getClient(chainId, {});
  let url = client.chain?.blockExplorers?.default.url;
  if (url && url.endsWith('/')) {
    url = url.slice(0, -1); // sanitize explorer url
  }
  return `${url}/address/${getAddress(address)}`;
}

export function getDate() {
  const date = new Date();
  const years = date.getFullYear();
  const months = date.getMonth() + 1; // it's js so months are 0 indexed
  const day = date.getDate();
  return `${years}${months <= 9 ? '0' : ''}${months}${day <= 9 ? '0' : ''}${day}`;
}

export function getVotingPortal(votingNetwork?: VOTING_NETWORK | VotingNetwork) {
  if (votingNetwork == VOTING_NETWORK.ETHEREUM) {
    return 'GovernanceV3Ethereum.VOTING_PORTAL_ETH_ETH';
  } else if (votingNetwork == VOTING_NETWORK.AVALANCHE) {
    return 'GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX';
  }
  return 'GovernanceV3Ethereum.VOTING_PORTAL_ETH_POL'; // default voting network is polygon
}

/**
 * Prefix with the date for proper sorting
 * @param {*} options
 * @returns
 */
export function generateFolderName(options: Options) {
  return `${options.date}_${options.markets.length === 1 ? options.markets[0] : 'Multi'}_${
    options.shortName
  }`;
}

/**
 * Suffix with the date as prefixing would generate invalid contract names
 * @param {*} options
 * @param {*} chain
 * @returns
 */
export function generateContractName(options: Options, market?: MarketIdentifier) {
  let name = market ? `${market}_` : '';
  name += `${options.shortName}`;
  name += `_${options.date}`;
  return name;
}

export function getChainAlias(chain) {
  return chain === 'Ethereum' ? 'mainnet' : chain.toLowerCase();
}

export function toSolidityIdentifier(symbol: string) {
  return symbol.replace(/[^a-zA-Z0-9_]/g, '_');
}

export function pascalCase(str: string) {
  return str
    .replace(/[\W]/g, ' ') // remove special chars as this is used for solc contract name
    .replace(/(\w)(\w*)/g, function (g0, g1, g2) {
      return g1.toUpperCase() + g2;
    })
    .replace(/ /g, '');
}

export const CHAIN_TO_CHAIN_ID = {
  Ethereum: mainnet.id,
  Polygon: polygon.id,
  Optimism: optimism.id,
  Arbitrum: arbitrum.id,
  Avalanche: avalanche.id,
  Metis: metis.id,
  Base: base.id,
  BNB: bsc.id,
  Gnosis: gnosis.id,
  Scroll: scroll.id,
  ZkSync: zkSync.id,
  Linea: linea.id,
  Celo: celo.id,
  Sonic: sonic.id,
  Soneium: soneium.id,
  Ink: ink.id,
  Plasma: plasma.id,
  Mantle: mantle.id,
  MegaEth: megaeth.id,
  XLayer: xLayer.id,
  Monad: monad.id,
};

export function flagAsRequired(message: string, required?: boolean) {
  return required ? `${message}*` : message;
}

/// Risk params record (schema.json). Risk values only, filled from the risk provider's post.
/// Percentages in bps, caps in whole tokens. A field left out of an update means keep current.
export type Bps = number;
export type V3Cap = number | 'unlimited';

export interface RecordAsset {
  symbol: string;
  address?: `0x${string}`;
}

/// `label` is the address-book eMode name, e.g. `xBTC__USDT_USDG_GHO_USDC`.
export type EModeRef = {id: number} | {label: string} | {ref: string};

export interface FromPreset {
  preset: 'v3NonBorrowable' | 'v3Default';
  fields: string[];
}

export interface V3Rates {
  optimal?: Bps;
  base?: Bps;
  slope1?: Bps;
  slope2?: Bps;
}

export interface V3Listing {
  asset: Required<RecordAsset>;
  /// Feed address, or the feed name when the address comes from ops.
  priceFeed: string;
  ltv: Bps;
  liqThreshold: Bps;
  liqBonus: Bps;
  liqProtocolFee: Bps;
  reserveFactor: Bps;
  supplyCap: V3Cap;
  borrowCap: V3Cap;
  borrowable: boolean;
  flashloanable: boolean;
  rates: Required<V3Rates>;
  fromPreset?: FromPreset;
}

export interface V3ReserveUpdate {
  asset: RecordAsset;
  ltv?: Bps;
  liqThreshold?: Bps;
  liqBonus?: Bps;
  liqProtocolFee?: Bps;
  reserveFactor?: Bps;
  supplyCap?: V3Cap;
  borrowCap?: V3Cap;
  borrowable?: boolean;
  flashloanable?: boolean;
  rates?: V3Rates;
  priceFeed?: string;
  frozen?: boolean;
}

export interface V3EModeCreate {
  ref: string;
  label: string;
  ltv: Bps;
  liqThreshold: Bps;
  liqBonus: Bps;
  isolated: boolean;
  collateral: RecordAsset[];
  borrowable: RecordAsset[];
}

export interface V3EModeUpdate {
  eMode: EModeRef;
  label?: string;
  ltv?: Bps;
  liqThreshold?: Bps;
  liqBonus?: Bps;
  isolated?: boolean;
}

export interface V3EModeAsset {
  asset: RecordAsset;
  eMode: EModeRef;
  collateral?: boolean;
  borrowable?: boolean;
  ltvZero?: boolean;
}

export interface V3Market {
  listings?: V3Listing[];
  reserveUpdates?: V3ReserveUpdate[];
  eModeCreates?: V3EModeCreate[];
  eModeUpdates?: V3EModeUpdate[];
  eModeAssets?: V3EModeAsset[];
}

export interface RiskParamsRecord {
  schemaVersion: '1.0';
  aip: string;
  version: number;
  updatedAt: string;
  provider: string;
  forumPost: string;
  notes?: string[];
  markets: Record<string, V3Market>;
}

/// Values that are not risk params and stay with Aave Labs: addresses, decimals, seed, LM admin.
/// Keyed by market, then by asset symbol.
export interface ListingOps {
  decimals: number;
  /// Needed when the record names the feed instead of giving its address.
  priceFeed?: `0x${string}`;
  admin?: `0x${string}` | '';
  /// Seed supplied to the dust bin, as a Solidity literal (e.g. `100e6`). Defaults to 1 token.
  seedAmount?: string;
}

export interface RecordOps {
  rootOptions: Record<string, unknown>;
  markets: Record<string, {listings?: Record<string, ListingOps>; cache: {blockNumber: number}}>;
}

/// Ops file (ops.schema.json): the values that are not risk params. Everything is optional;
/// what is missing is read onchain (block number, token decimals) or taken from the CLI flags.
export interface OpsFile {
  rootOptions?: {
    title?: string;
    author?: string;
    discussion?: string;
    snapshot?: string;
    votingNetwork?: 'POLYGON' | 'ETHEREUM' | 'AVALANCHE';
  };
  markets?: Record<
    string,
    {cache?: {blockNumber: number}; listings?: Record<string, Partial<ListingOps>>}
  >;
}

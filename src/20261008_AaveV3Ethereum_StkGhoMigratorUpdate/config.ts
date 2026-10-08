import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Ethereum'],
    title: 'Move stkGHO Claim Helper Role to Updated StkGhoMigrator',
    shortName: 'StkGhoMigratorUpdate',
    date: '20261008',
    author: 'Aave Labs',
    discussion: 'TODO',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26149767}}},
};

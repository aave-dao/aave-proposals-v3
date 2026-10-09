import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Ethereum'],
    title: 'Move stkGHO Claim Helper Role to Updated StkGhoMigrator',
    shortName: 'StkGhoMigratorUpdate',
    date: '20261008',
    author: 'Aave Labs',
    discussion: 'https://governance.aave.com/t/technical-maintenance-proposals/15274/138',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26149767}}},
};

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAaveV3ConfigEngine as IEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {AaveV3EthereumHorizon} from 'aave-address-book/AaveV3EthereumHorizon.sol';

library AaveV3EthereumHorizonCustom {
  function defaultRwaInterestRateInputData()
    internal
    pure
    returns (IEngine.InterestRateInputData memory)
  {
    return
      IEngine.InterestRateInputData({
        optimalUsageRatio: 99_00,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 0,
        variableRateSlope2: 0
      });
  }

  // from AaveV3EthereumHorizon address book
  address internal constant POOL = address(AaveV3EthereumHorizon.POOL);
  address internal constant DEFAULT_A_TOKEN_IMPL =
    address(AaveV3EthereumHorizon.DEFAULT_A_TOKEN_IMPL);
  address internal constant DEFAULT_VARIABLE_DEBT_TOKEN_IMPL =
    address(AaveV3EthereumHorizon.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL);
  address internal constant RWA_A_TOKEN_IMPL = AaveV3EthereumHorizon.RWA_A_TOKEN_IMPL;
  address internal constant CONFIG_ENGINE = AaveV3EthereumHorizon.CONFIG_ENGINE;

  // executor roles
  // https://etherscan.io/address/0xe6ec1f0ae6cd023bd0a9b4d0253bdc755103253c
  address public constant HORIZON_OPS = 0xE6ec1f0Ae6Cd023bd0a9B4d0253BDC755103253c;
  // https://etherscan.io/address/0x13b57382c36bab566e75c72303622af29e27e1d3
  address public constant HORIZON_EMERGENCY = 0x13B57382c36BAB566E75C72303622AF29E27e1d3;
  // https://etherscan.io/address/0x09e8e1408a68778ceddc1938729ea126710e7dda
  address public constant HORIZON_EXECUTOR = 0x09e8E1408a68778CEDdC1938729Ea126710E7Dda;

  // horizon deployments
  // https://etherscan.io/address/0x87593272C06f4FC49EC2942eBda0972d2F1Ab521
  address internal constant DEFAULT_INTEREST_RATE_STRATEGY =
    0x87593272C06f4FC49EC2942eBda0972d2F1Ab521;

  // oracle param registry
  // https://etherscan.io/address/0x69d55d504bc9556e377b340d19818e736bbb318b
  address public constant RWA_ORACLE_PARAMS_REGISTRY = 0x69D55D504BC9556E377b340D19818E736bbB318b;

  // horizon assets
  // https://etherscan.io/address/0x17418038ecF73BA4026c4f428547BF099706F27B
  address public constant ACRED_UNDERLYING = 0x17418038ecF73BA4026c4f428547BF099706F27B;
  // https://etherscan.io/address/0x60AEd7d20AC6328f7BA771aD58931c996aff30E8
  address public constant ACRED_PRICE_FEED = 0x60AEd7d20AC6328f7BA771aD58931c996aff30E8;

  // https://etherscan.io/address/0x7433806912Eae67919e66aea853d46Fa0aef98A8
  address public constant MGLOBAL_UNDERLYING = 0x7433806912Eae67919e66aea853d46Fa0aef98A8;
  // https://etherscan.io/address/0xe034De753a3d855B6daD1A4984de75a5c443E939
  address public constant MGLOBAL_PRICE_FEED = 0xe034De753a3d855B6daD1A4984de75a5c443E939;
}

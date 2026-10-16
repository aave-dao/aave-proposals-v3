// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAaveV4ConfigEngine as IEngine} from 'aave-address-book/AaveV4.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';

/// @dev Mirror of aave-dao/aave-v4-risk-stewards `IReduceRiskStewardWrapper`.
interface IReduceRiskStewardWrapper {
  error InvalidCaller();
  error UpdateNotReducing();
  error InvalidLiquidationBonus();

  function reduceHubSpokeCaps(IEngine.SpokeConfigUpdate[] calldata updates) external;

  function addReducedDynamicReserveConfigs(
    IEngine.DynamicReserveConfigAddition[] calldata additions
  ) external;

  function RISK_STEWARD() external view returns (IRiskStewardV4);

  function RISK_COUNCIL() external view returns (address);
}

/// @dev `RiskSteward` errors missing from `IRiskStewardV4`.
interface IRiskStewardErrors {
  error InvalidCaller();
  error ParamChangeNotAllowed();
  error OwnableUnauthorizedAccount(address account);
}

interface IPermissionedPayloadsControllerView {
  function owner() external view returns (address);

  function guardian() external view returns (address);

  function payloadsManager() external view returns (address);
}

interface IMidasToken {
  function accessControl() external view returns (address);

  function M_WIN_GREENLISTED_ROLE() external view returns (bytes32);

  function M_WIN_MIN_BALANCE_EXEMPT_ROLE() external view returns (bytes32);
}

interface IMidasAccessControl {
  function grantRole(bytes32 role, address account) external;
}

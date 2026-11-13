// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumAssets} from 'aave-address-book/AaveV4Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {AaveV4PayloadEthereum} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadEthereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {IAccessManaged} from 'aave-v4/dependencies/openzeppelin/IAccessManaged.sol';
import {Ownable} from 'aave-v4/dependencies/openzeppelin/Ownable.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {V4RoleWiring} from 'aave-helpers/src/v4-config-engine/V4RoleWiring.sol';
import {IBTCVaultSwap} from './IBTCVaultSwap.sol';

/**
 * @title Onboard Native BTC as Collateral to Aave V4 via Babylon Trustless Bitcoin Vaults
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x83f578d707966014cd4ef7c7972f4af89c14964970f3f7088c688c07a6d915c0
 * - Discussion: https://governance.aave.com/t/arfc-onboard-native-btc-as-collateral-to-aave-v4-via-babylon-trustless-bitcoin-vaults/25845
 */
contract AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119 is AaveV4PayloadEthereum {
  // https://etherscan.io/address/0xAd0fd800cbaF41a4Ced1BEa3a4f90aA18CfBC49d
  address public constant BABYLON_HUB = 0xAd0fd800cbaF41a4Ced1BEa3a4f90aA18CfBC49d;

  // https://etherscan.io/address/0x3DbE3F48A5BCc529e1863a6710A3bCDf58220Fc0
  address public constant BABYLON_HUB_PROXY_ADMIN = 0x3DbE3F48A5BCc529e1863a6710A3bCDf58220Fc0;

  // https://etherscan.io/address/0x093d0d3bD44054155bae8C445C6832c762063278
  address public constant BABYLON_SPOKE = 0x093d0d3bD44054155bae8C445C6832c762063278;

  // https://etherscan.io/address/0xdC8F506531907643679Af52f7e2E920290ab563E
  address public constant BABYLON_SPOKE_PROXY_ADMIN = 0xdC8F506531907643679Af52f7e2E920290ab563E;

  // https://etherscan.io/address/0x6fE08B5AC181bbd67FE39039320B3eFCE786ec01
  address public constant BABYLON_USDT_TOKENIZATION_SPOKE =
    0x6fE08B5AC181bbd67FE39039320B3eFCE786ec01;

  // https://etherscan.io/address/0xaD9433F9256849AD67E0D4C09F722bF63b72BEbd
  address public constant BABYLON_USDC_TOKENIZATION_SPOKE =
    0xaD9433F9256849AD67E0D4C09F722bF63b72BEbd;

  // https://etherscan.io/address/0x23dBcde82Aac61Ebb36D36687F48BD57dA6D2F8b
  address public constant BABYLON_GHO_TOKENIZATION_SPOKE =
    0x23dBcde82Aac61Ebb36D36687F48BD57dA6D2F8b;

  // https://etherscan.io/address/0xb9C2d84578bD1a6548781d7793342E390E9B6eE7
  address public constant BABYLON_WBTC_TOKENIZATION_SPOKE =
    0xb9C2d84578bD1a6548781d7793342E390E9B6eE7;

  // https://etherscan.io/address/0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341
  address public constant VAULT_BTC = 0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341;

  // Babylon's AaveAdapter, the liquidation manager of the Babylon Spoke
  // https://etherscan.io/address/0xadca531564f3B26d0aAF48a044d741fD6cD571Ea
  address public constant AAVE_ADAPTER = 0xadca531564f3B26d0aAF48a044d741fD6cD571Ea;

  // https://etherscan.io/address/0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9
  address public constant BTC_VAULT_SWAP = 0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9;

  // Aave Labs, Babylon and LlamaRisk 2-of-3 Safe
  // https://etherscan.io/address/0x828AA986e31D60Eb07EFC1543FF9297835f4A9f7
  address public constant BTC_VAULT_SWAP_MULTISIG = 0x828AA986e31D60Eb07EFC1543FF9297835f4A9f7;

  uint64 public constant BABYLON_BTC_VAULT_SWAP_FEE_ROLE = 2001;
  uint64 public constant BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE = 2002;

  uint32 public constant BTC_VAULT_SWAP_FEE_EXECUTION_DELAY = 5 days;

  // AaveAdapter roles that pause and unpause, and freeze, Babylon's side of the market
  bytes32 public constant APPLICATION_PAUSE_GUARDIAN = keccak256('APPLICATION_PAUSE_GUARDIAN');
  bytes32 public constant APPLICATION_FREEZE_GUARDIAN = keccak256('APPLICATION_FREEZE_GUARDIAN');

  /// @dev The Babylon Hub and Babylon Spoke must be fully handed over to Aave governance: both under
  /// the Aave V4 AccessManager, with their ProxyAdmins owned by the V4 Security Council. Babylon must
  /// also have granted the V4 Security Council both guardian roles on its AaveAdapter.
  function _preExecute() internal view override {
    require(
      IAccessControl(AAVE_ADAPTER).hasRole(
        APPLICATION_PAUSE_GUARDIAN,
        MiscEthereum.V4_SECURITY_COUNCIL
      ),
      'AAVE_ADAPTER_PAUSE_GUARDIAN_NOT_GRANTED'
    );
    require(
      IAccessControl(AAVE_ADAPTER).hasRole(
        APPLICATION_FREEZE_GUARDIAN,
        MiscEthereum.V4_SECURITY_COUNCIL
      ),
      'AAVE_ADAPTER_FREEZE_GUARDIAN_NOT_GRANTED'
    );
    require(
      IAccessManaged(BABYLON_HUB).authority() == address(AaveV4Ethereum.ACCESS_MANAGER),
      'BABYLON_HUB_NOT_HANDED_OVER'
    );
    require(
      IAccessManaged(BABYLON_SPOKE).authority() == address(AaveV4Ethereum.ACCESS_MANAGER),
      'BABYLON_SPOKE_NOT_HANDED_OVER'
    );
    require(
      Ownable(BABYLON_HUB_PROXY_ADMIN).owner() == MiscEthereum.V4_SECURITY_COUNCIL,
      'BABYLON_HUB_PROXY_ADMIN_NOT_HANDED_OVER'
    );
    require(
      Ownable(BABYLON_SPOKE_PROXY_ADMIN).owner() == MiscEthereum.V4_SECURITY_COUNCIL,
      'BABYLON_SPOKE_PROXY_ADMIN_NOT_HANDED_OVER'
    );
  }

  function accessManagerRoleMemberships()
    public
    pure
    override
    returns (IConfigEngine.RoleMembership[] memory)
  {
    IConfigEngine.RoleMembership[] memory items = new IConfigEngine.RoleMembership[](5);
    items[0] = IConfigEngine.RoleMembership({
      authority: address(AaveV4Ethereum.ACCESS_MANAGER),
      roleId: BABYLON_BTC_VAULT_SWAP_FEE_ROLE,
      account: BTC_VAULT_SWAP_MULTISIG,
      granted: true,
      executionDelay: BTC_VAULT_SWAP_FEE_EXECUTION_DELAY
    });
    items[1] = _guardianMembership(BTC_VAULT_SWAP_MULTISIG);
    items[2] = _guardianMembership(MiscEthereum.V4_SECURITY_COUNCIL);
    items[3] = _guardianMembership(MiscEthereum.V4_SECURITY_COUNCIL_EXECUTOR);
    items[4] = _guardianMembership(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    return items;
  }

  function accessManagerRoleUpdates()
    public
    pure
    override
    returns (IConfigEngine.RoleUpdate[] memory)
  {
    IConfigEngine.RoleUpdate[] memory items = new IConfigEngine.RoleUpdate[](2);
    items[0] = IConfigEngine.RoleUpdate({
      authority: address(AaveV4Ethereum.ACCESS_MANAGER),
      roleId: BABYLON_BTC_VAULT_SWAP_FEE_ROLE,
      admin: EngineFlags.KEEP_CURRENT_UINT64,
      guardian: BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE,
      grantDelay: EngineFlags.KEEP_CURRENT_UINT32,
      label: 'BABYLON_BTC_VAULT_SWAP_FEE_ROLE',
      labelUpdate: false
    });
    items[1] = IConfigEngine.RoleUpdate({
      authority: address(AaveV4Ethereum.ACCESS_MANAGER),
      roleId: BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE,
      admin: EngineFlags.KEEP_CURRENT_UINT64,
      guardian: EngineFlags.KEEP_CURRENT_UINT64,
      grantDelay: EngineFlags.KEEP_CURRENT_UINT32,
      label: 'BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE',
      labelUpdate: false
    });
    return items;
  }

  function accessManagerTargetFunctionRoleUpdates()
    public
    pure
    override
    returns (IConfigEngine.TargetFunctionRoleUpdate[] memory)
  {
    bytes4[] memory feeSelectors = new bytes4[](1);
    feeSelectors[0] = IBTCVaultSwap.setSwapFeeBps.selector;

    bytes4[] memory guardianSelectors = new bytes4[](4);
    guardianSelectors[0] = IBTCVaultSwap.pause.selector;
    guardianSelectors[1] = IBTCVaultSwap.unpause.selector;
    guardianSelectors[2] = IBTCVaultSwap.freeze.selector;
    guardianSelectors[3] = IBTCVaultSwap.unfreeze.selector;

    IConfigEngine.TargetFunctionRoleUpdate[]
      memory btcVaultSwapWiring = new IConfigEngine.TargetFunctionRoleUpdate[](2);
    btcVaultSwapWiring[0] = IConfigEngine.TargetFunctionRoleUpdate({
      authority: address(AaveV4Ethereum.ACCESS_MANAGER),
      target: BTC_VAULT_SWAP,
      selectors: feeSelectors,
      roleId: BABYLON_BTC_VAULT_SWAP_FEE_ROLE
    });
    btcVaultSwapWiring[1] = IConfigEngine.TargetFunctionRoleUpdate({
      authority: address(AaveV4Ethereum.ACCESS_MANAGER),
      target: BTC_VAULT_SWAP,
      selectors: guardianSelectors,
      roleId: BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE
    });

    return
      V4RoleWiring.merge(
        V4RoleWiring.merge(
          V4RoleWiring.hubWiring(address(AaveV4Ethereum.ACCESS_MANAGER), BABYLON_HUB),
          V4RoleWiring.spokeWiring(address(AaveV4Ethereum.ACCESS_MANAGER), BABYLON_SPOKE)
        ),
        btcVaultSwapWiring
      );
  }

  function hubSpokeToAssetsAdditions()
    public
    pure
    override
    returns (IConfigEngine.SpokeToAssetsAddition[] memory)
  {
    IConfigEngine.SpokeToAssetsAddition[] memory items = new IConfigEngine.SpokeToAssetsAddition[](
      7
    );
    {
      IConfigEngine.SpokeAssetConfig[] memory assets = new IConfigEngine.SpokeAssetConfig[](5);
      assets[0] = _spokeAssetConfig({underlying: VAULT_BTC, addCap: 20, drawCap: 0});
      assets[1] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDT_UNDERLYING,
        addCap: 5_000_000,
        drawCap: 250_000
      });
      assets[2] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDC_UNDERLYING,
        addCap: 5_000_000,
        drawCap: 250_000
      });
      assets[3] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.GHO_UNDERLYING,
        addCap: 1_000_000,
        drawCap: 100_000
      });
      assets[4] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.WBTC_UNDERLYING,
        addCap: 100,
        drawCap: 20
      });
      items[0] = _spokeToAssetsAddition({hub: BABYLON_HUB, spoke: BABYLON_SPOKE, assets: assets});
    }
    items[1] = _tokenizationSpokeAddition({
      spoke: BABYLON_USDT_TOKENIZATION_SPOKE,
      underlying: AaveV4EthereumAssets.USDT_UNDERLYING,
      addCap: 1_000_000
    });
    items[2] = _tokenizationSpokeAddition({
      spoke: BABYLON_USDC_TOKENIZATION_SPOKE,
      underlying: AaveV4EthereumAssets.USDC_UNDERLYING,
      addCap: 1_000_000
    });
    items[3] = _tokenizationSpokeAddition({
      spoke: BABYLON_GHO_TOKENIZATION_SPOKE,
      underlying: AaveV4EthereumAssets.GHO_UNDERLYING,
      addCap: 1_000_000
    });
    items[4] = _tokenizationSpokeAddition({
      spoke: BABYLON_WBTC_TOKENIZATION_SPOKE,
      underlying: AaveV4EthereumAssets.WBTC_UNDERLYING,
      addCap: 10
    });
    {
      IConfigEngine.SpokeAssetConfig[] memory assets = new IConfigEngine.SpokeAssetConfig[](5);
      assets[0] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDT_UNDERLYING,
        addCap: 0,
        drawCap: 500_000
      });
      assets[1] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDC_UNDERLYING,
        addCap: 0,
        drawCap: 500_000
      });
      assets[2] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDG_UNDERLYING,
        addCap: 0,
        drawCap: 250_000
      });
      assets[3] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.GHO_UNDERLYING,
        addCap: 0,
        drawCap: 100_000
      });
      assets[4] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.RLUSD_UNDERLYING,
        addCap: 0,
        drawCap: 100_000
      });
      items[5] = _spokeToAssetsAddition({
        hub: address(AaveV4EthereumHubs.CORE_HUB),
        spoke: BABYLON_SPOKE,
        assets: assets
      });
    }
    {
      IConfigEngine.SpokeAssetConfig[] memory assets = new IConfigEngine.SpokeAssetConfig[](1);
      assets[0] = _spokeAssetConfig({
        underlying: AaveV4EthereumAssets.WBTC_UNDERLYING,
        addCap: 0,
        drawCap: 20
      });
      items[6] = _spokeToAssetsAddition({
        hub: address(AaveV4EthereumHubs.CORE_HUB),
        spoke: BTC_VAULT_SWAP,
        assets: assets
      });
    }
    return items;
  }

  function _guardianMembership(
    address account
  ) internal pure returns (IConfigEngine.RoleMembership memory) {
    return
      IConfigEngine.RoleMembership({
        authority: address(AaveV4Ethereum.ACCESS_MANAGER),
        roleId: BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE,
        account: account,
        granted: true,
        executionDelay: 0
      });
  }

  function _tokenizationSpokeAddition(
    address spoke,
    address underlying,
    uint40 addCap
  ) internal pure returns (IConfigEngine.SpokeToAssetsAddition memory) {
    IConfigEngine.SpokeAssetConfig[] memory assets = new IConfigEngine.SpokeAssetConfig[](1);
    assets[0] = _spokeAssetConfig({underlying: underlying, addCap: addCap, drawCap: 0});
    return _spokeToAssetsAddition({hub: BABYLON_HUB, spoke: spoke, assets: assets});
  }

  function _spokeToAssetsAddition(
    address hub,
    address spoke,
    IConfigEngine.SpokeAssetConfig[] memory assets
  ) internal pure returns (IConfigEngine.SpokeToAssetsAddition memory) {
    return
      IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        hub: hub,
        spoke: spoke,
        assets: assets
      });
  }

  function _spokeAssetConfig(
    address underlying,
    uint40 addCap,
    uint40 drawCap
  ) internal pure returns (IConfigEngine.SpokeAssetConfig memory) {
    return
      IConfigEngine.SpokeAssetConfig({
        underlying: underlying,
        config: IHub.SpokeConfig({
          addCap: addCap,
          drawCap: drawCap,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
  }
}

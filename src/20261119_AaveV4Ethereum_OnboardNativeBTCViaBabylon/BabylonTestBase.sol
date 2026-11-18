// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {ITokenizationSpoke} from 'aave-v4/spoke/interfaces/ITokenizationSpoke.sol';
import {IAccessManaged} from 'aave-v4/dependencies/openzeppelin/IAccessManaged.sol';
import {IAccessManagerEnumerable} from 'aave-v4/access/interfaces/IAccessManagerEnumerable.sol';
import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumSpokes, AaveV4EthereumAssets, AaveV4EthereumGetters} from 'aave-address-book/AaveV4Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IAaveAdapter} from 'src/interfaces/babylon/IAaveAdapter.sol';
import {IVaultBTC} from 'src/interfaces/babylon/IVaultBTC.sol';
import {BabylonMainnet} from './BabylonMainnet.sol';
import {AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119} from './AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119.sol';

/**
 * @dev Fork setup shared by the Babylon launch tests. Aave's addresses come from aave-address-book
 * and Babylon's from `BabylonMainnet`. The addresses of the Aave deployment and the LlamaRisk
 * parameters are written out from their source. None is read from the payload, so a wrong constant
 * in the payload fails a test.
 */
abstract contract BabylonTestBase is ProtocolV4TestBaseEthereum {
  // after the handover of the Babylon Hub and Babylon Spoke, sent in blocks 26,409,220 to 26,409,237
  uint256 internal constant FORK_BLOCK = 26_409_250;
  // the deployer still controlled the market, used to test the payload's handover checks
  uint256 internal constant PRE_HANDOVER_BLOCK = 26_407_400;
  uint256 internal constant BABYLON_SPOKE_DEPLOY_BLOCK = 26_394_302;

  address internal constant ACCESS_MANAGER = address(AaveV4Ethereum.ACCESS_MANAGER);
  address internal constant HUB_CONFIGURATOR = address(AaveV4Ethereum.HUB_CONFIGURATOR);
  address internal constant SPOKE_CONFIGURATOR = address(AaveV4Ethereum.SPOKE_CONFIGURATOR);
  address internal constant TREASURY_SPOKE = address(AaveV4Ethereum.TREASURY_SPOKE);
  address internal constant CORE_HUB = address(AaveV4EthereumHubs.CORE_HUB);
  address internal constant MAIN_SPOKE = address(AaveV4EthereumSpokes.MAIN_SPOKE);
  address internal constant RISK_STEWARD = AaveV4Ethereum.RISK_STEWARD;
  address internal constant RISK_COUNCIL = AaveV4Ethereum.RISK_COUNCIL;
  address internal constant EXECUTOR_LVL_1 = GovernanceV3Ethereum.EXECUTOR_LVL_1;
  address internal constant V4_SECURITY_COUNCIL = MiscEthereum.V4_SECURITY_COUNCIL;
  address internal constant V4_SECURITY_COUNCIL_EXECUTOR =
    MiscEthereum.V4_SECURITY_COUNCIL_EXECUTOR;

  // Aave deployment report, aave-v4 scripts/markets/babylon/reports/mainnet.json
  address internal constant BABYLON_HUB = 0xAd0fd800cbaF41a4Ced1BEa3a4f90aA18CfBC49d;
  address internal constant BABYLON_HUB_IMPLEMENTATION = 0x294871258134336FB340761F86c9970474A6A4d7;
  address internal constant BABYLON_HUB_PROXY_ADMIN = 0x3DbE3F48A5BCc529e1863a6710A3bCDf58220Fc0;
  address internal constant BABYLON_HUB_IR_STRATEGY = 0xe94Fb20280100aff45E49C7242c91e91E6652676;
  address internal constant BABYLON_SPOKE = 0x093d0d3bD44054155bae8C445C6832c762063278;
  address internal constant BABYLON_SPOKE_IMPLEMENTATION =
    0x2c2167aA1F1eEb2e65c92D9BF9130185d3f188C4;
  address internal constant BABYLON_SPOKE_PROXY_ADMIN = 0xdC8F506531907643679Af52f7e2E920290ab563E;
  address internal constant BABYLON_SPOKE_ORACLE = 0x1E3Acad6B31CF5A4E9Ca3B66BC448876EE53e3dF;
  address internal constant WA_BABYLON_USDT = 0x6fE08B5AC181bbd67FE39039320B3eFCE786ec01;
  address internal constant WA_BABYLON_USDC = 0xaD9433F9256849AD67E0D4C09F722bF63b72BEbd;
  address internal constant WA_BABYLON_GHO = 0x23dBcde82Aac61Ebb36D36687F48BD57dA6D2F8b;
  address internal constant WA_BABYLON_WBTC = 0xb9C2d84578bD1a6548781d7793342E390E9B6eE7;

  // contracts the Aave deployer leaves behind at the handover
  address internal constant DEPLOYER = 0x4df5D09841A716391E00fB9B118f3FaBCFD4c8D1;
  address internal constant DEPLOYMENT_ACCESS_MANAGER = 0x39abDA92f1C220aA5f57F8971Ac8711E91496aeA;
  address internal constant DEPLOYMENT_HUB_CONFIGURATOR =
    0x2207F01E4eAe1AdE3339B96B11F01aa3C196d3A2;
  address internal constant DEPLOYMENT_SPOKE_CONFIGURATOR =
    0x18cBeC03D6cB32cfbC3F1e7791b4fDE3fD205000;

  address internal constant BABYLON_AAVE_ADAPTER = BabylonMainnet.AAVE_ADAPTER;
  address internal constant BABYLON_AAVE_ADAPTER_IMPLEMENTATION =
    BabylonMainnet.AAVE_ADAPTER_IMPLEMENTATION;
  address internal constant BABYLON_BTC_VAULT_SWAP_SPOKE = BabylonMainnet.BTC_VAULT_SWAP_SPOKE;
  address internal constant BABYLON_BTC_VAULT_SWAP_SPOKE_IMPLEMENTATION =
    BabylonMainnet.BTC_VAULT_SWAP_SPOKE_IMPLEMENTATION;
  address internal constant BABYLON_BTC_VAULT_SWAP_SPOKE_PROXY_ADMIN =
    BabylonMainnet.BTC_VAULT_SWAP_SPOKE_PROXY_ADMIN;
  address internal constant VAULT_BTC = BabylonMainnet.VAULT_BTC;
  address internal constant BABYLON_DEPLOYER = BabylonMainnet.DEPLOYER;
  address internal constant BABYLON_INTERIM_GOVERNANCE = BabylonMainnet.INTERIM_GOVERNANCE;
  address internal constant BABYLON_APPLICATION_TIMELOCK = BabylonMainnet.APPLICATION_TIMELOCK;
  bytes32 internal constant BABYLON_APPLICATION_ADMIN_ROLE = BabylonMainnet.APPLICATION_ADMIN_ROLE;
  bytes32 internal constant BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE =
    BabylonMainnet.APPLICATION_PAUSE_GUARDIAN_ROLE;
  bytes32 internal constant BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE =
    BabylonMainnet.APPLICATION_FREEZE_GUARDIAN_ROLE;
  // Aave Labs, Babylon and LlamaRisk 2-of-3 Safe
  address internal constant BTC_VAULT_SWAP_MULTISIG = 0x828AA986e31D60Eb07EFC1543FF9297835f4A9f7;

  address internal constant USDT = AaveV4EthereumAssets.USDT_UNDERLYING;
  address internal constant USDC = AaveV4EthereumAssets.USDC_UNDERLYING;
  address internal constant GHO = AaveV4EthereumAssets.GHO_UNDERLYING;
  address internal constant WBTC = AaveV4EthereumAssets.WBTC_UNDERLYING;
  address internal constant USDG = AaveV4EthereumAssets.USDG_UNDERLYING;
  address internal constant RLUSD = AaveV4EthereumAssets.RLUSD_UNDERLYING;

  // LlamaRisk price feed recommendation
  address internal constant BTC_USD_SVR_FEED = 0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A;
  address internal constant USDT_FEED = 0x260326c220E469358846b187eE53328303Efe19C;
  address internal constant USDC_FEED = 0x3f73F03aa83B2A48ed27E964eD0fDb590332095B;
  address internal constant GHO_FEED = 0xD110cac5d8682A3b045D5524a9903E031d70FCCd;
  address internal constant WBTC_FEED = 0xDaa4B74C6bAc4e25188e64ebc68DB5050b690cAc;
  address internal constant USDG_FEED = 0x83D20dEEdcd4aC1313496c8CBcAad0fa298c0CE4;
  address internal constant RLUSD_FEED = 0xf0eaC18E908B34770FDEe46d069c846bDa866759;

  uint256 internal constant CORE_USDT_ASSET_ID = 4;
  uint256 internal constant CORE_USDC_ASSET_ID = 5;
  uint256 internal constant CORE_GHO_ASSET_ID = 6;
  uint256 internal constant CORE_RLUSD_ASSET_ID = 7;
  uint256 internal constant CORE_USDG_ASSET_ID = 8;
  uint256 internal constant CORE_WBTC_ASSET_ID = 11;

  uint256 internal constant BABYLON_VAULT_BTC_ASSET_ID = 0;
  uint256 internal constant BABYLON_USDT_ASSET_ID = 1;
  uint256 internal constant BABYLON_USDC_ASSET_ID = 2;
  uint256 internal constant BABYLON_GHO_ASSET_ID = 3;
  uint256 internal constant BABYLON_WBTC_ASSET_ID = 4;

  uint256 internal constant VAULT_BTC_RESERVE_ID = 0;
  uint256 internal constant BABYLON_USDT_RESERVE_ID = 1;
  uint256 internal constant BABYLON_USDC_RESERVE_ID = 2;
  uint256 internal constant BABYLON_GHO_RESERVE_ID = 3;
  uint256 internal constant BABYLON_WBTC_RESERVE_ID = 4;
  uint256 internal constant CORE_USDT_RESERVE_ID = 5;
  uint256 internal constant CORE_USDC_RESERVE_ID = 6;
  uint256 internal constant CORE_GHO_RESERVE_ID = 7;
  uint256 internal constant CORE_USDG_RESERVE_ID = 8;
  uint256 internal constant CORE_RLUSD_RESERVE_ID = 9;
  uint256 internal constant RESERVE_COUNT = 10;

  uint64 internal constant ADMIN_ROLE = 0;
  uint64 internal constant HUB_CONFIGURATOR_ROLE = 101;
  uint64 internal constant HUB_FEE_MINTER_ROLE = 102;
  uint64 internal constant HUB_DEFICIT_ELIMINATOR_ROLE = 103;
  uint64 internal constant SPOKE_CONFIGURATOR_ROLE = 301;
  uint64 internal constant SPOKE_USER_POSITION_UPDATER_ROLE = 302;
  // reserved, the proposal does not create it
  uint64 internal constant BABYLON_BTC_VAULT_SWAP_DOMAIN_ADMIN_ROLE = 2000;
  uint64 internal constant BABYLON_BTC_VAULT_SWAP_FEE_ROLE = 2001;
  uint64 internal constant BABYLON_BTC_VAULT_SWAP_GUARDIAN_ROLE = 2002;
  uint32 internal constant BTC_VAULT_SWAP_FEE_DELAY = 432_000;

  bytes32 internal constant IMPLEMENTATION_SLOT =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
  bytes32 internal constant PROXY_ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119 internal proposal;

  address internal user = makeAddr('user');
  address internal supplier = makeAddr('supplier');

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);
    _replayGuardianGrants({pause: true, freeze: true});
    proposal = new AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119();
  }

  /// @dev Babylon grants the V4 Security Council both guardian roles on the AaveAdapter through its
  /// application timelock, which it has not queued yet. Once the grants are executed on-chain, move
  /// `FORK_BLOCK` past them and delete this replay.
  function _replayGuardianGrants(bool pause, bool freeze) internal {
    IAaveAdapter adapter = IAaveAdapter(BABYLON_AAVE_ADAPTER);
    require(
      !adapter.hasRole(BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE, V4_SECURITY_COUNCIL) &&
        !adapter.hasRole(BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE, V4_SECURITY_COUNCIL),
      'guardian roles are on-chain: move FORK_BLOCK past the grants and delete the replay'
    );
    vm.startPrank(BABYLON_APPLICATION_TIMELOCK);
    if (pause) adapter.grantRole(BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE, V4_SECURITY_COUNCIL);
    if (freeze) adapter.grantRole(BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE, V4_SECURITY_COUNCIL);
    vm.stopPrank();
  }

  function _executePayload() internal {
    GovV3Helpers.executePayload(vm, address(proposal));
  }

  // the Babylon market is not in aave-address-book until the proposal executes

  function _getHubs() internal view virtual override returns (IHub[] memory) {
    IHub[] memory listed = AaveV4EthereumGetters.getAllHubs();
    IHub[] memory hubs = new IHub[](listed.length + 1);
    for (uint256 i; i < listed.length; ++i) {
      require(address(listed[i]) != BABYLON_HUB, 'Babylon Hub is in aave-address-book');
      hubs[i] = listed[i];
    }
    hubs[listed.length] = IHub(BABYLON_HUB);
    return hubs;
  }

  function _getSpokes() internal view virtual override returns (ISpoke[] memory) {
    ISpoke[] memory listed = AaveV4EthereumGetters.getAllSpokes();
    ISpoke[] memory spokes = new ISpoke[](listed.length + 1);
    for (uint256 i; i < listed.length; ++i) {
      require(address(listed[i]) != BABYLON_SPOKE, 'BabylonSpoke is in aave-address-book');
      spokes[i] = listed[i];
    }
    spokes[listed.length] = ISpoke(BABYLON_SPOKE);
    return spokes;
  }

  function _getTokenizationSpokes()
    internal
    view
    virtual
    override
    returns (ITokenizationSpoke[] memory)
  {
    ITokenizationSpoke[] memory listed = AaveV4EthereumGetters.getAllTokenizationSpokes();
    address[4] memory babylon = _babylonTokenizationSpokes();
    ITokenizationSpoke[] memory spokes = new ITokenizationSpoke[](listed.length + babylon.length);
    for (uint256 i; i < listed.length; ++i) {
      spokes[i] = listed[i];
    }
    for (uint256 i; i < babylon.length; ++i) {
      spokes[listed.length + i] = ITokenizationSpoke(babylon[i]);
    }
    return spokes;
  }

  function _babylonTokenizationSpokes() internal pure returns (address[4] memory) {
    return [WA_BABYLON_USDT, WA_BABYLON_USDC, WA_BABYLON_GHO, WA_BABYLON_WBTC];
  }

  function _btcVaultSwapGuardians() internal pure returns (address[4] memory) {
    return [
      BTC_VAULT_SWAP_MULTISIG,
      V4_SECURITY_COUNCIL,
      V4_SECURITY_COUNCIL_EXECUTOR,
      EXECUTOR_LVL_1
    ];
  }

  /// @dev vaultBTC is minted by the AaveAdapter and moves only to the Hub, the adapter or a
  /// registered position proxy.
  function _mintVaultBtc(address to, uint256 amount) internal {
    vm.startPrank(BABYLON_AAVE_ADAPTER);
    IVaultBTC(VAULT_BTC).addValidProxy(to);
    IVaultBTC(VAULT_BTC).mint(to, amount);
    vm.stopPrank();
  }

  function _supplyVaultBtcAsCollateral(address account, uint256 amount) internal {
    _mintVaultBtc(account, amount);
    vm.startPrank(account);
    IERC20(VAULT_BTC).approve(BABYLON_SPOKE, amount);
    ISpoke(BABYLON_SPOKE).supply(VAULT_BTC_RESERVE_ID, amount, account);
    ISpoke(BABYLON_SPOKE).setUsingAsCollateral(VAULT_BTC_RESERVE_ID, true, account);
    vm.stopPrank();
  }

  function _supplyToBabylonHub(address token, uint256 reserveId, uint256 amount) internal {
    deal(token, supplier, amount);
    vm.startPrank(supplier);
    (bool ok, ) = token.call(abi.encodeCall(IERC20.approve, (BABYLON_SPOKE, amount)));
    require(ok, 'approve');
    ISpoke(BABYLON_SPOKE).supply(reserveId, amount, supplier);
    vm.stopPrank();
  }

  function _spokeConfig(
    uint40 addCap,
    uint40 drawCap
  ) internal pure returns (IHub.SpokeConfig memory) {
    return
      IHub.SpokeConfig({
        addCap: addCap,
        drawCap: drawCap,
        riskPremiumThreshold: 0,
        active: true,
        halted: false
      });
  }

  function _implementation(address proxy) internal view returns (address) {
    return address(uint160(uint256(vm.load(proxy, IMPLEMENTATION_SLOT))));
  }

  function _proxyAdmin(address proxy) internal view returns (address) {
    return address(uint160(uint256(vm.load(proxy, PROXY_ADMIN_SLOT))));
  }
}

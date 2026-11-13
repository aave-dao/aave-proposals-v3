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
import {AaveV4EthereumGetters} from 'aave-address-book/AaveV4Ethereum.sol';
import {AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119} from './AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119.sol';

interface IVaultBTC {
  function HUB() external view returns (address);

  function adapter() external view returns (address);

  function mint(address to, uint256 amount) external;

  function addValidProxy(address proxyAddress) external;
}

interface IAaveAdapter {
  function BTC_VAULT_CORE_SPOKE() external view returns (address);

  function BTC_VAULT_HUB() external view returns (address);

  function EXIT_BTC_RESERVE_ID() external view returns (uint256);

  function VAULT_BTC_RESERVE_ID() external view returns (uint256);

  function liquidationFeeBps() external view returns (uint256);

  function hasRole(bytes32 role, address account) external view returns (bool);

  function grantRole(bytes32 role, address account) external;
}

interface IBTCVaultSwapView {
  function ADAPTER() external view returns (address);

  function HUB() external view returns (address);

  function EXIT_BTC() external view returns (address);

  function EXIT_BTC_ASSET_ID() external view returns (uint256);

  function sellDiscountBps() external view returns (uint256);

  function minimumProfitThresholdBps() external view returns (uint256);

  function isPaused() external view returns (bool);

  function isFrozen() external view returns (bool);
}

interface IBabylonSpoke {
  error UnsupportedLiquidationCall();

  function LIQUIDATION_MANAGER() external view returns (address);

  function MANAGED_COLLATERAL_RESERVE_ID() external view returns (uint256);

  function liquidationCall(
    uint256 debtReserveId,
    uint256 debtToCover,
    address user,
    uint256 collateralToLiquidate
  ) external;
}

interface ISafe {
  function getOwners() external view returns (address[] memory);

  function getThreshold() external view returns (uint256);

  function getModulesPaginated(
    address start,
    uint256 pageSize
  ) external view returns (address[] memory, address);
}

interface IOwnable {
  function owner() external view returns (address);

  function transferOwnership(address newOwner) external;
}

/**
 * @dev Fork setup shared by the Babylon launch tests. Every address and value below is written out
 * from its source (aave-address-book, the Aave deployment report, Babylon's deployment, the
 * LlamaRisk parameters) and none is read from the payload, so a wrong constant in the payload fails
 * a test.
 */
abstract contract BabylonTestBase is ProtocolV4TestBaseEthereum {
  // after the handover of the Babylon Hub and Babylon Spoke, sent in blocks 26,409,220 to 26,409,237
  uint256 internal constant FORK_BLOCK = 26_409_250;
  // the deployer still controlled the market, used to test the payload's handover checks
  uint256 internal constant PRE_HANDOVER_BLOCK = 26_407_400;
  uint256 internal constant BABYLON_SPOKE_DEPLOY_BLOCK = 26_394_302;

  // aave-address-book AaveV4Ethereum
  address internal constant ACCESS_MANAGER = 0x08aE3BE30958cDd1847ec58fFfd4C451a87fDF01;
  address internal constant HUB_CONFIGURATOR = 0x1F0753480bB03EaA00863224602267B7E0525C3d;
  address internal constant SPOKE_CONFIGURATOR = 0x9BFFf48BFb5A7AE70c348d4d4cb97E8DEFa5389a;
  address internal constant TREASURY_SPOKE = 0xB9B0b8616f6Bf6841972a52058132BE08d723155;
  address internal constant CORE_HUB = 0xCca852Bc40e560adC3b1Cc58CA5b55638ce826c9;
  address internal constant MAIN_SPOKE = 0x94e7A5dCbE816e498b89aB752661904E2F56c485;
  address internal constant RISK_STEWARD = 0x6f48d9Cdb8EE6E17c96B2d8Aec128af426A295c1;
  address internal constant RISK_COUNCIL = 0x47c71dFEB55Ebaa431Ae3fbF99Ea50e0D3d30fA8;
  // aave-address-book GovernanceV3Ethereum
  address internal constant EXECUTOR_LVL_1 = 0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A;
  // aave-address-book MiscEthereum
  address internal constant V4_SECURITY_COUNCIL = 0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9;
  address internal constant V4_SECURITY_COUNCIL_EXECUTOR =
    0x14339e2178A954d5FB839D5Ff31644fE0F25F517;

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

  // Babylon's deployment
  address internal constant AAVE_ADAPTER = 0xadca531564f3B26d0aAF48a044d741fD6cD571Ea;
  address internal constant AAVE_ADAPTER_IMPLEMENTATION =
    0xf86510AffA83a492200d7150901F5915bb48A067;
  address internal constant BTC_VAULT_SWAP_IMPLEMENTATION =
    0xbA1A3AF731e2561465c642623427883CaC9B8677;
  address internal constant VAULT_BTC = 0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341;
  address internal constant BTC_VAULT_SWAP = 0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9;
  address internal constant BTC_VAULT_SWAP_PROXY_ADMIN = 0xdFf5C4b8baC0c3969a08F50926C4a3A72ec4a019;
  // the only proposer on Babylon's timelocks
  address internal constant BABYLON_INTERIM_GOVERNANCE = 0xcd9e54acA1B7fb9BcE10208201b01559A6B01949;
  // admin of the AaveAdapter roles, 5 day delay
  address internal constant BABYLON_APPLICATION_TIMELOCK =
    0x0a575185163a2446F7A0433f48B0395ca4A9fBb0;
  // keccak256 of the role names, as Babylon's AaveAdapter defines them
  bytes32 internal constant APPLICATION_PAUSE_GUARDIAN =
    0xca16ee6b20db9286cfb1a9beee8e8a87e6c3bf160859d756b3335bdcde7871d2;
  bytes32 internal constant APPLICATION_FREEZE_GUARDIAN =
    0x0c21afe69d1e0290272fa2a9f3df85589b7946c6845042b725f40fa7a09e18a0;
  // Aave Labs, Babylon and LlamaRisk 2-of-3 Safe
  address internal constant BTC_VAULT_SWAP_MULTISIG = 0x828AA986e31D60Eb07EFC1543FF9297835f4A9f7;

  address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
  address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address internal constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
  address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
  address internal constant USDG = 0xe343167631d89B6Ffc58B88d6b7fB0228795491D;
  address internal constant RLUSD = 0x8292Bb45bf1Ee4d140127049757C2E0fF06317eD;

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
  uint64 internal constant BTC_VAULT_SWAP_DOMAIN_ADMIN_ROLE = 2000;
  uint64 internal constant BTC_VAULT_SWAP_FEE_ROLE = 2001;
  uint64 internal constant BTC_VAULT_SWAP_GUARDIAN_ROLE = 2002;
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
    IAaveAdapter adapter = IAaveAdapter(AAVE_ADAPTER);
    require(
      !adapter.hasRole(APPLICATION_PAUSE_GUARDIAN, V4_SECURITY_COUNCIL) &&
        !adapter.hasRole(APPLICATION_FREEZE_GUARDIAN, V4_SECURITY_COUNCIL),
      'guardian roles are on-chain: move FORK_BLOCK past the grants and delete the replay'
    );
    vm.startPrank(BABYLON_APPLICATION_TIMELOCK);
    if (pause) adapter.grantRole(APPLICATION_PAUSE_GUARDIAN, V4_SECURITY_COUNCIL);
    if (freeze) adapter.grantRole(APPLICATION_FREEZE_GUARDIAN, V4_SECURITY_COUNCIL);
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
    vm.startPrank(AAVE_ADAPTER);
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

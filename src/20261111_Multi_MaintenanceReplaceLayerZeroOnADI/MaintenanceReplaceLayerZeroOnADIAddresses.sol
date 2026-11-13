// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Payloads and bridge adapters deployed from aave-dao/adi-deploy (feat/replace-layerzero).
 *      Payload sources: src/adapter_payloads/Ethereum_Replace_LZ_Payload.sol and Remote_Replace_LZ_Payload.sol
 */
library MaintenanceReplaceLayerZeroOnADIAddresses {
  // payloads
  address internal constant ETHEREUM_PAYLOAD = 0x8312F5ad259AAB7A3f9C090746B3be80643147ea;
  address internal constant POLYGON_PAYLOAD = 0x5665adC50a076A17087Ebb32965E7A08142C9b83;
  address internal constant AVALANCHE_PAYLOAD = 0x04C02073e13fBc162E393280E5030F92E6B82dbe;
  address internal constant BNB_PAYLOAD = 0x250f199fE5b8672c263a4b1e6476709a3F459cF3;
  address internal constant MONAD_PAYLOAD = 0xdeccc59707d77b8F8fca4B9acAc9F94eEEC95A65;
  address internal constant GNOSIS_PAYLOAD = 0x22D753e7c05EE2D23B4f5c6C9428fb7229df4abe;

  // new adapters
  address internal constant ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER =
    0xA2A952378DFe468ddb793c4574a0c27Dd81FA560;
  address internal constant ETHEREUM_GNOSIS_CCIP_ADAPTER =
    0x458E8e349192a909B400ecE95DEe16A13665e7a8;
  address internal constant POLYGON_WORMHOLE_EXECUTOR_ADAPTER =
    0xe556210CfCDd4Ce198B6742E7DF8B21C3460A1d0;
  address internal constant AVALANCHE_WORMHOLE_EXECUTOR_ADAPTER =
    0x758540A2f8eB9f37d5fcc064A5eB1b12f7D1390c;
  address internal constant BNB_WORMHOLE_EXECUTOR_ADAPTER =
    0x4fab391411EB51694763731C041c8E3d4bE006B6;
  address internal constant MONAD_WORMHOLE_EXECUTOR_ADAPTER =
    0xe7cb2DbbEfCB82aF2EB3E6719103a0EE3dC39773;
  address internal constant GNOSIS_CCIP_ADAPTER = 0x4018c061c70e186699cb3f0520745B56d261204d;

  // LayerZero adapters being removed
  /// @dev also serves the Celo path, which keeps it
  address internal constant ETHEREUM_LZ_ADAPTER = 0x8410d9BD353b420ebA8C48ff1B0518426C280FCC;
  address internal constant ETHEREUM_MONAD_LZ_ADAPTER = 0xf9482751C9937fF940b93B5921B8984645dD0a53;
  address internal constant POLYGON_LZ_ADAPTER = 0x7FAE7765abB4c8f778d57337bB720d0BC53057e3;
  address internal constant AVALANCHE_LZ_ADAPTER = 0x10f02995a399C0dC0FaF29914220E9C1bCdE8640;
  address internal constant BNB_LZ_ADAPTER = 0xa5cc218513305221201f196760E9e64e9D49d98A;
  address internal constant MONAD_LZ_ADAPTER = 0xb544322f8e59B71d7875e0E2EbceB7f3783257BE;
  address internal constant GNOSIS_LZ_ADAPTER = 0x9b6f5ef589A3DD08670Dd146C11C4Fb33E04494F;
}

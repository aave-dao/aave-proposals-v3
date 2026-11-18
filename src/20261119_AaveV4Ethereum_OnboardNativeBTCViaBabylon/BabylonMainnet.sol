// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Babylon's deployment on Ethereum, shared by the Babylon launch tests. It is not in
 * aave-address-book until the proposal executes. Every value is written out from Babylon's
 * deployment and none is read from the payload, so a wrong constant in the payload fails a test.
 */
library BabylonMainnet {
  address internal constant AAVE_ADAPTER = 0xadca531564f3B26d0aAF48a044d741fD6cD571Ea;
  address internal constant AAVE_ADAPTER_IMPLEMENTATION =
    0xf86510AffA83a492200d7150901F5915bb48A067;
  address internal constant AAVE_ADAPTER_CONFIG = 0xaB6900Dee104781ADFdEa151ccFf8acE47E33C54;
  address internal constant AAVE_ADAPTER_PROXY_MANAGER = 0xd73AcD95867c775Bc48979E5DB4E8ED63F9C78DB;
  address internal constant VAULT_BTC = 0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341;
  address internal constant BTC_VAULT_SWAP_SPOKE = 0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9;
  address internal constant BTC_VAULT_SWAP_SPOKE_IMPLEMENTATION =
    0xbA1A3AF731e2561465c642623427883CaC9B8677;
  address internal constant BTC_VAULT_SWAP_SPOKE_PROXY_ADMIN =
    0xdFf5C4b8baC0c3969a08F50926C4a3A72ec4a019;

  // deployed Babylon's contracts
  address internal constant DEPLOYER = 0x29D6008BFB46007a554Fcf47Ac05d5F4F4BE7313;
  // admin of the AaveAdapter roles, 5 day delay
  address internal constant APPLICATION_TIMELOCK = 0x0a575185163a2446F7A0433f48B0395ca4A9fBb0;
  address internal constant PROTOCOL_TIMELOCK = 0xDeC656861922d11A3F08e8ba3631cCdeA877D9d3;
  // the only proposer on Babylon's timelocks
  address internal constant INTERIM_GOVERNANCE = 0xcd9e54acA1B7fb9BcE10208201b01559A6B01949;
  address internal constant EMERGENCY_GUARDIAN = 0xbd8AEfA24Bd875c6a36C4Dc3be818059372dF2B0;
  address internal constant FEE_RECIPIENT = 0x5b1AdCC0330c8c1D5A70302E657174416a25Ba8C;
  // fee recipient once Babylon's queued batch executes
  address internal constant QUEUED_FEE_RECIPIENT = 0x6F4009EF05baE2C2B6074458B411372723E4027F;
  // freeze guardians of the AaveAdapter besides the Safes and the Aave V4 Security Council
  address internal constant FREEZE_GUARDIAN_1 = 0x9539706d585Ac92E57076a59Ac23B66ebC8a044f;
  address internal constant FREEZE_GUARDIAN_2 = 0xCe32DDC41De2eB5A587d4A7194b73fc7cF78d54d;
  address internal constant FREEZE_GUARDIAN_3 = 0x9df6DB43B620B78618E19E7A75C2Dfa57987CAC7;
}

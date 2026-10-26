// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3PayloadArbitrum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadArbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Revision of ETH & BTC Collateral Efficiency on Aave
 * @author LlamaRisk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x0845fbf2d49ec5ad85f8a569e51ce7014f6f4c6dfc34e3b6cd28ef3f9037d586
 * - Discussion: https://governance.aave.com/t/arfc-revision-of-eth-btc-collateral-efficiency-on-aave/25649
 */
contract AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016 is AaveV3PayloadArbitrum {
  function collateralsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[]
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](2);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3ArbitrumAssets.WETH_UNDERLYING,
      ltv: 81_00,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3ArbitrumAssets.WBTC_UNDERLYING,
      ltv: 78_00,
      liqThreshold: 82_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });

    return collateralUpdate;
  }
}

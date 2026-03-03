---
title: "ACI Is Leaving Aave"
author: "Aavechan Initiative @aci"
discussions: "https://governance.aave.com/t/direct-to-aip-aci-stream-settlement/24206"
---

## Simple Summary

Cancel ACI’s GHO stream (ID 100070) on the Aave Collector and transfer 120 days worth of stream to `treasury.aci.eth`. The remaining balance returns to the Collector.

ACI is departing the Aave DAO. The full context is in our [departure post](https://governance.aave.com/t/aci-is-leaving-aave/24205).

## Motivation

ACI is leaving the Aave DAO. We’re not disappearing overnight. The plan is a four-month wind-down: continue governance activity, implement outstanding commitments, document every system, transfer every tool, and give successor service providers enough context to pick up where we left off.

ACI’s service contract and stream 100070 both run through November 8, 2026. We’re accelerating the exit to 120 days. This proposal requests only what covers that period, not the full remaining stream. The rest goes back to the DAO treasury. The question is whether we can count on the stream staying active while we do the work.

The AWW Temp Check demonstrated that a single entity holds enough voting power to pass its own budget proposals over community opposition. That same voting power could cancel any active stream at any time. We don’t consider the current governance process decentralized enough to guarantee that existing commitments will be honored.

Converting the stream to a lump sum is the only way to ensure ACI can deliver a seamless transition without depending on a process where the outcome is controlled by one party.

## Specification

**Contract**: Aave V3 Ethereum Collector (`0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c`)

**Stream ID**: 100070

**Token**: aEthLidoGHO (`0x18eFE565A5373f430e2f809b97De30335B3ad96A`)

**Recipient**: `treasury.aci.eth` (`0x55Ac902cb75cC15288D473ed8E3E185a75b3f330`)

**Payload actions:**

1. Withdraw accrued unclaimed balance from stream 100070 to `treasury.aci.eth`
2. Cancel stream 100070 (unstreamed portion returns to Collector)
3. Transfer 120 days worth of stream from Collector to `treasury.aci.eth`

The exact amounts will be calculated at payload creation time based on the stream state at that block.

## If this proposal fails

If the DAO rejects this AIP, we’ll treat it as a signal that the protocol doesn’t intend to honor its commitments to ACI. In that case we’ll cease all activity immediately, cut our own stream and consider our obligations terminated.

That’s not the outcome we want. We’re professionals. We want a graceful wind-down that benefits Aave users and leaves every system we built in good hands. This AIP makes it possible.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/bc13493c62b18d7dbc89c85045d5dcb9f9bd7139/src/20260302_AaveV3Ethereum_ACIIsLeavingAave/AaveV3Ethereum_ACIIsLeavingAave_20260302.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/bc13493c62b18d7dbc89c85045d5dcb9f9bd7139/src/20260302_AaveV3Ethereum_ACIIsLeavingAave/AaveV3Ethereum_ACIIsLeavingAave_20260302.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-aci-stream-settlement/24206)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

# Proposal authoring

Help the user question the implementation and verify that it matches the proposal's actual intent; do not put the agent on autopilot or impose opinionated choices.

## Reconcile scope

- Compare the forum, deployments, config, payloads, tests, and Markdown; surface every mismatch.
- Build a complete before-and-after inventory of every material configuration change, recording its current onchain value, protocol scope, directional effect, and written rationale. Verify each row against actual protocol behavior and identify existing assets or positions affected by shared settings; do not sample changes or stop after finding the first issues. Treat any conflict between the value, rationale, and intended outcome as unresolved until the authoritative source reconciles it.
- Check every address-book address against addresses explicitly named in the forum. If they differ, identify the correct target and tell the user to coordinate a forum amendment before syncing code and Markdown.
- If any information appears outdated, explain what likely changed and ask the user before updating the source or implementation with current information.
- For multichain scope, use this baseline and verify its current status:
  - V3 active: Ethereum (Core, Prime, and Horizon), Plasma, Avalanche, BNB Chain, Gnosis, Monad, Base, Arbitrum, Mantle, Ink, X Layer, Polygon, Linea, Optimism, MegaETH, and Celo.
  - V3 deprecated (legacy): Sonic, Scroll, zkSync, Metis, Soneium, Aptos, and Ethereum EtherFi.
  - V4 active: Ethereum and Avalanche. No V4 deployments are deprecated.

## Validate the specification before implementation

If no authoritative specification exists for the current governance stage, stop. When subagents are available and authorized, give a context-isolated subagent only the authoritative specification sources and relevant protocol or generator interfaces. Ask it to audit completeness without implementing, choosing values, or seeing suspected gaps.

Require a matrix mapping every required payload field and implicit protocol side effect to its scope, current value, proposed value, units, source, and rationale. Distinguish explicit requirements from derived values and assumptions. Treat missing material inputs, contradictory sources, and undisclosed side effects as blockers until the authoritative specification resolves them.

## Bootstrap and choose custom execution shape

Always bootstrap the proposal with the repository generator. If it has no premade setup for the required action, preserve the generated structure and build the custom implementation from it. For custom proposals, choose how to register multiple actions:

- One `createPayload` call with multiple actions creates one payload ID. Actions execute sequentially and atomically: one revert rolls back the whole payload. Prefer this for dependent actions.

```solidity
IPayloadsControllerCore.ExecutionAction[] memory actions =
  new IPayloadsControllerCore.ExecutionAction[](2);
actions[0] = GovV3Helpers.buildAction(payloadA);
actions[1] = GovV3Helpers.buildAction(payloadB);
GovV3Helpers.createPayload(actions);
```

- Separate `createPayload` calls create separate payload IDs. Their executions are failure-isolated and have no ordering guarantee, even when included in one governance proposal. Prefer this for independent actions.

```solidity
IPayloadsControllerCore.ExecutionAction[] memory actions =
  new IPayloadsControllerCore.ExecutionAction[](1);
actions[0] = GovV3Helpers.buildAction(payloadA);
GovV3Helpers.createPayload(actions);
actions[0] = GovV3Helpers.buildAction(payloadB);
GovV3Helpers.createPayload(actions);
```

- Recommend based on dependency and failure isolation, then ask when no choice was given.

## Reuse contract surfaces

- Address-book interfaces take priority; update the canonical interface when a method is missing instead of shadowing it locally.
- For Aave-infrastructure contracts, add missing entries to `aave-address-book`, then propagate the revision through `aave-helpers` before using it here.
- If the address book has no interface, a minimal local interface containing only required methods is fine.
- Do not add a dependency solely to obtain an interface.
- Prefer typed entries and runtime getters over recasting and hardcoded role hashes.
- Before deploying a contract in `execute`, surface whether it is one-off or likely reusable. Keep one-offs local; recommend predeploying, verifying, and registering recurring components.

## Keep implementation focused

- Keep NatSpec and inline comments to intent and non-obvious invariants.

## Test behavior

- For each material change, propose an exact pre-state assertion, one execution, and a post-state assertion.
- When rewriting a configuration, identify untouched fields at risk and test selected unchanged fields.
- Inspect generated diffs and events; flag missing instrumentation instead of treating an absent diff as proof of no change.

## Write Markdown

- Use the current generator skeleton and References format; regenerate instead of handcrafting the layout.
- Fetch the Discourse topic through its `.json` URL, save the post content, and mechanically diff it with the Markdown after normalizing only generator-imposed structure and explicit Disclaimer removal. Content differences are not acceptable.
- Keep generated repository links on `main` before merge so the IPFS workflow can pin the final commit.
- Diff against both the generator skeleton and saved forum content, accounting for every difference.

## Validate large cross-chain dispatches

- Simulate the complete Ethereum `executeProposal` from cold state using real Governance, CrossChainController, and configured adapters rather than per-payload mocks.
- Report gas against current constraints, `PayloadSent` count, adapter attempts, and successful destinations, distinguishing attempts from chains.
- If results or margin are concerning, present splitting options and ask before changing the execution shape.

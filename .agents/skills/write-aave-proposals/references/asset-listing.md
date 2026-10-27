# Asset listings

Before treating a new asset listing as ready for implementation or review, verify that both assessments are complete and directly referenced by the proposal specification or forum post:

- the Aave Labs technical assessment;
- the LlamaRisk risk assessment.

Confirm that each assessment covers the asset and deployment being listed. If either assessment is missing, incomplete, unreferenced, or out of scope, surface it as a blocker and ask the user to resolve it before proceeding.

For V4 listings, discuss the Tokenization Spoke choice with the user and explain the current implicit convention: prefer deploying and registering one even for a non-borrowable asset or when tokenization is not intended, with an add cap of 0.

Do not assume an assessment is internally correct because it is authoritative. For every risk parameter and rationale, independently derive from protocol behavior how increasing or decreasing the parameter changes the claimed risk, compare the current and proposed values, and record the result even when they agree. Treat a directional contradiction as unresolved until the risk assessment is corrected or clarified.

## Pendle PT listings

PT listings follow this process:

1. TokenLogic coordinates the new PT listing.
2. LlamaRisk defines the parameters.
3. TokenLogic contributes the asset deployment part of the AIP.
4. Aave Labs adds the PT oracle agent and workflow deployments to that same AIP once they are done.
5. Aave Labs and Certora review everything together in one PR.

Do not split the oracle agent or workflow deployments into a separate AIP or PR.

## Stock listings

The process for stock listings is not yet specified. Before drafting or reviewing one, ask the user to confirm the process with the team, and do not infer it from the PT or standard listing process.

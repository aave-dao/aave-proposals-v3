# Asset listings

Before treating a new asset listing as ready for implementation or review, verify that both assessments are complete and directly referenced by the proposal specification or forum post:

- the Aave Labs technical assessment;
- the LlamaRisk risk assessment.

Confirm that each assessment covers the asset and deployment being listed. If either assessment is missing, incomplete, unreferenced, or out of scope, surface it as a blocker and ask the user to resolve it before proceeding.

For V4 listings, discuss the Tokenization Spoke choice with the user and explain the current implicit convention: prefer deploying and registering one even for a non-borrowable asset or when tokenization is not intended, with an add cap of 0.

Do not assume an assessment is internally correct because it is authoritative. For every risk parameter and rationale, independently derive from protocol behavior how increasing or decreasing the parameter changes the claimed risk, compare the current and proposed values, and record the result even when they agree. Treat a directional contradiction as unresolved until the risk assessment is corrected or clarified.

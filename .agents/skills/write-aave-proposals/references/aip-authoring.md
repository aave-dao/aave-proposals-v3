# AIP authoring

- Use the current generator skeleton and References format; regenerate instead of handcrafting the layout.
- Fetch the Discourse topic through its `.json` URL. The specification may be split across posts, such as a proposer's narrative and a risk provider's parameters, possibly in another topic; ask which posts are authoritative when that is not explicit, and save each separately.
- Map every AIP section to its source post and mechanically diff it against that post only, after normalizing only generator-imposed structure, explicit Disclaimer removal, and image removal. Content differences are not acceptable. List content with no source post separately: verify derived implementation details onchain, and treat any new action, such as a role grant, as a blocker until the forum is amended.
- If an authoritative post is old enough that its values may have changed since, such as current onchain values or market conditions behind risk parameters, discuss with the user whether they need refreshing before implementing.
- When LlamaRisk provides the risk parameters, the PR needs an approval from a LlamaRisk team member before merge.
- Link every authoritative post in References.
- Remove forum images (`![...](upload://...)` and other Discourse-hosted embeds); they do not resolve outside Discourse.
- Keep generated repository links on `main` before merge; the separate [IPFS uploader workflow](../../../../.github/workflows/ipfs.yml) rewrites them to the final commit and uploads the Markdown after merge.
- Diff against both the generator skeleton and saved forum content, accounting for every difference.

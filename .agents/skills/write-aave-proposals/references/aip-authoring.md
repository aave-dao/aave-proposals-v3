# AIP authoring

- Use the current generator skeleton and References format; regenerate instead of handcrafting the layout.
- Fetch the Discourse topic through its `.json` URL, save the post content, and mechanically diff it with the Markdown after normalizing only generator-imposed structure and explicit Disclaimer removal. Content differences are not acceptable.
- Keep generated repository links on `main` before merge; the separate [IPFS uploader workflow](../../../../.github/workflows/ipfs.yml) rewrites them to the final commit and uploads the Markdown after merge.
- Diff against both the generator skeleton and saved forum content, accounting for every difference.

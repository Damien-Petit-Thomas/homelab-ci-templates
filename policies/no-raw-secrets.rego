package main

# Denies any manifest of kind "Secret" entirely — not just ones
# carrying inline plaintext data.
#
# In this architecture, real Secrets are never authored directly in
# Git — they are generated dynamically at deploy time by External
# Secrets Operator, backed by Vault. A rendered chart should never
# contain a raw "Secret" object at all, not even an empty placeholder
# one; only an "ExternalSecret" that references one.

deny contains msg if {
    input.kind == "Secret"
    metadata := object.get(input, "metadata", {})
    name := object.get(metadata, "name", object.get(metadata, "generateName", "<unknown>"))
    msg := sprintf(
        "manifest defines a raw Secret '%s' — Secrets must never be authored directly, use an ExternalSecret instead",
        [name]
    )
}

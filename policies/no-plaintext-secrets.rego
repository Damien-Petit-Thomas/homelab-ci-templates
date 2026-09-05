package main

# This policy checks that Secrets do not contain inline data,
# and instead are backed by ExternalSecrets (e.g., from Vault)

deny[msg] {
    input.kind == "Secret"
    data := object.get(input, "data", {})
    string_data := object.get(input, "stringData", {})
    count(data) + count(string_data) > 0
    not input.metadata.annotations["generated-by"] == "external-secrets"
    msg := sprintf(
        "Secret '%s' contains inline data — use an ExternalSecret backed by Vault instead",
        [input.metadata.name]
    )
}

package main


deny[msg] {
    input.kind == "Secret"
    input.data
    count(input.data) > 0
    not input.metadata.annotations["generated-by"] == "external-secrets"
    msg := sprintf(
        "Secret '%s' contains inline data — use an ExternalSecret backed by Vault instead",
        [input.metadata.name]
    )
}

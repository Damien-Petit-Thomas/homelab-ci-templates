package main

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "container '%s' uses ':latest' tag (image: %s) — pin an explicit version",
        [container.name, container.image]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf(
        "container '%s' has no tag specified (image: %s), defaults to ':latest'",
        [container.name, container.image]
    )
}

deny[msg] {
    input.kind == "DaemonSet"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "container '%s' uses ':latest' tag (image: %s) — pin an explicit version",
        [container.name, container.image]
    )
}

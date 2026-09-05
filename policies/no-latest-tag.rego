package main

# Denies any image using the :latest tag, or no tag at all
# (which implicitly resolves to :latest).

# Workload kinds carrying a pod template at this exact path
# (.spec.template.spec.containers) — factored once to avoid
# duplicating the same logic per kind.
workload_kinds := {"Deployment", "DaemonSet", "StatefulSet"}

deny contains msg if {
    workload_kinds[input.kind]
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "container '%s' uses ':latest' tag (image: %s) — pin an explicit version",
        [container.name, container.image]
    )
}

# Missing-tag detection: a plain `not contains(image, ":")` produces
# a false negative for registries exposing an explicit port (e.g.
# registry:5000/app, where the ":" belongs to the port, not a tag).
# We instead check that a ":" appears AFTER the last "/" (a real
# tag), and exempt digest-pinned images (@sha256:...), which are
# already fully reproducible without needing a tag.

deny contains msg if {
    workload_kinds[input.kind]
    container := input.spec.template.spec.containers[_]
    not contains(container.image, "@")
    not regex.match(":[^/]+$", container.image)
    msg := sprintf(
        "container '%s' has no tag specified (image: %s), defaults to ':latest'",
        [container.name, container.image]
    )
}

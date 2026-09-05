package main

# Denies any image using the :latest tag, or no tag at all
# (which implicitly resolves to :latest).

# Workload kinds enforced by this policy — all expose containers at
# .spec.template.spec.containers / .initContainers. Add more kinds
# here if broader coverage is needed (e.g. CronJob, which nests an
# extra .spec.jobTemplate level and would need a separate rule).
workload_kinds := {"Deployment", "DaemonSet", "StatefulSet", "Job", "ReplicaSet"}

# Matches ":latest" at the end of the tag portion, OR immediately
# followed by "@" (an image can carry both a mutable tag AND a
# digest at once, e.g. repo:latest@sha256:... — the digest makes it
# look pinned, but the tag itself remains mobile and misleading).
# A plain `endswith(image, ":latest")` misses this combined form.
is_latest(image) if {
    regex.match(":latest($|@)", image)
}

deny contains msg if {
    workload_kinds[input.kind]
    container := input.spec.template.spec.containers[_]
    is_latest(container.image)
    msg := sprintf(
        "container '%s' uses ':latest' tag (image: %s) — pin an explicit version",
        [container.name, container.image]
    )
}

# initContainers are just as valid a vector for introducing an
# unpinned image as regular containers — ignoring them would leave
# a real gap despite the policy's stated intent.
deny contains msg if {
    workload_kinds[input.kind]
    container := input.spec.template.spec.initContainers[_]
    is_latest(container.image)
    msg := sprintf(
        "initContainer '%s' uses ':latest' tag (image: %s) — pin an explicit version",
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

deny contains msg if {
    workload_kinds[input.kind]
    container := input.spec.template.spec.initContainers[_]
    not contains(container.image, "@")
    not regex.match(":[^/]+$", container.image)
    msg := sprintf(
        "initContainer '%s' has no tag specified (image: %s), defaults to ':latest'",
        [container.name, container.image]
    )
}

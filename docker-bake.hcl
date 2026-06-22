target "builder" {
    context = "."
    dockerfile = "docker/builder.Dockerfile"
    target = "flycomp-builder"
}

target "built-artifact" {
    context = "."
    dockerfile = "docker/builder.Dockerfile"
    target = "flycomp-built-artifact"
}

target "demo-base" {
    context = "."
    dockerfile = "docker/demo_base.Dockerfile"
}

target "_demo-base" {
    context = "."
    contexts = {
        demo-base = "target:demo-base"
    }
    output = ["type=local,dest=./"]
}

target "demo-extracted" {
    inherits = ["_demo-base"]
    contexts = {
        flycomp-extracted-binary = "target:built-artifact"
    }
    dockerfile = "docker/demo_flycomp.Dockerfile"
}

group "demos" {
    targets = [
        "demo-extracted"
    ]
}

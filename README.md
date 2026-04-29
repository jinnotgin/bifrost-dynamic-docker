# Bifrost Dynamic Alpine Docker Build

This repository builds a Dockerized, dynamic/plugin-capable version of Bifrost using Alpine Linux. The image is intended to be published to GitHub Container Registry and reused across machines without rebuilding locally.

The generated image can be used like this:

```bash
docker pull ghcr.io/jinnotgin/bifrost-dynamic-alpine:v1.4.24
````

This build is designed for Bifrost plugin support, so Bifrost and any `.so` plugins must be built against the same environment: Linux, Alpine/musl libc, matching CPU architecture, and a compatible Go version.

## Runners and architectures

The GitHub Actions workflow uses Docker Buildx to build the image automatically.

By default, the workflow can build for:

```text
linux/amd64
linux/arm64
```

This creates a multi-architecture Docker image under a single tag, for example:

```text
ghcr.io/jinnotgin/bifrost-dynamic-alpine:v1.4.24
```

When a machine pulls this image, Docker automatically selects the correct architecture for that host.

For example:

```bash
docker run ghcr.io/jinnotgin/bifrost-dynamic-alpine:v1.4.24
```

will pull the AMD64 image on an x86_64 machine, and the ARM64 image on an ARM64 machine.

If only one architecture is needed, the workflow can be run with a single platform:

```text
linux/amd64
```

or:

```text
linux/arm64
```

Single-architecture builds are usually faster and use less registry storage, but they are less portable.

## Go builder image

Bifrost’s required Go version may change between upstream releases. For example, Bifrost `v1.4.24` requires Go `1.26.2` or newer.

The Dockerfile uses a single build argument for the Go builder image:

```dockerfile
ARG GO_BUILDER_IMAGE=golang:1.26.2-alpine3.23
```

If the Docker build fails with an error like:

```text
go.mod requires go >= 1.26.2
```

then update the `go_builder_image` workflow input when running the GitHub Actions workflow.

Example:

```text
golang:1.26.2-alpine3.23
```

The same Go builder image should also be used to build any dynamic plugins. For example:

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  golang:1.26.2-alpine3.23 \
  sh -c "apk add --no-cache gcc musl-dev sqlite-dev && \
         CGO_ENABLED=1 go build -buildmode=plugin -o myplugin.so main.go"
```

Keeping the Go version, Alpine version, libc, CPU architecture, and CGO dependencies aligned helps avoid plugin loading issues caused by mismatched build environments.

## Local build

To build locally with the default Go builder image:

```bash
docker build \
  -f Dockerfile.dynamic-alpine \
  --build-arg BIFROST_VERSION=1.4.24 \
  -t bifrost-dynamic-alpine:v1.4.24 .
```

To override the Go builder image:

```bash
docker build \
  -f Dockerfile.dynamic-alpine \
  --build-arg BIFROST_VERSION=1.4.24 \
  --build-arg GO_BUILDER_IMAGE=golang:1.26.2-alpine3.23 \
  -t bifrost-dynamic-alpine:v1.4.24 .
```

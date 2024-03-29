# cpp-multiarch

Sandbox for building a multiarch Docker image for a C++ application using `docker buildx`

## Sample app details
- Built via CMake using host (x86_64) and [aarch64-linux-gnu](https://copr.fedorainfracloud.org/coprs/lantw44/aarch64-linux-gnu-toolchain/) toolchains on Fedora
- Dependencies: yaml-cpp, spdlog/fmt (statically linked)
- Note: Dockerfile uses Fedora 39 in order for glibc version (2.38) to match the aarch64-linux-gnu toolchain

```bash
$ mkdir build; cd build
$ cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$PWD/.. ..
$ make install
$ cd ..; mkdir build_aarch64; cd build_aarch64
$ cmake -DCMAKE_TOOLCHAIN_FILE=../ArmLinux.cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTAL_PREFIX=$PWD/.. .. 
$ make install
```

## Container images
- x86_64, aarch64

## Building image with Docker buildx, pushing to dockerhub

```bash
$ docker login
$ docker buildx create --use
$ docker buildx build --platform linux/amd64,linux/arm64 --push -t cjlove2024/multiarchtest:latest .
```

## Building image with Docker buildx, pushing to private registry

- Create /etc/buildkitd.toml with entry for private registry and path to its root CA:

```
# /etc/buildkitd.toml
debug = true
[registry."fir.love.io:3005"]
  ca=["/etc/docker/certs.d/fir.love.io:3005/ca.crt"]
```

```bash
$ docker buildx create --use --bootstrap --name mybuilder --driver docker-container --config /etc/buildkitd.toml
$ docker buildx build --platform linux/amd64,linux/arm64 --push -t fir.love.io:3005/multiarch:latest .
```

## Deploying to multi-architecture K3S cluster
The number of replicas in the deployment ensures pods scheduled on all nodes in a K3S cluster consisting of x86_64 and aarch64 nodes:

```bash
$ kubectl apply -f multiarch.yaml
```

## CI/CD

- `ci` directory has Concourse pipeline (retired) which built the app and image for `x86_64` and `aarch64` and pushes to a private registry
- `.gitea/workflows/ci.yaml` has Gitea action workflow which builds the app and image for `x86_64` and `aarch64` and pushes to a private registry
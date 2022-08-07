FROM golang:1.19-bullseye as build
ARG PROTOC_VERSION=21.4
WORKDIR /opt

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1; \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0; \
    go install github.com/googleapis/api-linter/cmd/api-linter@latest

RUN arch="$(uname -m)"; \
    if [ "$arch" = "aarch64" ]; then \
        arch="aarch_64"; \
    fi; \
    os="$(uname -s)"; \
    case "$os" in \
        Linux) os="linux" ;; \
        Darwin) os="osx" ;; \
    esac; \
    curl -sSLo protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-${os}-${arch}.zip; \
    apt-get update; \
    apt-get install -y unzip; \
    unzip protoc.zip


FROM golang:1.19-bullseye

RUN curl -sSLo /usr/local/bin/semver https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver && chmod +x /usr/local/bin/semver

COPY --from=build /go/bin/ /go/bin/
COPY --from=build /opt/bin/protoc /usr/local/bin/
COPY --from=build /opt/include /usr/local/
FROM golang:bullseye AS builder
LABEL MAINTAINER="roman@misakai.com"

# Copy the directory into the container outside of the gopath
RUN mkdir -p /go-build/src/github.com/emitter-io/emitter/
WORKDIR /go-build/src/github.com/emitter-io/emitter/
ADD . /go-build/src/github.com/emitter-io/emitter/

# Download and install any required third party dependencies into the container.
RUN apt update && \
    apt install -y git g++ && \
    go install

# Base image for runtime
FROM debian:bullseye-slim
RUN apt update && \
    apt install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/
# Get the executable binary from build-img declared previously
COPY --from=builder /go/bin/emitter .

# Expose emitter ports
EXPOSE 4000
EXPOSE 8080
EXPOSE 8443

# Start the broker
CMD ["./emitter"]

# Use a smaller base image
FROM alpine:latest

# Install dependencies in one layer and remove cache
RUN apk add --no-cache git go musl-dev && \
    mkdir -p /app && \
    cd /app && \
    # Install gox
    go install github.com/mitchellh/gox@latest && \
    # Clone remote_syslog2
    git clone https://github.com/papertrail/remote_syslog2.git . && \
    # Build remote_syslog2
    go build -o /app/build/remote_syslog2/remote_syslog . && \
    cp README.md LICENSE example_config.yml /app/build/remote_syslog2 && \
    # Copy the binary to the bin directory
    cp /app/build/remote_syslog2/remote_syslog /usr/local/bin/remote_syslog2 && \
    # Make the binary executable
    chmod +x /usr/local/bin/remote_syslog2 && \
    # Clean up build dependencies and go cache
    apk del git go musl-dev && \
    rm -rf /var/cache/apk/* /root/go /app/*

# Set up Go environment
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV GO111MODULE on

WORKDIR /app

# Check if go is available and where it is located
RUN which go || (echo "Go not found" && exit 1)

# The final image only contains the compiled binary and its configuration files
CMD ["/usr/local/bin/remote_syslog2", "-D", "--configfile", "/etc/rsyslog.yml"]

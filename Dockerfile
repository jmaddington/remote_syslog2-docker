# This dockerfile is helpful for troubleshooting build problems
# You probably want to use the alpine dockerfile for production

FROM debian:trixie-slim

RUN apt update && apt dist-upgrade -y
RUN apt -y install git golang-go wget nano bash file

# Set up Go environment
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV GO111MODULE on

# Check if go is available and where it is located
RUN which go || (echo "Go not found" && exit 1)

# Clone and build remote_syslog2
RUN mkdir -p /app
WORKDIR /app

# Install gox
RUN go install github.com/mitchellh/gox@latest

# Clone remote_syslog2
RUN git clone https://github.com/papertrail/remote_syslog2.git .

# Build remote_syslog2
RUN BUILDPATH="/app/build/remote_syslog2"
RUN set -e
RUN mkdir -p /app/build/remote_syslog2
RUN go build -o /app/build/remote_syslog2/remote_syslog .
RUN cp README.md LICENSE example_config.yml /app/build/remote_syslog2

# Copy the binary to the bin directory
RUN cp /app/build/remote_syslog2/remote_syslog /usr/local/bin/remote_syslog2

# Make the binary executable
RUN chmod +x /usr/local/bin/remote_syslog2

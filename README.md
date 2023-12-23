# remote_syslog2 Docker Container Integration

This guide explains how to integrate the RSyslog Docker container into an existing Docker Compose setup to forward logs to Papertrail.

This uses (https://github.com/papertrail/remote_syslog2)[https://github.com/papertrail/remote_syslog2]

## Prerequisites

- Docker and Docker Compose installed on your host machine.
- An existing `docker-compose.yml` for your application.
- A Papertrail account with a destination set up to receive logs.

## Configuration

1. **Papertrail Settings**: Configure the `rsyslog.yml` to match your Papertrail log destination details:

    ```yaml
    destination:
      host: logsX.papertrailapp.com  # Replace with your Papertrail host.
      port: 1234                     # Replace with your Papertrail port.
      protocol: tls
    ```

2. **Log Files**: Specify the log files to monitor in `rsyslog.yml`. Adjust paths to match where your services write logs:

    ```yaml
    files:
      - /logs/*.log
      - /var/logs/*.log
    ```

## Integrating with Existing Docker Compose

1. **Merge Services**: Include the `rsyslog` service definition in your existing `docker-compose.yml`:

    ```yaml
    services:
      rsyslog:
        image: rsyslog
        build:
          context: .
          dockerfile: Dockerfile
        command: ["/usr/local/bin/remote_syslog2", "-D", "--configfile", "/etc/rsyslog.yml"]
        volumes:
          - ./rsyslog.yml:/etc/rsyslog.yml
          - logs:/logs
        restart: always
    ```

2. **Define Shared Volume**: Add the `logs` volume to your existing `docker-compose.yml` to be shared across services that produce logs:

    ```yaml
    volumes:
      logs:
    ```

3. **Configure Services to Use Shared Volume**: Update the service definitions that generate logs to use the `logs` volume. For example:

    ```yaml
    services:
      web:
        image: my-web-app
        volumes:
          - logs:/var/log/my-web-app
    ```

    Update the `rsyslog.yml` file to watch the correct paths according to where services write logs.

## Usage

1. **Starting Services**: Bring up your services, including the RSyslog container, with:

    ```bash
    docker-compose up -d
    ```

2. **Log Verification**: Check Papertrail to ensure that logs from your services are being forwarded correctly.

## Troubleshooting

- Verify that your services are writing logs to the shared `logs` volume.
- Ensure that `rsyslog.yml` paths match the log file locations in the volume.
- Inspect the RSyslog container logs for errors:

    ```bash
    docker-compose logs rsyslog
    ```

## Stopping Services

To stop all services, including the RSyslog container, and remove volumes:

```bash
docker-compose down -v

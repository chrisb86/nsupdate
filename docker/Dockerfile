FROM alpine:latest

ENV TZ="UTC"
ENV SCHEDULE="* * * * *"
ENV PUID=1000
ENV PGID=1000

## Configure runtime variables for nsupdate
ENV NSUPDATE_CONFD_DIR="/config"
ENV NSUPDATE_LOG_DIR="/log"

## Install requirements
RUN apk add --no-cache git curl libxml2-utils tzdata jq

# Cache Bust upon new commits
ADD https://api.github.com/repos/chrisb86/nsupdate/git/refs/heads/main /.git-hashref

COPY --chmod=755 nsupdate.sh /usr/local/bin/nsupdate.sh
COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Create volume directories (ownership will be set at runtime)
RUN mkdir -p /config /log

## Start crond
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

VOLUME /config
VOLUME /log
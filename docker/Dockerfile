FROM alpine:latest

ENV TZ "UTC"
ENV SCHEDULE="* * * * *"

## Configure runtime variables for nsupdate
ENV NSUPDATE_CONFD_DIR="/config"
ENV NSUPDATE_LOG_DIR="/log"

## Install requirements
RUN apk update
RUN apk add --no-cache git curl libxml2-utils tzdata

# Read timezone from server, so in docker-compose you can change TZ
RUN ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone && date

# Cache Bust upon new commits
ADD https://api.github.com/repos/chrisb86/nsupdate/git/refs/heads/main /.git-hashref

COPY nsupdate.sh /usr/local/bin/nsupdate.sh
RUN chmod +x /usr/local/bin/nsupdate.sh

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["cron","-f", "-l", "2"]

VOLUME /config
VOLUME /log

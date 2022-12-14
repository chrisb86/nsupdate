FROM alpine:latest
MAINTAINER Christian Baer <chris@debilux.org>

ENV TZ "UTC"

## Run cron every minute
ENV SCHEDULE "* * * * *"

ENV GIT_REPO "https://github.com/chrisb86/nsupdate"
ENV NSUPDATE_CONFD_DIR="/config"
ENV NSUPDATE_LOG_DIR="/log"

## Install requirements
RUN apk update
RUN apk add --update-cache \
        git \
        curl \
        libxml2-utils

# Read timezone from server, so in docker-compose you can change TZ
RUN apk add --no-cache tzdata

RUN ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone && date

## Clone git repo
RUN mkdir app
RUN git clone $GIT_REPO /app

## Setup cron job
RUN echo "${SCHEDULE} sh /app/nsupdate.sh" >> /etc/crontabs/root

## Start crond
CMD [ "crond", "-l", "2", "-f" ]

VOLUME /config
VOLUME /log

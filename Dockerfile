FROM r.j3ss.co/img:v0.5.6 AS img
FROM docker:18.09

RUN apk add --no-cache \
  # our dependencies
  make \
  bash \
  curl \
  # dockerd dependencies
  util-linux \
  iptables \
  # docker-compose dependencies
  py-pip \
  python-dev \
  libffi-dev \
  openssl-dev \
  gcc \
  libc-dev \
  # img dependencies
  git

ARG DOCKER_COMPOSE_VERSION='1.24.0'

RUN pip --no-cache-dir install "docker-compose==${DOCKER_COMPOSE_VERSION}" "awscli"

COPY ./docker-helpers.sh .
COPY ./build .

COPY --from=img /usr/bin/img /usr/bin/img
COPY --from=img /usr/bin/newuidmap /usr/bin/newuidmap
COPY --from=img /usr/bin/newgidmap /usr/bin/newgidmap

CMD "ash"

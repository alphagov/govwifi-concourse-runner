FROM docker:20.10.12

RUN apk add --no-cache \
  # our dependencies
  make \
  bash \
  curl \
  # dockerd dependencies
  util-linux \
  iptables \
  dumb-init \
  # docker-compose dependencies
  py-pip \
  python3-dev \
  rust \
  cargo \
  libffi-dev \
  openssl-dev \
  gcc \
  libc-dev \
  # passwordstore deps
  git \
  gnupg

ARG DOCKER_COMPOSE_VERSION='1.29.2'
ARG PASSWORD_STORE_VERSION='1.7.3'

WORKDIR /tmp/password-store
ADD "http://www.zx2c4.com/keys/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc" /tmp
RUN gpg --import "/tmp/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc" \
  && git clone https://git.zx2c4.com/password-store -b "${PASSWORD_STORE_VERSION}" . \
  && git tag --verify "${PASSWORD_STORE_VERSION}" \
  && make install \
  && rm -rf "/tmp/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc" "/tmp/password-store"

WORKDIR /
RUN pip --no-cache-dir install "docker-compose==${DOCKER_COMPOSE_VERSION}" "awscli"


COPY ./docker-helpers.sh /
COPY ./docker-wrapper /usr/local/bin/

ENTRYPOINT [ "docker-wrapper" ]
CMD "ash"

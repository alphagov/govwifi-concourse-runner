ARG DOCKER_VERSION='18.09'
ARG DOCKER_COMPOSE_VERSION='1.24.0'
ARG ALPINE_VERSION='3.9'

FROM docker/compose:${DOCKER_COMPOSE_VERSION} AS docker-compose
FROM docker:${DOCKER_VERSION} AS docker-cli

FROM alpine:${ALPINE_VERSION} AS passwordstore
ARG PASSWORD_STORE_VERSION='1.7.3'

RUN apk add --no-cache \
  make \
  git \
  gnupg \
  && git clone https://git.zx2c4.com/password-store -b ${PASSWORD_STORE_VERSION} \
  && cd password-store \
  && wget "http://www.zx2c4.com/keys/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc" \
  && gpg --import AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc \
  && git tag --verify ${PASSWORD_STORE_VERSION} \
  && make install

FROM alpine:${ALPINE_VERSION} AS runtime

ARG AWSCLI_VERSION='1.16.154'

RUN apk add --no-cache \
  # our dependencies
  make \
  bash \
  curl \
  # passwordstore deps
  gnupg \
  # dockerd dependencies	
  util-linux \	
  iptables \
  # awscli deps
  python2 \
  py2-pip \
  # setup aws-cli
  && pip --no-cache-dir install awscli==${AWSCLI_VERSION} \
  && apk --purge -v del py-pip

COPY ./docker-helpers.sh .

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker-compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose
COPY --from=passwordstore /usr/lib/password-store/ /usr/lib/password-store/
COPY --from=passwordstore /usr/bin/pass /usr/bin

ENTRYPOINT ["ash"]

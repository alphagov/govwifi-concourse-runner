ARG DOCKER_VERSION='18.09'
ARG DOCKER_COMPOSE_VERSION='1.24.0'

FROM docker:${DOCKER_VERSION} AS docker-cli
FROM docker/compose:${DOCKER_COMPOSE_VERSION}

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

ENV PASSWORD_STORE_VERSION "1.7.3"
ENV AWSCLI_VERSION "1.16.154"

RUN apk add --no-cache \
  # our dependencies
  make \
  bash \
  curl \
  # passwordstore deps
  git \
  gnupg \
  # dockerd dependencies	
  util-linux \	
  iptables \
  # awscli deps
  python \
  py-pip \
  && git clone https://git.zx2c4.com/password-store -b $PASSWORD_STORE_VERSION \
  && cd password-store \
  && wget "http://www.zx2c4.com/keys/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc" \
  && gpg --import AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc \
  && git tag --verify $PASSWORD_STORE_VERSION \
  && make install \
  && cd - \
  && rm -rf password-store \
  && pip install awscli==$AWSCLI_VERSION \
  && apk --purge -v del py-pip

COPY ./docker-helpers.sh .

ENTRYPOINT ["ash"]

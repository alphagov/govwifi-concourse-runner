FROM docker/compose:1.24.0

ARG PASSWORD_STORE_VERSION='1.7.3'

RUN apk add --no-cache \
    # our dependencies
    make \
    bash \
    curl \
    # passwordstore deps
    git \
    gnupg \
    # awscli deps
    py-pip \
 && git clone https://git.zx2c4.com/password-store -b "${PASSWORD_STORE_VERSION}" \
 && cd password-store \
 && wget "http://www.zx2c4.com/keys/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc" \
 && gpg --import AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc \
 && git tag --verify "${PASSWORD_STORE_VERSION}" \
 && make install \
 && cd - \
 && rm -rf password-store \
 && pip --no-cache-dir install awscli

COPY ./docker-helpers.sh .

ENTRYPOINT "ash"

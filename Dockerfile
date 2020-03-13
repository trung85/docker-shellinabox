
FROM golang:alpine

ENV SIAB_USERCSS="Normal:+/etc/shellinabox/options-enabled/00+Black-on-White.css,Reverse:-/etc/shellinabox/options-enabled/00_White-On-Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color-Terminal.css,Monochrome:-/etc/shellinabox/options-enabled/01_Monochrome.css" \
  SIAB_PORT=4200 \
  SIAB_ADDUSER=true \
  SIAB_USER=siab \
  SIAB_USERID=1001 \
  SIAB_GROUP=siab \
  SIAB_GROUPID=1001 \
  SIAB_PASSWORD=putsafepasswordhere \
  SIAB_SHELL=/bin/bash \
  SIAB_HOME=/home/siab \
  SIAB_SUDO=false \
  SIAB_SSL=true \
  SIAB_SERVICE=/:LOGIN \
  SIAB_PKGS=none \
  SIAB_SCRIPT=none

# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

# Install aws-cli
RUN apk -Uuv add groff less python py-pip jq
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

# Configure Go
ENV GOROOT /usr/local/go
ENV GOPATH /go
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

ENV PATH /go/bin:$PATH
ENV PATH /usr/local/go/bin:$PATH

# example
WORKDIR /myapps
COPY app.go /myapps
RUN go get -d
RUN go build -o app

# Fetch dependencies.
# Using go get.
RUN go get -u github.com/trung85/ecsq

# Install shellinabox
ADD files/user-css.tar.gz /

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    chmod 755 /etc && \
    apk update && \
    apk upgrade && \
    apk add --update shadow util-linux pciutils coreutils binutils findutils grep bash bash-completion openssl curl openssh-client sudo shellinabox && rm -rf /var/cache/apk/* && \
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

EXPOSE 4200

VOLUME /home

ADD files/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["shellinabox"]

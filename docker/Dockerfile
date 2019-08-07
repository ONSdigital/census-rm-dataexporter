FROM alpine:3.7
RUN apk add --update \
    postgresql-client \
    openssl \
    zip \
    bash \
    python \
    py-pip \
    py-cffi \
    py-cryptography \
  && pip install --upgrade pip \
  && apk add --virtual build-deps \
    gcc \
    libffi-dev \
    python-dev \
    linux-headers \
    musl-dev \
    openssl-dev \
  && pip install gsutil \
  && apk del build-deps \
  && rm -rf /var/cache/apk/*
ADD run.sh run.sh
ADD boto /root/.boto
ENV BOTO_CONFIG /root/.boto
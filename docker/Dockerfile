FROM google/cloud-sdk:alpine

RUN apk add --update \
    postgresql-client \
    openssl \
    zip \
    bash \
    python3 \
    py-pip \
    py-cffi \
    py-cryptography \
  && pip install --upgrade pip \
  && apk add --virtual build-deps \
    gcc \
    libffi-dev \
    python3-dev \
    linux-headers \
    musl-dev \
    openssl-dev \
  && pip install gsutil \
  && apk del build-deps \
  && rm -rf /var/cache/apk/*
ADD run.sh run.sh

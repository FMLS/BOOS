FROM alpine:latest

RUN apk add --no-cache build-base nasm

WORKDIR /root
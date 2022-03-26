FROM golang:1.16.15-alpine as builder
RUN apk add --no-cache --update alpine-sdk \
    git \
    make

ENV GODEBUG netdns=cgo

RUN mkdir -p /go/src/github.com/lightningnetwork

RUN cd /go/src/github.com/lightningnetwork && git clone https://github.com/lightningnetwork/lnd 

RUN cd /go/src/github.com/lightningnetwork/lnd && git checkout v0.14.2-beta

RUN cd /go/src/github.com/lightningnetwork/lnd \
    &&  make \
    &&  make install

# Start a new, final image to reduce size.
FROM alpine as final

# Expose lnd ports (server, rpc).
EXPOSE 9735 10009

# Copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/

# Add bash.
RUN apk add --no-cache \
    bash

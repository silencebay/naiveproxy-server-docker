FROM --platform=$TARGETPLATFORM golang:1.16-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /app

RUN set -eux; \
    \
    go get -u github.com/caddyserver/xcaddy/cmd/xcaddy; \
    /go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

###

FROM --platform=$TARGETPLATFORM alpine AS runtime
ARG TARGETPLATFORM
ARG BUILDPLATFORM

COPY --from=builder /app/caddy /usr/bin/caddy
ADD ./html /var/www/html
ADD ./config /etc/naiveproxy
CMD /usr/bin/caddy run -config /etc/naiveproxy/Caddyfile

FROM --platform=$TARGETPLATFORM golang:1.19-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /app

RUN set -eux; \
    \
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest; \
    /go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

###

FROM --platform=$TARGETPLATFORM alpine AS runtime
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG NAIVE_USER_ID=1000
ARG NAIVE_GROUP_ID=1000

COPY --from=builder /app/caddy /usr/local/bin/caddy
ADD ./html /var/www/html
ADD ./config /etc/naiveproxy

RUN set -eux; \
    \
    runDeps=" \
        libcap \
    "; \
    \
    apk add --no-network --virtual .run-deps \
        $runDeps \
    ; \
    \
	addgroup -g "${NAIVE_GROUP_ID}" -S naive; \
	adduser -u "${NAIVE_USER_ID}" -D -S -s /bin/bash -G naive naive; \
	sed -i '/^naive/s/!/*/' /etc/shadow; \
	echo "PS1='\w\$ '" >> /home/naive/.bashrc; \
    \
    chmod +x /docker-entrypoint.sh /usr/local/bin/caddy; \
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy; \
    \
# some test
    caddy version

USER naive

CMD [ "/usr/local/bin/caddy", "run", "--config", "/etc/naiveproxy/Caddyfile" ]

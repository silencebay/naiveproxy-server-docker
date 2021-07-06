# Naïve Docker
upstream from [docker-images](https://github.com/wppurking/docker-images)

Run [NaïveProxy](https://github.com/klzgrad/naiveproxy) as a server in Docker.

## Usage

- Fill out [Caddy config](config/Caddyfile)
- Put your certificate at `config/cert.pem` and key at `config/key.pem`
- Build the image with `docker build -t naive .`
- Start with `docker-compose up -d`

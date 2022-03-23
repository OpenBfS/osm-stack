FROM nginx:1.20.1-alpine

RUN apk add --no-cache bash bash-doc bash-completion

COPY ./proxy.conf /etc/nginx/conf.d/default.conf

COPY ./ors-demo /usr/share/nginx/html

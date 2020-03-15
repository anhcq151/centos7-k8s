#!/bin/bash

WORKDIR="/misc_data"
export PROXY_HTTP_PORT='30708' PROXY_HTTPS_PORT='30762'
envsubst '${PROXY_HTTP_PORT} ${PROXY_HTTPS_PORT}' < $WORKDIR/nginx.conf.tmpl > $WORKDIR/nginx.conf 
docker run --name nginx-lb -v $WORKDIR/nginx.conf:/etc/nginx/nginx.conf:ro -v $WORKDIR/nginx_log:/var/log/nginx -p 80:$PROXY_HTTP_PORT -p 443:$PROXY_HTTPS_PORT --restart unless-stopped -d nginx:stable-alpine
sleep 3

# Run these commands to configure alpine timezone to Asia/Ho_Chi_Minh

docker exec -it nginx-lb /bin/sh -c "apk add tzdata"
docker exec -it nginx-lb /bin/sh -c "cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime"
docker exec -it nginx-lb /bin/sh -c "apk del tzdata"
docker exec -it nginx-lb /bin/sh -c "date"
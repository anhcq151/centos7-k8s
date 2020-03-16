#!/bin/bash

WORKDIR="/misc_data"
export PROXY_HTTP_PORT='30001' PROXY_HTTPS_PORT='30002'
envsubst '${PROXY_HTTP_PORT} ${PROXY_HTTPS_PORT}' < $WORKDIR/nginx.conf.tmpl > $WORKDIR/nginx.conf 
docker run --name nginx-lb -v $WORKDIR/nginx.conf:/etc/nginx/nginx.conf:ro -v $WORKDIR/nginx_log:/var/log/nginx -p 80:$PROXY_HTTP_PORT -p 443:$PROXY_HTTPS_PORT --restart always -d nginx:stable-alpine
sleep 3

# Run these commands to configure alpine timezone to Asia/Ho_Chi_Minh, 
# available timezone list can be found here http://en.wikipedia.org/wiki/List_of_tz_database_time_zones

docker exec -it nginx-lb /bin/sh -c "apk add tzdata"
docker exec -it nginx-lb /bin/sh -c "cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime"
docker exec -it nginx-lb /bin/sh -c "apk del tzdata"
docker exec -it nginx-lb /bin/sh -c "date"

cat <<EOF > /usr/local/sbin/nginx-lb.sh
#!/bin/bash

WORKDIR="/misc_data"
PROXY_HTTP_PORT='30708'
PROXY_HTTPS_PORT='30762'
docker run --name nginx-lb -v $WORKDIR/nginx.conf:/etc/nginx/nginx.conf:ro -v $WORKDIR/nginx_log:/var/log/nginx -p 80:$PROXY_HTTP_PORT -p 443:$PROXY_HTTPS_PORT --restart always -d nginx:stable-alpine
sleep 3
docker exec -it nginx-lb /bin/sh -c "apk add tzdata"
docker exec -it nginx-lb /bin/sh -c "cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime"
docker exec -it nginx-lb /bin/sh -c "apk del tzdata"
docker exec -it nginx-lb /bin/sh -c "date"
EOF
cat <<EOF > /etc/systemd/system/nginx-lb.service
[Unit]
Description=Auto start nginx-lb docker container after system startup
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/nginx-lb.sh
TimeoutStartSec=0
Restart=always

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable nginx-lb.service
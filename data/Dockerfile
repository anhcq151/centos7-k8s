FROM alpine

ARG HELM_VERSION='3.1.2'

RUN apk --no-cache add \
        curl \
        bash \
    && curl -fsSL -o /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    && chmod +x /tmp/kubectl \
    && mv /tmp/kubectl /usr/bin \
    && mkdir /root/.kube

RUN curl -fsSL -o /tmp/helm.tar.gz "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz" \
    && tar -zxvf /tmp/helm.tar.gz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/bin \
    && rm -rf /tmp/*

ENTRYPOINT [ "/bin/bash" ]
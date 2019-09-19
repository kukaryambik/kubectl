FROM alpine:3.10

ARG KUBECTL_VER
ARG KUBEVAL_VER
ENV KUBECTL_VER=1.15.3 \
    KUBEVAL_VER=0.14.0 \
    HOME=/kubectl

RUN set -x \
    && apk add --no-cache curl ca-certificates \
    # Create non-root user (with a randomly chosen UID/GUI).
    && adduser kubectl -Du $((RANDOM%8998+1001)) -h $HOME

RUN set -x \
    # Install Kubectl
    && wget https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VER/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    # Install Kubeval
    && export TMP_PATH="$(mktemp -d)" \
    && cd $TMP_PATH \
    && export ARCH=amd64 \
    && ( uname -m | grep -q 64 ) || export ARCH=386 \
    && wget https://github.com/instrumenta/kubeval/releases/download/$KUBEVAL_VER/kubeval-linux-$ARCH.tar.gz -O kubeval-linux-amd64.tar.gz \
    && tar xf kubeval-linux-amd64.tar.gz \
    && cp kubeval /usr/local/bin/ \
    && rm -rf "$TMP_PATH"

USER kubectl
WORKDIR $HOME

ENTRYPOINT ["/usr/local/bin/kubectl"]

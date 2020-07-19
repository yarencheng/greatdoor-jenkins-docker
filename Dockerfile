FROM ubuntu:20.04

RUN apt update
RUN apt-get install -y curl sudo
RUN useradd -m jenkins
RUN echo 'jenkins  ALL=(ALL)  NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /home/jenkins

## Docker
# RUN curl -fsSL https://get.docker.com | sh
# RUN usermod -aG docker jenkins

## golang
ARG GOLANG_VERSION=1.14.6
ARG GOLANG_SHA256=5c566ddc2e0bcfc25c26a5dc44a440fcc0177f7350c1f01952b34d5989a0d287
RUN curl -fsSL https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    echo "${GOLANG_SHA256} go.tar.gz" | sha256sum --check && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH=/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

## node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

## yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

## Helm
ARG HELM_VERSION=v3.2.4
ARG HELM_SHA256=8eb56cbb7d0da6b73cd8884c6607982d0be8087027b8ded01d6b2759a72e34b1
RUN curl https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
    echo "${HELM_SHA256} helm.tar.gz" | sha256sum --check && \
    mkdir helm && \
    tar -xvf helm.tar.gz -C helm && \
    chmod +x helm/linux-amd64/helm && \
    mv helm/linux-amd64/helm /bin/helm && \
    rm -rf helm.tar.gz helm

COPY entrypoint.sh entrypoint.sh
ENV CI=1
USER jenkins
ENTRYPOINT [ "bash", "/home/jenkins/entrypoint.sh" ]

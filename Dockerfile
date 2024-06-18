ARG TERRAFORM_VERSION="1.8.5"
ARG EGET_VERSION="1.3.4"
ARG DEBIAN_RELEASE="bookworm"

FROM debian:${DEBIAN_RELEASE}-slim
ARG TERRAFORM_VERSION
ARG EGET_VERSION
ARG DEBIAN_RELEASE
ARG TARGETARCH
ENV DEBIAN_FRONTEND noninteractive

LABEL org.opencontainers.image.source https://github.com/hseagle2015/docker-terraform-ci
LABEL org.opencontainers.image.authors="sasa@tekovic.com"

RUN useradd -m terraform -s /bin/bash \
&& apt-get update && apt-get upgrade -V -y \
&& apt-get install -V -y curl git unzip tar \
&& mkdir -p /tmp/terraform \
&& cd /tmp/terraform && curl -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip" \
&& unzip terraform.zip && mv terraform /usr/local/bin/ \
&& mkdir -p /tmp/eget && cd /tmp/eget/ && curl -o eget.tar.gz -L "https://github.com/zyedidia/eget/releases/download/v${EGET_VERSION}/eget-${EGET_VERSION}-linux_${TARGETARCH}.tar.gz" \
&& tar xvvfz eget.tar.gz --strip-components=1 "eget-${EGET_VERSION}-linux_${TARGETARCH}/eget" \
&& mv eget /usr/local/bin/ \
&& find /usr/local/bin/ -type f -exec chmod 755 {} \; \
&& eget --to /usr/local/bin/ bridgecrewio/checkov \
&& eget --to /usr/local/bin/ terraform-docs/terraform-docs \
&& eget --to /usr/local/bin/ terraform-linters/tflint \
&& rm -rfv /tmp/* /var/lib/apt/lists/*

USER terraform:terraform
ENTRYPOINT ["terraform"]
CMD ["-help"]

ARG TERRAFORM_VERSION="1.11.3" # github-tags/hashicorp/terraform&versioning=semver
ARG EGET_VERSION="1.3.4" # github-tags/zyedidia/eget&versioning=semver
ARG CHECKOV_VERSION="3.2.396" # github-tags/bridgecrewio/checkov&versioning=semver
ARG TFDOCS_VERSION="0.20.0" # github-tags/terraform-docs/terraform-docs&versioning=semver
ARG TFLINT_VERSION="0.55.1" # github-tags/terraform-linters/tflint&versioning=semver
ARG SOPS_VERSION="3.10.2" # github-tags/getsops/sops&versioning=semver

FROM debian:12.10-slim
ARG TERRAFORM_VERSION
ARG EGET_VERSION
ARG CHECKOV_VERSION
ARG TFDOCS_VERSION
ARG TFLINT_VERSION
ARG SOPS_VERSION
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source=https://github.com/hseagle2015/docker-terraform-ci
LABEL org.opencontainers.image.authors="sasa@tekovic.com"

RUN useradd -m terraform -s /bin/bash \
&& apt-get update && apt-get upgrade -V -y \
&& apt-get install -V -y curl git unzip tar age python3-pip \
&& mkdir -p /tmp/terraform \
&& cd /tmp/terraform && curl -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip" \
&& unzip terraform.zip && mv terraform /usr/local/bin/ \
&& mkdir -p /tmp/eget && cd /tmp/eget/ && curl -o eget.tar.gz -L "https://github.com/zyedidia/eget/releases/download/v${EGET_VERSION}/eget-${EGET_VERSION}-linux_${TARGETARCH}.tar.gz" \
&& tar xvvfz eget.tar.gz --strip-components=1 "eget-${EGET_VERSION}-linux_${TARGETARCH}/eget" \
&& mv eget /usr/local/bin/ \
&& find /usr/local/bin/ -type f -exec chmod 755 {} \; \
&& eget --to /usr/local/bin/ terraform-docs/terraform-docs -t ${TFDOCS_VERSION} \
&& eget --to /usr/local/bin/ terraform-linters/tflint -t ${TFLINT_VERSION} \
&& eget --to /usr/local/bin/ -a '^sbom.json' getsops/sops -t ${SOPS_VERSION} \
&& pip3 install checkov==${CHECKOV_VERSION} --break-system-packages \
&& rm -rfv /tmp/* /var/lib/apt/lists/*

USER terraform:terraform
ENTRYPOINT ["terraform"]
CMD ["-help"]

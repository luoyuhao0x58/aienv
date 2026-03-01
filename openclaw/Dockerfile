FROM debian:13-slim
ARG DEBIAN_FRONTEND=noninteractive
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=openclaw
ARG USER_HOME=/home/$USER_NAME
ARG OPENCLAW_VERSION=latest
ARG NPM_MIRROR=https://registry.npmmirror.com

ADD ./init-scripts /tmp/init-scripts
RUN cd /tmp/init-scripts && ./install.sh

ARG SUPERVISOR_DIR=/.openclaw/supervisor
ENV PLAYWRIGHT_BROWSERS_PATH=/.openclaw/playwright-browsers
ARG PIP_MIRROR=https://mirrors.aliyun.com/pypi/simple
ENV GOPROXY=https://goproxy.io,direct
ARG MIRROR_RUBY_GEM=https://mirrors.aliyun.com/rubygems/
ARG VERSION_K8S=1.35
ARG MIRROR_K8S=https://mirrors.aliyun.com/kubernetes-new
ENV HF_ENDPOINT=https://hf-mirror.com

ADD ./install-tools-scripts /tmp/install-tools-scripts
RUN cd /tmp/install-tools-scripts && ./install.sh
ADD ./supervisord.conf /etc/supervisor/supervisord.conf
ADD entrypoint.sh /.openclaw/entrypoint.sh

ENV NODE_COMPILE_CACHE=/var/tmp/openclaw-compile-cache
ENV OPENCLAW_NO_RESPAWN=1
ENV UV_SYSTEM_PYTHON=1
ENV CLAWHUB_TOKEN=

USER ${USER_NAME}
ADD --chown=${USER_NAME}:${USER_NAME} ./init-data /.openclaw/init-data
WORKDIR ${USER_HOME}/.openclaw/
CMD ["/.openclaw/entrypoint.sh"]
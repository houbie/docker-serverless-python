FROM python:3.8.8-buster
MAINTAINER Ivo Houbrechts <ivo@houbrechts-it.be>

RUN \
  echo "deb https://deb.nodesource.com/node_12.x buster main" > /etc/apt/sources.list.d/nodesource.list && \
  wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -yqq nodejs=$(apt-cache show nodejs|grep Version|grep nodesource|cut -c 10-) yarn && \
  apt-mark hold nodejs && \
  pip install -U pip && pip install pipenv && pip install poetry && \
  npm i -g npm@^6.12.0

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk-11.0.10+9_openj9-0.24.0

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='c48d2b19bf7040c74dfdcac9e395ba7b8f937522ee756c820465f2e8e3dffec2'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.10%2B9_openj9-0.24.0/OpenJDK11U-jre_aarch64_linux_openj9_11.0.10_9_openj9-0.24.0.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='5d2b2939637f999a1910d5cc0fb3d96756125941e5f8b9e3003635aa863664b5'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.10%2B9_openj9-0.24.0/OpenJDK11U-jre_ppc64le_linux_openj9_11.0.10_9_openj9-0.24.0.tar.gz'; \
         ;; \
       s390x) \
         ESUM='2ff9f50d6ffc345434703c43a1d67ac6d3d054b5d4925b4b73a3ce51b02940e5'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.10%2B9_openj9-0.24.0/OpenJDK11U-jre_s390x_linux_openj9_11.0.10_9_openj9-0.24.0.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='7e5f97071f8b86c22c36ddfd7f821c3e8ec531c1128e2e6c931b2e64118a517a'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.10%2B9_openj9-0.24.0/OpenJDK11U-jre_x64_linux_openj9_11.0.10_9_openj9-0.24.0.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

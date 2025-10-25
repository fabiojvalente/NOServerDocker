FROM steamcmd/steamcmd:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG BEPINEX_VERSION=5.4.23.3
ENV TZ=US/Eastern

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y jq file unzip wget --no-install-recommends --no-install-suggests && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up Steam app installation
WORKDIR /server
RUN steamcmd +force_install_dir /server +login anonymous +app_update 3930080 validate +quit && \
    cp -r /server/linux64/* /server/ -f

# Download and install BepInEx
RUN mkdir -p /tmp/bepinex && \
    cd /tmp/bepinex && \
    wget -O "BepInEx_linux_x64_${BEPINEX_VERSION}.zip" "https://github.com/BepInEx/BepInEx/releases/download/v${BEPINEX_VERSION}/BepInEx_linux_x64_${BEPINEX_VERSION}.zip" && \
    unzip -o "BepInEx_linux_x64_${BEPINEX_VERSION}.zip" && \
    rm "BepInEx_linux_x64_${BEPINEX_VERSION}.zip" && \
    cp -a . /server/ -f && \
    rm -rf /tmp/bepinex

# Copy bepinex_preconfig if it exists
COPY ./bepinex_preconfig /server/

WORKDIR /
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/replays"]
VOLUME ["/missions"]
ENTRYPOINT ["/entrypoint.sh"]
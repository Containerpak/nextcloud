FROM ubuntu:26.04 AS source

ADD --checksum=sha256:e4e703e25ecddad2abddfdd0931e59514d1066b2e4cc6b1323db2ffd013eb3cf https://github.com/nextcloud-releases/desktop/releases/download/v34.0.3/Nextcloud-34.0.3-x86_64.AppImage /tmp/app.AppImage

RUN apt-get update && \
    apt-get install -y --no-install-recommends squashfs-tools && \
    chmod 0755 /tmp/app.AppImage && \
    cd /tmp && \
    ./app.AppImage --appimage-extract >/dev/null && \
    mv /tmp/squashfs-root /out

FROM ghcr.io/containerpak/gtk3:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/nextcloud"

COPY --from=source /out /opt/nextcloud

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libnss3 libxkbcommon-x11-0 xdg-utils && \
    ln -sf /opt/nextcloud/AppRun /usr/bin/nextcloud && \
    cpak-clean-junk

COPY icon.png /usr/share/icons/hicolor/128x128/apps/nextcloud.png
COPY nextcloud.desktop /usr/share/applications/nextcloud.desktop

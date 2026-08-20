FROM ubuntu:26.04 AS source

ADD --checksum=sha256:219dee2db502168997a11e5143010333b624c38c0e5ed8e31f4aa0cb5640ae8c https://github.com/nextcloud-releases/desktop/releases/download/v34.0.2/Nextcloud-34.0.2-x86_64.AppImage /tmp/app.AppImage

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

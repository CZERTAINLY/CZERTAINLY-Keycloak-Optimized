FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs postgresql --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup

FROM quay.io/keycloak/keycloak:26.4.6-0 AS builder

LABEL org.opencontainers.image.authors="CZERTAINLY <support@czertainly.com>"

# we can use only build options that will be persisted
# see https://www.keycloak.org/server/all-config?f=build

ENV KC_CACHE_STACK=kubernetes
ENV KC_DB=postgres
ENV KC_HTTP_RELATIVE_PATH=/kc
ENV KC_HEALTH_ENABLED=true

WORKDIR /opt/keycloak

RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

RUN /opt/keycloak/bin/kc.sh build

# build optimized image
FROM quay.io/keycloak/keycloak:26.4.6-0

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=ubi-micro-build /mnt/rootfs /

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

FROM quay.io/keycloak/keycloak:21.0.1 as builder

MAINTAINER CZERTAINLY <support@czertainly.com>

# we can use only build options that will be persisted
# see https://www.keycloak.org/server/all-config?f=build

ENV KC_CACHE_STACK=kubernetes
ENV KC_DB=postgres
ENV KC_HTTP_RELATIVE_PATH=/kc
ENV KC_HEALTH_ENABLED=true

WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

# build optimized image
FROM quay.io/keycloak/keycloak:21.0.1

COPY --from=builder /opt/keycloak/ /opt/keycloak/
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
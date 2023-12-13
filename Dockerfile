FROM quay.io/keycloak/keycloak:latest as builder

# Configure the database vendor, and enable health and metrics endpoints
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# For demonstration purposes only. Use signed certificates in production!
WORKDIR /opt/keycloak
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

# Create the optimized configuration
RUN /opt/keycloak/bin/kc.sh build

# Defines the runtime container image
FROM quay.io/keycloak/keycloak:latest

# Copy the configuration files from the builder image to this runtime image
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Set default values for runtime variables
ENV KC_DB_POOL_INITIAL_SIZE=100
ENV KC_DB_POOL_MIN_SIZE=100
ENV KC_DB_POOL_MAX_SIZE=100
ENV KC_HOSTNAME=localhost
ENV QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

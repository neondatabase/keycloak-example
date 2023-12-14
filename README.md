# Neon Database and Keycloak

[![Deploy to Koyeb](https://www.koyeb.com/static/images/deploy/button.svg)](https://app.koyeb.com/apps/deploy?type=docker&image=quay.io%2Fkeycloak%2Fkeycloak%3A23.0.1&name=keycloak&env%5BKC_DB_USERNAME%5D=&env%5BKC_DB_PASSWORD%5D=&env%5BKC_DB_URL%5D=jdbc%3Apostgresql%3A%2F%2FNEON_HOSTNAME%2Fkeycloak%3Fsslmode%3Drequire&env%5BKC_HOSTNAME%5D=&env%5BKC_HTTP_ENABLED%5D=true&env%5BKC_PROXY%5D=edge&env%5BKC_DB%5D=postgres&ports=8080%3Bhttp%3B%2F&tag=23.0.1&docker.image.tag=23.0.1&image-tag=23.0.1&command=start&env%5BKEYCLOAK_ADMIN%5D=admin&env%5BKEYCLOAK_ADMIN_PASSWORD%5D=)

If you'd like to quickly and easily deploy Keycloak on a hosting provider,
complete the steps in _Neon Postgres Database Setup_ below, then click the
button above to deploy Keycloak on Koyeb. Make sure that you configure the
following values on Koyeb:

* `KC_DB_URL`, `KC_DB_PASSWORD`, `KC_DB_USERNAME` - Refer to [Neon Postgres Database Setup](#neon-postgres-database-setup).
* `KEYCLOAK_ADMIN_PASSWORD` - You'll use this to login to the Keycloak console as the `admin` user.
* `KC_HOSTNAME` - This should be set to the **App name** at the end of the Koyeb deployment UI.
* Ideally, select a depoloyment region close to your Neon database.

## Development Setup

Keycloak can be run locally if you have a JDK installed per the 
[Keycloak docs](https://www.keycloak.org/getting-started/getting-started-zip).
Alternatively you can use Docker or Podman to run Keycloak in a container. This
development guide will use Docker to run Keycloak locally.

### Neon Postgres Database Setup

1. Log in to the Neon console and create a project (or skip to step #2 if using an existing project)
1. Go to the **Databases** UI in your project, and create a new database named `keycloak`.
1. Use the **SQL Editor** in your project to run the following queries in the `keycloak` database:
```sql
/* Create a strong password per: https://neon.tech/docs/manage/roles */
CREATE USER keycloak_admin WITH PASSWORD 'r3plac3_th1s';
GRANT ALL ON SCHEMA public TO keycloak_admin;
```
1. Return to the **Connection Details** screen in your Neon project and take
note of your database's hostname, since you'll need it soon.

### Run Keycloak in Dev Mode

1. Clone this repository and `cd` into it. Run all subsequent commands from within the repository.
1. Create a copy of the `.env.example` file name `.env`.
    ```bash
    cp .env.example .env
    ```
1. Replace the `KC_DB_PASSWORD` with the password you set when creating the `keycloak_admin` user.
1. Replace the `hostname` in `KC_DB_URL` with your database hostname from the **Connection Details** in the Neon project dashboard.
1. Load your environment variables and start keycloak:
    ```bash
    source .env

    docker run --rm --name neon-keycloak \
    -p 8080:8080 \
    -v $(pwd)/realms:/opt/keycloak/data/import \
    -e KC_DB=postgres \
    -e KC_DB_URL=$KC_DB_URL \
    -e KC_DB_PASSWORD=$KC_DB_PASSWORD \
    -e KC_DB_USERNAME=$KC_DB_USERNAME \
    -e KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN \
    -e KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
    quay.io/keycloak/keycloak:23.0.1 start-dev --import-realm
    ```

Be patient on the first start, since Keycloak has to create over 90 tables in
the database and populate them with some data. Subsequent starts will take just
a few seconds to become ready.

Keycloak is ready when the following log is printed:

```
Keycloak 23.0.1 on JVM (powered by Quarkus 3.2.9.Final) started in 175.226s. Listening on: http://0.0.0.0:8080
```

> [!NOTE]  
> This log line is from the initial Keycloak startup using an M2 MacBook Pro using Docker. Startup times are measured in seconds afterwards. On Linux machines that don't require virtualisation to run containers the startup is always measured in seconds.

## Connect an Application to Keycloak

Once you have Keycloak running and connectd to your Neon Postgres database, you
can use it to authenticate users of your application.

The prior `docker run` command mounted the local `realms/` folder and set the
`--import-realm` flag to create a [realm and client](https://www.keycloak.org/docs/latest/server_admin/#core-concepts-and-terms).

Having a realm and client pre-created means you can test your Keycloak instance
using the included [next-auth-sample](/next-auth-sample) application.

## Building an Optimized Keycloak Container

Performing this step is useful to reduce startup times in production. Refer to
[running Keycloak in a container](https://www.keycloak.org/server/containers)
for comprehensive documentation.

### Building an Optimised Container Image

```
docker build . -t neon-keycloak
```

### Run the Container Image

```bash
# Create a .env file
cp .env.example .env

# Modify the .env file with your desired credentials and Neon database URL
vi .env

docker run --rm --name neon-keycloak \
-p 8080:8080 \
-e KC_DB_URL=$KC_DB_URL \
-e KC_DB_PASSWORD=$KC_DB_PASSWORD \
-e KC_DB_USERNAME=$KC_DB_USERNAME \
-e KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN \
-e KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
neon-keycloak start --optimized
```

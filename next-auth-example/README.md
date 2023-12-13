# Next Auth & Keycloak Example

This example is a modified version of the [next-auth example](https://github.com/nextauthjs/next-auth/tree/main/apps/examples/nextjs)

## Running Locally

### Start Keycloak

Follow the instructions in the _README.md_ the at root of this repository to
configure and run a Keycloak instance.

### Install Dependencies

```
cd next-auth-example
npm install
```

### Configure Environment Variables

Copy the `.env.local.example` file in this directory to `.env.local`:

```
cp .env.local.example .env.local
```

Edit the `.env.local` file to use the correct URL for the `KEYCLOAK_ISSUER`,
and edit the `KEYCLOAK_CLIENT_ID` and `KEYCLOAK_CLIENT_SECRET` if you're not
using the sample realm and client configuration provided.

> [!IMPORTANT]
> Do not use the sample realm and client provided in _/realms/quickstart.json_ for production. It contains a hardcoded secret and password that are only appropriate for this example application!

### Start the Application

To run your site locally, use:

```
npm run dev
```

To run it in production mode, use:

```
npm run build
npm run start
```

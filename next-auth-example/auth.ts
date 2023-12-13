import NextAuth from "next-auth"
import Keycloak from "next-auth/providers/keycloak"
import type { NextAuthConfig } from "next-auth"

import { get } from 'env-var'

export const config = {
  theme: {
    logo: "https://next-auth.js.org/img/logo/logo-sm.png",
  },
  providers: [
    Keycloak({
      clientId: get('KEYCLOAK_CLIENT_ID').required().asString(),
      clientSecret: get('KEYCLOAK_CLIENT_SECRET').required().asString(),
      issuer: get('KEYCLOAK_ISSUER').required().asUrlString()
    })
  ],
  callbacks: {
    authorized({ request, auth }) {
      const { pathname } = request.nextUrl
      if (pathname === "/middleware-example") return !!auth
      return true
    },
  },
} satisfies NextAuthConfig

export const { handlers, auth, signIn, signOut } = NextAuth(config)

import {defineConfig, envField} from "astro/config"
import node from "@astrojs/node"
import sitemap from "@astrojs/sitemap"
import mdx from "@astrojs/mdx"

export default defineConfig({
  site: "https://eliseev.mx",
  output: "server",
  adapter: node({
    mode: "standalone"
  }),
  integrations: [sitemap(), mdx()],
  i18n: {
    locales: ["ru", "en"],
    defaultLocale: "ru"
  },
  experimental: {
    env: {
      schema: {
        LOOKING_FOR_JOB: envField.boolean({
          context: "server",
          access: "public",
          optional: true,
          default: true
        })
      }
    }
  }
})

import {defineConfig} from "astro/config"
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
  }
})

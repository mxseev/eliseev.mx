import eslint from "@eslint/js"
import tseslint from "typescript-eslint"
import astro from "eslint-plugin-astro"
import stylistic from "@stylistic/eslint-plugin"

const stylisticConfig = stylistic.configs.customize({
  indent: 2,
  quotes: "double",
  semi: false,
  jsx: true,
  blockSpacing: false,
  commaDangle: "never"
})

const overrides = {
  rules: {
    "@stylistic/object-curly-spacing": ["warn", "never"],
    "@typescript-eslint/consistent-type-definitions": ["error", "type"],
    // he's bugging in astro <style> tag
    "@stylistic/jsx-one-expression-per-line": ["off", {}]
  }
}

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strict,
  ...tseslint.configs.stylistic,
  ...astro.configs.recommended,
  ...astro.configs["jsx-a11y-strict"],
  stylisticConfig,
  overrides
)

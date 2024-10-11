# eliseev.mx website

yet another personal website

### Usage

This is typical [Astro](https://astro.build) project with [MDX](https://docs.astro.build/en/guides/integrations-guide/mdx) integration, so it's pretty straightforward to use (in case you do need to make changes in another person's personal site):

1. Clone
2. Install dependencies via pnpm: `pnpm install`
3. Build: `pnpm build`

- Run development server: `pnpm develop` (yup, I don't like abbreviations)
- Build Docker image: TODO

#### Remarks

- There are ESLint and Stylelint configs in the repository, configure them in your editor (formatting is performed through them as well, including CSS)
- CSS has a unit `step` which means the minimum step for margin/padding (almost like Tailwind CSS with its `mt-2`, `p-4`, etc.)

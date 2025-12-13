# Changed Defaults

These are behavior changes in Astro v6. Your code may still work, but the results may be different than expected.

## i18n Redirect Default

`i18n.routing.redirectToDefaultLocale` now defaults to `false` (was `true`).

### What Changed

In v5, visitors to `/` would be redirected to `/{defaultLocale}/` by default.
In v6, visitors stay at `/` unless you explicitly enable redirects.

### If You Want the Old Behavior

```js
// astro.config.mjs
export default defineConfig({
  i18n: {
    routing: {
      prefixDefaultLocale: true,        // Required for redirects
      redirectToDefaultLocale: true     // Explicitly enable
    }
  }
});
```

**Note:** `redirectToDefaultLocale: true` now requires `prefixDefaultLocale: true`.

### For Manual Routing

Update middleware if using manual routing:

```js
// src/middleware.js
import { middleware } from "astro:i18n";

export const onRequest = middleware({
  prefixDefaultLocale: true,
  redirectToDefaultLocale: true,
});
```

## Script and Style Rendering Order

`<script>` and `<style>` tags now render in **source order** (same order as in your code).

### What Changed

In v5, the order was reversed in the generated HTML.
In v6, order matches your source code.

### Example

```astro
<!-- Your code -->
<style>
  body { background: yellow; }
</style>
<style>
  body { background: red; }
</style>
```

**v5 output:** `red` first, then `yellow` (yellow wins)
**v6 output:** `yellow` first, then `red` (red wins)

### If You Have Issues

Review your style/script order if you see unexpected behavior:

```astro
<!-- If you need yellow to win, swap the order -->
<style>
  body { background: red; }
</style>
<style>
  body { background: yellow; }
</style>
```

## import.meta.env Handling

`import.meta.env` values are now **always inlined** and **never coerced**.

### What Changed

**Inlining:** Non-public env vars are no longer replaced with `process.env` references. Values are inlined at build time.

**No coercion:** String values like `"true"` or `"1"` are no longer converted to booleans/numbers.

### Migration for Coercion

If you relied on automatic type coercion:

```ts
// Before - implicit coercion
const enabled: boolean = import.meta.env.ENABLED;

// After - explicit comparison
const enabled: boolean = import.meta.env.ENABLED === "true";
```

### Migration for process.env

If you relied on transformation to `process.env`:

```ts
// Before - transformed to process.env
const password = import.meta.env.DB_PASSWORD;

// After - use process.env directly for server secrets
const password = process.env.DB_PASSWORD;
```

### Update Type Definitions

```ts
// src/env.d.ts
interface ImportMetaEnv {
  readonly PUBLIC_API_URL: string;
  readonly ENABLED: string;  // Was boolean, now string
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

// For server-side secrets
namespace NodeJS {
  interface ProcessEnv {
    DB_PASSWORD: string;
  }
}
```

### Consider astro:env

For better env variable handling, use `astro:env`:

```ts
// astro.config.mjs
export default defineConfig({
  env: {
    schema: {
      PUBLIC_API_URL: envField.string({ context: "client", access: "public" }),
      DB_PASSWORD: envField.string({ context: "server", access: "secret" }),
    }
  }
});
```

## Image Cropping by Default

Images are now cropped by default when `width` and `height` are specified.

### What Changed

In v5, setting `fit="contain"` was needed to crop images.
In v6, cropping happens automatically with `width` and `height`.

### Migration

If you were explicitly using `fit="contain"`, you can now remove it:

```astro
---
import { Image } from 'astro:assets';
import photo from '../assets/photo.jpg';
---

<!-- Before -->
<Image src={photo} width={400} height={300} fit="contain" />

<!-- After - same result, simpler -->
<Image src={photo} width={400} height={300} />
```

## Images Never Upscale

The default image service no longer upscales images.

### What Changed

In v5, requesting dimensions larger than the source would upscale.
In v6, images are never upscaled beyond their original dimensions.

### Migration

If you need larger images:
1. Use source images with sufficient resolution
2. Use a custom image service that supports upscaling
3. Manually upscale images before adding to project

## Markdown Heading ID Generation

Trailing hyphens are now preserved in heading IDs.

### What Changed

Headings ending in special characters now keep trailing hyphens in their `id` attribute.

```md
## `<Picture />`
```

**v5 output:** `<h2 id="picture">...</h2>`
**v6 output:** `<h2 id="picture-">...</h2>`

### Migration

Update any links to headings that end in special characters:

```md
<!-- Before -->
See [Picture component](/guides/images/#picture)

<!-- After -->
See [Picture component](/guides/images/#picture-)
```

### Backward Compatibility

To keep old IDs (without trailing hyphens), create a custom rehype plugin:

```js
// plugins/rehype-slug.mjs
import GithubSlugger from 'github-slugger';
import { headingRank } from 'hast-util-heading-rank';
import { visit } from 'unist-util-visit';
import { toString } from 'hast-util-to-string';

const slugs = new GithubSlugger();

export function rehypeSlug() {
  return (tree) => {
    slugs.reset();
    visit(tree, 'element', (node) => {
      if (headingRank(node) && !node.properties.id) {
        let slug = slugs.slug(toString(node));
        // Strip trailing hyphens (old behavior)
        if (slug.endsWith('-')) slug = slug.slice(0, -1);
        node.properties.id = slug;
      }
    });
  };
}
```

Then add to config:

```js
// astro.config.mjs
import { rehypeSlug } from './plugins/rehype-slug';

export default defineConfig({
  markdown: {
    rehypePlugins: [rehypeSlug],
  },
});
```

Required packages:
```bash
npm i github-slugger hast-util-heading-rank unist-util-visit hast-util-to-string
```

## Checklist

- [ ] Review i18n redirect behavior if using internationalization
- [ ] Check script/style ordering for CSS specificity issues
- [ ] Update env variable type coercion to explicit comparisons
- [ ] Test image output for expected cropping/sizing
- [ ] Update anchor links to headings with special characters

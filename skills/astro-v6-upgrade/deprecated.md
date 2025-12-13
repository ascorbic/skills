# Deprecated Features

These features still work in Astro v6 but show deprecation warnings. They will be removed in a future major version. Update your code now to avoid future breaking changes.

## Astro in getStaticPaths()

Accessing `Astro` object inside `getStaticPaths()` is deprecated.

### What Changed

In v5.x, `getStaticPaths()` had access to an `Astro` object with `site` and `generator` properties. This was confusing because it wasn't the full `Astro` object available in frontmatter.

In v6, using `Astro.site` or `Astro.generator` logs a deprecation warning. In a future version, it will throw an error.

### Migration

Replace `Astro.site` with `import.meta.env.SITE`:

```astro
---
// Before
export async function getStaticPaths() {
  return getPages(Astro.site);
}

// After
export async function getStaticPaths() {
  return getPages(import.meta.env.SITE);
}
---
```

Remove `Astro.generator` entirely:

```astro
---
// Before
export async function getStaticPaths() {
  console.log(Astro.generator);  // Remove this
  // ...
}
---
```

## import.meta.env.ASSETS_PREFIX

This environment variable is deprecated in favor of the `astro:config/server` module.

### Migration

```ts
// Before
const prefix = import.meta.env.ASSETS_PREFIX;
someLogic(prefix);

// After
import { build } from 'astro:config/server';
someLogic(build.assetsPrefix);
```

This is a drop-in replacement providing the same value.

## astro:schema Module

The `astro:schema` virtual module is deprecated. It was an alias for `astro/zod`.

### Migration

```ts
// Before
import { z } from 'astro:schema';

// After
import { z } from 'astro/zod';
```

## z from astro:content

Importing `z` from `astro:content` is deprecated.

### Migration

```ts
// Before
import { defineCollection, z } from 'astro:content';

// After
import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
```

### Example Content Config

```ts
// src/content.config.ts
import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
  }),
});

export const collections = { blog };
```

## Exposed Transitions Internals

Several internal exports from `astro:transitions` and `astro:transitions/client` are deprecated:

- `createAnimationScope()`
- `isTransitionBeforePreparationEvent()`
- `isTransitionBeforeSwapEvent()`
- `TRANSITION_BEFORE_PREPARATION`
- `TRANSITION_AFTER_PREPARATION`
- `TRANSITION_BEFORE_SWAP`
- `TRANSITION_AFTER_SWAP`
- `TRANSITION_PAGE_LOAD`

### Migration

**Remove `createAnimationScope()`:**

```ts
// Before
import { createAnimationScope } from 'astro:transitions';
// Just remove - this was internal only
```

**Replace event type checks:**

```ts
// Before
import { isTransitionBeforePreparationEvent } from 'astro:transitions/client';
if (isTransitionBeforePreparationEvent(event)) { /* ... */ }

// After
if (event.type === 'astro:before-preparation') { /* ... */ }
```

**Replace constants with strings:**

```ts
// Before
import { TRANSITION_AFTER_SWAP } from 'astro:transitions/client';
document.addEventListener(TRANSITION_AFTER_SWAP, handler);

// After
document.addEventListener('astro:after-swap', handler);
```

**Event type strings:**
- `TRANSITION_BEFORE_PREPARATION` → `'astro:before-preparation'`
- `TRANSITION_AFTER_PREPARATION` → `'astro:after-preparation'`
- `TRANSITION_BEFORE_SWAP` → `'astro:before-swap'`
- `TRANSITION_AFTER_SWAP` → `'astro:after-swap'`
- `TRANSITION_PAGE_LOAD` → `'astro:page-load'`

## Migration Checklist

- [ ] Replace `Astro.site` in `getStaticPaths()` with `import.meta.env.SITE`
- [ ] Remove `Astro.generator` usage in `getStaticPaths()`
- [ ] Replace `import.meta.env.ASSETS_PREFIX` with `build.assetsPrefix` from `astro:config/server`
- [ ] Replace `astro:schema` imports with `astro/zod`
- [ ] Replace `z` imports from `astro:content` with `astro/zod`
- [ ] Replace transitions internal exports with string literals

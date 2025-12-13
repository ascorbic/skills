# Breaking Changes

These changes may require code updates. They're not removals or deprecations, but changes to how existing features work.

## Endpoints with File Extensions

Endpoints with file extensions (e.g., `/sitemap.xml`) can no longer be accessed with a trailing slash.

### What Changed

| Endpoint | v5 | v6 |
|----------|-----|-----|
| `/sitemap.xml` | Works | Works |
| `/sitemap.xml/` | Works | **404** |

This applies regardless of your `build.trailingSlash` config.

### Migration

Remove trailing slashes from links to endpoints with file extensions:

```html
<!-- Before -->
<a href="/sitemap.xml/">Sitemap</a>
<a href="/feed.rss/">RSS Feed</a>

<!-- After -->
<a href="/sitemap.xml">Sitemap</a>
<a href="/feed.rss">RSS Feed</a>
```

Check programmatic references too:

```ts
// Before
const response = await fetch('/api/data.json/');

// After
const response = await fetch('/api/data.json');
```

## getStaticPaths() Params Must Be Strings

`getStaticPaths()` can no longer return `params` of type `number`.

### What Changed

In v5, numbers were allowed and automatically stringified.
In v6, you must explicitly use strings.

### Migration

Convert number params to strings:

```astro
---
export function getStaticPaths() {
  return [
    {
      params: {
        // Before
        // id: 1,

        // After
        id: "1",
        label: "foo",
      }
    },
    {
      params: {
        // Before
        // id: 2,

        // After
        id: "2",
        label: "bar",
      }
    },
  ];
}
---
```

### Dynamic Generation

If generating params from data:

```ts
export async function getStaticPaths() {
  const items = await fetchItems();

  return items.map((item) => ({
    params: {
      // Ensure string conversion
      id: String(item.id),
      // or
      id: item.id.toString(),
      // or use template literal
      id: `${item.id}`,
    },
    props: item,
  }));
}
```

## Content Loader Schema Function

The schema function signature for content loaders has changed.

### What Changed

If you're building a custom content loader that dynamically generates schemas, the function signature is different.

### Migration

Use `createSchema()` instead of a schema function:

```ts
// Before
import type { Loader } from 'astro/loaders';

function myLoader(): Loader {
  return {
    name: 'my-loader',
    load: async (context) => { /* ... */ },
    schema: async () => await getSchemaFromApi(),  // Old way
  };
}

// After
import type { Loader } from 'astro/loaders';
import { createTypeAlias, zodToTs } from 'zod-to-ts';

function myLoader() {
  return {
    name: 'my-loader',
    load: async (context) => { /* ... */ },
    createSchema: async () => {
      const schema = await getSchemaFromApi();
      const identifier = 'Entry';
      const { node } = zodToTs(schema, identifier);
      const typeAlias = createTypeAlias(node, identifier);

      return {
        schema,
        types: `export ${typeAlias}`
      };
    }
  } satisfies Loader;
}
```

Note: Use `satisfies Loader` instead of explicit return type for proper type inference.

## Schema Types Are Inferred

For content loaders, types are now inferred instead of generated with `zod-to-ts`.

### Migration

Use `satisfies` operator when providing a schema in a content loader:

```ts
// Before
import type { Loader } from 'astro/loaders';

function myLoader(): Loader {
  return {
    name: 'my-loader',
    load: async (context) => { /* ... */ },
    schema: z.object({ /* ... */ })
  };
}

// After
function myLoader() {
  return {
    name: 'my-loader',
    load: async (context) => { /* ... */ },
    schema: z.object({ /* ... */ })
  } satisfies Loader;
}
```

## Quick Reference

| Change | Action |
|--------|--------|
| Endpoint trailing slashes | Remove trailing slash from URLs with file extensions |
| Number params | Convert to strings in `getStaticPaths()` |
| Loader schema function | Use `createSchema()` property |
| Loader schema types | Use `satisfies Loader` pattern |

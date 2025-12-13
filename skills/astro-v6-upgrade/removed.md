# Removed Features

These features have been completely removed in Astro v6. Using them will cause build errors.

## ViewTransitions Component

The `<ViewTransitions />` component has been renamed to `<ClientRouter />`.

### Migration

```astro
---
// Before
import { ViewTransitions } from 'astro:transitions';
---
<html>
  <head>
    <ViewTransitions />
  </head>
</html>

---
// After
import { ClientRouter } from 'astro:transitions';
---
<html>
  <head>
    <ClientRouter />
  </head>
</html>
```

### handleForms Prop

The `handleForms` prop has been removed - form handling is now the default behavior:

```astro
<!-- Before -->
<ClientRouter handleForms />

<!-- After - just remove the prop -->
<ClientRouter />
```

## Astro.glob()

`Astro.glob()` has been removed. Use `import.meta.glob()` instead.

### Migration

```astro
---
// Before
const posts = await Astro.glob('./posts/*.md');

// After
const posts = Object.values(import.meta.glob('./posts/*.md', { eager: true }));
---

{posts.map((post) => (
  <li><a href={post.url}>{post.frontmatter.title}</a></li>
))}
```

### Key Differences

| `Astro.glob()` | `import.meta.glob()` |
|----------------|---------------------|
| Returns array | Returns object (use `Object.values()`) |
| Async (returns Promise) | Sync with `{ eager: true }` |
| Astro-specific | Standard Vite feature |

### Lazy Loading

For lazy loading (load on demand):

```ts
// Lazy - returns functions that load the module
const posts = import.meta.glob('./posts/*.md');

// Load a specific post
const post = await posts['./posts/hello.md']();
```

### Consider Content Collections

For content files, consider using [Content Collections](content-collections.md) instead:

```ts
// More powerful querying and type safety
import { getCollection } from 'astro:content';
const posts = await getCollection('blog');
```

## emitESMImage()

Renamed to `emitImageMetadata()`.

### Migration

```ts
// Before
import { emitESMImage } from 'astro/assets/utils';
const result = await emitESMImage(imageId, false, false);

// After
import { emitImageMetadata } from 'astro/assets/utils';
const result = await emitImageMetadata(imageId);
```

The `_watchMode` and `experimentalSvgEnabled` arguments have been removed.

## prefetch() with Option

The `with` option for the programmatic `prefetch()` function has been removed.

### Migration

```ts
// Before
prefetch('/about', { with: 'fetch' });

// After - just remove the option
prefetch('/about');
```

Astro now automatically chooses the best prefetching strategy.

## rewrite() from Actions

The `rewrite()` method has been removed from `ActionAPIContext`.

### Migration

Remove any calls to `rewrite()` in your action handlers:

```ts
// Before
export const server = {
  myAction: defineAction({
    handler: async (input, context) => {
      context.rewrite('/');  // Remove this
      // ...
    }
  })
};

// After - use custom endpoints for redirects/rewrites
```

Use custom endpoints if you need rewrite functionality.

## Actions Internals

Several internal exports have been removed from `astro:actions`:

**Removed exports:**
- `ACTION_ERROR_CODES`
- `ActionInputError`
- `appendForwardSlash`
- `astroCalledServerError`
- `callSafely`
- `deserializeActionResult`
- `formDataToObject`
- `getActionQueryString`
- `serializeActionResult`
- Types: `Actions`, `ActionAccept`, `AstroActionContext`, `SerializedActionResult`

### Migration

For `serializeActionResult` and `deserializeActionResult`, use `getActionContext()`:

```ts
// Before
import { serializeActionResult, deserializeActionResult } from 'astro:actions';

// After
import { getActionContext } from 'astro:actions';

export const onRequest = defineMiddleware(async (context, next) => {
  const { serializeActionResult, deserializeActionResult } = getActionContext(context);
  // ...
});
```

Remove any other internal imports - they were not meant for public use.

## Percent-Encoding in Routes

Files with `%25` in filenames are no longer supported for security reasons.

### Migration

Rename any route files that contain `%25`:

```bash
# Before
src/pages/test%25file.astro

# After
src/pages/test-file.astro
```

## Legacy Content Collections

See [content-collections.md](content-collections.md) for full migration guide.

Removed:
- `legacy.collections` config flag
- `src/content/config.ts` location
- `type: 'content'` / `type: 'data'` property
- `getEntryBySlug()` / `getDataEntryById()`
- `entry.slug` property
- `entry.render()` method

## Transitions Internals

Several internal exports have been removed from `astro:transitions` and `astro:transitions/client`:

**Removed:**
- `createAnimationScope()`
- `isTransitionBeforePreparationEvent()`
- `isTransitionBeforeSwapEvent()`
- `TRANSITION_BEFORE_PREPARATION`
- `TRANSITION_AFTER_PREPARATION`
- `TRANSITION_BEFORE_SWAP`
- `TRANSITION_AFTER_SWAP`
- `TRANSITION_PAGE_LOAD`

### Migration

Remove `createAnimationScope()` entirely.

For event type checking:

```ts
// Before
import { isTransitionBeforePreparationEvent } from 'astro:transitions/client';
console.log(isTransitionBeforePreparationEvent(event));

// After - check event type directly
console.log(event.type === 'astro:before-preparation');
```

For constants:

```ts
// Before
import { TRANSITION_AFTER_SWAP } from 'astro:transitions/client';
console.log(TRANSITION_AFTER_SWAP);

// After - use string literal
console.log('astro:after-swap');
```

## Experimental Flags

These experimental flags have been removed. Delete them from your config:

```js
// astro.config.mjs - Remove these
export default defineConfig({
  experimental: {
    liveContentCollections: true,     // Now stable
    preserveScriptOrder: true,         // Now default
    staticImportMetaEnv: true,         // Now default
    headingIdCompat: true,             // Now default
    failOnPrerenderConflict: true      // Use prerenderConflictBehavior
  },
});
```

For `failOnPrerenderConflict`, use the new config option:

```js
export default defineConfig({
  prerenderConflictBehavior: 'error',  // or 'warn'
});
```

## Integration/Adapter API Removals

See [integration-api.md](integration-api.md) for:
- `astro:ssr-manifest` virtual module
- `RouteData.generate()`
- `routes` on `astro:build:done` hook
- `entryPoints` on `astro:build:ssr` hook
- Old `app.render()` signature
- `app.setManifestData()`
- Content Loader `schema` function signature

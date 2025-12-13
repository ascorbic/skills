# Dependency Upgrades

Astro v6 upgrades three major dependencies that may require changes to your project.

## Node 22

Astro v6 requires **Node 22.12.0 or higher**. Node 18 and 20 are no longer supported.

### Check Your Version

```bash
node -v
# Must be v22.12.0 or higher
```

### Update Node

Using nvm:
```bash
nvm install 22
nvm use 22
```

Using Homebrew (macOS):
```bash
brew install node@22
```

### Update Deployment Environment

Check your hosting provider's documentation. Most support specifying Node version via:

1. **Dashboard setting** - Look for "Node version" in build settings
2. **`.nvmrc` file** - Create at project root:

```bash
# .nvmrc
22.12.0
```

3. **`package.json` engines** - Some hosts read this:

```json
{
  "engines": {
    "node": ">=22.12.0"
  }
}
```

## Vite 7

Astro v6 uses Vite 7 as the development server and bundler. The upgrade is automatic with `@astrojs/upgrade`.

### What to Check

If you use Vite plugins or custom Vite config, review the [Vite 7 migration guide](https://vite.dev/guide/migration).

Key changes:
- Some plugin APIs have changed
- Build output may differ slightly
- HMR patterns updated (see [integration-api.md](integration-api.md) for integration authors)

### Vite Environment API

Astro v6 uses Vite's new Environment API internally. This primarily affects:
- Integration authors (see [integration-api.md](integration-api.md))
- Custom dev toolbar apps
- Advanced HMR usage

For most users, no action needed.

## Zod 4

Astro v6 upgrades to Zod 4, which has breaking changes to schema definitions.

### Import Change

Use `astro/zod` instead of deprecated imports:

```ts
// Before (deprecated)
import { z } from 'astro:content';
import { z } from 'astro:schema';

// After
import { z } from 'astro/zod';
```

### String Format Methods

Many string format methods moved to top-level:

```ts
// Before (Zod 3)
z.string().email()
z.string().url()
z.string().uuid()
z.string().cuid()
z.string().regex(/pattern/)

// After (Zod 4)
z.email()
z.url()
z.uuid()
z.cuid()
z.string().regex(/pattern/)  // regex unchanged
```

### Error Messages

The error message API changed:

```ts
// Before (Zod 3)
z.string().min(5, { message: "Too short." });

// After (Zod 4)
z.string().min(5, { error: "Too short." });
```

The `errorMap` option is no longer supported. Use `error` property instead.

### Default Values with Transforms

In Zod 4, `.default()` must match the **output** type (after transforms), not the input type:

```ts
// Before (Zod 3) - default matched input type
const schema = z.object({
  views: z.string().transform(Number).default("0"),
});

// After (Zod 4) - default must match output type
const schema = z.object({
  views: z.string().transform(Number).default(0),
});
```

If you want the default to be parsed (old behavior), use `.prefault()`:

```ts
// Zod 4 - default is parsed through the schema
const schema = z.object({
  views: z.string().transform(Number).prefault("0"),
});
```

### Actions Schema Migration

If you use Astro Actions with Zod schemas:

```ts
// src/actions/index.ts
import { defineAction } from 'astro:actions';
import { z } from 'astro/zod';

export const server = {
  subscribe: defineAction({
    input: z.object({
      // Before (Zod 3)
      // email: z.string().email(),

      // After (Zod 4)
      email: z.email(),
    }),
    handler: async (input) => {
      // ...
    },
  }),
};
```

### Content Schema Migration

Update schemas in `content.config.ts`:

```ts
// src/content.config.ts
import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const newsletter = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/subscribers' }),
  schema: z.object({
    name: z.string(),
    // Before: z.string().email()
    email: z.email(),
    // Before: z.string().url().optional()
    website: z.url().optional(),
  }),
});
```

### Zod 4 Migration Checklist

- [ ] Update imports to `astro/zod`
- [ ] Replace `.email()`, `.url()`, `.uuid()` with top-level `z.email()`, etc.
- [ ] Change `{ message: "..." }` to `{ error: "..." }`
- [ ] Update `.default()` values to match output types
- [ ] Remove any `errorMap` usage

### Resources

- [Zod 4 Changelog](https://zod.dev/v4/changelog)
- [Zod Documentation](https://zod.dev/)

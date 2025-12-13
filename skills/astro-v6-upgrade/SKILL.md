---
name: astro-v6-upgrade
description: Guide for upgrading Astro projects from v5 to v6. Use when users mention upgrading Astro, Astro v6, Astro 6, migrating to Astro 6, or need help with Astro migration errors related to content collections, ViewTransitions, Astro.glob, Zod schemas, Node version requirements, or Content Layer API.
---

# Astro v6 Upgrade Guide

Help users migrate from Astro v5 to v6. This is a major upgrade with 40+ breaking changes.

## Quick Start

Run the upgrade command first:

```bash
# npm
npx @astrojs/upgrade

# pnpm
pnpm dlx @astrojs/upgrade

# yarn
yarn dlx @astrojs/upgrade
```

After upgrading, you may not need any code changes. If you see errors, use this guide.

## Detection

Run `scripts/detect.sh <project-path>` to scan an Astro project for patterns needing migration. The script identifies:

- Legacy content collection patterns
- Deprecated imports and APIs
- Removed features still in use
- Integration API changes

## Triage: What Applies to You?

### Everyone Must Do

1. **Node 22**: Astro v6 requires Node 22.12.0+. Check with `node -v`
2. **Vite 7**: Automatically upgraded, but check plugins for compatibility
3. **Zod 4**: Schema syntax changes if you use Zod validation

### Check Your Project

| If you use... | Read... |
|--------------|---------|
| Content collections | [content-collections.md](content-collections.md) - **Most impactful change** |
| Zod schemas in content/actions | [dependencies.md](dependencies.md) - Zod 4 syntax changes |
| `<ViewTransitions />` | [removed.md](removed.md) - Now `<ClientRouter />` |
| `Astro.glob()` | [removed.md](removed.md) - Use `import.meta.glob()` |
| Custom integrations/adapters | [integration-api.md](integration-api.md) |
| i18n routing | [changed-defaults.md](changed-defaults.md) |
| Environment variables | [changed-defaults.md](changed-defaults.md) |

## Reference Files

Load these as needed based on what applies:

| File | Contents |
|------|----------|
| [content-collections.md](content-collections.md) | Legacy Content Collections → Content Layer API migration |
| [dependencies.md](dependencies.md) | Node 22, Vite 7, Zod 4 upgrade details |
| [removed.md](removed.md) | Features removed entirely (ViewTransitions, Astro.glob, etc.) |
| [deprecated.md](deprecated.md) | Features still working but deprecated |
| [changed-defaults.md](changed-defaults.md) | Behavior changes (i18n, script order, env vars, images) |
| [breaking-changes.md](breaking-changes.md) | Code changes needed (endpoints, params, etc.) |
| [integration-api.md](integration-api.md) | Changes for integration/adapter authors |

## Common Migration Paths

### Simple Site (no content collections)

1. Upgrade Node to 22.12.0+
2. Run `npx @astrojs/upgrade`
3. Replace `Astro.glob()` with `import.meta.glob()` if used
4. Replace `<ViewTransitions />` with `<ClientRouter />` if used
5. Done

### Site Using Content Collections

1. Upgrade Node to 22.12.0+
2. Run `npx @astrojs/upgrade`
3. **Read [content-collections.md](content-collections.md)** - follow the full migration
4. Update Zod schemas per [dependencies.md](dependencies.md)
5. Check other removed/deprecated features

### Integration/Adapter Author

1. Upgrade Node to 22.12.0+
2. Run `npx @astrojs/upgrade`
3. **Read [integration-api.md](integration-api.md)** - significant API changes
4. Test with Vite 7 Environment API changes

## Error Quick Reference

| Error | Solution |
|-------|----------|
| `LegacyContentConfigError` | Rename `src/content/config.ts` → `src/content.config.ts` |
| `ContentCollectionMissingALoaderError` | Add `loader` property to collection. See [content-collections.md](content-collections.md) |
| `ContentCollectionInvalidTypeError` | Remove `type: 'content'` or `type: 'data'` from collection |
| `GetEntryDeprecationError` | Replace `getEntryBySlug()`/`getDataEntryById()` with `getEntry()` |
| `ContentSchemaContainsSlugError` | Replace `slug` with `id` in schemas and queries |
| Cannot find `ViewTransitions` | Replace with `ClientRouter` from `astro:transitions` |
| Cannot find `Astro.glob` | Use `import.meta.glob()` instead |
| Node version error | Upgrade to Node 22.12.0+ |

## Resources

- [Full Astro v6 Changelog](https://github.com/withastro/astro/blob/main/packages/astro/CHANGELOG.md)
- [Astro v6 Blog Post](https://astro.build/blog/astro-6/)
- [Vite 7 Migration Guide](https://vite.dev/guide/migration)
- [Zod 4 Changelog](https://zod.dev/v4/changelog)
- [Content Layer Deep Dive](https://astro.build/blog/content-layer-deep-dive/)

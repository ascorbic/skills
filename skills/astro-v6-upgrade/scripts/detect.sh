#!/bin/bash
# Astro v6 Migration Detection Script
# Scans an Astro project for patterns that need updating

set -e

PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Directory '$PROJECT_DIR' not found"
    exit 1
fi

echo "Scanning Astro project at: $PROJECT_DIR"
echo "=========================================="
echo ""

FOUND_ISSUES=0

# Helper function
check_pattern() {
    local pattern="$1"
    local description="$2"
    local file_types="$3"
    local reference="$4"

    local results
    results=$(grep -r -l --include="$file_types" "$pattern" "$PROJECT_DIR" 2>/dev/null || true)

    if [ -n "$results" ]; then
        FOUND_ISSUES=$((FOUND_ISSUES + 1))
        echo "[$FOUND_ISSUES] $description"
        echo "    Pattern: $pattern"
        echo "    Reference: $reference"
        echo "    Files:"
        echo "$results" | sed 's/^/        /'
        echo ""
    fi
}

echo "=== Content Collections ==="
echo ""

# Legacy content config location
if [ -f "$PROJECT_DIR/src/content/config.ts" ] || [ -f "$PROJECT_DIR/src/content/config.js" ]; then
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
    echo "[$FOUND_ISSUES] Legacy content config file location"
    echo "    Found: src/content/config.ts or .js"
    echo "    Action: Rename to src/content.config.ts"
    echo "    Reference: content-collections.md"
    echo ""
fi

# Collection type property
check_pattern "type:[[:space:]]*['\"]content['\"]" \
    "Legacy collection type: 'content'" \
    "*.ts" \
    "content-collections.md - Remove type property"

check_pattern "type:[[:space:]]*['\"]data['\"]" \
    "Legacy collection type: 'data'" \
    "*.ts" \
    "content-collections.md - Remove type property"

# Legacy query methods
check_pattern "getEntryBySlug" \
    "Deprecated: getEntryBySlug()" \
    "*.{ts,js,astro}" \
    "content-collections.md - Use getEntry() instead"

check_pattern "getDataEntryById" \
    "Deprecated: getDataEntryById()" \
    "*.{ts,js,astro}" \
    "content-collections.md - Use getEntry() instead"

# Legacy render method
check_pattern "\.render()" \
    "Possible legacy render method: entry.render()" \
    "*.{ts,js,astro}" \
    "content-collections.md - Use render(entry) function from astro:content"

# Slug property usage
check_pattern "\.slug" \
    "Possible slug property usage (now 'id')" \
    "*.{ts,js,astro}" \
    "content-collections.md - Replace .slug with .id"

echo "=== Removed Features ==="
echo ""

# ViewTransitions component
check_pattern "ViewTransitions" \
    "Removed: <ViewTransitions /> component" \
    "*.{ts,js,astro}" \
    "removed.md - Replace with <ClientRouter />"

# Astro.glob
check_pattern "Astro\.glob" \
    "Removed: Astro.glob()" \
    "*.{ts,js,astro}" \
    "removed.md - Use import.meta.glob() instead"

# emitESMImage
check_pattern "emitESMImage" \
    "Removed: emitESMImage()" \
    "*.{ts,js}" \
    "removed.md - Use emitImageMetadata() instead"

# handleForms prop
check_pattern "handleForms" \
    "Removed: handleForms prop on ClientRouter" \
    "*.{ts,js,astro}" \
    "removed.md - Remove prop (now default behavior)"

# prefetch with option
check_pattern "prefetch.*with:" \
    "Removed: prefetch() 'with' option" \
    "*.{ts,js,astro}" \
    "removed.md - Remove the 'with' option"

echo "=== Deprecated Imports ==="
echo ""

# astro:schema
check_pattern "from ['\"]astro:schema['\"]" \
    "Deprecated: astro:schema import" \
    "*.{ts,js}" \
    "deprecated.md - Use astro/zod instead"

# z from astro:content
check_pattern "{ z }.*from ['\"]astro:content['\"]" \
    "Deprecated: z from astro:content" \
    "*.{ts,js}" \
    "deprecated.md - Import z from astro/zod instead"

check_pattern "{ z," \
    "Possible deprecated z import from astro:content" \
    "*.{ts,js}" \
    "deprecated.md - Check if importing from astro:content"

echo "=== Deprecated APIs ==="
echo ""

# Astro in getStaticPaths
check_pattern "Astro\.site" \
    "Deprecated: Astro.site in getStaticPaths" \
    "*.{ts,js,astro}" \
    "deprecated.md - Use import.meta.env.SITE instead"

check_pattern "Astro\.generator" \
    "Deprecated: Astro.generator" \
    "*.{ts,js,astro}" \
    "deprecated.md - Remove usage"

# ASSETS_PREFIX
check_pattern "import\.meta\.env\.ASSETS_PREFIX" \
    "Deprecated: import.meta.env.ASSETS_PREFIX" \
    "*.{ts,js,astro}" \
    "deprecated.md - Use build.assetsPrefix from astro:config/server"

echo "=== Integration/Adapter API ==="
echo ""

# astro:ssr-manifest
check_pattern "astro:ssr-manifest" \
    "Removed: astro:ssr-manifest virtual module" \
    "*.{ts,js}" \
    "integration-api.md - Use astro:config/server instead"

# RouteData.generate
check_pattern "\.generate(" \
    "Possible RouteData.generate() usage (removed)" \
    "*.{ts,js}" \
    "integration-api.md - Remove calls to route.generate()"

# Old app.render signature
check_pattern "app\.render.*routeData.*locals" \
    "Possible old app.render() signature" \
    "*.{ts,js}" \
    "integration-api.md - Use app.render(request, { routeData, locals })"

# entryPoints on astro:build:ssr
check_pattern "entryPoints" \
    "Possible entryPoints usage (removed from astro:build:ssr)" \
    "*.{ts,js}" \
    "integration-api.md - Remove entryPoints parameter"

echo "=== Experimental Flags ==="
echo ""

check_pattern "liveContentCollections" \
    "Experimental flag: liveContentCollections (now stable)" \
    "*.{ts,js,mjs}" \
    "SKILL.md - Remove from config"

check_pattern "preserveScriptOrder" \
    "Experimental flag: preserveScriptOrder (now default)" \
    "*.{ts,js,mjs}" \
    "SKILL.md - Remove from config"

check_pattern "staticImportMetaEnv" \
    "Experimental flag: staticImportMetaEnv (now default)" \
    "*.{ts,js,mjs}" \
    "SKILL.md - Remove from config"

check_pattern "headingIdCompat" \
    "Experimental flag: headingIdCompat (now default)" \
    "*.{ts,js,mjs}" \
    "SKILL.md - Remove from config"

check_pattern "failOnPrerenderConflict" \
    "Experimental flag: failOnPrerenderConflict (replaced)" \
    "*.{ts,js,mjs}" \
    "SKILL.md - Use prerenderConflictBehavior config instead"

echo "=== Zod Schema Patterns ==="
echo ""

check_pattern "z\.string()\.email()" \
    "Zod 4 change: .email() method" \
    "*.{ts,js}" \
    "dependencies.md - Use z.email() instead"

check_pattern "z\.string()\.url()" \
    "Zod 4 change: .url() method" \
    "*.{ts,js}" \
    "dependencies.md - Use z.url() instead"

check_pattern "\.default(.*transform" \
    "Possible Zod .default() with transform issue" \
    "*.{ts,js}" \
    "dependencies.md - Default must match output type in Zod 4"

echo "=========================================="
echo ""
if [ $FOUND_ISSUES -eq 0 ]; then
    echo "No migration issues detected!"
    echo "Your project may already be compatible with Astro v6."
else
    echo "Found $FOUND_ISSUES potential migration issues."
    echo "Review each item and consult the referenced documentation."
fi
echo ""
echo "Note: This script uses pattern matching and may have false positives."
echo "Always verify findings manually."

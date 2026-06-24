#!/usr/bin/env bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: LOCKFILE, PACKAGE_MANAGER, ROOT_DIR, IS_SILENT

LOCKFILE_PATH="$ROOT_DIR/$LOCKFILE"

if [ ! -f "$LOCKFILE_PATH" ]; then
  log -cl -e -m "Error: File $LOCKFILE not found in the project root ($ROOT_DIR)\n" -slm "$IS_SILENT"
  exit 1
fi

log -ic "$ICON_PROGRESS" -m "Searching $LOCKFILE for 0.x.x packages..." -in -slm "$IS_SILENT"

if [ "$PACKAGE_MANAGER" = "npm" ]; then
  PACKAGE_INFO=$(node -e "
    const fs = require('fs');
    try {
      const lock = JSON.parse(fs.readFileSync('$LOCKFILE_PATH', 'utf8'));
      const pkgs = lock.packages || lock.dependencies || {};
      const res = new Set();
      Object.keys(pkgs).forEach(k => {
        const v = pkgs[k].version;
        if (v && v.startsWith('0.')) {
          const name = k.split('node_modules/').pop();
          if (name) res.add(name + ' ' + v);
        }
      });
      console.log([...res].join('\n'));
    } catch(e) {}
  " 2> /dev/null | sort -u)
elif [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  PACKAGE_INFO=$(grep -Eo '(@?[a-zA-Z0-9_\.\-]+)@0\.[0-9]+\.[0-9]+' "$LOCKFILE_PATH" 2> /dev/null | sed -E 's/@(0\.[0-9]+\.[0-9]+)$/ \1/' | sort -u)
else
  PACKAGE_INFO=$(awk '/^[^[:space:]]/ {pkg=$0} /^[[:space:]]*version: "?0\./ {
    ver=$2; gsub(/["\r]/, "", ver); print pkg "===" ver
  }' "$LOCKFILE_PATH" 2> /dev/null | sed -E 's/^"?(@?[^@:,]+)@.*===([^ ]+)/\1 \2/' | sort -u)
fi

if [ -z "$PACKAGE_INFO" ]; then
  log -cl -s -m "No packages with 0.x.x version found" -slm "$IS_SILENT"
  emit_meta "__SKIPPED__"
  exit 0
fi

TOTAL=$(echo "$PACKAGE_INFO" | grep -vc '^$')

if ! is_enabled "$IS_SILENT"; then
  log -cl -w -m "Found potentially unstable packages: $TOTAL"
  echo ""
  echo "$ICON_PACKAGE Packages list:"
  echo "$PACKAGE_INFO" | while read -r pkg ver; do
    if [ -n "$pkg" ]; then
      echo "  - $pkg: $ver"
    fi
  done
  echo ""
fi

#!/bin/bash

set -e

echo "🔧 Refactoring Environment usage in async blocks..."

# 1. Change function signatures from `&Environment` to `Environment`
rg --files-with-matches '&Environment' src | while read -r file; do
  sed -i 's/&Environment/Environment/g' "$file"
done

# 2. Remove unnecessary references when calling functions
rg --files-with-matches '&environment' src | while read -r file; do
  sed -i 's/&environment/environment/g' "$file"
done

# 3. Add `.clone()` where needed before tokio::spawn
rg 'tokio::spawn\(async move \{' src | while read -r line; do
  file=$(echo "$line" | cut -d: -f1)
  if ! grep -q 'let environment_clone' "$file"; then
    sed -i '/tokio::spawn(async move {/i\
let environment = environment.clone();' "$file"
  fi
done

# 4. Stage changes
git add src/**/*.rs

# 5. Commit
git commit -m "fix: pass Environment by value and clone for async move blocks"

echo "✅ Fix applied and committed."

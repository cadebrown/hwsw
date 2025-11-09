#!/usr/bin/env bash
# tools/install-brewfile-linux.sh - a fix script for installing Homebrew brewfile on Linux without sudo

export HOMEBREW_NO_INSTALL_CLEANUP=1

# TODO: option parsing?
BREWFILE="$1"

# makeshift set of seen packages
PKGS_SEEN=""
# list of packages to install, in DFS dependency order (so no brew install)
PKGS_LIST=""

# for caching dependencies, since `brew deps` is slow
DEPS_CACHE_DIR=".brewfile_deps_cache_dir"
mkdir -p "$DEPS_CACHE_DIR"

pkgs_visit() {
    local pkg="$1"

    # don't visit the same package twice
    local seen_key="$pkg;"
    if [[ "$PKGS_SEEN" == *"$seen_key"* ]]; then
        return
    fi

    # keep track before recursing
    PKGS_SEEN="$PKGS_SEEN;$seen_key"


    # get a list of all deps, caching so that
    local deps_file="$DEPS_CACHE_DIR/.deps-$pkg.txt"
    if [ ! -f "$deps_file" ] || [ ! -s "$deps_file" ]; then
        # either empty or doesn't exist, so we need to generate it
        brew deps "$pkg" 2>/dev/null > "$deps_file"
    fi

    # now, get all dependencies and recursively process them
    for dep in $(cat "$deps_file"); do
        pkgs_visit "$dep"
    done
    
    # Add to install order after all deps are processed
    PKGS_LIST="$PKGS_LIST;$pkg"
}

# now, iterate over all listed packages in the brewfile
echo "visiting all packages and dependencies in $BREWFILE ..."
# TODO: brew|cask?
for pkg in $(grep -E '^\s*(brew)' "$BREWFILE" | awk -F'"' '{print $2}'); do
    pkgs_visit "$pkg"
done

# finally, iterate and install in dependency order
echo "installing all packages in dependency order..."
for pkg in $(echo "$PKGS_LIST" | tr ';' '\n'); do
    echo "installing single package: $pkg ..."
    brew install "$pkg" --force --keep-tmp -v -v
done

echo "done!"

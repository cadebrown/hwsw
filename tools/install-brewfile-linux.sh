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
    export PKGS_SEEN="$PKGS_SEEN;$seen_key"

    echo "visiting $pkg and traversing deps..."

    # get a list of all deps, caching so that
    local deps_file="$DEPS_CACHE_DIR/.deps-$pkg.txt"
    if [ ! -f "$deps_file" ]; then
        # either empty or doesn't exist, so we need to generate it
        echo "actually running: brew deps $pkg ... "
        brew deps "$pkg" 2>/dev/null > "$deps_file"
        if [ ! -s "$deps_file" ]; then
            # if empty, add a special key so we know it went through
            echo "_no_deps_from_homebrew_" >> "$deps_file"      
        fi
    fi

    # now, get all dependencies and recursively process them
    for dep in $(cat "$deps_file"); do
        if [ "$dep" != "_no_deps_from_homebrew_" ]; then
            pkgs_visit "$dep"
        fi
    done

    # wait for all
    #wait
 
    # Add to install order after all deps are processed
    export PKGS_LIST="$PKGS_LIST;$pkg"
    echo "adding package to install list: $pkg"
}

# now, iterate over all listed packages in the brewfile
echo "visiting all packages and dependencies in $BREWFILE ..."
# TODO: brew|cask?

for pkg in $(grep -E '^\s*(brew)' "$BREWFILE" | awk -F'"' '{print $2}'); do
    pkgs_visit "$pkg"
done


# finally, iterate and install in dependency order
echo $PKGS_LIST > install-homebrew-linux.txt
echo "installing all packages in dependency order..."
for pkg in $(echo "$PKGS_LIST" | tr ';' '\n'); do
    echo "installing single package: $pkg ..."
    brew install "$pkg" --force --keep-tmp || echo "package install failed: $pkg" >> install-homebrew-linux.txt
done

echo "done!"

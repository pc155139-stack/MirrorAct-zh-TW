#!/bin/sh
# Keep UxPlay and MirrorAct on the same OpenSSL major version.
set -eu
brew_bin=$(command -v brew)
brew_prefix=$("$brew_bin" --prefix)
openssl_prefix=$("$brew_bin" --prefix openssl@3)
export PKG_CONFIG_PATH="$openssl_prefix/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
exec "$brew_prefix/bin/pkg-config" "$@"

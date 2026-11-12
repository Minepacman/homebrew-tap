#!/usr/bin/env bash
# Pone al día Casks/punto-de-venta.rb con la versión y las sumas SHA-256 de una release publicada.
#
#   scripts/actualizar-cask.sh 1.0.1                       # baja SHA256SUMS.txt de la release v1.0.1
#   scripts/actualizar-cask.sh 1.0.1 --sumas ./SHA256SUMS.txt   # usa un archivo local (lo usa el flujo de CI)
#   scripts/actualizar-cask.sh 1.0.1 --descargar           # sin SHA256SUMS: baja los dos .dmg y calcula las sumas
#
# Solo toca tres líneas del cask (version y las dos sha256); el resto se mantiene tal cual. Si la release no
# tiene el .dmg de Intel o el de Apple Silicon, no cambia nada y termina con error: el cask exige las dos sumas.
set -euo pipefail

REPO="Minepacman/Punto-Ventas"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASK="$AQUI/Casks/punto-de-venta.rb"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  echo "Uso: $0 <versión> [--sumas SHA256SUMS.txt | --descargar]" >&2
  exit 2
fi
VERSION="${VERSION#v}"
case "$VERSION" in
  *[!0-9.]*|"") echo "Versión no válida: '$VERSION' (se esperaba x.y.z; los prelanzamientos no van al cask)" >&2; exit 2 ;;
esac

SUMAS=""
DESCARGAR=false
shift
while [ $# -gt 0 ]; do
  case "$1" in
    --sumas) SUMAS="${2:-}"; shift 2 ;;
    --descargar) DESCARGAR=true; shift ;;
    *) echo "Opción desconocida: $1" >&2; exit 2 ;;
  esac
done

BASE="https://github.com/$REPO/releases/download/v$VERSION"
ARM="PuntoDeVenta-$VERSION-macos-arm64.dmg"
INTEL="PuntoDeVenta-$VERSION-macos-x64.dmg"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

sha_de_archivo() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# Busca la suma de un nombre de archivo en un SHA256SUMS.txt ("<sha>  <nombre>")
sha_en_sumas() {
  awk -v n="$2" '$2 == n || $2 == "*" n { print $1; exit }' "$1"
}

SHA_ARM=""
SHA_INTEL=""
if [ "$DESCARGAR" = false ]; then
  if [ -z "$SUMAS" ]; then
    SUMAS="$TMP/SHA256SUMS.txt"
    echo "Bajando $BASE/SHA256SUMS.txt"
    if ! curl -fsSL --retry 3 -o "$SUMAS" "$BASE/SHA256SUMS.txt"; then
      echo "No existe SHA256SUMS.txt en la release v$VERSION (¿aún no se publicó?). Prueba con --descargar." >&2
      exit 1
    fi
  fi
  [ -f "$SUMAS" ] || { echo "No encuentro $SUMAS" >&2; exit 1; }
  SHA_ARM="$(sha_en_sumas "$SUMAS" "$ARM")"
  SHA_INTEL="$(sha_en_sumas "$SUMAS" "$INTEL")"
else
  for f in "$ARM" "$INTEL"; do
    echo "Bajando $BASE/$f"
    curl -fsSL --retry 3 -o "$TMP/$f" "$BASE/$f"
  done
  SHA_ARM="$(sha_de_archivo "$TMP/$ARM")"
  SHA_INTEL="$(sha_de_archivo "$TMP/$INTEL")"
fi

for par in "arm64:$SHA_ARM" "x64:$SHA_INTEL"; do
  arq="${par%%:*}"
  sha="${par#*:}"
  if [ -z "$sha" ]; then
    echo "Falta el .dmg de $arq en la release v$VERSION: el cask necesita las dos sumas (arm64 e Intel). No se cambió nada." >&2
    exit 1
  fi
  if [ ${#sha} -ne 64 ] || [ -n "$(printf '%s' "$sha" | tr -d '0-9a-f')" ]; then
    echo "Suma SHA-256 rara para $arq: '$sha'. No se cambió nada." >&2
    exit 1
  fi
done

# Sustituye solo las tres líneas (version, sha arm, sha intel); perl está en macOS y en Ubuntu
perl -0pi -e '
  s/^(\s*version\s+")[^"]*(")/${1}'"$VERSION"'${2}/m;
  s/^(\s*sha256\s+arm:\s+")[0-9a-f]{64}(")/${1}'"$SHA_ARM"'${2}/m;
  s/^(\s*intel:\s+")[0-9a-f]{64}(")/${1}'"$SHA_INTEL"'${2}/m;
' "$CASK"

grep -q "version \"$VERSION\"" "$CASK" && grep -q "$SHA_ARM" "$CASK" && grep -q "$SHA_INTEL" "$CASK" \
  || { echo "El cask no quedó como se esperaba; revísalo a mano: $CASK" >&2; exit 1; }

echo "Casks/punto-de-venta.rb → versión $VERSION"
echo "  arm64: $SHA_ARM"
echo "  x64:   $SHA_INTEL"

# homebrew-tap

Tap de [Homebrew](https://brew.sh) con el cask de **Caja Libre** (antes «Punto de Venta»), el punto de venta libre de
escritorio para tiendas de abarrotes ([Minepacman/Punto-Ventas](https://github.com/Minepacman/Punto-Ventas)).

## Instalar en macOS

```bash
brew tap minepacman/tap
brew install --cask punto-de-venta
```

Instala `PuntoDeVenta.app` (nombre técnico; en el Dock aparece «Caja Libre») en `/Applications` (elige solo el `.dmg` de Apple Silicon o el de Intel
según tu Mac). Para actualizar: `brew upgrade --cask punto-de-venta`.

### La primera vez macOS la bloquea

La app no está firmada ni notarizada por Apple (no hay cuenta de desarrollador de pago), así que
Gatekeeper la detiene la primera vez. Dos maneras de dejarla pasar:

1. Intenta abrirla, ve a **Ajustes del Sistema → Privacidad y seguridad** y pulsa
   **«Abrir de todos modos»**.
2. O en la Terminal:

   ```bash
   xattr -dr com.apple.quarantine "/Applications/PuntoDeVenta.app"
   ```

> La opción `brew install --cask --no-quarantine` ya **no existe** en Homebrew (se retiró en
> la 4.7); por eso se documenta `xattr`.

### Desinstalar

```bash
brew uninstall --cask punto-de-venta
```

Esto quita la app pero **no** tus datos: la base de datos, la configuración y los respaldos siguen
en `~/Library/Application Support/PuntoDeVenta`. El cask no define `zap` a propósito, para que
`brew uninstall --zap` nunca borre la base de datos de una tienda por accidente. Si de verdad
quieres borrarlo todo, respalda y elimina esa carpeta a mano.

## Mantenimiento (para el dueño del repositorio)

El cask apunta a los `.dmg` de las releases de GitHub:
`https://github.com/Minepacman/Punto-Ventas/releases/download/v<versión>/PuntoDeVenta-<versión>-macos-{arm64,x64}.dmg`.

Cada release nueva requiere actualizar `version` y las dos `sha256` del cask. Hay dos caminos:

- **Automático**: el flujo `release.yml` del repositorio principal, al publicar una versión final,
  ejecuta `scripts/actualizar-cask.sh` y hace push a este tap **si** existe el secreto `TAP_TOKEN`
  (token de grano fino con permiso *Contents: read and write* solo sobre `homebrew-tap`).
- **A mano**, una vez publicada la release (necesita `curl` y `perl`, ambos vienen en macOS):

  ```bash
  scripts/actualizar-cask.sh 1.0.1      # baja SHA256SUMS.txt de la release y reescribe el cask
  git commit -am "punto-de-venta 1.0.1" && git push
  ```

  Si la release no tuviera `SHA256SUMS.txt`, `scripts/actualizar-cask.sh 1.0.1 --descargar` baja los
  dos `.dmg` y calcula las sumas. Los prelanzamientos (`1.1.0-beta.1`) no van al cask.

Mientras las `sha256` del cask sean ceros (release todavía no construida), `brew install` falla con
"SHA256 mismatch": es lo esperado hasta correr el script.

Comprobar el cask en local: `brew style Casks/punto-de-venta.rb` y, con el tap instalado,
`brew audit --cask --online punto-de-venta`.

## Canales oficiales

Caja Libre es gratuito; este tap, el sitio <https://minepacman.github.io/Punto-Ventas/> y las releases de
<https://github.com/Minepacman/Punto-Ventas> son los únicos canales del autor (Elias Oziel Sánchez Fernández).
Cada `.dmg` tiene su suma en `SHA256SUMS.txt` y una attestation de procedencia de GitHub
(`gh attestation verify <archivo> --repo Minepacman/Punto-Ventas`). El token del cask sigue siendo
`punto-de-venta` para que las instalaciones existentes se actualicen sin cambios.

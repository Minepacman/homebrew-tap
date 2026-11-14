cask "punto-de-venta" do
  arch arm: "arm64", intel: "x64"

  version "1.0.4"
  # Sumas provisionales (la release aún no existía): las reemplaza scripts/actualizar-cask.sh
  sha256 arm:   "7e99d7677f4b990a103fb5848ad9526917003ece19e71ca4098ea8a382eaae8e",
         intel: "590d6554f02f1cece15307d8a3154f2b458f4f94a2e584001e2181689fd6ed16"

  url "https://github.com/Minepacman/Punto-Ventas/releases/download/v#{version}/PuntoDeVenta-#{version}-macos-#{arch}.dmg"
  name "Caja Libre"
  desc "Punto de venta libre para tiendas de abarrotes (antes Punto de Venta)"
  homepage "https://minepacman.github.io/Punto-Ventas/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "PuntoDeVenta.app"

  caveats <<~EOS
    PuntoDeVenta.app no está firmada ni notarizada por Apple, así que la primera vez
    macOS la bloqueará. Cualquiera de estas dos opciones la deja pasar:

      1. Ajustes del Sistema → Privacidad y seguridad → «Abrir de todos modos»
         (justo después del primer intento de abrirla).
      2. En la Terminal:  xattr -dr com.apple.quarantine "/Applications/PuntoDeVenta.app"

    Tus datos (base de datos, configuración y respaldos) viven en
    ~/Library/Application Support/PuntoDeVenta y NO se borran al desinstalar.
  EOS

  # A propósito NO hay "zap": ~/Library/Application Support/PuntoDeVenta contiene la base de datos de
  # la tienda y `brew uninstall --zap` la borraría sin preguntar. Para borrarlo todo, respalda primero
  # y luego elimina esa carpeta a mano.
end

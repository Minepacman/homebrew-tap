cask "punto-de-venta" do
  arch arm: "arm64", intel: "x64"

  version "1.0.3"
  # Sumas provisionales (la release aún no existía): las reemplaza scripts/actualizar-cask.sh
  sha256 arm:   "91f66896a4218254a08f7831a5f27b7e9adc63db4859aa8321d4e5c3eb805fa2",
         intel: "355787d415e612eabefd6b01458c1a6c6c743aab5edbc46795408e278d64a9fe"

  url "https://github.com/Minepacman/Punto-Ventas/releases/download/v#{version}/PuntoDeVenta-#{version}-macos-#{arch}.dmg"
  name "Punto de Venta"
  desc "Caja registradora de escritorio para tiendas de abarrotes"
  homepage "https://github.com/Minepacman/Punto-Ventas"

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

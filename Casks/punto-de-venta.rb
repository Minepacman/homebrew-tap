cask "punto-de-venta" do
  arch arm: "arm64", intel: "x64"

  version "1.0.2"
  # Sumas provisionales (la release aún no existía): las reemplaza scripts/actualizar-cask.sh
  sha256 arm:   "8e907b2e45f33571e2f7f53a899113d177fe0b437e19561510a46c119f54b1a7",
         intel: "906fd3ff7b53e036aecefc457c9f44b612d1cf555c7df93339d35f5592e3a8c3"

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

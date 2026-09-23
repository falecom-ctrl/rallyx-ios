import UIKit
import Capacitor

/// Registra os plugins proprios do app (nao vem de pacote npm).
class MainViewController: CAPBridgeViewController {
    override func capacitorDidLoad() {
        bridge?.registerPluginInstance(ShareImagePlugin())
    }
}

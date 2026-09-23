import Foundation
import UIKit
import Capacitor

/// Compartilhar / salvar uma IMAGEM gerada pela pagina (canvas -> base64) — equivalente ao
/// ShareImagePlugin.java do Android. O WKWebView nao compartilha arquivos nem baixa "data:".
///
/// JS (pagina remota): window.Capacitor.Plugins.ShareImage.share({ base64, filename, instagram })
///                     window.Capacitor.Plugins.ShareImage.saveToGallery({ base64, filename })
@objc(ShareImagePlugin)
public class ShareImagePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "ShareImagePlugin"
    public let jsName = "ShareImage"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "share", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveToGallery", returnType: CAPPluginReturnPromise),
    ]

    private var salvarCall: CAPPluginCall?

    private func imagem(_ call: CAPPluginCall) -> UIImage? {
        var b64 = call.getString("base64") ?? ""
        if b64.hasPrefix("data:"), let virgula = b64.firstIndex(of: ",") {
            b64 = String(b64[b64.index(after: virgula)...])
        }
        guard let dados = Data(base64Encoded: b64, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: dados)
    }

    /// Abre a folha de compartilhar do iOS (Instagram, WhatsApp, Salvar imagem...).
    /// No iOS nao existe "ir direto pro Instagram" com imagem sem SDK proprio; a folha ja lista o Instagram.
    @objc func share(_ call: CAPPluginCall) {
        guard let img = imagem(call) else {
            call.reject("Imagem invalida")
            return
        }
        DispatchQueue.main.async {
            let vc = UIActivityViewController(activityItems: [img], applicationActivities: nil)
            if let pop = vc.popoverPresentationController, let view = self.bridge?.viewController?.view {
                pop.sourceView = view // iPad exige ancora
                pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                pop.permittedArrowDirections = []
            }
            self.bridge?.viewController?.present(vc, animated: true) {
                call.resolve(["destino": "seletor"])
            }
        }
    }

    /// Salva a imagem na galeria (permissao NSPhotoLibraryAddUsageDescription no Info.plist).
    @objc func saveToGallery(_ call: CAPPluginCall) {
        guard let img = imagem(call) else {
            call.reject("Imagem invalida")
            return
        }
        salvarCall = call
        DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.aoSalvar(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc private func aoSalvar(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard let call = salvarCall else { return }
        salvarCall = nil
        if let error = error {
            call.reject("Falha ao salvar na galeria: \(error.localizedDescription)")
        } else {
            call.resolve()
        }
    }
}

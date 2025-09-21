import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
    var webVC: WebViewController? = nil
    let bridge = AppBridge()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.prepareBridgeIfPossible()
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func prepareBridgeIfPossible() {
        guard
            let (window, controller) = resolveFlutterViewController(),
            let webVC = provideWebViewController()
        else {
            return
        }

        bridge.initiate(controller: controller, window: window, webVC: webVC)
    }

    private func provideWebViewController() -> WebViewController? {
        if let webVC {
            return webVC
        }

        guard
            let controller = UIStoryboard(
                name: "Main",
                bundle: nil
            ).instantiateViewController(withIdentifier: "WebViewController") as? WebViewController
        else {
            return nil
        }

        controller.loadViewIfNeeded()
        webVC = controller
        return controller
    }

    private func resolveFlutterViewController() -> (UIWindow, FlutterViewController)? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if let flutterController = window.rootViewController as? FlutterViewController {
                    return (window, flutterController)
                }
            }
        }

        return nil
    }
}

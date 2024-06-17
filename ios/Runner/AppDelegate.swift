import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var webVC: WebViewController? = nil
    let bridge = AppBridge()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        webVC = UIStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateViewController(withIdentifier: "WebViewController") as? WebViewController

        webVC?.viewDidLoad()
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        if let window = window, let webVC = webVC {
            bridge.initiate(controller: controller, window: window, webVC: webVC)
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

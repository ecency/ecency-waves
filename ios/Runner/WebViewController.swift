//
//  WebViewController.swift
//  Runner
//
//  Created by Sagar on 17/06/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    let app = "app"

    let config = WKWebViewConfiguration()
    let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
    var webView: WKWebView?
    var didFinish = false
    var handlers: [String: ((String) -> Void)] = [: ]

    override func viewDidLoad() {
        super.viewDidLoad()
        config.userContentController.add(self, name: app)
        webView = WKWebView(frame: rect, configuration: config)
        webView?.navigationDelegate = self
        //        #if DEBUG
        if #available(iOS 16.4, *) {
            self.webView?.isInspectable = true
        }
        //        #endif
        guard
            let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "public")
        else { return }
        let dir = url.deletingLastPathComponent()
        webView?.loadFileURL(url, allowingReadAccessTo: dir)
    }
    private func js(_ s: String?) -> String {
        guard let s = s else { return "" }
        return s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
    }

    func runThisJS(
        id: String,
        jsCode: String,
        handler: @escaping (String) -> Void
    ) {
        handlers[id] = handler
        OperationQueue.main.addOperation { [weak self] in
            let call = "runThisJS('\(self?.js(jsCode) ?? "")','\(self?.js(id) ?? "")');"
            self?.webView?.evaluateJavaScript(call, completionHandler: nil)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinish = true
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == app else { return }
        guard let dict = message.body as? [String: AnyObject] else { return }
        guard let data = dict["data"] as? String else { return }
        guard let id = dict["id"] as? String else { return }
        guard let handler = handlers[id] else { return }
        handler(data)
        handlers[id] = nil
    }
}

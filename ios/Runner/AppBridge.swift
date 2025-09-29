//
//  AppBridge.swift
//  Runner
//

import Foundation
import UIKit
import Flutter

final class AppBridge: NSObject {
    var window: UIWindow?
    var webVC: WebViewController?
    var controller: FlutterViewController?

    func initiate(
        controller: FlutterViewController,
        window: UIWindow,
        webVC: WebViewController
    ) {
        self.window = window
        self.webVC = webVC
        self.controller = controller

        let bridgeChannel = FlutterMethodChannel(
            name: "bridge",
            binaryMessenger: controller.binaryMessenger
        )

        bridgeChannel.setMethodCallHandler { [weak self] call, result in
            guard
                let args = call.arguments as? [String: Any],
                let id = args["id"] as? String
            else {
                debugPrint("bridge: missing id")
                result(FlutterMethodNotImplemented)
                return
            }
            guard let webVC = self?.webVC else {
                debugPrint("bridge: WebViewController not set")
                result(FlutterMethodNotImplemented)
                return
            }

            // Helper to escape single-quoted JS string literals
            func jsEscape(_ s: String?) -> String {
                guard var t = s else { return "" }
                t = t.replacingOccurrences(of: "\\", with: "\\\\")
                t = t.replacingOccurrences(of: "'", with: "\\'")
                t = t.replacingOccurrences(of: "\n", with: "\\n")
                t = t.replacingOccurrences(of: "\r", with: "")
                return t
            }

            // Helper to stringify Swift collections to JSON for JS literals
            func toJSONLiteral(_ obj: Any) -> String {
                if JSONSerialization.isValidJSONObject(obj),
                   let data = try? JSONSerialization.data(withJSONObject: obj, options: []),
                   let s = String(data: data, encoding: .utf8) {
                    return s
                }
                // Fallback to empty JSON
                return "[]"
            }

            switch call.method {
            case "runThisJS":
                guard let jsCode = args["jsCode"] as? String else {
                    debugPrint("bridge.runThisJS: jsCode missing")
                    result(FlutterMethodNotImplemented)
                    return
                }
                // Call the wrapper in index.html: runThisJS(code, id)
                let js = "runThisJS('\(jsEscape(jsCode))','\(jsEscape(id))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "doWeHaveHiveKeychainExtension":
                let js = "doWeHaveHiveKeychainExtension('\(jsEscape(id))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "signInWithHiveKeychain":
                guard
                    let username = args["username"] as? String,
                    let message  = args["message"]  as? String
                else {
                    debugPrint("bridge.signInWithHiveKeychain: missing username/message")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let js = "signInWithHiveKeychain('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(message))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "getRedirectUriData":
                guard let username = args["username"] as? String else {
                    debugPrint("bridge.getRedirectUriData: username missing")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let js = "getRedirectUriData('\(jsEscape(id))','\(jsEscape(username))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "getDecryptedHASToken":
                guard
                    let username     = args["username"]     as? String,
                    let encryptedData = args["encryptedData"] as? String,
                    let authKey      = args["authKey"]      as? String
                else {
                    debugPrint("bridge.getDecryptedHASToken: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let js = "getDecryptedHASToken('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(encryptedData))','\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "validatePostingKey":
                guard
                    let username  = args["username"]  as? String,
                    let postingKey = args["postingKey"] as? String,
                    let account    = args["account"]    as? String
                else {
                    debugPrint("bridge.validatePostingKey: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let js = "validatePostingKey('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(postingKey))','\(jsEscape(account))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "commentOnContent":
                guard
                    let username       = args["username"]       as? String,
                    let parentAuthor   = args["author"]         as? String,  // parent/root author
                    let parentPermlink = args["parentPermlink"] as? String,
                    let permlink       = args["permlink"]       as? String,
                    let commentB64     = args["comment"]        as? String,  // base64 body
                    let tags           = args["tags"]           as? [String],
                    let postingKey     = args["postingKey"]     as? String,
                    let token          = args["token"]          as? String,
                    let authKey        = args["authKey"]        as? String
                else {
                    debugPrint("bridge.commentOnContent: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let tagsJson = toJSONLiteral(tags) // JSON array literal (e.g., ["waves","ecency"])
                // Note: tagsJson is injected as a string (function expects tagsJson string)
                let js = "commentOnContent('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(parentAuthor))','\(jsEscape(parentPermlink))','\(jsEscape(permlink))','\(jsEscape(commentB64))','\(jsEscape(tagsJson))','\(jsEscape(postingKey))','\(jsEscape(token))','\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "voteContent":
                guard
                    let username  = args["username"]  as? String,
                    let author    = args["author"]    as? String,
                    let permlink  = args["permlink"]  as? String,
                    let weight    = args["weight"]    as? Int,
                    let postingKey = args["postingKey"] as? String,
                    let token     = args["token"]     as? String,
                    let authKey   = args["authKey"]   as? String
                else {
                    debugPrint("bridge.voteContent: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                // weight is a number literal (no quotes)
                let js = "voteContent('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(author))','\(jsEscape(permlink))',\(weight),'\(jsEscape(postingKey))','\(jsEscape(token))','\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "castPollVote":
                guard
                    let username  = args["username"]  as? String,
                    let pollId    = args["pollId"]    as? String,
                    let choices   = args["choices"]   as? [Int],
                    let postingKey = args["postingKey"] as? String,
                    let token     = args["token"]     as? String,
                    let authKey   = args["authKey"]   as? String
                else {
                    debugPrint("bridge.castPollVote: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                // Inject choices as a real JS array literal (NO quotes)
                let choicesLiteral = toJSONLiteral(choices) // e.g., [0,2]
                let js = "castPollVote('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(pollId))',\(choicesLiteral),'\(jsEscape(postingKey))','\(jsEscape(token))','\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "transfer":
                guard
                    let username  = args["username"]  as? String,
                    let recipient = args["to"]        as? String,
                    let amount    = args["amount"]    as? String,
                    let asset     = args["asset"]     as? String,
                    let postingKey = args["postingKey"] as? String
                else {
                    debugPrint("bridge.transfer: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let memo    = args["memo"] as? String ?? ""
                let token   = args["token"] as? String ?? ""
                let authKey = args["authKey"] as? String ?? ""
                let js = "transfer('\\(jsEscape(id))','\\(jsEscape(username))','\\(jsEscape(recipient))','\\(jsEscape(amount))','\\(jsEscape(asset))','\\(jsEscape(memo))','\\(jsEscape(postingKey))','\\(jsEscape(token))','\\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "muteUser":
                guard
                    let username  = args["username"]  as? String,
                    let author    = args["author"]    as? String,
                    let postingKey = args["postingKey"] as? String,
                    let token     = args["token"]     as? String,
                    let authKey   = args["authKey"]   as? String,
                    let mute      = args["mute"]      as? Bool
                else {
                    debugPrint("bridge.muteUser: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let muteLiteral = mute ? "true" : "false"
                let js = "muteUser('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(author))',\(muteLiteral),'\(jsEscape(postingKey))','\(jsEscape(token))','\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            case "followUser":
                guard
                    let username  = args["username"]  as? String,
                    let author    = args["author"]    as? String,
                    let postingKey = args["postingKey"] as? String,
                    let token     = args["token"]     as? String,
                    let authKey   = args["authKey"]   as? String,
                    let follow    = args["follow"]     as? Bool
                else {
                    debugPrint("bridge.followUser: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let followLiteral = follow ? "true" : "false"
                let followJs = "followUser('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(author))',\(followLiteral),'\(jsEscape(postingKey))','\(jsEscape(token))','\(jsEscape(authKey))');"
                webVC.runThisJS(id: id, jsCode: followJs) { text in result(text) }

            case "getImageUploadProofWithPostingKey":
                guard
                    let username  = args["username"]  as? String,
                    let postingKey = args["postingKey"] as? String
                else {
                    debugPrint("bridge.getImageUploadProofWithPostingKey: missing params")
                    result(FlutterMethodNotImplemented)
                    return
                }
                let js = "getImageUploadProofWithPostingKey('\(jsEscape(id))','\(jsEscape(username))','\(jsEscape(postingKey))');"
                webVC.runThisJS(id: id, jsCode: js) { text in result(text) }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

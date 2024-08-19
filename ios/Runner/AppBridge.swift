//
//  AppBridge.swift
//  Runner
//
//  Created by Sagar on 17/06/24.
//

import Foundation
import UIKit
import Flutter

class AppBridge: NSObject {
    var window: UIWindow? = nil
    var webVC: WebViewController? = nil
    var controller: FlutterViewController? = nil

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

        bridgeChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard
                let arguments = call.arguments as? NSDictionary,
                let id = arguments ["id"] as? String
            else {
                debugPrint("Identifier for the flutter platform call not found")
                result(FlutterMethodNotImplemented)
                return
            }
            guard
                let webVC = self?.webVC
            else {
                debugPrint("WebView Controller is not set")
                result(FlutterMethodNotImplemented)
                return
            }
            switch (call.method) {
                case "runThisJS":
                    guard
                        let jsCode = arguments ["jsCode"] as? String
                    else {
                        debugPrint("jsCode is not set")
                        return result(FlutterMethodNotImplemented)
                    }
                    let js = "runThisJS(\"\(jsCode)\",\"\(id)\");"
                    debugPrint(js)
                    webVC.runThisJS(
                        id: id,
                        jsCode: js
                    ) { text in result(text) }
                case "doWeHaveHiveKeychainExtension":
                    webVC.runThisJS(
                        id: id,
                        jsCode: "doWeHaveHiveKeychainExtension('\(id)');"
                    ) { text in result(text) }
                case "signInWithHiveKeychain":
                    guard
                        let username = arguments ["username"] as? String,
                        let message = arguments ["message"] as? String
                    else {
                        debugPrint("username & message are not set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "signInWithHiveKeychain('\(id)', '\(username)','\(message)');"
                    ) { text in result(text) }
                case "getRedirectUriData":
                    guard
                        let username = arguments ["username"] as? String
                    else {
                        debugPrint("username is not set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "getRedirectUriData('\(id)', '\(username)');"
                    ) { text in result(text) }
                case "getDecryptedHASToken":
                    guard
                        let username = arguments ["username"] as? String,
                        let encryptedData = arguments ["encryptedData"] as? String,
                        let authKey = arguments ["authKey"] as? String
                    else {
                        debugPrint("username & encryptedData & authKey are not set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "getDecryptedHASToken('\(id)', '\(username)', '\(encryptedData)', '\(authKey)');"
                    ) { text in result(text) }
                case "validatePostingKey":
                    guard
                        let username = arguments ["username"] as? String,
                        let postingKey = arguments ["postingKey"] as? String
                    else {
                        debugPrint("username & postingKey are not set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "validatePostingKey('\(id)', '\(username)', '\(postingKey)');"
                    ) { text in result(text) }
                case "commentOnContent":
                    guard
                        let username = arguments ["username"] as? String,
                        let author = arguments ["author"] as? String,
                        let parentPermlink = arguments ["parentPermlink"] as? String,
                        let permlink = arguments ["permlink"] as? String,
                        let comment = arguments ["comment"] as? String,
                        let postingKey = arguments ["postingKey"] as? String,
                        let token = arguments ["token"] as? String,
                        let authKey = arguments ["authKey"] as? String
                    else {
                        debugPrint("username, author, parentPermlink, permlink, comment, postingKey, token, authKey - are note set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "commentOnContent('\(id)','\(username)', '\(author)', '\(parentPermlink)', '\(permlink)', '\(comment)', '\(postingKey)', '\(token)', '\(authKey)');"
                    ) { text in result(text) }
                case "voteContent":
                    guard
                        let username = arguments ["username"] as? String,
                        let author = arguments ["author"] as? String,
                        let permlink = arguments ["permlink"] as? String,
                        let weight = arguments ["weight"] as? Int,
                        let postingKey = arguments ["postingKey"] as? String,
                        let token = arguments ["token"] as? String,
                        let authKey = arguments ["authKey"] as? String
                    else {
                        debugPrint("username, author, permlink, weight, postingKey, token, authKey - are note set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "voteContent('\(id)','\(username)', '\(author)', '\(permlink)', '\(weight)', '\(postingKey)', '\(token)', '\(authKey)');"
                    ) { text in result(text) }
                case "castPollVote":
                    guard
                        let username = arguments ["username"] as? String,
                        let pollId = arguments ["pollId"] as? String,
                        let choices = arguments ["choices"] as? [Int],
                        let postingKey = arguments ["postingKey"] as? String,
                        let token = arguments ["token"] as? String,
                        let authKey = arguments ["authKey"] as? String
                    else {
                        debugPrint("username, pollId, choices, postingkey, token, authKey - are note set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "castPollVote('\(id)','\(username)', '\(pollId)', '\(choices)', '\(postingKey)', '\(token)', '\(authKey)');"
                    ) { text in result(text) }
                case "muteUser":
                    guard
                        let username = arguments ["username"] as? String,
                        let author = arguments ["author"] as? String,
                        let postingKey = arguments ["postingKey"] as? String,
                        let token = arguments ["token"] as? String,
                        let authKey = arguments ["authKey"] as? String
                    else {
                        debugPrint("username, author, postingKey, token, authKey - are note set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "muteUser('\(id)','\(username)', '\(author)', '\(postingKey)', '\(token)', '\(authKey)');"
                    ) { text in result(text) }
                case "getImageUploadProofWithPostingKey":
                    guard
                        let username = arguments ["username"] as? String,
                        let postingKey = arguments ["postingKey"] as? String
                    else {
                        debugPrint("username & postingKey are not set")
                        return result(FlutterMethodNotImplemented)
                    }
                    webVC.runThisJS(
                        id: id,
                        jsCode: "getImageUploadProofWithPostingKey('\(id)', '\(username)', '\(postingKey)');"
                    ) { text in result(text) }
                default:
                    result(FlutterMethodNotImplemented)
            }
        })
    }
}

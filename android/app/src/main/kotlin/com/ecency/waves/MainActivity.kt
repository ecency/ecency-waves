package com.ecency.waves

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import android.os.Build
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.webkit.WebViewAssetLoader
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var webView: WebView? = null
    var handlers: MutableMap<String, MethodChannel.Result> = mutableMapOf()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (webView == null) {
            setupView()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "bridge"
        ).setMethodCallHandler { call, result ->
            val id = call.argument<String?>("id")
            val username = call.argument<String?>("username")
            val message = call.argument<String?>("message")
            val encryptedData = call.argument<String?>("encryptedData")
            val authKey = call.argument<String?>("authKey")
            val token = call.argument<String?>("token")
            val postingKey = call.argument<String?>("postingKey")
            val author = call.argument<String?>("author")
            val permlink = call.argument<String?>("permlink")
            val parentPermlink = call.argument<String?>("parentPermlink")
            val comment = call.argument<String?>("comment")
            val weight = call.argument<Int?>("weight")
            val pollId = call.argument<String?>("pollId")
            val choices = call.argument<IntArray?>("choices")
            val tags = call.argument<StringArray?>("tags")
            
            if (id == null) {
                result.error(
                    "UNAVAILABLE",
                    "Identifier for the flutter platform call not found",
                    null
                )
                return@setMethodCallHandler
            }
            handlers[id] = result
            val jsCode = call.argument<String?>("jsCode")
            if (call.method == "runThisJS" && jsCode != null) {
                webView?.evaluateJavascript(
                    "runThisJS(\"$jsCode\", \"$id\");",
                    null
                )
            } else if (call.method == "doWeHaveHiveKeychainExtension") {
                webView?.evaluateJavascript(
                    "doWeHaveHiveKeychainExtension('$id');",
                    null
                )
            } else if (call.method == "signInWithHiveKeychain" && username != null && message != null) {
                webView?.evaluateJavascript(
                    "signInWithHiveKeychain('$id','$username','$message');",
                    null
                )
            } else if (call.method == "getRedirectUriData" && username != null) {
                webView?.evaluateJavascript(
                    "getRedirectUriData('$id', '$username');",
                    null
                )
            } else if (call.method == "getDecryptedHASToken" && username != null && encryptedData != null && authKey != null) {
                webView?.evaluateJavascript(
                    "getDecryptedHASToken('$id', '$username', '$encryptedData', '$authKey');",
                    null
                )
            } else if (call.method == "validatePostingKey" && username != null && postingKey != null) {
                webView?.evaluateJavascript(
                    "validatePostingKey('$id', '$username', '$postingKey');",
                    null
                )
            } else if (call.method == "commentOnContent" && username != null && author != null
                && parentPermlink != null && permlink != null && comment != null && postingKey != null && token != null
                && authKey != null ) {
                webView?.evaluateJavascript(
                    "commentOnContent('$id','$username', '$author', '$parentPermlink', '$permlink', '$comment', '$tags',  '$postingKey', '$token', '$authKey');",
                    null
                )
            } else if (call.method == "voteContent" && username != null && author != null
                && permlink != null && weight != null && postingKey != null && token != null
                && authKey != null ) {
                webView?.evaluateJavascript(
                    "voteContent('$id','$username', '$author', '$permlink', '$weight', '$postingKey', '$token', '$authKey');",
                    null
                )
            } 
            else if (call.method == "castPollVote" && username != null && pollId != null
                && choices != null && postingKey != null && token != null
                && authKey != null ) {
                webView?.evaluateJavascript(
                    "castPollVote('$id','$username', '$pollId', '$choices', '$postingKey', '$token', '$authKey');",
                    null
                )
            } else if (call.method == "getImageUploadProofWithPostingKey" && username != null && postingKey != null) {
                webView?.evaluateJavascript(
                    "getImageUploadProofWithPostingKey('$id', '$username', '$postingKey');",
                    null
                )
            } else if (call.method == "muteUser" && username != null && author != null
                && postingKey != null && token != null && authKey != null ) {
                webView?.evaluateJavascript(
                    "muteUser('$id','$username', '$author', '$postingKey', '$token', '$authKey');",
                    null
                )
            } 
    }
}

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupView() {
        val params = FrameLayout.LayoutParams(0, 0)
        webView = WebView(this)
        val decorView = this.window.decorView as FrameLayout
        decorView.addView(webView, params)
        webView?.visibility = View.GONE
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.domStorageEnabled = true
//        webView?.webChromeClient = WebChromeClient()
        WebView.setWebContentsDebuggingEnabled(true)
        val assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()
        val client: WebViewClient = object : WebViewClient() {
            @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
            override fun shouldInterceptRequest(
                view: WebView,
                request: WebResourceRequest
            ): WebResourceResponse? {
                return assetLoader.shouldInterceptRequest(request.url)
            }

            override fun shouldInterceptRequest(
                view: WebView,
                url: String
            ): WebResourceResponse? {
                return assetLoader.shouldInterceptRequest(Uri.parse(url))
            }
        }
        webView?.webViewClient = client
        webView?.addJavascriptInterface(WebAppInterface(this), "Android")
        webView?.loadUrl("https://appassets.androidplatform.net/assets/index.html")
    }
}

class WebAppInterface(private val mContext: Context) {
    @JavascriptInterface
    fun postMessage(message: String, id: String) {
        val main = mContext as? MainActivity ?: return
        main.handlers[id]?.success(message)
        main.handlers.remove(id)
    }
}

data class JSEvent(
    var id: String,
)


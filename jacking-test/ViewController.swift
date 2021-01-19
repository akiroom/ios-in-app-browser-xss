//
//  ViewController.swift
//  jacking-test
//
//  Created by Hiroki Akiyama on 2021/01/19.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        // JavaScriptで取得したキーイベントをすべてselfにpostするための
        // JavaScriptをWKWebViewに仕込む
        let userController:WKUserContentController = WKUserContentController()
        let js:String = """
            document.onkeyup = function(event) {
                var message = {'key': event.key};
                window.webkit.messageHandlers.keyUpHandler.postMessage(message);
                
                // WKWebViewのコンソールに出力
                console.log('テスト', event);
            }
        """
        let userScript:WKUserScript =  WKUserScript(
            source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false
        )
        userController.addUserScript(userScript)
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(self, contentWorld: WKContentWorld.page, name: "keyUpHandler")
        
        // https://twitter.com/loginを開く
        // (アプリ内ブラウザでSNSログインする状況を想定)
        guard let url: URL = URL(string: "https://twitter.com/") else { return }
        let request = URLRequest.init(url: url)
        webView.load(request)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "keyUpHandler" {
            // JavaScriptからpostされたメッセージをXcodeのコンソールに出力
            print(message.body)
        }
    }
}

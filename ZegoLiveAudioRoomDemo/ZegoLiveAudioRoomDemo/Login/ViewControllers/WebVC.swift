//
//  WebVC.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2022/1/11.
//

import UIKit
import WebKit

class WebVC: UIViewController {

    
    lazy var webView: WKWebView = {
        let web = WKWebView()
        web.navigationDelegate = self
        web.uiDelegate = self
        return web
    }()
    
    var urlStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(backItemClick(_:)))
        self.navigationItem.leftBarButtonItem = backItem
        
        // Do any additional setup after loading the view.
        let y = view.safeAreaInsets.top
        webView.frame = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(webView)
        
        if let urlStr = urlStr,
           let url = URL(string: urlStr) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc
    func backItemClick(_ item: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WebVC : WKNavigationDelegate, WKUIDelegate {
    
}

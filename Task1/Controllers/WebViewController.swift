//
//  WebViewController.swift
//  Task1
//
//  Created by user132392 on 11/15/17.
//  Copyright © 2017 user132392. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pageURL = URL(string: url!) {
            let request: URLRequest = URLRequest(url: pageURL)
            self.webView.load(request)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

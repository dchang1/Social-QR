//
//  InstagramViewController.swift
//  Social-QR
//
//  Created by David Chang on 8/2/17.
//  Copyright © 2017 David Chang. All rights reserved.
//

import UIKit

class InstagramViewController: UIViewController, UIWebViewDelegate {
    

    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    public var success : ((URLRequest) -> Void)?
    public var presentVC : SettingsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginWebView.delegate = self
        unSignedRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        loginWebView.loadRequest(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        print("Instagram authentication token ==", authToken)
        defaults.set(authToken, forKey: "instagram")
    }

    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
            
        if requestURLString.contains("access_token") {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            let dataURL = String("https://api.instagram.com/v1/users/self/?access_token=" + (defaults.object(forKey: "instagram") as! String))
            let url = URL(string: dataURL!)
            URLSession.shared.dataTask(with:url!) {(data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                        let alldata = parsedData["data"] as! [String:Any]
                        
                        print(alldata)
                        
                        let userID = alldata["id"] as! String
                        print(userID)
                        defaults.set((defaults.object(forKey: "contacts") as! String) + ", " + (defaults.object(forKey: "instagramID") as! String) + ", " + (defaults.object(forKey: "twitterID") as! String), forKey: "code")
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }.resume()
            dismiss(animated: true, completion: nil)
            return false;
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = false
        loginIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = true
        loginIndicator.stopAnimating()
        presentVC?.present(self, animated: true, completion: nil)

    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewDidFinishLoad(webView)
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

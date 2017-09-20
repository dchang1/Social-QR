//
//  CameraViewController.swift
//  Social-QR
//
//  Created by David Chang on 7/28/17.
//  Copyright © 2017 David Chang. All rights reserved.
//

import UIKit
import AVFoundation
import Contacts
import TwitterKit

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var messageLabel: UILabel!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var isAlertViewShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get an instance of the AVCaptureDevice class to initalize a device object and provide video as
        //media type parameter
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            //get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            //Initialize captureSession object
            captureSession = AVCaptureSession()
            
            //Set input device on capture session
            captureSession?.addInput(input)
            
            //Initialize a AVCaptureMetadataOutput object and set it as the output device to
            //capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            //Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            //Initialize the video preview layer and add it as a sublayer to the viewPreview views layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            //Start video capture
            captureSession?.startRunning()
            view.bringSubview(toFront: messageLabel)
            
            //Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            //If error occurs, print it out and do not continue
            print(error)
            return
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
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        //Check if the metadataObjects array is not null and it contains at least one object
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        //Get metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            //If the found metadata is equal to the QR code metadata then update the labels text
            // and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                let contactInfo = metadataObj.stringValue.components(separatedBy: ", ")
                let name = contactInfo[0] + " " + contactInfo[1]
                if isAlertViewShowing == false {
                    isAlertViewShowing = true
                    createAlert(title: name, message: "Contacts", contactInfo: contactInfo)
                }
            }
        }
    }
    
    func createAlert (title:String, message: String, contactInfo: Array<Any>) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //Contacts
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
            let contact = CNMutableContact()
            if contactInfo[0] as! String != "NONE" {
                contact.givenName = contactInfo[0] as! String
            }
            if contactInfo[1] as! String != "NONE" {
                contact.familyName = contactInfo[1] as! String
            }
            if contactInfo[2] as! String != "NONE" {
            contact.phoneNumbers = [CNLabeledValue(label:CNLabelPhoneNumberiPhone, value:CNPhoneNumber(stringValue: contactInfo[2] as! String))]
            }
            if contactInfo[3] as! String != "NONE" {
            contact.emailAddresses = [CNLabeledValue(label:CNLabelHome, value: contactInfo[3] as! NSString)]
            }
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try! store.execute(saveRequest)
            
            //Instagram
            if contactInfo[4] as! String != "NONE" {
                var followURL = URLRequest(url: URL(string: ("https://api.instagram.com/v1/users/" + (contactInfo[4] as! String) + "/relationship?access_token=" + (defaults.object(forKey: "instagram") as! String)))!)
                print(followURL)
                followURL.httpMethod = "POST"
                let postString = "action=follow"
                followURL.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: followURL) {data, response, error in
                    guard let data = data, error == nil else {
                        print("error")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("Error")
                    }
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
                    }
                task.resume()
            }
            //Twitter
            if contactInfo[5] as! String != "NONE" {
                let twitterStore = Twitter.sharedInstance().sessionStore
                if let userid = twitterStore.session()?.userID{
                    let client = TWTRAPIClient(userID: userid)
                    let followEndpoint = "https://api.twitter.com/1.1/friendships/create.json"
                    let params = ["user_id" : (contactInfo[5] as! String), "follow" : "true"]
                    var clientError : NSError?
                    let request = client.urlRequest(withMethod: "POST", url:    followEndpoint, parameters: params, error: &clientError)
                    client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                        if connectionError != nil {
                            print("Error: \(String(describing: connectionError))")
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: [])
                            print("json: \(json)")
                        } catch let jsonError as NSError {
                            print("json error: \(jsonError.localizedDescription)")
                        }
                    }
                }
            }
            self.isAlertViewShowing = false
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) in
            self.isAlertViewShowing = false
            print("CANCEL")}))
    
        self.present(alert, animated: true, completion: nil)
    }
}


//
//  QRCodeViewController.swift
//  Social-QR
//
//  Created by David Chang on 7/28/17.
//  Copyright © 2017 David Chang. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    

    @IBOutlet weak var imageView: UIImageView!
    func generateQRCode(from string: String) -> UIImage? {

        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            guard let qrCodeImage = filter.outputImage else {return nil}
            
            let scaleX = imageView.frame.size.width / qrCodeImage.extent.size.width
            let scaleY = imageView.frame.size.height / qrCodeImage.extent.size.height
            
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((defaults.object(forKey: "code")) == nil) {
            defaults.set("NONE, NONE, NONE, NONE", forKey: "contacts")
            defaults.set("NONE", forKey: "instagramID")
            defaults.set("NONE", forKey: "twitterID")
            let image = generateQRCode(from: "NONE, NONE, NONE, NONE, NONE, NONE")
            imageView.image = image
        }
        else {
            let image = generateQRCode(from: defaults.object(forKey: "code") as! String)
            imageView.image = image   
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ((defaults.object(forKey: "code")) == nil) {
            defaults.set("NONE, NONE, NONE, NONE", forKey: "contacts")
            defaults.set("NONE", forKey: "instagramID")
            defaults.set("NONE", forKey: "twitterID")
            let image = generateQRCode(from: "NONE, NONE, NONE, NONE, NONE, NONE")
            imageView.image = image
        }
        else {
            let image = generateQRCode(from: defaults.object(forKey: "code") as! String)
            imageView.image = image
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


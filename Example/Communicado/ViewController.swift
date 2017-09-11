//
//  ViewController.swift
//  Communicado
//
//  Created by Joe Fabisevich on 9/9/17.
//  Copyright © 2017 Mergesort. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, SharingCapableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }

}

private extension ViewController {
    
    func setup() {
        self.title = "Sharing Example"
        
        self.sharingTitleTextAttributes = [
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0, green: 0.2156862745, blue: 0.5019607843, alpha: 1),
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 21.0)
        ]

        self.sharingBarButtonItemAttributes = [
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1),
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)
        ]

        self.sharingBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.7098039216, blue: 0.9960784314, alpha: 1)

        self.sharingCompleted = { shareResult in
            print("Was successful: \(shareResult.success)")
            print("Sharing service: \(shareResult.sharingService)")
        }
    }
    
    @IBAction func messagesButtonTapped() {
        self.shareViaMessages()
    }
    
    @IBAction func mailButtonTapped() {
        self.shareViaMail()
    }
    
    @IBAction func twitterButtonTapped() {
        self.shareViaTwitter()
    }
    
    @IBAction func pasteboardButtonTapped() {
        self.shareViaPasteboard()
    }
    
    @IBAction func activityControllerButtonTapped() {
        self.shareViaActivityViewController()
    }
    
    func shareViaMessages() {
        let messageShareParameters = MessagesShareParameters(message: "I ❤️ Communicado", attachments: nil)
        self.share(messageShareParameters)
    }
    
    func shareViaMail() {
        let attachments: [Attachment]?
        
        let blankImage = UIImage()
        if let imageData = UIImagePNGRepresentation(blankImage) {
            attachments = [Attachment(attachmentType: .png, filename: "blankImage.png", data: imageData)]
        } else {
            attachments = nil
        }
        
        let mailShareParameters = MailShareParameters(subject: "I ❤️ Communicado", message: "<b>I ❤️ Communicado.</b>", isHTML: true, toRecepients: ["github@fabisevi.ch"], ccRecepients: nil, bccRecepients: nil, attachments: attachments)
        self.share(mailShareParameters)
    }
    
    func shareViaActivityViewController() {
        // All the parameters are optional except for the activity.
        // You can call a simplified version like this if you'd prefer.
        // let activityShareParameters = ActivityShareParameters(activityItems: ["I ❤️ Communicado"]])
        
        let activityShareParameters = ActivityShareParameters(activityItems: ["I ❤️ Communicado"], excludedActivityTypes: [.airDrop, .print], applicationActivites: nil, completionItemsHandler: nil, sourceView: nil)
        self.share(activityShareParameters)
    }
    
    func shareViaPasteboard() {
        let pasteBoardShareParmeters = PasteboardShareParameters(value: PasteboardShareParameters.Value.string("I ❤️ Communicado"))
        self.share(pasteBoardShareParmeters)
    }
    
    func shareViaTwitter() {
        // You can share to any of the built in Social networks (Twitter, Facebook, Sina Weibo, and Tencent Weibo).
        // This functionality has been deprecated in iOS 11
        // as Apple removed the Social framework which this was based on.
        
        if #available(iOS 11.0, *) {
            let alertController = UIAlertController(title: "This functionality has been deprecated in iOS 11", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            let twitterShareDestination = TwitterShareDestination()
            let twitterShareParameters = SocialShareParameters(network: twitterShareDestination, message: "I ❤️ Communicado", images: nil, urls: nil)
            self.share(twitterShareParameters)
        }
    }

    
}

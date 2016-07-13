//
//  UIViewController+Sharing
//  Copyright © 2016 Joseph Fabisevich (@mergesort). All rights reserved.
//

import UIKit

import MessageUI
import Photos
import Social
import ObjectiveC.runtime


// MARK: MessageAttachment

public final class MessageAttachment {

    let attachmentType: String
    let filename: String
    let data: NSData

    public init(attachmentType: String, filename: String, data: NSData) {
        self.attachmentType = attachmentType
        self.filename = filename
        self.data = data
    }

}


// MARK: SharingCompletedEvent

public typealias SharingCompletedEvent = ((success: Bool, sharingService: String) -> Void)


// MARK: Extension

public extension UIViewController {

    public static var textMessageSharingService: String { get { return "com.apple.UIKit.activity.Message" } }
    public static var emailSharingService: String { get { return "com.apple.UIKit.activity.Mail" } }
    public static var cancelledSharingService: String { get { return "com.plugin.cancelled" } }
    public static var photosSharingService: String { get { return "com.apple.UIKit.photos" } }
    public static var instagramSharingService: String { get { return "com.instagram.exclusivegram" } }

    public func canShareViaText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }

    public func canShareViaEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }

    public func canShareViaTwitter() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }

    public func canShareViaFacebook() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    }

    public func canShareViaInstagram() -> Bool {
        if let instagramURL = NSURL(string: "instagram://") {
            return UIApplication.sharedApplication().canOpenURL(instagramURL)
        }

        return false
    }

    public func canShareViaSinaWeibo() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo)
    }

    public func canShareViaTencentWeibo() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTencentWeibo)
    }

    public func shareViaActivityController(activityItems: [AnyObject], excludedActivityTypes: [String]?, applicationActivites: [UIActivity]?, completionItemsHandler:((activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> ())?) {
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivites)
        activityController.excludedActivityTypes = excludedActivityTypes

        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if let completionItemsHandler = completionItemsHandler {
                completionItemsHandler(activityType: activityType, completed: completed, returnedItems: returnedItems, activityError: activityError)
            }

            let sharingService = activityType ?? UIViewController.cancelledSharingService
            self.sharingCompleted?(success: (completed && activityError == nil), sharingService: sharingService)
        }

        self.presentViewController(activityController, animated: true, completion: nil)
    }

    public func shareViaTextMessage(message: String?, attachments:[MessageAttachment]?) {
        if self.canShareViaText() {
            let messageController = MFMessageComposeViewController()
            messageController.messageComposeDelegate = self
            messageController.body = message

            if let attachments = attachments {
                for attachment in attachments {
                    messageController.addAttachmentData(attachment.data, typeIdentifier: attachment.attachmentType, filename: attachment.filename)
                }
            }

            if let titleTextAttributes = self.sharingTitleTextAttributes {
                messageController.navigationBar.titleTextAttributes = titleTextAttributes
            }

            if let barButtonItemTintColor = self.sharingBarButtonItemTintColor {
                messageController.navigationBar.tintColor = barButtonItemTintColor
            }

            self.presentViewController(messageController, animated: true, completion: nil)
        } else {
            self.sharingCompleted?(success: false, sharingService: UIViewController.textMessageSharingService)
        }
    }

    public func shareViaEmailWithSubject(subject: String?, message: String?, isHTML: Bool, toRecepients:[String]?, ccRecepients:[String]?, bccRecepients:[String]?, attachments:[MessageAttachment]?) {
        if self.canShareViaEmail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self;
            mailController.setSubject(subject ?? "")
            mailController.setMessageBody(message ?? "", isHTML: isHTML)
            mailController.setToRecipients(toRecepients)
            mailController.setCcRecipients(ccRecepients)
            mailController.setBccRecipients(bccRecepients)

            if let attachments = attachments {
                for attachment in attachments {
                    mailController.addAttachmentData(attachment.data, mimeType: attachment.attachmentType, fileName: attachment.filename)
                }
            }

            if let titleTextAttributes = self.sharingTitleTextAttributes {
                mailController.navigationBar.titleTextAttributes = titleTextAttributes
            }

            if let barButtonItemTintColor = self.sharingBarButtonItemTintColor {
                mailController.navigationBar.tintColor = barButtonItemTintColor
            }

            self.presentViewController(mailController, animated: true, completion: nil)
        } else {
            self.sharingCompleted?(success: false, sharingService: UIViewController.emailSharingService)
        }
    }

    public func shareViaFacebook(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaFacebook() {
            self.shareViaSLComposeViewController(SLServiceTypeFacebook, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeTwitter)
        }
    }

    public func shareViaTwitter(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaTwitter() {
            self.shareViaSLComposeViewController(SLServiceTypeTwitter, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeTwitter)
        }
    }

    public func shareViaSinaWeiboWithMessage(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaSinaWeibo() {
            self.shareViaSLComposeViewController(SLServiceTypeTwitter, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeSinaWeibo)
        }
    }

    public func shareViaTencentWeiboWithMessage(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaTencentWeibo() {
            self.shareViaSLComposeViewController(SLServiceTypeTwitter, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeTencentWeibo)
        }
    }

    public func saveImageToCameraRoll(image: UIImage) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ _ in
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            changeRequest.creationDate = NSDate()
        }) { success, error in
            let saved = (error == nil && success)
            self.sharingCompleted?(success: saved, sharingService:UIViewController.photosSharingService)
        }
    }

    public func shareViaInstagram(image: UIImage, text: String?) {
        let sharingSucceeded: Bool

        if self.canShareViaInstagram() {
            if let documentsDirectory = (NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)).last {
                let imageURL = documentsDirectory.URLByAppendingPathComponent("temporary").URLByAppendingPathExtension("igo")
                if let imagePath = imageURL.path {
                    let imageData = UIImageJPEGRepresentation(image, 1.0)
                    imageData?.writeToFile(imagePath, atomically: true)

                    self.sharingDocumentInteractionController = UIDocumentInteractionController(URL: imageURL)

                    if let documentInteractionController = self.sharingDocumentInteractionController {
                        documentInteractionController.delegate = self
                        documentInteractionController.UTI = UIViewController.instagramSharingService
                        if let text = text {
                            documentInteractionController.annotation = [
                                "InstagramCaption" : text,
                            ]
                        }
                        documentInteractionController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
                        sharingSucceeded = true
                    } else {
                        sharingSucceeded = false
                    }
                } else {
                    sharingSucceeded = false
                }
            } else {
                sharingSucceeded = false
            }
        } else {
            sharingSucceeded = false
        }

        if sharingSucceeded == false { // Otherwise it will occur in the delegate callback
            self.sharingCompleted?(success: sharingSucceeded, sharingService:UIViewController.instagramSharingService)
        }
    }

    public func shareViaCopyString(string: String?) {
        UIPasteboard.generalPasteboard().string = string
    }
    
    public func shareViaCopyImage(image: UIImage?) {
        guard let image = image else {
            return
        }

        UIPasteboard.generalPasteboard().image = image
    }


    public func shareViaCopyURL(URL: NSURL?) {
        UIPasteboard.generalPasteboard().URL = URL
    }

}

private extension UIViewController {

    func shareViaSLComposeViewController(network: String, message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if SLComposeViewController.isAvailableForServiceType(network) {
            let composeController = SLComposeViewController(forServiceType: network)
            composeController.setInitialText(message)

            if let URLs = URLs {
                for URL in URLs {
                    composeController.addURL(URL)
                }
            }

            if let images = images {
                for image in images {
                    composeController.addImage(image)
                }
            }

            composeController.completionHandler = { result in
                if let sharingCompleted = self.sharingCompleted {
                    sharingCompleted(success: (result == SLComposeViewControllerResult.Done), sharingService: network)
                }

                self.dismissViewControllerAnimated(true, completion: nil)
            }

            self.presentViewController(composeController, animated: true, completion: nil)
        }
    }

}

extension UIViewController: UIDocumentInteractionControllerDelegate {

    public func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        self.sharingCompleted?(success: true, sharingService: UIViewController.instagramSharingService)
    }

}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)

        self.sharingCompleted?(success: (result == MFMailComposeResultSent || result == MFMailComposeResultSaved), sharingService: UIViewController.emailSharingService)
    }

}

extension UIViewController: MFMessageComposeViewControllerDelegate {

    public func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)

        self.sharingCompleted?(success: (result == MessageComposeResultSent), sharingService: UIViewController.textMessageSharingService)
    }

}


// MARK: Associated objects

public extension UIViewController {

    private struct AssociatedObjectKeys {
        static var sharingBarButtonItemTintColor = "UIViewController.sharingBarButtonItemTintColor"
        static var sharingBarTintColor = "UIViewController.sharingBarTintColor"
        static var sharingTitleTextAttributes = "UIViewController.sharingTitleTextAttributes"
        static var sharingCompleted = "UIViewController.sharingCompleted"
        static var sharingDocumentInteractionController = "UIViewController.sharingDocumentInteractionController"
    }

    public var sharingBarButtonItemTintColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemTintColor) as? UIColor
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemTintColor, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    public var sharingTitleTextAttributes: [ String : NSObject ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes) as? [ String : NSObject ]
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    public var sharingCompleted: SharingCompletedEvent? {
        get {
            if let box = objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingCompleted) as? SharingCompletedEventBox {
                return box.event
            }

            return nil;
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingCompleted, SharingCompletedEventBox(event: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var sharingDocumentInteractionController: UIDocumentInteractionController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingDocumentInteractionController) as? UIDocumentInteractionController
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingDocumentInteractionController, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}


// MARK: Boxing so we can store the sharingCompleted closure on UIViewController

private class SharingCompletedEventBox {
    
    var event: SharingCompletedEvent?
    
    init(event: SharingCompletedEvent?) {
        self.event = event
    }
    
}

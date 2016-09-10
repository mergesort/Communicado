//
//  UIViewController+Sharing
//  Copyright © 2016 Joseph Fabisevich (@mergesort). All rights reserved.
//

import UIKit

import MessageUI
import Photos
import Social
import ObjectiveC.runtime


// MARK: SharingCompletedEvent

public typealias SharingType = (success: Bool, sharingService: UIActivityType)
public typealias SharingCompletedEvent = (SharingType) -> Void


// ShareNetwork

public enum ShareDestination {

    case text(parameters: TextShareParameters)
    case email(parameters: MailShareParameters)
    case twitter(parameters: SocialShareParameters)
    case facebook(parameters: SocialShareParameters)
    case sinaWeibo(parameters: SocialShareParameters)
    case tencentWeibo(parameters: SocialShareParameters)
    case pasteboard(parameters: PasteboardShareParameters)
    case photos(parameters: PhotosShareParameters)
    case activityController(parameters: ActivityShareParameters)

    public var canShare: Bool {
        switch self {

        case .text(_):
            return MFMessageComposeViewController.canSendText()

        case .email(_):
            return MFMailComposeViewController.canSendMail()

        case .twitter(_):
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)

        case .facebook(_):
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)

        case .sinaWeibo(_):
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeSinaWeibo)

        case .tencentWeibo(_):
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTencentWeibo)

        case .pasteboard(_):
            return true

        case .photos(_):
            return PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .notDetermined

        case .activityController(_):
            return true

        }
    }

    public var name: String {
        switch self {

        case .text(_):
            return UIActivityType.message.rawValue

        case .email(_):
            return UIActivityType.mail.rawValue

        case .twitter(_):
            return SLServiceTypeTwitter

        case .facebook(_):
            return SLServiceTypeFacebook

        case .sinaWeibo(_):
            return SLServiceTypeSinaWeibo

        case .tencentWeibo(_):
            return SLServiceTypeTencentWeibo

        case .pasteboard(_):
            return UIActivityType.copyToPasteboard.rawValue

        case .photos(_):
            return UIActivityType.saveToCameraRoll.rawValue

        case .activityController(_):
            return "com.apple.activityController"
            
        }
    }

    var activityType: UIActivityType {
        return UIActivityType(self.name)
    }

    public static let cancelled = UIActivityType("com.plugin.cancelled")

}

public extension UIViewController {

    func share(destination: ShareDestination) {
        if destination.canShare {
            switch destination {

            case .text(let parameters):
                self.share(textParameters: parameters)

            case .email(let parameters):
                self.share(mailParameters: parameters)

            case .twitter(let parameters):
                self.share(socialParameters: parameters, network: destination.name)

            case .facebook(let parameters):
                self.share(socialParameters: parameters, network: destination.name)

            case .sinaWeibo(let parameters):
                self.share(socialParameters: parameters, network: destination.name)

            case .tencentWeibo(let parameters):
                self.share(socialParameters: parameters, network: destination.name)

            case .pasteboard(let parameters):
                self.share(pasteboardParmaeters: parameters)

            case .photos(let parameters):
                self.share(photosParameters: parameters)

            case .activityController(let parameters):
                self.share(activityParameters: parameters)

            }
        } else {
            self.sharingCompleted?((success: false, sharingService: destination.activityType))
        }
    }

}

fileprivate extension UIViewController {

    func share(activityParameters parameters: ActivityShareParameters) {
        let activityController = UIActivityViewController(activityItems: parameters.activityItems, applicationActivities: parameters.applicationActivites)
        activityController.excludedActivityTypes = parameters.excludedActivityTypes

        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            parameters.completionItemsHandler?(activityType, completed, returnedItems, activityError)

            let sharingService = activityType ?? ShareDestination.cancelled
            self.sharingCompleted?(success: (completed && activityError == nil), sharingService: sharingService)
        }

        self.present(activityController, animated: true, completion: nil)
    }

    func share(textParameters parameters: TextShareParameters) {
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.body = parameters.message

        messageController.navigationBar.titleTextAttributes = self.sharingTitleTextAttributes
        messageController.navigationBar.tintColor = self.sharingBarButtonItemTintColor

        parameters.attachments?.forEach { attachment in
            messageController.addAttachmentData(attachment.data, typeIdentifier: attachment.attachmentType, filename: attachment.filename)
        }

        self.present(messageController, animated: true, completion: nil)
    }

    func share(mailParameters parameters: MailShareParameters) {
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setSubject(parameters.subject ?? "")
        mailController.setMessageBody(parameters.message ?? "", isHTML: parameters.isHTML)
        mailController.setToRecipients(parameters.toRecepients)
        mailController.setCcRecipients(parameters.ccRecepients)
        mailController.setBccRecipients(parameters.bccRecepients)

        mailController.navigationBar.titleTextAttributes = self.sharingTitleTextAttributes
        mailController.navigationBar.tintColor = self.sharingBarButtonItemTintColor

        parameters.attachments?.forEach { attachment in
            mailController.addAttachmentData(attachment.data, mimeType: attachment.attachmentType, fileName: attachment.filename)
        }

        self.present(mailController, animated: true, completion: nil)
    }

    func share(socialParameters parameters: SocialShareParameters, network: String) {
        if let composeController = SLComposeViewController(forServiceType: network) {
            composeController.setInitialText(parameters.message)

            parameters.urls.flatMap { $0 }?.lazy.forEach({ composeController.add($0) })
            parameters.images.flatMap { $0 }?.lazy.forEach({ composeController.add($0) })

            composeController.completionHandler = { result in
                let succeeded = (result == SLComposeViewControllerResult.done)
                self.sharingCompleted?((success: succeeded, sharingService: UIActivityType(network)))
                self.dismiss(animated: true, completion: nil)
            }

            self.present(composeController, animated: true, completion: nil)
        }
    }

    func share(pasteboardParmaeters parameters: PasteboardShareParameters) {
        UIPasteboard.general.url = parameters.url
        UIPasteboard.general.image = parameters.image
        UIPasteboard.general.string = parameters.string
    }

    func share(photosParameters parameters: PhotosShareParameters) {
        PHPhotoLibrary.shared().performChanges({ _ in
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: parameters.image)
            changeRequest.creationDate = Date()
        }) { success, error in
            let saved = (error == nil && success)
            let parameters = PhotosShareParameters(image: parameters.image)
            let activity = ShareDestination.photos(parameters: parameters).activityType
            self.sharingCompleted?(success: saved, sharingService: activity)
        }
    }

}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

        let success = (result == MFMailComposeResult.sent || result == MFMailComposeResult.saved)
        let emailActivity = ShareDestination.email(parameters: MailShareParameters()).activityType
        self.sharingCompleted?((success: success, sharingService: emailActivity))
    }

}

extension UIViewController: MFMessageComposeViewControllerDelegate {

    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)

        let success = (result == MessageComposeResult.sent)
        let textActivity = ShareDestination.text(parameters: TextShareParameters()).activityType
        self.sharingCompleted?((success: success, sharingService: textActivity))
    }

}


// MARK: Associated objects

public extension UIViewController {

    private struct AssociatedObjectKeys {
        static var sharingBarButtonItemTintColor = "UIViewController.sharingBarButtonItemTintColor"
        static var sharingBarTintColor = "UIViewController.sharingBarTintColor"
        static var sharingTitleTextAttributes = "UIViewController.sharingTitleTextAttributes"
        static var sharingCompleted = "UIViewController.sharingCompleted"
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

}

public struct SocialShareParameters {

    let message: String?
    let images: [UIImage]?
    let urls: [URL]?

    init(message: String? = nil, images: [UIImage]? = nil, urls: [URL]? = nil) {
        self.message = message
        self.images = images
        self.urls = urls
    }

}

public struct ActivityShareParameters {

    let activityItems: [AnyObject]
    let excludedActivityTypes: [UIActivityType]?
    let applicationActivites: [UIActivity]?
    let completionItemsHandler: UIActivityViewControllerCompletionWithItemsHandler?

    init(activityItems: [AnyObject], excludedActivityTypes: [UIActivityType]? = nil, applicationActivites: [UIActivity]? = nil, completionItemsHandler: UIActivityViewControllerCompletionWithItemsHandler? = nil) {
        self.activityItems = activityItems
        self.excludedActivityTypes = excludedActivityTypes
        self.applicationActivites = applicationActivites
        self.completionItemsHandler = completionItemsHandler
    }

}

public struct TextShareParameters {

    let message: String?
    let attachments: [MessageAttachment]?

    init(message: String? = nil, attachments: [MessageAttachment]? = nil) {
        self.message = message
        self.attachments = attachments
    }

}

public struct MailShareParameters {

    let subject: String?
    let message: String?
    let isHTML: Bool
    let toRecepients: [String]?
    let ccRecepients: [String]?
    let bccRecepients: [String]?
    let attachments: [MessageAttachment]?

    init(subject: String? = nil, message: String? = nil, isHTML: Bool = false, toRecepients: [String]? = nil, ccRecepients: [String]? = nil, bccRecepients: [String]? = nil, attachments: [MessageAttachment]? = nil) {
        self.subject = subject
        self.message = message
        self.isHTML = isHTML
        self.toRecepients = toRecepients
        self.ccRecepients = ccRecepients
        self.bccRecepients = bccRecepients
        self.attachments = attachments
    }

}

public struct PasteboardShareParameters {

    let string: String?
    let image: UIImage?
    let url: URL?

    init(string: String? = nil, image: UIImage? = nil, url: URL? = nil) {
        self.string = string
        self.image = image
        self.url = url
    }

}

public struct PhotosShareParameters {

    let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

}

public struct MessageAttachment {

    let attachmentType: String
    let filename: String
    let data: Data

    public init(attachmentType: String, filename: String, data: Data) {
        self.attachmentType = attachmentType
        self.filename = filename
        self.data = data
    }
    
}


// MARK: Boxing so we can store the sharingCompleted closure on UIViewController

private class SharingCompletedEventBox {
    
    var event: SharingCompletedEvent?
    
    init(event: SharingCompletedEvent?) {
        self.event = event
    }
    
}

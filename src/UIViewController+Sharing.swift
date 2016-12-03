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


// MARK: ShareDestination

public enum ShareDestination {

    case text
    case email
    case twitter
    case facebook
    case sinaWeibo
    case tencentWeibo
    case pasteboard
    case photos
    case activityController

    public var canShare: Bool {
        switch self {

        case .text:
            return MFMessageComposeViewController.canSendText()

        case .email:
            return MFMailComposeViewController.canSendMail()

        case .twitter:
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)

        case .facebook:
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)

        case .sinaWeibo:
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeSinaWeibo)

        case .tencentWeibo:
            return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTencentWeibo)

        case .pasteboard:
            return true

        case .photos:
            return PHPhotoLibrary.authorizationStatus() == .authorized

        case .activityController:
            return true

        }
    }

    public var name: String {
        switch self {

        case .text:
            return UIActivityType.message.rawValue

        case .email:
            return UIActivityType.mail.rawValue

        case .twitter:
            return SLServiceTypeTwitter

        case .facebook:
            return SLServiceTypeFacebook

        case .sinaWeibo:
            return SLServiceTypeSinaWeibo

        case .tencentWeibo:
            return SLServiceTypeTencentWeibo

        case .pasteboard:
            return UIActivityType.copyToPasteboard.rawValue

        case .photos:
            return UIActivityType.saveToCameraRoll.rawValue

        case .activityController:
            return "com.apple.activityController"

        }
    }

    var activityType: UIActivityType {
        return UIActivityType(self.name)
    }

    public static let cancelled = UIActivityType("com.plugin.cancelled")

    public enum SocialNetwork {

        case twitter
        case facebook
        case sinaWeibo
        case tencentWeibo

        var shareDestination: ShareDestination {
            switch self {

            case .twitter:
                return ShareDestination.twitter

            case .facebook:
                return ShareDestination.facebook

            case .sinaWeibo:
                return ShareDestination.sinaWeibo

            case .tencentWeibo:
                return ShareDestination.tencentWeibo

            }
        }

    }

}

public extension UIViewController {

    /// Share using UIActivityViewController.
    ///
    /// - parameter parameters: Parameters that are applicable for sharing when using UIActivityViewController.
    func share(_ parameters: ActivityShareParameters) {
        self.shareIfPossible(destination: ShareDestination.activityController) {
            let activityController = UIActivityViewController(activityItems: parameters.activityItems, applicationActivities: parameters.applicationActivites)
            activityController.excludedActivityTypes = parameters.excludedActivityTypes

            activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                parameters.completionItemsHandler?(activityType, completed, returnedItems, activityError)

                let sharingService = activityType ?? ShareDestination.cancelled
                self.sharingCompleted?(success: (completed && activityError == nil), sharingService: sharingService)
            }

            self.present(activityController, animated: true, completion: nil)
        }
    }

    /// Share to the Messages app.
    ///
    /// - parameter parameters: Parameters that are applicable for sharing to Messages.
    func share(_ parameters: TextShareParameters) {
        self.shareIfPossible(destination: ShareDestination.activityController) {
            let messageController = MFMessageComposeViewController()
            messageController.messageComposeDelegate = self
            messageController.body = parameters.message

            messageController.navigationBar.titleTextAttributes = self.sharingTitleTextAttributes
            messageController.navigationBar.tintColor = self.sharingBarButtonItemTintColor

            parameters.attachments?.forEach { attachment in
                messageController.addAttachmentData(attachment.data, typeIdentifier: attachment.attachmentType.identifier, filename: attachment.filename)
            }

            self.present(messageController, animated: true, completion: nil)
        }
    }

    /// Share to the Mail app.
    ///
    /// - parameter parameters: Parameters that are applicable for sharing to Mail.
    func share(_ parameters: MailShareParameters) {
        self.shareIfPossible(destination: ShareDestination.activityController) {
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
                mailController.addAttachmentData(attachment.data, mimeType: attachment.attachmentType.identifier, fileName: attachment.filename)
            }

            self.present(mailController, animated: true, completion: nil)
        }
    }

    /// Share to a social network.
    /// This includes SocialNetwork.twitter, .facebook, .sinaWeibo, and .tencentWeibo.
    ///
    /// - parameter parameters: Parameters that are applicable for sharing to a social network.
    func share(_ parameters: SocialShareParameters) {
        self.shareIfPossible(destination: ShareDestination.activityController) {
            let destination = parameters.network.shareDestination
            if let composeController = SLComposeViewController(forServiceType: destination.name) {
                composeController.setInitialText(parameters.message)

                parameters.urls.flatMap { $0 }?.lazy.forEach({ composeController.add($0) })
                parameters.images.flatMap { $0 }?.lazy.forEach({ composeController.add($0) })

                composeController.completionHandler = { result in
                    let succeeded = (result == SLComposeViewControllerResult.done)
                    self.sharingCompleted?((success: succeeded, sharingService: destination.activityType))
                    self.dismiss(animated: true, completion: nil)
                }

                self.present(composeController, animated: true, completion: nil)
            }
        }
    }

    /// Share to the user's pasteboard.
    ///
    /// - parameter parameters: Parameters that are applicable for sharing to the pasteboard.
    func share(_ parameters: PasteboardShareParameters) {
        self.shareIfPossible(destination: ShareDestination.activityController) {
            UIPasteboard.general.url = parameters.url
            UIPasteboard.general.image = parameters.image
            UIPasteboard.general.string = parameters.string
        }
    }

    /// Share to the user's photo library.
    ///
    /// - parameter parameters: Parameters that are applicable for sharing to the photo library.
    func share(_ parameters: PhotosShareParameters) {
        PHPhotoLibrary.shared().performChanges({ _ in
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: parameters.image)
            changeRequest.creationDate = Date()
        }) { success, error in
            let saved = (error == nil && success)
            let activity = ShareDestination.photos.activityType
            self.sharingCompleted?(success: saved, sharingService: activity)
        }
    }

}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

        let success = (result == MFMailComposeResult.sent || result == MFMailComposeResult.saved)
        self.sharingCompleted?((success: success, sharingService: ShareDestination.email.activityType))
    }

}

extension UIViewController: MFMessageComposeViewControllerDelegate {

    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)

        let success = (result == MessageComposeResult.sent)
        self.sharingCompleted?((success: success, sharingService: ShareDestination.text.activityType))
    }

}

private extension UIViewController {

    /// A method that determines whether we can currently share to a specified ShareDestination.
    ///
    /// - parameter destination:    The ShareDestination whose availability we should check.
    /// - parameter canShareAction: The action to take if you can indeed share to a destination.
    func shareIfPossible(destination: ShareDestination, canShareAction: () -> Void) {
        if destination.canShare {
            canShareAction()
        } else {
            self.sharingCompleted?((success: false, sharingService: destination.activityType))
        }
    }

}


// MARK: Associated objects

public extension UIViewController {

    private enum AssociatedObjectKeys {
        static var sharingBarButtonItemTintColor = "UIViewController.sharingBarButtonItemTintColor"
        static var sharingBarTintColor = "UIViewController.sharingBarTintColor"
        static var sharingTitleTextAttributes = "UIViewController.sharingTitleTextAttributes"
        static var sharingCompleted = "UIViewController.sharingCompleted"
    }

    /// A property for configuring the tintColor on MFMailComposeViewController or MFMessageComposeViewController.
    public var sharingBarButtonItemTintColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemTintColor) as? UIColor
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemTintColor, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    /// A property for configuring the titleTextAttributes on MFMailComposeViewController or MFMessageComposeViewController.
    public var sharingTitleTextAttributes: [ String : NSObject ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes) as? [ String : NSObject ]
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    /// A closure that fires when a sharing event completes, whether it is succeeds or fails.
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

    public let network: ShareDestination.SocialNetwork
    public let message: String?
    public let images: [UIImage]?
    public let urls: [URL]?

    public init(network: ShareDestination.SocialNetwork, message: String? = nil, images: [UIImage]? = nil, urls: [URL]? = nil) {
        self.network = network
        self.message = message
        self.images = images
        self.urls = urls
    }

}

public struct ActivityShareParameters {

    public let activityItems: [Any]
    public let excludedActivityTypes: [UIActivityType]?
    public let applicationActivites: [UIActivity]?
    public let completionItemsHandler: UIActivityViewControllerCompletionWithItemsHandler?

    public init(activityItems: [Any], excludedActivityTypes: [UIActivityType]? = nil, applicationActivites: [UIActivity]? = nil, completionItemsHandler: UIActivityViewControllerCompletionWithItemsHandler? = nil) {
        self.activityItems = activityItems
        self.excludedActivityTypes = excludedActivityTypes
        self.applicationActivites = applicationActivites
        self.completionItemsHandler = completionItemsHandler
    }

}

public struct TextShareParameters {

    public let message: String?
    public let attachments: [Attachment]?

    public init(message: String? = nil, attachments: [Attachment]? = nil) {
        self.message = message
        self.attachments = attachments
    }

}

public struct MailShareParameters {

    public let subject: String?
    public let message: String?
    public let isHTML: Bool
    public let toRecepients: [String]?
    public let ccRecepients: [String]?
    public let bccRecepients: [String]?
    public let attachments: [Attachment]?

    public init(subject: String? = nil, message: String? = nil, isHTML: Bool = false, toRecepients: [String]? = nil, ccRecepients: [String]? = nil, bccRecepients: [String]? = nil, attachments: [Attachment]? = nil) {
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

    public let string: String?
    public let image: UIImage?
    public let url: URL?

    public init(string: String? = nil, image: UIImage? = nil, url: URL? = nil) {
        self.string = string
        self.image = image
        self.url = url
    }

}

public struct PhotosShareParameters {

    public let image: UIImage

    public init(image: UIImage) {
        self.image = image
    }

}

public struct Attachment {

    public let attachmentType: AttachmentType
    public let filename: String
    public let data: Data

    public init(attachmentType: AttachmentType, filename: String, data: Data) {
        self.attachmentType = attachmentType
        self.filename = filename
        self.data = data
    }

}

public enum AttachmentType {

    case aiff
    case avi
    case gif
    case html
    case jpg
    case mov
    case mp3
    case mp4
    case pdf
    case plainText
    case png
    case psd
    case rtf
    case tiff
    case zip
    case custom(value: String)

    var identifier: String {
        switch self {

        case .aiff:
            return "audio/aiff"

        case .avi:
            return "video/avi"

        case .gif:
            return "image/gif"

        case .html:
            return "text/html"

        case .jpg:
            return "image/jpeg"

        case .mov:
            return "video/quicktime"

        case .mp3:
            return "audio/mp3"

        case .mp4:
            return "video/mp4"

        case .pdf:
            return "application/pdf"

        case .plainText:
            return "text/plain"

        case .png:
            return "image/png"

        case .psd:
            return "image/psd"

        case .rtf:
            return "text/rtf"

        case .tiff:
            return "image/tiff"

        case .zip:
            return "application/zip"

        case .custom(let value):
            return value

        }
    }

}

// Boxing so we can store the sharingCompleted closure on UIViewController
private class SharingCompletedEventBox {

    var event: SharingCompletedEvent?

    init(event: SharingCompletedEvent?) {
        self.event = event
    }

}

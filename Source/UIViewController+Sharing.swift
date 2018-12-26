import UIKit

import MessageUI
import Photos
import Social
import ObjectiveC.runtime

/// A value returned for when sharing events occur.
/// - success: Whether or not the share was successful or failed.
/// - sharingService: A `UIActivityType` for which specific service was attempting to be shared.
public typealias ShareResult = (success: Bool, sharingService: UIActivity.ActivityType)

/// A unified completion handler after a share event occurs.
public typealias SharingCompletedEvent = (ShareResult) -> Void

/// A protocol for defining where the share functionality for `UIViewController`s exists.
public protocol SharingCapableViewController {}

public extension SharingCapableViewController where Self: UIViewController {

    /// Share using UIActivityViewController.
    ///
    /// - Parameter parameters: Parameters that are applicable for sharing when using UIActivityViewController.
    func share(_ parameters: ActivityShareParameters) {
        self.shareIfPossible(destination: parameters.shareDestination) {
            let activityController = UIActivityViewController(activityItems: parameters.activityItems, applicationActivities: parameters.applicationActivites)
            activityController.excludedActivityTypes = parameters.excludedActivityTypes

            activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                parameters.completionItemsHandler?(activityType, completed, returnedItems, activityError)

                let sharingService = activityType ?? UIActivity.ActivityType.cancelled
                self.sharingCompleted?((success: (completed && activityError == nil), sharingService: sharingService))
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController.modalPresentationStyle = .popover
                self.present(activityController, animated: true, completion: nil)
                if let controller = activityController.popoverPresentationController {
                    controller.permittedArrowDirections = .any
                    controller.sourceView = parameters.sourceView
                }
            } else {
                self.present(activityController, animated: true, completion: nil)
            }
        }
    }

    /// Share to the Messages app.
    ///
    /// - Parameter parameters: Parameters that are applicable for sharing to Messages.
    func share(_ parameters: MessagesShareParameters) {
        self.shareIfPossible(destination: parameters.shareDestination) {
            self.temporarySharingBarButtonItemAttributes = UIBarButtonItem.appearance().titleTextAttributes(for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes(self.sharingBarButtonItemAttributes, for: .normal)
            
            if let backgroundColor = self.sharingBackgroundColor {
                self.temporarySharingBackgroundImage = UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default)
                UINavigationBar.appearance().setBackgroundImage(UIImage(color: backgroundColor), for: UIBarMetrics.default)
            }

            let messageController = MFMessageComposeViewController()
            messageController.messageComposeDelegate = self
            messageController.body = parameters.message
            parameters.attachments?.forEach { attachment in
                messageController.addAttachmentData(attachment.data, typeIdentifier: attachment.attachmentType.identifier, filename: attachment.filename)
            }

            self.present(messageController, animated: true, completion: nil)
        }
    }

    /// Share to the Mail app.
    ///
    /// - Parameter parameters: Parameters that are applicable for sharing to Mail.
    func share(_ parameters: MailShareParameters) {
        self.shareIfPossible(destination: parameters.shareDestination) {
            self.temporarySharingBarButtonItemAttributes = UIBarButtonItem.appearance().titleTextAttributes(for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes(self.sharingBarButtonItemAttributes, for: .normal)
     
            if let backgroundColor = self.sharingBackgroundColor {
                self.temporarySharingBackgroundImage = UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default)
                UINavigationBar.appearance().setBackgroundImage(UIImage(color: backgroundColor), for: UIBarMetrics.default)
            }

            let mailController = MFMailComposeViewController()

            mailController.navigationBar.titleTextAttributes = self.sharingTitleTextAttributes
            
            mailController.mailComposeDelegate = self
            mailController.setSubject(parameters.subject ?? "")
            mailController.setMessageBody(parameters.message ?? "", isHTML: parameters.isHTML)
            mailController.setToRecipients(parameters.toRecepients)
            mailController.setCcRecipients(parameters.ccRecepients)
            mailController.setBccRecipients(parameters.bccRecepients)

            parameters.attachments?.forEach { attachment in
                mailController.addAttachmentData(attachment.data, mimeType: attachment.attachmentType.identifier, fileName: attachment.filename)
            }

            self.present(mailController, animated: true, completion: nil)
        }
    }

    /// Share to a social network.
    /// This includes SocialNetwork.twitter, .facebook, .sinaWeibo, and .tencentWeibo.
    ///
    /// - Parameter parameters: Parameters that are applicable for sharing to a social network.
    @available(iOS, deprecated: 11.0)
    func share(_ parameters: SocialShareParameters) {
        self.shareIfPossible(destination: parameters.network) {
            let destination = parameters.network
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
    /// - Parameter parameters: Parameters that are applicable for sharing to the pasteboard.
    func share(_ parameters: PasteboardShareParameters) {
        self.shareIfPossible(destination: parameters.shareDestination) {
            if let string = parameters.string {
                UIPasteboard.general.string = string
            }
            
            if let url = parameters.url {
                UIPasteboard.general.url = url
            }
            
            if let image = parameters.image {
                UIPasteboard.general.image = image
            }
        }
    }

    /// Share to the user's photo library.
    ///
    /// - Parameter parameters: Parameters that are applicable for sharing to the photo library.
    func share(_ parameters: PhotosShareParameters) {
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: parameters.image)
            changeRequest.creationDate = Date()
        }) { success, error in
            let saved = (error == nil && success)
            let activity = parameters.shareDestination.activityType
            self.sharingCompleted?((success: saved, sharingService: activity))
        }
    }

}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Reset the UIAppearance styles to what they were before we started
        UINavigationBar.appearance().setBackgroundImage(self.temporarySharingBackgroundImage, for: UIBarMetrics.default)
        if let temporarySharingBarButtonItemAttributes = self.temporarySharingBarButtonItemAttributes as? [NSAttributedString.Key : Any] {
            UIBarButtonItem.appearance().setTitleTextAttributes(temporarySharingBarButtonItemAttributes, for: .normal)
        }

        self.temporarySharingBackgroundImage = nil
        self.temporarySharingBarButtonItemAttributes = nil

        controller.dismiss(animated: true, completion: nil)

        let success = (result == MFMailComposeResult.sent || result == MFMailComposeResult.saved)
        let mailDestination = MailShareDestination()
        self.sharingCompleted?((success: success, sharingService: mailDestination.activityType))
    }

}

extension UIViewController: MFMessageComposeViewControllerDelegate {

    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Reset the UIAppearance styles to what they were before we started
        UINavigationBar.appearance().setBackgroundImage(self.temporarySharingBackgroundImage, for: UIBarMetrics.default)
        if let temporarySharingBarButtonItemAttributes = self.temporarySharingBarButtonItemAttributes as? [NSAttributedString.Key : Any] {
            UIBarButtonItem.appearance().setTitleTextAttributes(temporarySharingBarButtonItemAttributes, for: .normal)
        }

        self.temporarySharingBackgroundImage = nil
        self.temporarySharingBarButtonItemAttributes = nil

        controller.dismiss(animated: true, completion: nil)

        let success = (result == MessageComposeResult.sent)
        let messagesDestination = MessagesShareDestination()
        self.sharingCompleted?((success: success, sharingService: messagesDestination.activityType))
    }

}

private extension UIViewController {

    /// A method that determines whether we can currently share to a specified ShareDestination.
    ///
    /// - Parameter destination: The ShareDestination whose availability we should check.
    /// - Parameter canShareAction: The action to take if you can indeed share to a destination.
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
        static var sharingBarButtonItemAttributes = "UIViewController.sharingBarButtonItemAttributes"
        static var sharingTitleTextAttributes = "UIViewController.sharingTitleTextAttributes"
        static var sharingBackgroundColor = "UIViewController.sharingBackgroundColor"
        static var sharingCompleted = "UIViewController.sharingCompleted"

        static var temporarySharingBarButtonItemAttributes = "UIViewController.temporarySharingBarButtonItemAttributes"
        static var temporarySharingBackgroundImage = "UIViewController.temporarySharingBackgroundImage"
    }

    /// A property for configuring the `backgroundColor` on `MFMailComposeViewController` or `MFMessageComposeViewController`.
    public var sharingBackgroundColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingBackgroundColor) as? UIColor
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// A property for configuring the `titleTextAttributes` on `MFMailComposeViewController`.
    /// Unfortunately this does not work on `MFMessageComposeViewController`.
    public var sharingTitleTextAttributes: [ NSAttributedString.Key : Any ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes) as? [ NSAttributedString.Key : Any ]
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// A property for configuring the `barButtonItemAttributes` on `MFMailComposeViewController` or `MFMessageComposeViewController`.
    public var sharingBarButtonItemAttributes: [ NSAttributedString.Key : Any ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemAttributes) as? [ NSAttributedString.Key : Any ]
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemAttributes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// A closure that fires when a sharing event completes, whether it is succeeds or fails.
    public var sharingCompleted: SharingCompletedEvent? {
        get {
            guard let box = objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingCompleted) as? SharingCompletedEventBox else {
                return nil
            }

            return box.event
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingCompleted, SharingCompletedEventBox(event: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: Temporary properties which are used to store in between presenting
    // `MFMailComposeViewController` and `MFMessageComposeViewController` since they require delegate
    // callbacks.

    /// A temporary store for the original `UINavigationBar.backgroundImage` while we are presenting a
    /// `MFMailComposeViewController` or `MFMessageComposeViewController`, to be restored after use.
    fileprivate var temporarySharingBackgroundImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.temporarySharingBackgroundImage) as? UIImage
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.temporarySharingBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// A temporary store for the original `titleTextAttributes` while we are presenting a
    /// `MFMailComposeViewController` or `MFMessageComposeViewController`, to be restored after use.
    public var temporarySharingBarButtonItemAttributes: [ AnyHashable : Any ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.temporarySharingBarButtonItemAttributes) as? [ AnyHashable : Any ]
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.temporarySharingBarButtonItemAttributes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// UIImage extension to create an image from specified color
private extension UIImage
{
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// Boxing so we can store the sharingCompleted closure on UIViewController
private class SharingCompletedEventBox {

    var event: SharingCompletedEvent?

    init(event: SharingCompletedEvent?) {
        self.event = event
    }

}

import UIKit

/// A protocol for types which share values to a `ShareDestination`.
protocol ShareParameters {
    var shareDestination: ShareDestination { get }
}

/// Parameters which are used when sharing via the built in `UIActivityViewController`.
public struct ActivityShareParameters: ShareParameters {

    let shareDestination: ShareDestination = ActivityControllerShareDestination()

    public let activityItems: [Any]
    public let excludedActivityTypes: [UIActivity.ActivityType]?
    public let applicationActivites: [UIActivity]?
    public let completionItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
    public let sourceView: UIView?
    
    public init(activityItems: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil, applicationActivites: [UIActivity]? = nil, completionItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil, sourceView: UIView? = nil) {
        self.activityItems = activityItems
        self.excludedActivityTypes = excludedActivityTypes
        self.applicationActivites = applicationActivites
        self.completionItemsHandler = completionItemsHandler
        self.sourceView = sourceView
    }
    
}

/// Parameters which are used when sharing via the built in `MFMessageComposeViewController`.
public struct MessagesShareParameters: ShareParameters {

    let shareDestination: ShareDestination = MessagesShareDestination()

    public let message: String?
    public let attachments: [Attachment]?
    
    public init(message: String? = nil, attachments: [Attachment]? = nil) {
        self.message = message
        self.attachments = attachments
    }
    
}

/// Parameters which are used when sharing via the built in `MFMailComposeViewController`.
public struct MailShareParameters: ShareParameters {

    let shareDestination: ShareDestination = MailShareDestination()

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

/// Parameters which are used when saving a `PasteboardShareParameters.Value` to the user's pasteboard.
public struct PasteboardShareParameters: ShareParameters {

    public enum Value {
        case string(String?)
        case image(UIImage?)
        case url(URL?)
    }
    
    let shareDestination: ShareDestination = PasteboardShareDestination()

    public let string: String?
    public let image: UIImage?
    public let url: URL?

    public init(value: PasteboardShareParameters.Value) {
        switch value {

        case .string(let string):
            self.string = string
            self.image = nil
            self.url = nil
            
        case .image(let image):
            self.image = image
            self.string = nil
            self.url = nil
        
        case .url(let url):
            self.url = url
            self.string = nil
            self.image = nil
        }
    }
    
}

/// Parameters which are used when saving an image to the user's camera roll.
public struct PhotosShareParameters: ShareParameters {
    
    let shareDestination: ShareDestination = PhotosShareDestination()

    public let image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
    
}

/// Parameters which are used when posting to a social network.
/// Deprecated in iOS 11, as Apple removed the Social framework, which this was based on.
@available(iOS, deprecated: 11.0)
public struct SocialShareParameters {
    
    public let network: SocialShareDestination
    public let message: String?
    public let images: [UIImage]?
    public let urls: [URL]?
    
    public init(network: SocialShareDestination, message: String? = nil, images: [UIImage]? = nil, urls: [URL]? = nil) {
        self.network = network
        self.message = message
        self.images = images
        self.urls = urls
    }
    
}

import MessageUI
import Photos
import Social
import UIKit

/// A type that defines the values needed for a destination to share to.
public protocol ShareDestination {
    
    /// The name of the destination we're sharing to.
    static var name: String { get }
    
    /// A computed var telling us whether or not we are currently capable of sharing to this destination.
    var canShare: Bool { get }
    
    /// A `UIActivityType` of the destination that we are sharing to.
    var activityType: UIActivityType { get }
}

/// A type that defines the values needed for a social network backed destination to share to.
public protocol SocialShareDestination: ShareDestination {
    
    /// The name of the destination we're sharing to.
    var name: String { get }
}

/// A ShareDestination for sharing to Messages.
public struct MessagesShareDestination: ShareDestination {
    
    public static let name = UIActivityType.message.rawValue

    public var canShare: Bool {
        return MFMessageComposeViewController.canSendText()
    }

    public var activityType: UIActivityType {
        return UIActivityType(MessagesShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to Mail.
public struct MailShareDestination: ShareDestination {
    
    public static let name = UIActivityType.mail.rawValue
    
    public var canShare: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    public var activityType: UIActivityType {
        return UIActivityType(MailShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to the camera roll.
public struct PhotosShareDestination: ShareDestination {
    
    public static let name = UIActivityType.saveToCameraRoll.rawValue

    public var canShare: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public var activityType: UIActivityType {
        return UIActivityType(PhotosShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to the pasteboard.
public struct PasteboardShareDestination: ShareDestination {

    public static let name = UIActivityType.copyToPasteboard.rawValue

    public var canShare: Bool {
        return true
    }
    
    public var activityType: UIActivityType {
        return UIActivityType(PasteboardShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to the `UIActivityViewController`.
public struct ActivityControllerShareDestination: ShareDestination {
    
    public static let name = "com.apple.activityController"
    
    public var canShare: Bool {
        return true
    }
 
    public var activityType: UIActivityType {
        return UIActivityType(ActivityControllerShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to Twitter.
/// Deprecated in iOS 11, as Apple removed the Social framework, which this was based on.
@available(iOS, deprecated: 11.0)
public struct TwitterShareDestination: SocialShareDestination {

    public static let name = SLServiceTypeTwitter
    public let name = SLServiceTypeTwitter
    
    public var canShare: Bool {
        return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
    }
    
    public var activityType: UIActivityType {
        return UIActivityType(TwitterShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to Facebook.
/// Deprecated in iOS 11, as Apple removed the Social framework, which this was based on.
@available(iOS, deprecated: 11.0)
public struct FacebookShareDestination: SocialShareDestination {
    
    public static let name = SLServiceTypeFacebook
    public let name = SLServiceTypeTwitter
    
    public var canShare: Bool {
        return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
    }
    
    public var activityType: UIActivityType {
        return UIActivityType(FacebookShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to Tencent Weibo.
/// Deprecated in iOS 11, as Apple removed the Social framework, which this was based on.
@available(iOS, deprecated: 11.0)
public struct TencentWeiboShareDestination: SocialShareDestination {

    public static let name = SLServiceTypeTencentWeibo
    public let name = SLServiceTypeTencentWeibo
    
    public var canShare: Bool {
        return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTencentWeibo)
    }
    
    public var activityType: UIActivityType {
        return UIActivityType(TencentWeiboShareDestination.name)
    }

    public init() {}
}

/// A ShareDestination for sharing to Sina Weibo.
/// Deprecated in iOS 11, as Apple removed the Social framework, which this was based on.
@available(iOS, deprecated: 11.0)
public struct SinaWeiboShareDestination: SocialShareDestination {
    
    public static let name = SLServiceTypeSinaWeibo
    public let name = SLServiceTypeSinaWeibo
    
    public var canShare: Bool {
        return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeSinaWeibo)
    }
 
    public var activityType: UIActivityType {
        return UIActivityType(SinaWeiboShareDestination.name)
    }

    public init() {}
}

public extension UIActivityType {
    
    /// A `UIActivityType` which indicates that a share activity was cancelled by the user.
    public static let cancelled = UIActivityType("com.plugin.cancelled")

}

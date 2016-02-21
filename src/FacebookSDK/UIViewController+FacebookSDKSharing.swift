//
//  UIViewController+FacebookSDKSharing.swift
//  Copyright © 2016 Joseph Fabisevich (@mergesort). All rights reserved.
//

import UIKit
import Communicado
import FBSDKShareKit

public extension UIViewController {

    public static var facebookSDKSharingService: String { get { "com.facebook.Facebook" } }

    public func canShareViaFacebookSDK() -> Bool {
        if let facebookURL = NSURL(string: "fb://") {
            return UIApplication.sharedApplication().canOpenURL(facebookURL)
        }

        return false
    }

    public func shareViaFacebookSDK(content: FBSDKSharingContent) {
        let dialog = FBSDKShareDialog()
        dialog.mode = .Native
        dialog.shareContent = content
        dialog.delegate = self
        dialog.fromViewController = self
        dialog.show()
    }

}

extension UIViewController: FBSDKSharingDelegate {

    public func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        self.sharingCompleted?(success: true, sharingService:UIViewController.facebookSDKSharingService)
    }

    public func sharerDidCancel(sharer: FBSDKSharing!) {
        self.sharingCompleted?(success: false, sharingService:UIViewController.cancelledSharingService)
    }

    public func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        self.sharingCompleted?(success: false, sharingService:UIViewController.facebookNativeSharingService)
    }

}

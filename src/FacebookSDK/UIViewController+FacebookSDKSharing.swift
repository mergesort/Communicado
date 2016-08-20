//
//  UIViewController+FacebookSDKSharing.swift
//  Copyright © 2016 Joseph Fabisevich (@mergesort). All rights reserved.
//

import UIKit
import Communicado
import FBSDKShareKit

public extension UIViewController {

    public static var facebookSDKSharingService: String {
        return "com.facebook.Facebook"
    }

    public func canShareViaFacebookSDK() -> Bool {
        return self.canOpenFacebookURL("fb://")
    }

    public func canShareViaFacebookMessenger() -> Bool {
        return self.canOpenFacebookURL("fb-messenger://")
    }

    public func shareViaFacebookSDK(content: FBSDKSharingContent, mode: FBSDKShareDialogMode = .Automatic) {
        let dialog = FBSDKShareDialog()
        dialog.mode = mode
        dialog.fromViewController = self
        self.shareViaFacebook(dialog, content: content)
    }

    public func shareViaFacebookMessenger(content: FBSDKSharingContent) {
        let dialog = FBSDKMessageDialog()
        self.shareViaFacebook(dialog, content: content)
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
        self.sharingCompleted?(success: false, sharingService:UIViewController.facebookSDKSharingService)
    }
    
}

private extension UIViewController {

    func canOpenFacebookURL(urlString: String) -> Bool {
        if let facebookURL = NSURL(string: urlString) {
            return UIApplication.sharedApplication().canOpenURL(facebookURL)
        }

        return false
    }

    func shareViaFacebook(dialog: FBSDKSharingDialog, content: FBSDKSharingContent) {
        dialog.shareContent = content
        dialog.delegate = self
        dialog.show()
    }
    
}

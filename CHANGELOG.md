# Change Log

# 3.1 (2018-12-26)

- Adding Swift 4.2 support.

# 3.0.1 (2017-10-06)

- Adding public initializers for `ShareDestination`s.

# 3.0 (2017-09-11)

- The underlying framework is completely rewritten. If you find any bugs, please report them. 🐛

- This version is written in and supports Swift 4. If you need to use Swift 3, use version 2.0.2 of Communicado instead.

---

#### New Features

- You can now style the background color, `UINavigationBar`'s `titleTextAttributes` (on `MFMailComposeViewController` only), and `UIBarButtonItem`'s `titleTextAttributes` on `MFMailComposeViewController` and `MFMailComposeViewController` and `MFMessageComposeViewController`.

- You can now style multiple parts of the `MFMailComposeViewController` and `MFMessageComposeViewController` experience.

##### MFMailComposeViewController
- `UINavigationBar.titleTextAttributes`
- `UINavigationBar.backgroundColor`
- `UIBarButtonItem.titleTextAttributes`

##### MFMessageComposeViewController
- `UINavigationBar.backgroundColor`
- `UIBarButtonItem.titleTextAttributes`

--- 
#### ⚠️ Breaking changes ⚠️

- You must now implement `SharingCapableViewController` on any `UIViewController` you wish to share from. The API will be unavailable otherwise.

- `TwitterShareDestination`, `FacebookShareDestination`, `TencentWeiboShareDestination`, and `SinaWeiboShareDestination` are deprecated in iOS 11 because Apple deprecated the `Social` framework. They are still supported in iOS 9 and 10.

- `TextShareParameters` has been renamed `MessagesShareParameters`.

- `PasteboardShareParameters` now accepts a `PasteboardShareParameters.Value` with a string, image, or url, rather than potentially all three.

- `SharingType` has been renamed `ShareResult`.

# 2.0.2 (2017-03-05)

- Most of the checks preventing sharing if it wasn't *possible* were based on whether `UIActivityViewController` was around, which is always true. 

Since this was due to bad copy/pasting, next time I will write things out by hand, on a blackboard, as proper punishment.

# 2.0.1 (2016-12-03)

- `ActivityShareParameters` allow for `Any` `applicationActivities`, rather than `AnyObject` to support Swift 3 Foundation converted types (like `URL` instead of `NSURL`).

# 2.0 (2016-09-14)

### This release is a completely breaking change to the API.

- The library is now compatible with Swift 3 only. The previous release will continue to work with Swift 2.2.

- This version removes FacebookSDK support, until better Swift compatibility is provided.

- There are ShareDestination providers now, which you configure with lightweight `ShareParameter` configuration structs.

- There is only one method, `.share`, which you call with the proper `ShareParameter` struct.

A simple example, for text messages looks like this:

```swift
let heartImageData = UIImagePNGRepresentation(myHeartImage)
let attachment = Attachment(attachmentType: AttachmentType.png, filename: "heart.png", data: heartImageData)
let textParameters = TextShareParameters(message: "I love my users.", attachments: [ attachment ])
self.share(textParameters)
```

Steve Holt! \o/

# 1.4 (2016-08-13)

- After thinking about it, Instagram is not a good candidate to be in Communicado, since it is non-standard behavior, and relies on a workaround Instagram may drop support for.


# 1.3.3 (2016-05-13)

- Allowing sharingCompleted event to be nil.

# 1.3.2 (2016-04-12)

- Removing Facebook subspec.

# 1.3.1 (2016-04-11)

- Adding method to save an image to the clipboard.

# 1.3 (2016-02-21)

- Adding Facebook SDK sharing for those that don't want to use iOS's limited Facebook SDK integration.


# 1.2 (2016-02-18)

- Adding public modifiers for more sharing.

# 1.1.1 (2016-02-17)

- MessageAttachment's initializer is now public so it can be used in a framework.

# 1.1.0 (2016-02-17)

- Adding Instagram and Save to camera roll.

# 1.0 (2016-02-17)

- Initial release.

# Communicado

#### Are you tired of rewriting the same sharing code over and over again?

![](gifs/cartman.gif)
#### Me too!

![](gifs/homer.gif)
#### That's why I wrote Communicado!

---

Communicado is the simplest way to share using iOS built in methods. If you use this correctly, you'll end up with a whole lot more time to sleep.

![](gifs/kitty.gif)

---

#### Let's show you how it's done.

The first thing to know is the available methods for sharing.

```swift
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

}
```

Each sharing destination takes in parameters. Let's try a simple example.

```swift
let heartImageData = UIImagePNGRepresentation(myHeartImage)
let attachment = Attachment(attachmentType: AttachmentType.png, filename: "heart.png", data: heartImageData)
let textParameters = TextShareParameters(message: "I love my users.", attachments: [ attachment ])
```

Now let's call the **ONLY** method that's even available to you.

```swift
self.share(textParameters)
```

And we're done! If everything went well, you can send a text with that wonderful heart image to all your favorite users.

**You can do the same for the other sharing types as well.**

```swift
self.share(MailShareParameters)
self.share(SocialShareParameters)
self.share(ActivityShareParameters)
self.share(PhotosShareParameters)
self.share(PasteboardShareParameters)
```

Now all you can try this for all the kinds of sharing that you'd like to use in your app!

![](gifs/yay.gif)

## Installation
You can use [CocoaPods](http://cocoapods.org/) to install `Communicado` by adding it to your `Podfile`:

```swift
platform :ios, '9.0'
use_frameworks!

pod 'Communicado'
```

Or install it manually by downloading `UIViewController+Sharing.swift` and dropping it in your project.

## About me

Hi, I'm [Joe](http://fabisevi.ch) everywhere on the web, but especially on [Twitter](https://twitter.com/mergesort).

## License

See the [license](LICENSE) for more information about how you can use Communicado. I promise it's not GPL, because I am not "that guy".

## The end?

Yes, this is the end. Hopefully Communicado makes your life easier. It probably won't help you pay your rent, but it might make it easier to share in your app.

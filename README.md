Communicado
========================

The easiest way to share from your app to anywhere, because you've got so much to say! This library is a successor to [`UIViewController+Sharing`](https://github.com/mergesort/UIViewController-Sharing).

`Communicado ` supports sharing text, URLs, images, and attachments, all through Apple's frameworks. No more implementing your own `MFMailComposeViewController` delegate, or `SLServiceBlahBlahBlah`.

> Enough talk though, show me code...

Said some impatient brat.

    if (self.canShareViaFacebook()) {
        self.shareViaFacebookWithMessage("I've got so much to say!", withImages: [ UIImage(named:"sunglasses.png") ], withURLs: [ myCoolURL ])
    } else {
        ¯\_(ツ)_/¯ // Do whatever the heck you want
    }

It's as simple as that.

You can check out all the sharing choices are below.

```
func shareViaActivityController(activityItems: [AnyObject], excludedActivityTypes: [String]?, applicationActivites: [UIActivity]?, completionItemsHandler:((activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> ())?)

func shareViaTextWithMessage(message: String?, attachments: [AnyObject]?)

func shareViaTextMessage(message: String?, attachments:[MessageAttachment]?)

func shareViaEmailWithSubject(subject: String?, message: String?, isHTML: Bool, toRecepients:[String]?, ccRecepients:[String]?, bccRecepients:[String]?, attachments:[MessageAttachment]?)

func shareViaFacebook(message: String?, images: [UIImage]?, URLs: [NSURL]?)

func shareViaTwitter(message: String?, images: [UIImage]?, URLs: [NSURL]?)

func shareViaSinaWeiboWithMessage(message: String?, images: [UIImage]?, URLs: [NSURL]?)

func shareViaTencentWeiboWithMessage(message: String?, images: [UIImage]?, URLs: [NSURL]?)

func shareViaCopyString(string: String?)

func shareViaCopyURL(URL: NSURL?)
```

Customizing the navigation bar for `MFMailComposeViewController` and `MFMessageComposeViewController` is such a pain... But not any more. Just set a couple properties and when you share, it will implement your fun look and feel. And when you're done, no harm no foul, everything gets reset.

```
var sharingBarButtonItemTintColor: UIColor?
var sharingTitleTextAttributes: [NSObject : AnyObject]?
```

Callbacks when your sharing completes are great, for example if you'd like to track analytics on where people are sharing, if into creepy things like that.

```
var sharingCompleted: ((Bool, String) -> Void)?
```

I've run out of words, so go and use the library!
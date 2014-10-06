# QXCameraKit

An objc API library for Sony QX camera
this library makes it easy to connect to Sony QX Camera utilizing objc.

this library is originally based on Camera Remote API beta SDK from Sony
http://www.sony.net/Products/di/en-gb/products/ec8t/
https://developer.sony.com/develop/cameras/
https://developer.sony.com/2013/11/29/how-to-develop-an-app-using-the-camera-remote-api-2/

### Demo

http://instagram.com/p/txmivXPIm7/

### Examples

please check this sample app
https://github.com/akirahrkw/SampleQXCameraKit

### Using blocks

```objective-c
#import <QXCameraKit/QXCameraKit.h>

...

__weak typeof (self) selfie = self;
FetchImageBlock block = ^(UIImage *image, NSError *error) {
  ...
  ...
  @synchronized(self) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [selfie.liveImageView setImage:image];
    });
  }
};

QXAPIManager *manager = [[QXAPIManager alloc] init];
[manager discoveryDevicesWithFetchImageBlock:block];

```

### Podfile
coming soon...

### Author
* Akira Hirakawa (http://www.akirahrkw.com)

## Licenses
All source code is licensed under the [MIT License](http://opensource.org/licenses/MIT)
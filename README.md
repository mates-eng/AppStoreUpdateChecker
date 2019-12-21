AppStoreUpdateChecker
======

[![Version](https://img.shields.io/cocoapods/v/AppStoreUpdateChecker.svg?style=flat)](http://cocoadocs.org/docsets/AppStoreUpdateChecker)
[![Platform](https://img.shields.io/cocoapods/p/AppStoreUpdateChecker.svg?style=flat)](http://cocoadocs.org/docsets/AppStoreUpdateChecker)

AppStoreUpdateChecker can notify you if you need to update your app.

```swift
AppStoreUpdateChecker.check { updateURL in
    print("`\(String(describing: updateURL))")
}
```

## Requirements

- Swift 5.0 or later
- iOS 9.3 or later

## Installation

#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'AppStoreUpdateChecker', '~> 1.1'` to your Podfile.
- Run `pod install`.
<p align="center">
    <img width="900px" src="Assets/artwork.jpg">
</p>

<p align="center">
<img src="https://travis-ci.com/WeTransfer/Mocker.svg?token=Ur5V2zzKmBJLmMYHKJTF&branch=master"/>
<img src="https://img.shields.io/cocoapods/v/Mocker.svg?style=flat"/>
<img src="https://img.shields.io/cocoapods/l/Mocker.svg?style=flat"/>
<img src="https://img.shields.io/cocoapods/p/Mocker.svg?style=flat"/>
<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/>
<img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat"/>
</p>

Mocker is a library written in Swift which makes it possible to mock data requests using a custom `URLProtocol`.

- [Features](#features)
- [Example](#example)
- [Requirements](#requirements)
- [Usage](#usage)
    - [Activating the Mocker](#activating-the-mocker)
	    - [Custom URLSessions](#custom-urlsessions)
	    - [Alamofire](#alamofire)
    - [Register Mocks](#register-mocks)
	    - [Create your mocked data](#create-your-mocked-data)
	    - [JSON Requests](#json-requests)
	    - [File extensions](#file-extensions)
	    - [Custom HEAD and GET response](#custom-head-and-get-response)
- [Communication](#communication)
- [Installation](#installation)
- [Release Notes](#release-notes)
- [License](#license)

## Features
_Run all your data request unit tests offline_ 🎉

- [x] Create mocked data requests based on an URL
- [x] Create mocked data requests based on a file extension
- [x] Works with `URLSession` using a custom protocol class
- [x] Supports popular frameworks like `Alamofire`

## Requirements
- Swift 3.0, 3.1, 3.2
- iOS 8.0+
- Xcode 8.1, 8.2, 8.3

## Usage

Unit tests are written for the `Mocker` which can help you to see how it works.

### Activating the Mocker
The mocker will automatically be activated for the default URL loading system like `URLSession.shared` after you've registered your first `Mock`. 

##### Custom URLSessions
To make it work with your custom `URLSession`, the `MockingURLProtocol` needs to be registered:

```swift
let configuration = URLSessionConfiguration.default
configuration.protocolClasses = [MockingURLProtocol.self]
let urlSession = URLSession(configuration: configuration)
```

##### Alamofire
Quite similar like registering on a custom `URLSession`.

```swift
let configuration = URLSessionConfiguration.default
configuration.protocolClasses = [MockingURLProtocol.self]
let sessionManager = SessionManager(configuration: configuration)
```

### Register Mocks
##### Create your mocked data
It's recommend to create a class with all your mocked data accessible. An example of this can be found in the unit tests of this project:

```swift
public final class MockedData {
    public static let botAvatarImageResponseHead: Data = Bundle(for: MockedData.self).url(forResource: "Resources/Responses/bot-avatar-image-head", withExtension: "data")!.data
    public static let botAvatarImageFileUrl: URL = Bundle(for: MockedData.self).url(forResource: "wetransfer_bot_avater", withExtension: "png")!
    public static let exampleJSON: URL = Bundle(for: MockedData.self).url(forResource: "Resources/JSON Files/example", withExtension: "json")!
}
```

##### JSON Requests
``` swift
let originalURL = URL(string: "https://www.wetransfer.com/example.json")!
    
let mock = Mock(url: originalURL, contentType: .json, statusCode: 200, data: [
    .get : MockedData.exampleJSON.data // Data containing the JSON response
])
mock.register()

URLSession.shared.dataTask(with: originalURL) { (data, response, error) in
    guard let data = data, let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
        return
    }
    
    // jsonDictionary contains your JSON sample file data
    // ..
    
}.resume()
```

##### File extensions
```swift
let imageURL = URL(string: "https://www.wetransfer.com/sample-image.png")!

Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 200, data: [
    .get: MockedData.botAvatarImageFileUrl.data
]).register()

URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
    let botAvatarImage: UIImage = UIImage(data: data!)! // This is the image from your resources.
}.resume()
```

##### Custom HEAD and GET response
```swift
let exampleURL = URL(string: "https://www.wetransfer.com/api/endpoint")!

Mock(url: exampleURL, contentType: .json, statusCode: 200, data: [
    .head: MockedData.headResponse.data,
    .get: MockedData.exampleJSON.data
]).register()

URLSession.shared.dataTask(with: exampleURL) { (data, response, error) in
	// data is your mocked data
}.resume()
```

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Mocker into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Mocker', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Mocker into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "WeTransfer/Mocker" ~> 1.00
```

Run `carthage update` to build the framework and drag the built `Mocker.framework` into your Xcode project.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate Mocker into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add Mocker as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/WeTransfer/Mocker.git
  ```

- Open the new `Mocker ` folder, and drag the `Mocker.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `Mocker.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Select `Mocker.framework`.
- And that's it!

  > The `Mocker.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

---

## Release Notes

See [CHANGELOG.md](https://github.com/WeTransfer/Mocker/blob/master/Changelog.md) for a list of changes.

## License

Mocker is available under the MIT license. See the LICENSE file for more info.

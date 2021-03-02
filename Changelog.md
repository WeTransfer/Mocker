### 2.5.2
- Fixing usage of XCTest framework ([#89](https://github.com/WeTransfer/Mocker/pull/89)) via [@letatas](https://github.com/letatas)
- Merge release 2.5.1 into master ([#87](https://github.com/WeTransfer/Mocker/pull/87)) via [@wetransferplatform](https://github.com/wetransferplatform)

### 2.5.1
- Fix tests and make sure the new opt-in mode is working with existing logic ([#86](https://github.com/WeTransfer/Mocker/pull/86)) via [@AvdLee](https://github.com/AvdLee)
- Merge release 2.5.0 into master ([#85](https://github.com/WeTransfer/Mocker/pull/85)) via [@wetransferplatform](https://github.com/wetransferplatform)

### 2.5.0
- Feat: Global mode to choose only to mock registered routes ([#84](https://github.com/WeTransfer/Mocker/pull/84)) via [@letatas](https://github.com/letatas)
- Update README.md ([#74](https://github.com/WeTransfer/Mocker/pull/74)) via [@airowe](https://github.com/airowe)

### 2.3.0
- Add XCTest extensions ([#57](https://github.com/WeTransfer/Mocker/pull/57)) via [@AvdLee](https://github.com/AvdLee)
- Merge release 2.2.0 into master ([#55](https://github.com/WeTransfer/Mocker/pull/55)) via [@WeTransferBot](https://github.com/WeTransferBot)

### 2.2.0
- ignoring query example swap i/o url ([#54](https://github.com/WeTransfer/Mocker/pull/54)) via [@GeRryCh](https://github.com/GeRryCh)
- Update README.md ([#53](https://github.com/WeTransfer/Mocker/pull/53)) via [@mtsrodrigues](https://github.com/mtsrodrigues)
- mixing in the ability to send an explicit error from a mock response ([#52](https://github.com/WeTransfer/Mocker/pull/52)) via [@heckj](https://github.com/heckj)
- Document that onRequest and completion must be set before calling register() ([#47](https://github.com/WeTransfer/Mocker/pull/47)) via [@marcetcheverry](https://github.com/marcetcheverry)
- Update readme for Alamofire 5 ([#48](https://github.com/WeTransfer/Mocker/pull/48)) via [@AvdLee](https://github.com/AvdLee)
- Merge release 2.1.0 into master ([#46](https://github.com/WeTransfer/Mocker/pull/46)) via [@WeTransferBot](https://github.com/WeTransferBot)

### 2.1.0
- Enable post body checks ([#41](https://github.com/WeTransfer/Mocker/pull/41)) via @AvdLee
- Merge release 2.0.2 into master ([#40](https://github.com/WeTransfer/Mocker/pull/40))

### 2.0.2

- Make use of the shared SwiftLint script ([#39](https://github.com/WeTransfer/Mocker/pull/39)) via @AvdLee
- Enable tag releasing ([#38](https://github.com/WeTransfer/Mocker/pull/38)) via @AvdLee

### 2.0.1

- Switch over to Danger-Swift & Bitrise ([#34](https://github.com/WeTransfer/Mocker/pull/34)) via @AvdLee
- Fix important mismatch for getting the right mock ([#31](https://github.com/WeTransfer/Mocker/pull/31)) via @AvdLee

### 2.0.0
- A new completion callback can be set on `Mock` to use for expectation fulfilling once a `Mock` is completed.
- A new onRequest callback can be set on `Mock` to use for expectation fulfilling once a `Mock` is requested.
- Updated to Swift 5.0
- Only dispatch to the background queue if needed
- Correctly handle cancellation of delayed responses
- Adding and reading mocks is now thread safe by using a Dispatch Semaphore
- Add support for using Swift Package Manager
- Improved checking for Mocks using `URLRequest`.

### 1.3.0
- Updated to Swift 4.2

### 1.2.1 (2018-09-11)
- Improved CI
- Better matching Mocks based on `absoluteString`
- Migrated to Swift 4.1

### 1.2.0 (2018-02-09)
- Ignoring query path for mocks
- Missing mocks no longer break tests (removed fatalError)
- Improved SwiftLint implementation

### 1.1.0 (2017-11-03)
- Adds support for delayed responses
- Adds support for ignoring URLs
- Adds support for redirects
- Migrated to Swift 4.0

### 1.0 (2017-08-11)

- First public release! 🎉

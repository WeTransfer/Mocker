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

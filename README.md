# WeatherForecast

## Folder Structure:
          .Weather
          ├── Weather
          │   └── Style
          │   └── Screens
          │     └── BaseViewController
          │     └── WeatherList
          │       └── Config
          │       └── Services
          │       └── Services
          │       └── Model
          │       └── View
          │       └── ViewModel
          ├── Cacheable
          ├── ImageLoader
          ├── NetworkService
          ├── Extension
          ├── WeatherTests
          ├── WeatherUITests
          └── WeatherUITests

## High level overview
### MVVM+RxSwift: 
I choose MVVM+RxSwift [MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel) pattern and heavy use of [RxSwift] which make biding easier.
Dependency inversion principle: All of the dependencies will be injected to ViewModel through Protocol which make ViewModel more testable 
In MVVM ViewModel
will mostly handle business logic: 
- Received event search or loadview from view
- Check Search logic to make sure text contains more than three characters before triggering search request, also make debounce in 300ms to reduce request trigger
- Check if data from Cache is valid, then emit an event to update view while triggering request to the server, this is to make sure the app will always use the latest data. Therefore, it will show cache data to use while fetching new data from the server.
Since weather data change constantly, it's better to let the user get the newest update, and not to wait too long 
- Making new server request to get the newest data. After getting the response, trigger another event to reload view with data from server
- Handle error event from server-side
- After getting a successful response from server, trigger event to store response into Cache
### Network Layer
##### Network layer is an abstract layer that exposes an protocol to make the API request
- NetworkServiceType: Is a protocol to expose to outside to make API Request
- RequestType Protocol: Provide an interface for requesting input, such as: path, method, parameter, etc.
- EnvironmentProtocol: Provide interface to config some constants for API request 
- APIError: Customize Error for API request
- Method: GET/POST/PUT/DELETE
- URLSessionNetworkService is an URLSession implementation of NetworkServiceType
### Cacheable Layer
- CacheProtocol is a main interface of Cache layer which is exposed to outside a way to set/get from cache with the given key
- In this implementation: PersistentCache is an implementaion of CacheProtocol that will store data to [Document Directory](https://developer.apple.com/documentation/foundation/filemanager/searchpathdirectory/documentdirectory)
. Since this app just fetch and show data from server, I choose File Store approach. However, if we need to store in other ways, we can make other implementaion that conform with CacheProtocol. This will not affect the one which are using Cache.
### Image Loader
#### ImageLoader is Singleton which provides the ability to download and cache image, ImageLoader requires to provide implementations of ImadeDownloadType and ImageCacheType
By default, ImageLoader will use NSCache and URLSession for caching and downloading image.
Following Image best practice to reduce memory consumption when loading image to UIImageView. The UIImage should be resized before it is loaded into the container. After downloading the image, it
will be resized into the proper size. Key using for cache is the combine of url and size to avoid load inconsistence size or scale between image and container
## Dependencies
#### Dependencies will be installed through [Swift Package Manager](https://swift.org/package-manager/)
- RxSwift 6.2.0
- RxSwiftExt 6.1.0
## UnitTesting
- Most of the business logic in ViewModel, Network Layer, Cache and ImageLoader are covered by UnitTest
## UITesting
#### Making UI testable by acess acessibility identifier to do some flow tests:
-  Assert UI component exist
-  Search should render result in Tableview
-  Search with incorect location will show Error popup
## Accessibility for Disability Supports:
- Scaling Text is supported to change the font size. It has not yet supported the size of any item if the font is too large
- VoiceOver: The screen reader is enable by VoiceOver. However, some components is still not yet supported

## TODO
- Error Handler needs to be more friendly to use. It can be placed inside Weather List. By this approach, users can continute to type search text while seeing the error.
- UITesting is depending on real API, it can be solved by send `launchArguments` and catch it in CommandLine.arguments to modify app flow while runing. 
- Networklayer, Cache, ImageDownload can be separated into small modular like frameworks; therefore, it will be easier to maintain or reuse. 
## Checklist
- [x] The application is a simple iOS application that is written by Swift.
- [x] The application is able to retrieve the weather information from OpenWeatherMaps API. 
- [x] The application is able to allow user to input the searching term.
- [x] The application is able to proceed searching with a condition of the search term length must be from 3 characters or above.
- [x] The application is able to render the searched results as a list of weather items.
- [x] The application is able to support caching mechanism so as to prevent the app from generating a bunch of API requests.
- [x] The application is able to manage caching mechanism & lifecycle.  
- [x] The application is able to load the weather icons remotely and displayed on every weather item at the right-hand-side.
- [x] The application is able to handle failures.
- [x] Acceptance Tests
- [ ] The application is able to support the disability to scale large text for who can't see the text clearly
- [ ] The application is able to support the disability to read out the text using VoiceOver controls.

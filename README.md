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
- Check Search logic make sure text is more than three characters before trigger search request, also make debounce 300ms to avoid reduce request trigger
- Check data from Cache if valid then emit an event to update view other hand trigger request to the server, by this way it can make sure the app will always use latest data. So it will show cache data to use while fetching new data from the server.
Since weather data change recently so it better to let the user get the newest update also not let use wait to long 
- Making new server request to get newest data, after get response trigger another even to reload view with data from server
- Handle error event from server-side
- After getting a successful response from server trigger event to store response to Cache
### Network Layer
##### Network layer is an abstract layer that exposes an protocol to making API request
- NetworkServiceType: Is a protocol expose to outside to make API Request
- RequestType Protocol: Provide an interface for request input lie: path, method, parameter, etc.
- EnvironmentProtocol: Provide interface to config some API request constants
- APIError: Customize Error for API request
- Method: GET/POST/PUT/DELETE
- URLSessionNetworkService is an URLSession implementation of NetworkServiceType
### Cacheable Layer
- CacheProtocol is main interface of Cache layer which is expose to out side the way to set/get from cache with given key
- In this implementation: PersistentCache is an implementaion of CacheProtocol which will store data to [Document Directory](https://developer.apple.com/documentation/foundation/filemanager/searchpathdirectory/documentdirectory)
. Since this app just fetch and show data from server so I choose File Store approach but if we need more securer or datase store then we can make other implementaion conform with CacheProtocol, it will not affect the one which are using Cache.
### Image Loader
#### ImageLoader is Singleton which provide ability to download and cache image, ImageLoader required to provide implementations of ImadeDownloadType and ImageCacheType
By Default ImageLoader will use NSCache and URLSession for cache and download image.
Following Image best practice to reduce memory consumption when loading image to UIImageView, the UIImage should be resized before it loads into the container. The image after download
will be resized into the proper size. Key using for cache is the combine of url and size to avoid load inconsistence size or scale between image and container
## Dependencies
#### Dependencies will be installed through [Swift Package Manager](https://swift.org/package-manager/)
- RxSwift 6.2.0
- RxSwiftExt 6.1.0
## UnitTest
- Most of business logic in ViewModel, Network Layer, Cache and ImageLoader are covered by UnitTest
## Accessibility for Disability Supports:
- Scaling Text is supported to change size of the font size, not yet support the size of any item if the font is too large
- VoiceOver: The screen now able to read be VoiceOver but some components still not yet supported
## TODO
- Error Handler needs more friendly to use, it can be placed inside of Weather List. By this approach, use can continute to type search text while seeing the error.
- Missing UITesting 
- Networklayer, Cache, ImageDownload can be separated into small modular like frameworks, it will be easier to maintain or reuse. 
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
- [ ] The application is able to support the disability to scale large text for who can't see the text clearly
- [ ] The application is able to support the disability to read out the text using VoiceOver controls.

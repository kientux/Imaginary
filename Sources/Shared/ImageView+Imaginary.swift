import Foundation
import Cache

extension ImageView {
  public func setImage(url: URL?,
                       placeholder: Image? = nil,
                       configuration: Configuration = Configuration.default,
                       completion: Completion? = nil) {
    image = placeholder

    guard let url = url else {
      return
    }

    if let fetcher = fetcher {
      fetcher.cancel()
      self.fetcher = nil
    }

    configuration.imageStorage?.async.object(ofType: ImageWrapper.self,
                                             forKey: url.absoluteString) { [weak self] result in
      guard let `self` = self else {
        return
      }

      if case .value(let wrapper) = result {
        DispatchQueue.main.async {
          configuration.transitionClosure(self, wrapper.image)
          completion?(wrapper.image)
        }

        return
      }

      if placeholder == nil {
        DispatchQueue.main.async {
          configuration.preConfigure?(self)
        }
      }

      DispatchQueue.main.async {
        self.fetchFromNetwork(url: url, configuration: configuration, completion: completion)
      }
    }
  }

  fileprivate func fetchFromNetwork(url: URL, configuration: Configuration = Configuration.default, completion: Completion? = nil) {
    fetcher = Fetcher(url: url)
    fetcher?.start(configuration.preprocess) { [weak self] result in
      guard let `self` = self else {
        return
      }

      switch result {
      case let .success(image, bytes):
        configuration.track?(url, nil, bytes)
        configuration.transitionClosure(self, image)
        let wrapper = ImageWrapper(image: image)
        configuration.imageStorage?.async.setObject(wrapper, forKey: url.absoluteString, expiry: nil) { _ in
          // Don't care about result for now
        }
        completion?(image)
      case let .failure(error):
        configuration.track?(url, error, 0)
      }

      configuration.postConfigure?(self)
    }
  }

  var fetcher: Fetcher? {
    get {
      let wrapper = objc_getAssociatedObject(self, &Capsule.ObjectKey) as? Capsule
      let fetcher = wrapper?.concept as? Fetcher
      return fetcher
    }
    set (fetcher) {
      var wrapper: Capsule?
      if let fetcher = fetcher {
        wrapper = Capsule(concept: fetcher)
      }
      objc_setAssociatedObject(self, &Capsule.ObjectKey,
                               wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

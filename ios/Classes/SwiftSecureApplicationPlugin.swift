import Flutter
import UIKit

public class SwiftSecureApplicationPlugin: NSObject, FlutterPlugin {
    var secured = false;
    var secureView = UIVisualEffectView()
    var opacity: CGFloat = 0.2;
    var useLaunchImage: Bool = false;
    var backgroundColor: UIColor = UIColor.white;

    var backgroundTask: UIBackgroundTaskIdentifier!
    
    internal let registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
      super.init()
      registrar.addApplicationDelegate(self)
    }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_application", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureApplicationPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }


  public func applicationWillResignActive(_ application: UIApplication) {
    if ( secured ) {
        self.registerBackgroundTask()
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                   return w.isHidden == false
        }).first {
            if (useLaunchImage) {
                if let existingView = window.viewWithTag(99697) {
                    window.bringSubviewToFront(existingView)
                    return
                } else {
                    let imageView = UIImageView.init(frame: window.bounds)
                    imageView.tag = 99697
                    imageView.backgroundColor = backgroundColor
                    imageView.clipsToBounds = true
                    imageView.contentMode = .center
                    imageView.image = UIImage(named: "LaunchImage")
                    imageView.isMultipleTouchEnabled = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false

                    window.addSubview(imageView)
                    window.bringSubviewToFront(imageView)

                    window.snapshotView(afterScreenUpdates: true)
                    RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
                }
            } else {
                if let existingView = window.viewWithTag(99699), let existingBlurrView = window.viewWithTag(99698) {
                    window.bringSubviewToFront(existingView)
                    window.bringSubviewToFront(existingBlurrView)
                    return
                } else {
                    let colorView = UIView(frame: window.bounds);
                    colorView.tag = 99699
                    colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    colorView.backgroundColor = backgroundColor.withAlphaComponent(opacity)
                    window.addSubview(colorView)
                    window.bringSubviewToFront(colorView)

                    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.frame = window.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                    blurEffectView.tag = 99698

                    window.addSubview(blurEffectView)
                    window.bringSubviewToFront(blurEffectView)
                    window.snapshotView(afterScreenUpdates: true)
                    RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
                }
            }
        }
    self.endBackgroundTask()
    }
  }
   func registerBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(self.backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
       public func applicationWillEnterForeground(_ application: UIApplication) {
        self.unlockApp()
       }

    public func applicationWillResignActive(_ application: UIApplication) {
        if !secured { return }
        self.lockApp()
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        self.unlockApp()
    }
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
        case "secure":
            secured = true;
            if let args = call.arguments as? Dictionary<String, Any> {
                if let opacity = args["opacity"] as? NSNumber {
                    self.opacity = opacity as! CGFloat
                }
                if let useLaunchImage = args["useLaunchImage"] as? Bool {
                    self.useLaunchImage = useLaunchImage
                }

                if let backgroundColor = args["backgroundColor"] as? String {
                    self.backgroundColor = hexStringToUIColor(hex: backgroundColor)
                }
            }
        case "open" :
            secured = false;
            self.unlockApp()
            result(nil)
        case "opacity": 
            if let args = call.arguments as? Dictionary<String, Any>,
              let opacity = args["opacity"] as? NSNumber {
              self.opacity = opacity as! CGFloat
              }
            result(nil)  
        case "backgroundColor": 
            if let args = call.arguments as? Dictionary<String, Any>,
                let backgroundColor = args["backgroundColor"] as? String {
            self.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            }
        case "useLaunchImage":
            if let args = call.arguments as? Dictionary<String, Any>,
                let useLaunchImage = args["useLaunchImage"] as? Bool {
            self.useLaunchImage = useLaunchImage
        }
        case "unlock":
            if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                    return w.isHidden == false
            }).first {
                if let colorView = window.viewWithTag(99699), let blurrView = window.viewWithTag(99698) {
                    UIView.animate(withDuration: 0.5, animations: {
                        colorView.alpha = 0.0
                    }, completion: { finished in
                        colorView.removeFromSuperview()
                        blurrView.removeFromSuperview()
                    })
                }

                if let imageView = window.viewWithTag(99697) {
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 0.0
                    }, completion: { finished in
                        imageView.removeFromSuperview()
                    })
                }
            }
    }
  }
  private func unlockApp() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.secureView.backgroundColor = UIColor(white: 1, alpha: 0.0)
            self.secureView.effect = nil
        }, completion: { [weak self] (_) in
            guard let self else { return }
            self.secureView.removeFromSuperview()
        })
    }
    
    private func lockApp() {
        let window = UIApplication.shared.windows.first
        
        if let window, !self.secureView.isDescendant(of: window) {
            self.secureView.frame = window.bounds
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.secureView.backgroundColor = UIColor(white: 1, alpha: self.opacity)
                self.secureView.effect = UIBlurEffect(style: .light)
            }
            window.addSubview(self.secureView)
            window.snapshotView(afterScreenUpdates: true)
        }
    }

  func hexStringToUIColor (hex:String) -> UIColor {
      var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

      if (cString.hasPrefix("#")) {
          cString.remove(at: cString.startIndex)
      }

      if ((cString.count) != 6) {
          return UIColor.gray
      }

      var rgbValue:UInt64 = 0
      Scanner(string: cString).scanHexInt64(&rgbValue)

      return UIColor(
          red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
          green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
          blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
          alpha: CGFloat(1.0)
      )
  }
}

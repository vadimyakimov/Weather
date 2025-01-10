import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
                
        let navigationViewModel = MainNavigationViewModel()
        let navigationController = MainNavigationController(viewModel: navigationViewModel)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        return true
    }

}


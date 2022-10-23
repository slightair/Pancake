import ComposableArchitecture
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct PancakeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            PancakeView(
                store: Store(
                    initialState: Pancake.State(),
                    reducer: Pancake()
                        ._printChanges()
                        .dependency(\.bleAdvertisementScanner, MockBLEAdvertisementScanner())
                        .dependency(\.bleAdvertisementClient, .mock)
                        .dependency(\.metricsClient, .saveDryRun)
                )
            )
        }
    }
}

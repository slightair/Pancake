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

    private enum Mode {
        case development
        case production
    }

    private func makeStore(mode: Mode) -> StoreOf<Pancake> {
        switch mode {
        case .development:
            return Store(
                initialState: Pancake.State(),
                reducer: Pancake()
                    ._printChanges()
                    .dependency(\.bleAdvertisementScanner, MockBLEAdvertisementScanner())
                    .dependency(\.bleAdvertisementClient, .mock)
                    .dependency(\.metricsClient, .saveDryRun)
            )
        case .production:
            return Store(
                initialState: Pancake.State(),
                reducer: Pancake()
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            PancakeView(store: makeStore(mode: .development))
        }
    }
}

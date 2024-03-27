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
            Store(initialState: Pancake.State()) {
                Pancake()
            } withDependencies: {
                $0.bleAdvertisementScanner = MockBLEAdvertisementScanner()
                $0.bleAdvertisementClient = .mock
                $0.metricsClient = .saveDryRun
            }
        case .production:
            Store(initialState: Pancake.State()) {
                Pancake()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            PancakeView(store: makeStore(mode: .development))
        }
    }
}

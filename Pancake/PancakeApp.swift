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

    private func makeStore(mode: Mode) -> StoreOf<AppFeature> {
        switch mode {
        case .development:
            Store(initialState: AppFeature.State()) {
                AppFeature()
            } withDependencies: {
                $0.bleAdvertisementScanner = MockBLEAdvertisementScanner()
                $0.bleAdvertisementClient = .mock
                $0.metricsClient = .saveDryRun
            }
        case .production:
            Store(initialState: AppFeature.State()) {
                AppFeature()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: makeStore(mode: .development))
        }
    }
}

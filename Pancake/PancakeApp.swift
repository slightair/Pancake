import ComposableArchitecture
import SwiftUI

@main
struct PancakeApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: .live
                )
            )
        }
    }
}

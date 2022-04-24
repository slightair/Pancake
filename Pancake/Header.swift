import ComposableArchitecture
import Foundation
import SwiftUI

struct HeaderState: Equatable, Identifiable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    let id = UUID()
    var date = Date()

    var dateString: String {
        Self.dateFormatter.string(from: date)
    }
}

enum HeaderAction: Equatable {
    case timeUpdate(Date)
}

struct HeaderEnvironment {}

let headerReducer = Reducer<HeaderState, HeaderAction, HeaderEnvironment> { state, action, _ in
    switch action {
    case let .timeUpdate(date):
        state.date = date
        return .none
    }
}

struct HeaderView: View {
    let store: Store<HeaderState, HeaderAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .topLeading) {
//                AsyncImage(url: URL(string: "https://via.placeholder.com/834x469"))
//                AsyncImage(url: URL(string: "https://drscdn.500px.org/photo/1047170708/q%3D80_m%3D2000/v2?sig=9a6cbb90ec8e42f1c34cc870488f44c00c491a687820a81601296bf91454213f"))
//                    .frame(width: .infinity, height: 400)
//                    .aspectRatio(3 / 1, contentMode: .fit)
                Rectangle()
                    .foregroundColor(Color(white: 0.9))
                    .aspectRatio(3 / 1, contentMode: .fit)
                HStack(alignment: .top) {
                    Text(viewStore.dateString)
                    Spacer()
                }
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            store: Store(
                initialState: HeaderState(),
                reducer: headerReducer,
                environment: HeaderEnvironment()
            )
        )
    }
}

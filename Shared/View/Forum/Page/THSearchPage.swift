import SwiftUI

struct THSearchPage: View {
    @EnvironmentObject private var model: THSearchModel
    
    var body: some View {
        THBackgroundList {
            if !model.history.isEmpty && model.searchText.isEmpty {
                searchHistory
            }
            
            if let matchFloor = model.matchFloor {
                NavigationLink(value: THHoleLoader(floorId: matchFloor)) {
                    Label("##\(String(matchFloor))", systemImage: "arrow.right.square")
                }
            }
            
            if let matchHole = model.matchHole {
                NavigationLink(value: THHoleLoader(holeId: matchHole)) {
                    Label("#\(String(matchHole))", systemImage: "arrow.right.square")
                }
            }
            
            ForEach(model.matchTags) { tag in
                NavigationLink(value: tag) {
                    Label(tag.name, systemImage: "tag")
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchHistory: some View {
        HStack {
            Text("Recent Search")
            Spacer()
            Button {
                model.clearHistory()
            } label: {
                Text("Clear History")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
        }
        .font(.callout)
        .bold()
        .listRowSeparator(.hidden)
        
        ForEach(model.history, id: \.self) { history in
            Button {
                model.searchText = history
            } label: {
                Label {
                    Text(history)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "clock")
                }
            }
        }
    }
}


struct THSearchResultPage: View {
    @EnvironmentObject var navigationModel: THNavigationModel
    @EnvironmentObject var model: THSearchModel
    
    var body: some View {
        List {
            AsyncCollection { floors in
                try await THRequests.searchKeyword(keyword: model.searchText, startFloor: floors.count)
            } content: { floor in
                NavigationListRow(value: THHoleLoader(floor)) {
                    THSimpleFloor(floor: floor)
                }
            }
        }
        .listStyle(.inset)
    }
}

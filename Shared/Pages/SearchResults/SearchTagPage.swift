import SwiftUI

struct SearchTagPage: View {
    let tagname: String
    let divisionId: Int?
    @State private var endReached = false
    @State var holes: [THHole] = []
    
    @State var loading = false
    @State var errorInfo = ErrorInfo()
    
    func loadMoreHoles() async {
        do {
            loading = true
            defer { loading = false }
            let newHoles = try await NetworkRequests.shared.searchTag(tagName: tagname, divisionId: divisionId, startTime: holes.last?.updateTime.ISO8601Format())
            endReached = newHoles.isEmpty
            holes.append(contentsOf: newHoles)
        } catch NetworkError.ignore {
            // cancelled, ignore
        } catch let error as NetworkError {
            errorInfo = error.localizedErrorDescription
        } catch {
            errorInfo = ErrorInfo(title: "Unknown Error",
                                  description: "Error description: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(holes) { hole in
                    HoleView(hole: hole)
                        .background(NavigationLink("", destination: HoleDetailPage(hole: hole)).opacity(0))
                        .task {
                            if hole == holes.last {
                                await loadMoreHoles()
                            }
                        }
                }
            } footer: {
                if !endReached {
                    if !endReached {
                        ListLoadingView(loading: $loading,
                                        errorDescription: errorInfo.description,
                                        action: loadMoreHoles)
                    }
                }
            }
        }
        .task {
            if holes.isEmpty {
                await loadMoreHoles()
            }
        }
        .listStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(tagname)
    }
}

struct SearchTagPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchTagPage(tagname: "test", divisionId: 1)
    }
}

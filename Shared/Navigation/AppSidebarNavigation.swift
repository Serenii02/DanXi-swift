import SwiftUI

struct AppSidebarNavigation: View {
    @ObservedObject var model = treeholeDataModel

    enum NavigationItem {
        case treehole
        case settings
    }

    @State private var selection: NavigationItem? = .treehole
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(tag: NavigationItem.treehole, selection: $selection) {
                    Group {
                        if (model.loggedIn) {
                            TreeholePage()
                        } else {
                            WelcomePage()
                        }
                    }
                } label: {
                    Label("treehole", systemImage: "text.bubble")
                }
                
                NavigationLink(tag: NavigationItem.settings, selection: $selection) {
                    SettingsPage()
                } label: {
                    Label("settings", systemImage: "gearshape")
                }
            }
            .navigationTitle("danxi")
            
            EmptyView()
            EmptyView()
        }
        // FIXME: unable to simultaneously satisfy constraints on iPad (wide screen)
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    
    static var previews: some View {
        AppSidebarNavigation()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.landscapeRight)
    }
}

import SwiftUI

struct AppTabNavigation: View {
    @ObservedObject var model = TreeholeDataModel.shared
    
    enum Tab {
        case treehole
        case curriculum
        case campusInfo
        case settings
    }
    
    @State private var selection: Tab = .treehole
    
    var body: some View {
        TabView(selection: $selection) {
            Group {
                if model.loggedIn {
                    NavigationView {
                        TreeholePage()
                    }
                } else {
                    TreeholeWelcomePage()
                }
            }
            .tabItem {
                Image(systemName: "text.bubble")
                Text("Tree Hole")
            }
            .tag(Tab.treehole)
            
            Group {
                if model.loggedIn {
                    NavigationView {
                        CourseMainPage()
                    }
                } else {
                    CourseWelcomePage()
                }
            }
            .tabItem {
                Image(systemName: "books.vertical.fill")
                Text("Curriculum")
            }
            .tag(Tab.curriculum)
            
            // Temporary disable this section, will restore when necessary functions  are completed
//            NavigationView {
//                CampusInfoPage()
//            }
//            .tabItem {
//                Image(systemName: "books.vertical.fill")
//                Text("Campus Info")
//            }
//            .tag(Tab.campusInfo)
            
            NavigationView {
                SettingsPage()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }
            .tag(Tab.settings)
        }
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppTabNavigation()
            AppTabNavigation()
                .preferredColorScheme(.dark)
        }
    }
}

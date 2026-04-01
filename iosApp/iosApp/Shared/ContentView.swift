import SwiftUI
import Shared

@main
struct BDQRGenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: QRViewModel())
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: QRViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WebsiteView(viewModel: viewModel)
                .tabItem {
                    Label("Website", systemImage: "link")
                }
                .tag(0)
            
            WifiView(viewModel: viewModel)
                .tabItem {
                    Label("WiFi", systemImage: "wifi")
                }
                .tag(1)
            
            ContactView(viewModel: viewModel)
                .tabItem {
                    Label("Contact", systemImage: "person")
                }
                .tag(2)
            
            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "square.and.arrow.down")
                }
                .tag(3)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(4)
        }
    }
}
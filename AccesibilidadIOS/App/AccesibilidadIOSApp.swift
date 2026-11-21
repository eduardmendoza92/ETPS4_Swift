import SwiftUI

@main
struct AccesibilidadIOSApp: App {
    @StateObject private var preferences = AppPreferences()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .environmentObject(preferences)
        }
    }
}

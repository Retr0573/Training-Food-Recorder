import SwiftUI

@main
struct HelloIOSApp: App {
    let persistentContainer = PersistentController.shared.container

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}

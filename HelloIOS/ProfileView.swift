import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("User Name")
                                .font(.headline)
                            Text("Edit Profile")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.vertical, 10)
                }
                
                Section("Settings") {
                    NavigationLink(destination: Text("Personal Information")) {
                        Label("Personal Information", systemImage: "person")
                    }
                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    NavigationLink(destination: Text("Privacy")) {
                        Label("Privacy", systemImage: "lock")
                    }
                }
                
                Section("About") {
                    NavigationLink(destination: Text("Help Center")) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    NavigationLink(destination: Text("About Us")) {
                        Label("About Us", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
} 
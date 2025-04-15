import SwiftUI
import CoreData

struct TrainingPlanView: View {
    // 使用 @FetchRequest 获取 Core Data 中的 T_Theme 数据
    @FetchRequest(
        entity: T_Theme.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \T_Theme.name, ascending: true)]
    ) private var themes: FetchedResults<T_Theme>
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTheme = false

    var body: some View {
        NavigationView {
            List {
                // 遍历 Core Data 中的 T_Theme 数据
                ForEach(themes) { theme in
                    NavigationLink(
                        destination: TrainingThemeView(theme: theme, context: viewContext)
                    ) {
                        ThemeRowView(theme: theme)
                    }
                }
                .onDelete(perform: deleteThemes)
            }
            .navigationTitle("训练计划")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTheme = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTheme) {
                AddThemeView(isPresented: $showingAddTheme)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteThemes(at offsets: IndexSet) {
        for index in offsets {
            let theme = themes[index]
            viewContext.delete(theme)
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

import SwiftUI
import CoreData

struct AddThemeView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var themeName = ""
    @State private var themeNote = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("主题信息")) {
                    TextField("主题名称", text: $themeName)
                    TextField("备注（可选）", text: $themeNote)
                }
            }
            .navigationTitle("新建训练主题")
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                },
                trailing: Button("保存") {
          
                    saveTheme()
                }
                .disabled(themeName.isEmpty)
            )
        }
    }

    private func saveTheme() {
        let newTheme = T_Theme(context: viewContext)
        newTheme.id = UUID()
        newTheme.name = themeName
        newTheme.note = themeNote.isEmpty ? nil : themeNote
        
        do {
            try viewContext.save()
            isPresented = false
        } catch let error as NSError {
            print("Error saving theme: \(error), \(error.userInfo)")
        }
    }
}

import SwiftUI

struct ThemeRowView: View {
    let theme: T_Theme

    var body: some View {
        VStack(alignment: .leading) {
            Text(theme.name ?? "未命名主题")
                .font(.headline)
            if let note = theme.note {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

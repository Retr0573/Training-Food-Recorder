import SwiftUI
import CoreData
// 使用 @StateObject 初始化 RecordPlanViewModel。
// 通过 viewModel.themes 渲染卡片视图。
struct RecordPlanView: View {
    @StateObject private var viewModel: RecordPlanViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecordPlanViewModel(context: context))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.themes, id: \.id) { theme in
                    CardView(theme: theme)
                }
            }
            .padding()
        }
        .navigationTitle("训练计时")
    }
}

struct CardView: View {
    let theme: T_Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(theme.name ?? "未命名主题")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let note = theme.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
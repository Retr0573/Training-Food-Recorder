import SwiftUI
import CoreData
// 使用 @StateObject 初始化 RecordThemeViewModel。
// 通过 viewModel.items 渲染卡片视图，展示 T_Item 的名称和备注。
// 点击某个 T_Item 时，弹出确认对话框，确认后导航到 RecordItemView。
// struct RecordThemeView: View {
//     @StateObject private var viewModel: RecordThemeViewModel
//     @State private var showConfirmationDialog = false
//     @State private var selectedItem: T_Item?
//     @State private var navigateToRecordItem = false

//     init(context: NSManagedObjectContext, theme: T_Theme) {
//         _viewModel = StateObject(wrappedValue: RecordThemeViewModel(context: context, theme: theme))
//     }

//     var body: some View {
//         ScrollView {
//             VStack(spacing: 16) {
//                 ForEach(viewModel.items, id: \.id) { item in
//                     Button(action: {
//                         selectedItem = item
//                         showConfirmationDialog = true
//                     }) {
//                         ItemCardView(item: item)
//                     }
//                 }
//             }
//             .padding()
//         }
//         .navigationTitle(viewModel.currentTheme.name ?? "未命名主题")
//         .confirmationDialog("是否开始训练 \(viewModel.currentTheme.name ?? "该主题")？", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
//             Button("开始训练") {
//                 navigateToRecordItem = true
//             }
//             Button("取消", role: .cancel) {}
//         }
//         // .background(
//         //     NavigationLink(
//         //         destination: selectedItem.map { item in
//         //             AnyView(RecordItemView(context: viewModel.managedObjectContext, item: item))
//         //         } ?? AnyView(EmptyView()), // 确保返回的类型一致
//         //         isActive: $navigateToRecordItem,
//         //         label: { EmptyView() }
//         //     )
//         //     .hidden()
//         // )
//     }
// }
struct RecordThemeView: View {
    @StateObject private var viewModel: RecordThemeViewModel
    @State private var showConfirmationDialog = false
    @State private var selectedItem: T_Item?
    @State private var navigateToRecordItem = false

    init(context: NSManagedObjectContext, theme: T_Theme) {
        _viewModel = StateObject(wrappedValue: RecordThemeViewModel(context: context, theme: theme))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.items, id: \.id) { item in
                    Button(action: {
                        selectedItem = item
                        showConfirmationDialog = true
                    }) {
                        ItemCardView(item: item)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.currentTheme.name ?? "未命名主题")
        .confirmationDialog("是否开始训练 \(viewModel.currentTheme.name ?? "该主题")？", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("开始训练") {
                navigateToRecordItem = true
            }
            Button("取消", role: .cancel) {}
        }
        .navigationDestination(isPresented: $navigateToRecordItem) {
            if let selectedItem = selectedItem {
                RecordItemView(context: viewModel.managedObjectContext, item: selectedItem)
            }
        }
    }
}
struct ItemCardView: View {
    let item: T_Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name ?? "未命名项目")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let note = item.note, !note.isEmpty {
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

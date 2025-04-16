import SwiftUI
import CoreData

struct RecordItemView: View {
    @StateObject private var viewModel: RecordItemViewModel

    init(context: NSManagedObjectContext, item: T_Item) {
        _viewModel = StateObject(wrappedValue: RecordItemViewModel(context: context, item: item))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.sets, id: \.id) { set in
                    SetCardView(set: set)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.currentItem.name ?? "未命名项目")
    }
}

struct SetCardView: View {
    let set: T_Set

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("重量: \(set.weight, specifier: "%.1f") kg")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("次数: \(set.reps)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("休息时间: \(set.restTime) 秒")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if set.isWarmup {
                Text("热身组")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
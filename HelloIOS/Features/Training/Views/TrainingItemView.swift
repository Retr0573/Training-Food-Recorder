import SwiftUI

struct TrainingItemView: View {
    @State private var showingAddSet = false
    @State private var isEditingDescription = false
    let item: TrainingItem
    
    var body: some View {
        List {
            // 项目描述
            Section {
                HStack {
                    Text("说明")
                    Spacer()
                    Text(item.description ?? "添加说明")
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    isEditingDescription = true
                }
            }
            
            // 训练组列表
            Section("训练组") {
                ForEach(item.sets) { set in
                    SetRowView(set: set)
                }
                .onMove { from, to in
                    // TODO: 实现训练组重排序
                }
                .onDelete { indexSet in
                    // TODO: 实现训练组删除
                }
            }
        }
        .navigationTitle(item.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSet = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetView(isPresented: $showingAddSet)
        }
    }
}

struct SetRowView: View {
    let set: TrainingSet
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(set.reps) 次 × \(String(format: "%.1f", set.weight))kg")
                    .font(.headline)
                Text("休息 \(set.restTime)秒")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if set.isWarmup {
                Text("热身组")
                    .font(.caption)
                    .padding(4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddSetView: View {
    @Binding var isPresented: Bool
    @State private var reps = 10
    @State private var weight = 20.0
    @State private var restTime = 60
    @State private var isWarmup = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("训练组设置") {
                    Stepper("重复次数: \(reps)", value: $reps, in: 1...100)
                    HStack {
                        Text("重量")
                        Slider(value: $weight, in: 0...200, step: 2.5)
                        Text("\(String(format: "%.1f", weight))kg")
                    }
                    Stepper("休息时间: \(restTime)秒", value: $restTime, in: 0...300, step: 15)
                    Toggle("热身组", isOn: $isWarmup)
                }
            }
            .navigationTitle("添加训练组")
            .navigationBarItems(
                leading: Button("取消") { isPresented = false },
                trailing: Button("保存") {
                    // TODO: 保存训练组
                    isPresented = false
                }
            )
        }
    }
}

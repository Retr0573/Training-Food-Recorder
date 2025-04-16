import SwiftUI
import CoreData

struct RecordPlanView: View {
    @StateObject private var viewModel: RecordPlanViewModel
    @EnvironmentObject var timerManager: TrainingTimerManager // 使用计时管理器
    @Environment(\.presentationMode) var presentationMode

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecordPlanViewModel(context: context))
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.themes, id: \.id) { theme in
                            NavigationLink(destination: RecordThemeView(context: viewModel.managedObjectContext, theme: theme)
                                .environmentObject(timerManager)) { // 显式传递 timerManager
                                CardView(theme: theme)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("训练计划")
            .onDisappear {
                if presentationMode.wrappedValue.isPresented && timerManager.isTraining {
                    timerManager.endTraining()
                }
            }

            // 固定在底部的按钮
            VStack {
                Spacer()
                TrainingControlButton()
            }
        }
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
import SwiftUI

struct FoodView: View {
    @State private var navigateToMealPlan = false
    @State private var navigateToMealEntry = false
    @State private var navigateToNutritionData = false

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "fork.knife")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 40))
                    .padding()

                List {
                    buttonRow(label: "制定饮食计划", systemImage: "text.book.closed") {
                        navigateToMealPlan = true
                    }

                    buttonRow(label: "录入每餐信息", systemImage: "square.and.pencil") {
                        navigateToMealEntry = true
                    }

                    buttonRow(label: "查看营养数据", systemImage: "chart.pie") {
                        navigateToNutritionData = true
                    }
                }

                // Hidden navigation triggers
                NavigationLink("", destination: MealPlanView(), isActive: $navigateToMealPlan)
                    .hidden()
                NavigationLink("", destination: MealEntryView(), isActive: $navigateToMealEntry)
                    .hidden()
                NavigationLink("", destination: NutritionDataView(), isActive: $navigateToNutritionData)
                    .hidden()
            }
            .navigationTitle("Food")
        }
    }

    // 统一样式按钮
    @ViewBuilder
    private func buttonRow(label: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 24, height: 24)

                Text(label)
                    .font(.callout)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
    }
}

// 示例子视图
struct MealEntryView: View {
    var body: some View {
        Text("这里是录入每餐信息的页面")
            .font(.title)
            .padding()
    }
}

struct NutritionDataView: View {
    var body: some View {
        Text("这里是查看营养数据的页面")
            .font(.title)
            .padding()
    }
}
import SwiftUI
struct MealPlanView: View {
    @StateObject private var viewModel = MealPlanViewModel()

    var body: some View {
        VStack {
            Text("饮食计划")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(viewModel.mealPlans, id: \.self) { meal in
                    Text(meal)
                }
                .onDelete(perform: viewModel.deleteMeal)
            }

            HStack {
                TextField("添加新餐点", text: $viewModel.newMeal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: viewModel.addMeal) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.tint)
                }
                .padding(.trailing)
            }
        }
        .padding()
        .navigationTitle("饮食计划")
    }
}

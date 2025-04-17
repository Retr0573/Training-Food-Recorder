import Foundation

class MealPlanViewModel: ObservableObject {
    @Published var mealPlans: [String] = ["早餐: 燕麦粥", "午餐: 鸡胸肉沙拉", "晚餐: 烤鱼和蔬菜"]
    @Published var newMeal: String = ""

    func addMeal() {
        guard !newMeal.isEmpty else { return }
        mealPlans.append(newMeal)
        newMeal = ""
    }

    func deleteMeal(at offsets: IndexSet) {
        mealPlans.remove(atOffsets: offsets)
    }
}

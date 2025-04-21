// import Foundation

// struct NutritionTargets {
//     var energy: Int = 0 // 能量 (kcal)
//     var protein: Int = 0 // 蛋白质 (g)
//     var fat: Int = 0 // 脂肪 (g)
//     var carbs: Int = 0 // 碳水化合物 (g)
// }

// class MealPlanViewModel: ObservableObject {
//     @Published var nutritionTargets: NutritionTargets = NutritionTargets()

//     func calculateNutritionTargets(age: Int?, height: Int?, weight: Int?, gender: String, dietGoal: String) {
//         guard let age = age, let height = height, let weight = weight else { return }

//         // 示例计算逻辑（可根据实际需求调整）
//         let baseEnergy = gender.lowercased() == "男" ? 2000 : 1800
//         let energyAdjustment = dietGoal.lowercased() == "减脂" ? -500 : (dietGoal.lowercased() == "增肌" ? 500 : 0)
//         let totalEnergy = baseEnergy + energyAdjustment

//         nutritionTargets.energy = totalEnergy
//         nutritionTargets.protein = Int(Double(weight) * 1.5) // 每公斤体重 1.5g 蛋白质
//         nutritionTargets.fat = Int(Double(totalEnergy) * 0.25 / 9) // 25% 能量来自脂肪
//         nutritionTargets.carbs = (totalEnergy - (nutritionTargets.protein * 4 + nutritionTargets.fat * 9)) / 4 // 剩余能量来自碳水化合物
//     }
// }

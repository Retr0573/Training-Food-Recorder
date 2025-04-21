import SwiftUI

struct MealPlanView: View {
    @StateObject private var viewModel = MealPlanViewModel()
    @State private var gender: String = "男" // 默认值为 "男"
    @State private var age: String = "25" // 默认值为 "25"
    @State private var height: String = "170" // 默认值为 "170"
    @State private var weight: String = "65" // 默认值为 "65"
    @State private var dietGoal: String = "增肌" // 默认值为 "增肌"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("饮食计划")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // 用户情况输入
                VStack(alignment: .leading, spacing: 15) {
                    Text("用户情况")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Group {
                        HStack {
                            Text("性别:")
                                .frame(width: 80, alignment: .leading)
                            TextField("请输入性别", text: $gender)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        HStack {
                            Text("年龄:")
                                .frame(width: 80, alignment: .leading)
                            TextField("请输入年龄", text: $age) // 改为绑定 String
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        HStack {
                            Text("身高 (cm):")
                                .frame(width: 80, alignment: .leading)
                            TextField("请输入身高", text: $height) // 改为绑定 String
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        HStack {
                            Text("体重 (kg):")
                                .frame(width: 80, alignment: .leading)
                            TextField("请输入体重", text: $weight) // 改为绑定 String
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        HStack {
                            Text("饮食目标:")
                                .frame(width: 80, alignment: .leading)
                            TextField("请输入饮食目标", text: $dietGoal)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)

               Button {
                    // 输入有效性检查
                    guard !age.isEmpty, !height.isEmpty, !weight.isEmpty else {
                        viewModel.errorMessage = "请填写所有必填字段"
                        return
                    }
                    
                    // 执行异步调用
                    Task {
                        // 主线程更新加载状态
                        await MainActor.run {
                            viewModel.isLoading = true
                            viewModel.errorMessage = nil // 清空旧错误
                        }
                        
                        // 类型转换（建议在 ViewModel 处理，这里演示视图层处理方式）
                        let ageInt = Int(age)
                        let heightInt = Int(height)
                        let weightInt = Int(weight)
                        
                        // 执行计算
                        await viewModel.calculateNutritionTargets(
                            age: ageInt,
                            height: heightInt,
                            weight: weightInt,
                            gender: gender,
                            dietGoal: dietGoal
                        )
                    }
                } label: {
                    HStack(spacing: 8) {
                        // 加载指示器
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        
                        Text(viewModel.isLoading ? "计算中..." : "计算营养目标")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading) // 禁用重复点击
                .padding(.horizontal)

                // 营养目标显示
                VStack(alignment: .leading, spacing: 10) {
                    Text("营养目标")
                        .font(.headline)
                        .padding(.bottom, 5)

                    HStack {
                        Text("能量:")
                            .frame(width: 100, alignment: .leading)
                        Text("\(viewModel.nutritionTargets.energy) kcal")
                            .bold()
                    }

                    HStack {
                        Text("蛋白质:")
                            .frame(width: 100, alignment: .leading)
                        Text("\(viewModel.nutritionTargets.protein) g")
                            .bold()
                    }

                    HStack {
                        Text("脂肪:")
                            .frame(width: 100, alignment: .leading)
                        Text("\(viewModel.nutritionTargets.fat) g")
                            .bold()
                    }

                    HStack {
                        Text("碳水化合物:")
                            .frame(width: 100, alignment: .leading)
                        Text("\(viewModel.nutritionTargets.carbs) g")
                            .bold()
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding()
        }
        .navigationTitle("饮食计划")
    }
}

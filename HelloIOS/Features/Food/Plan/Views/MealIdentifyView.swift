import SwiftUI

struct MealIdentifyView: View {
    @StateObject private var viewModel = MealIdentifyViewModel()
    @State private var imageUrl: String = ""
    @FocusState private var isUrlFieldFocused: Bool
    @State private var recognitionProgress: Double = 0.0
    @State private var progressTimer: Timer?
    
    // 识别进程总时间（秒）
    private let recognitionTime: Double = 23.0
    private let timerInterval: Double = 0.1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("食物识别")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                // 图片URL输入
                VStack(alignment: .leading, spacing: 15) {
                    Text("图片信息")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Text("图片URL:")
                            .frame(width: 80, alignment: .leading)
                        TextField("请输入图片URL", text: $imageUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            .focused($isUrlFieldFocused)
                            .submitLabel(.done)
                    }
                    
                    // 链接示例
                    Text("示例: https://example.com/food-image.jpg")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                
                // 提交按钮
                Button {
                    // 检查输入有效性
                    guard !imageUrl.isEmpty else {
                        viewModel.errorMessage = "请输入图片URL"
                        return
                    }
                    
                    // 清除键盘焦点
                    isUrlFieldFocused = false
                    
                    // 重置进度
                    recognitionProgress = 0.0
                    
                    // 启动进度动画
                    startProgressAnimation()
                    
                    // 执行异步调用
                    Task {
                        await viewModel.identifyFoodFromImage(url: imageUrl)
                        // 完成后停止动画
                        stopProgressAnimation()
                        recognitionProgress = 1.0
                    }
                } label: {
                    HStack(spacing: 8) {
                        // 加载指示器
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        
                        Text(viewModel.isLoading ? "识别中..." : "识别食物")
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
                
                // 进度条动画
                if viewModel.isLoading {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("识别进度")
                            .font(.headline)
                        
                        // 进度条
                        ProgressView(value: recognitionProgress)
                            .animation(.linear, value: recognitionProgress)
                            .tint(.blue)
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        
                        // 进度百分比
                        HStack {
                            Text("\(Int(recognitionProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("剩余时间: \(Int(ceil(recognitionTime * (1-recognitionProgress))))秒")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                
                // 错误信息显示
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 识别结果显示 - 食物列表
                if !viewModel.foodItems.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("识别到的食物")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        // 表头
                        HStack {
                            Text("食物名称")
                                .font(.subheadline.bold())
                                .frame(width: 100, alignment: .leading)
                            Text("重量(g)")
                                .font(.subheadline.bold())
                                .frame(width: 70, alignment: .trailing)
                            Text("热量(kcal)")
                                .font(.subheadline.bold())
                                .frame(width: 90, alignment: .trailing)
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background(Color(UIColor.tertiarySystemBackground))
                        
                        // 食物列表
                        ForEach(viewModel.foodItems) { item in
                            VStack {
                                // 基本行 - 显示名称、重量、热量
                                HStack {
                                    Text(item.foodName)
                                        .frame(width: 100, alignment: .leading)
                                        .lineLimit(1)
                                    Text(String(format: "%.1f", item.weightG))
                                        .frame(width: 70, alignment: .trailing)
                                    Text(String(format: "%.1f", item.energyKcal))
                                        .frame(width: 90, alignment: .trailing)
                                    Spacer()
                                }
                                
                                // 营养素详情行
                                HStack {
                                    Text("蛋白质: \(String(format: "%.1f", item.proteinG))g")
                                        .font(.caption)
                                    Spacer()
                                    Text("脂肪: \(String(format: "%.1f", item.fatG))g")
                                        .font(.caption)
                                    Spacer()
                                    Text("碳水: \(String(format: "%.1f", item.carbG))g")
                                        .font(.caption)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.3))
                            .cornerRadius(5)
                        }
                        
                        // 总计
                        if viewModel.foodItems.count > 1 {
                            Divider()
                                .padding(.vertical, 5)
                            
                            let totalEnergy = viewModel.foodItems.reduce(0) { $0 + $1.energyKcal }
                            let totalProtein = viewModel.foodItems.reduce(0) { $0 + $1.proteinG }
                            let totalFat = viewModel.foodItems.reduce(0) { $0 + $1.fatG }
                            let totalCarbs = viewModel.foodItems.reduce(0) { $0 + $1.carbG }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("总计")
                                    .font(.headline)
                                
                                HStack {
                                    Text("热量: \(String(format: "%.1f", totalEnergy)) kcal")
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("蛋白质: \(String(format: "%.1f", totalProtein))g")
                                    Spacer()
                                    Text("脂肪: \(String(format: "%.1f", totalFat))g")
                                    Spacer()
                                    Text("碳水: \(String(format: "%.1f", totalCarbs))g")
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                
                // 原始JSON数据（可选，帮助调试）
                if !viewModel.recognitionResult.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("原始识别结果")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ScrollView {
                            Text(viewModel.recognitionResult)
                                .font(.caption)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 100)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("食物识别")
        .onDisappear {
            stopProgressAnimation()
        }
    }
    
    // 启动进度动画
    private func startProgressAnimation() {
        stopProgressAnimation() // 确保之前的计时器已停止
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            if recognitionProgress < 1.0 {
                // 计算每个时间间隔的进度增量
                let increment = timerInterval / recognitionTime
                recognitionProgress = min(recognitionProgress + increment, 1.0)
            } else {
                stopProgressAnimation()
            }
        }
    }
    
    // 停止进度动画
    private func stopProgressAnimation() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

struct MealIdentifyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealIdentifyView()
        }
    }
}

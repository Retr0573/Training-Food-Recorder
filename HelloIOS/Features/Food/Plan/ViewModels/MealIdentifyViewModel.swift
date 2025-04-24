import Foundation

// MARK: - 食物营养数据模型
struct FoodNutrition: Identifiable, Decodable {
    let id = UUID()
    let foodName: String
    let weightG: Double
    let carbG: Double
    let fatG: Double
    let proteinG: Double
    let energyKcal: Double
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case weightG = "weight_g"
        case carbG = "carb_g"
        case fatG = "fat_g"
        case proteinG = "protein_g"
        case energyKcal = "energy_kcal"
    }
}

// MARK: - API 响应模型
struct IdentifyResponse: Decodable {
    let output: [FoodNutrition]
}

// MARK: - 视图模型
class MealIdentifyViewModel: ObservableObject {
    @Published var imageUrl: String = ""
    @Published var recognitionResult: String = ""
    @Published var foodItems: [FoodNutrition] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Coze 配置参数
    private let workflowID = "7496738573661290532"
    private let accessToken = "Bearer pat_B1yNVAAfx7ICNnKyck4NC9ifXWejCcN235XEdtOXpMrscLygQNDu391CEJ5XDhAa"
    
    // MARK: - API 调用
    func identifyFoodFromImage(url: String) async {
        guard !url.isEmpty else {
            await MainActor.run {
                self.errorMessage = "请输入图片URL"
                self.isLoading = false
            }
            return
        }
        
        await MainActor.run { 
            self.isLoading = true 
            self.errorMessage = nil
            self.recognitionResult = ""
            self.foodItems = []
        }
        
        do {
            let parameters: [String: Any] = [
                "image_url": url
            ]
            
            if let (result, items) = try await callCozeWorkflow(parameters: parameters) {
                await MainActor.run {
                    self.recognitionResult = result
                    self.foodItems = items
                    self.errorMessage = nil
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "识别失败: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - 核心 API 请求
    private func callCozeWorkflow(parameters: [String: Any]) async throws -> (String, [FoodNutrition])? {
        let url = URL(string: "https://api.coze.cn/v1/workflow/run")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "workflow_id": workflowID,
            "parameters": parameters
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response = try decoder.decode(CozeWorkflowResponse.self, from: data)
        
        // 检查API调用是否成功
        if response.code != 0 {
            throw NSError(domain: "CozeAPIError", code: response.code, userInfo: [
                NSLocalizedDescriptionKey: response.msg
            ])
        }
        
        // 解析食物营养数据
        var foodItems: [FoodNutrition] = []
        if let jsonString = response.data, let jsonData = jsonString.data(using: .utf8) {
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                if let outputData = jsonObj?["output"] as? [[String: Any]] {
                    let outputJson = try JSONSerialization.data(withJSONObject: ["output": outputData])
                    let identifyResponse = try decoder.decode(IdentifyResponse.self, from: outputJson)
                    foodItems = identifyResponse.output
                }
            } catch {
                print("解析食物数据失败: \(error)")
            }
        }
        
        return (response.data ?? "", foodItems)
    }
}

import Foundation

// MARK: - 数据结构
struct NutritionTargets: Decodable {
    var energy: Int = 0
    var protein: Int = 0
    var fat: Int = 0
    var carbs: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case energy = "energy_kcal"
        case protein = "protein_g"
        case fat = "fat_g"
        case carbs = "carbohydrate_g"
    }
}

// MARK: - Coze API 响应结构
struct CozeWorkflowResponse: Decodable {
    let code: Int
    let msg: String
    let data: String?
    let debug_url: String?
    
    func parseNutritionData() -> NutritionTargets? {
        guard code == 0, let jsonString = data else { return nil }
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            return try JSONDecoder().decode(NutritionTargets.self, from: jsonData)
        } catch {
            print("JSON 解析失败: \(error)")
            return nil
        }
    }
}

// MARK: - ViewModel
class MealPlanViewModel: ObservableObject {
    @Published var nutritionTargets: NutritionTargets = NutritionTargets()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Coze 配置参数（需要替换为你的实际值）
    private let workflowID = "7494914814964760613"
    private let accessToken = "Bearer pat_B1yNVAAfx7ICNnKyck4NC9ifXWejCcN235XEdtOXpMrscLygQNDu391CEJ5XDhAa"
    
    // MARK: - API 调用
    func calculateNutritionTargets(age: Int?, height: Int?, weight: Int?, gender: String, dietGoal: String) async {
        guard let age = age, let height = height, let weight = weight else {
            DispatchQueue.main.async {
                self.errorMessage = "请填写所有必填字段"
            }
            return
        }
        
        DispatchQueue.main.async { self.isLoading = true }
        
        do {
          
            let parameters: [String: Any] = [
                "age": age,
                "gender": gender,
                "goal": dietGoal,
                "height_cm": height,
                "weight_kg": weight
            ]
            if let result = try await callCozeWorkflow(parameters: parameters) {
                DispatchQueue.main.async {
                    self.nutritionTargets = result
                    self.errorMessage = nil
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        DispatchQueue.main.async { self.isLoading = false }
    }
    
    // MARK: - 核心 API 请求
    private func callCozeWorkflow(parameters: [String: Any]) async throws -> NutritionTargets? {
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
        let response = try JSONDecoder().decode(CozeWorkflowResponse.self, from: data)
        print(response)
        guard let nutritionData = response.parseNutritionData() else {
            throw NSError(domain: "CozeAPIError", code: response.code, userInfo: [
                NSLocalizedDescriptionKey: response.msg
            ])
        }
        
        return nutritionData
    }
}

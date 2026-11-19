import Foundation

final class AIService {
    // ⚠️ এখানে Gemini API Key বসান: https://aistudio.google.com/apikey
    private let apiKey = "YOUR_GEMINI_API_KEY_HERE"
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

    enum AIError: LocalizedError {
        case missingAPIKey, invalidURL, networkError(String), decodingError, emptyResponse
        case serverError(Int, String)
        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Gemini API key সেট করা হয়নি।"
            case .invalidURL: return "API URL সঠিক নয়।"
            case .networkError(let msg): return "নেটওয়ার্ক সমস্যা: \(msg)"
            case .decodingError: return "AI response ডিকোড করা যায়নি।"
            case .emptyResponse: return "AI কোনো উত্তর দেয়নি।"
            case .serverError(let code, let msg): return "সার্ভার এরর (\(code)): \(msg)"
            }
        }
    }

    func rewrite(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty, apiKey != "YOUR_GEMINI_API_KEY_HERE" else {
            completion(.failure(AIError.missingAPIKey)); return
        }
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            completion(.failure(AIError.invalidURL)); return
        }
        let prompt = """
        Rewrite the following text correctly. If it is Bangla in phonetic form, convert it to proper Bangla. If it has spelling or grammar mistakes, fix them. Return ONLY the corrected text.

        Text: \(text)
        """
        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": ["temperature": 0.2, "maxOutputTokens": 512]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        do { request.httpBody = try JSONSerialization.data(withJSONObject: body) }
        catch { completion(.failure(AIError.decodingError)); return }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error { completion(.failure(AIError.networkError(error.localizedDescription))); return }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(AIError.networkError("Invalid response"))); return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown"
                completion(.failure(AIError.serverError(httpResponse.statusCode, msg))); return
            }
            guard let data else { completion(.failure(AIError.emptyResponse)); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let textPart = parts.first?["text"] as? String {
                    completion(.success(textPart.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else { completion(.failure(AIError.decodingError)) }
            } catch { completion(.failure(AIError.decodingError)) }
        }.resume()
    }
}

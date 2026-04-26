import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://broncohacks-494423.wl.r.appspot.com"
    private var authToken: String?

    func setToken(_ token: String) {
        authToken = token
    }

    func makeRequest(path: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = body
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        return data
    }

    func get<T: Decodable>(_ path: String) async throws -> T {
        let data = try await makeRequest(path: path)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    func post<T: Decodable>(_ path: String, body: Encodable) async throws -> T {
        let encoded = try JSONEncoder().encode(body)
        let data = try await makeRequest(path: path, method: "POST", body: encoded)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

//
//  Network.swift
//  Pokemon
//
//  Created by Bern on 2025/11/2.
//

import Foundation

enum HTTP {
    enum Method: String { case get = "GET", post = "POST", put = "PUT", delete = "DELETE" }
    typealias Parameters = [String: String]
}

struct Request {
    enum Encoding { case query, json }
}

protocol EndpointType { var path: String { get } }

protocol Requestable {
    var encoding: Request.Encoding { get }
    var httpMethod: HTTP.Method { get }
    var endpoint: EndpointType { get }
    var parameters: HTTP.Parameters { get }
}

enum NetworkError: Error { case invalidURL, requestFailed(statusCode: Int), decodingFailed, transportError(Error) }

extension String {
    func asURL() throws -> URL {
        guard let url = URL(string: self),
              let scheme = url.scheme?.lowercased(), (scheme == "http" || scheme == "https"),
              let host = url.host, !host.isEmpty else {
            throw NetworkError.invalidURL
        }
        return url
    }
}

enum Network {
    struct Server: Sendable {
        let baseURL: URL
        static func basic(baseURL: URL) -> Server { Server(baseURL: baseURL) }
    }

    struct Service: Sendable {
        let server: Server

        func request<T: Decodable>(_ requestable: Requestable) async throws -> T {
            // Build URL
            let base = server.baseURL.appendingPathComponent(requestable.endpoint.path)
            var components = URLComponents(url: base, resolvingAgainstBaseURL: false)

            if requestable.encoding == .query, requestable.httpMethod == .get, !requestable.parameters.isEmpty {
                components?.queryItems = requestable.parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            }

            guard let url = components?.url else { throw NetworkError.invalidURL }

            // Build request
            var req = URLRequest(url: url)
            req.httpMethod = requestable.httpMethod.rawValue

            if requestable.httpMethod != .get, requestable.encoding == .json, !requestable.parameters.isEmpty {
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = try JSONSerialization.data(withJSONObject: requestable.parameters, options: [])
                req.httpBody = body
            }

            // Execute
            do {
                let (data, response) = try await URLSession.shared.data(for: req)
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
                }

                let decoder = JSONDecoder()
                do { return try decoder.decode(T.self, from: data) }
                catch { throw NetworkError.decodingFailed }
            } catch { throw NetworkError.transportError(error) }
        }
    }
}

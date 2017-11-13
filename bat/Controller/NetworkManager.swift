//
//  NetworkManager.swift
//  bat
//
//  Created by Sebastian Limbach on 10.10.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import Foundation
import Locksmith

final class NetworkManager {

    private let sessionConfig: URLSessionConfiguration
    private let session: URLSession
    private let apiUrl: URL

    static let shared = NetworkManager()

    enum AuthorizationState {
        case authorized
        case unauthorized
    }

    enum ResultType {
        case success(data: Data)
        case error(error: Error)
        case unauthorized
        case backendError
        case networkError
    }

    private init() {
        sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        apiUrl = URL(string: "https://gcp.sebastianlimbach.com")!
    }

    func update(location: (lat: Double, lng: Double), completion: @escaping (_ result: ResultType) -> ()) {
        DispatchQueue.global().async {
            let locationAPIPath = self.apiUrl.userPathSuffix().appendingPathComponent("/location")
            print(locationAPIPath)
            var request = URLRequest(url: locationAPIPath)
            request.httpMethod = "PUT"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addUserAuthorizationHeader()
            let bodyObject: [String : Any] = [
                "latitude": location.lat,
                "longitude": location.lng
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyObject, options: [])

            let task = self.session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200 {
                        if let error = error {
                            completion(.error(error: error))
                        } else {
                            completion(.success(data: data!))
                        }
                    } else {
                        completion(.unauthorized)
                    }
                }
            }
            task.resume()
        }
    }

    func update(destination: Destination?, completion: @escaping (_ result: ResultType) -> ()) {
        DispatchQueue.global().async {
            let locationAPIPath = self.apiUrl.userPathSuffix().appendingPathComponent("/destination")
            print(locationAPIPath)
            var request = URLRequest(url: locationAPIPath)
            request.httpMethod = "PUT"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addUserAuthorizationHeader()
            let bodyObject: [String : Any] = [
                "destinationID": (destination?.id) ?? "null"
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyObject, options: [])

            let task = self.session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200 {
                        if let error = error {
                            completion(.error(error: error))
                        } else {
                            completion(.success(data: data!))
                        }
                    } else {
                        completion(.unauthorized)
                    }
                }
            }
            task.resume()
        }
    }

    func sendMessage(ofButton buttonKey: String, completion: @escaping (_ result: ResultType) -> ()) {
        guard let buttonSettings = UserDefaults.standard.object(forKey: buttonKey) as? [String:String],
            let buttonMessage = buttonSettings["Message"]  else {
            completion(.backendError)
            return
        }

        DispatchQueue.global().async {
            let locationAPIPath = self.apiUrl.userPathSuffix().appendingPathComponent("/message")
            print(locationAPIPath)
            var request = URLRequest(url: locationAPIPath)
            request.httpMethod = "POST"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addUserAuthorizationHeader()

            let bodyObject: [String : Any] = [
                "message": buttonMessage
            ]
            dump(bodyObject)
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyObject, options: [])

            let task = self.session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200 {
                        if let error = error {
                            completion(.error(error: error))
                        } else {
                            completion(.success(data: data!))
                        }
                    } else {
                        completion(.unauthorized)
                    }
                }
            }
            task.resume()
        }
    }


    func authenticate(user: User, completion: @escaping (_ authorization: AuthorizationState) -> ()) {
        DispatchQueue.global().async {
            let authAPIPath = self.apiUrl.appendingPathComponent("/user/\(user.username)/auth")
            var request = URLRequest(url: authAPIPath)
            request.httpMethod = "GET"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")

            let task = self.session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(.authorized)
                    } else {
                        completion(.unauthorized)
                    }
                }
            }
            task.resume()
        }
    }

}

extension URLRequest {
    mutating func addUserAuthorizationHeader() {
        guard let userData = Locksmith.loadDataForUserAccount(userAccount: "api-user") else { return }

        if let userToken = userData["token"] {
            self.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        }
    }
}

extension URL {
    func userPathSuffix() -> URL {
        guard let userData = Locksmith.loadDataForUserAccount(userAccount: "api-user") else { return self }
        if let username = userData["username"] {
            return self.appendingPathComponent("/user/\(username)")
        }
        return self
    }
}

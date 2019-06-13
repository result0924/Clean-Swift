//
//  Alamofire+Extension.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/12.
//  Copyright © 2019 jlai. All rights reserved.
//

import Foundation
import Alamofire

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
}

extension DataRequest {
    /// @Returns - DataRequest
    /// completionHandler handles JSON Object T
    @discardableResult func responseObject<T: Decodable> (
        queue: DispatchQueue? = nil ,
        completionHandler: @escaping (DataResponse<T>) -> Void ) -> Self {
        
        let responseSerializer = DataResponseSerializer<T> { (_, response: HTTPURLResponse?, data: Data?, error: Error?) in
            
            if let error = error {
                return .failure(BackendError.network(error: error))
            }
            
            let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
            guard case let .success(jsonData) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error ?? NSError(domain: "Can't find alamofire result error", code: -1, userInfo: nil)))
            }
            
            // (1)- Json Decoder. Decodes the data object into expected type T
            // throws error when failes
            let decoder = JSONDecoder()
            guard let responseObject = try? decoder.decode(T.self, from: jsonData) else {
                return .failure(BackendError.objectSerialization(reason: "JSON object could not be serialized \(String(data: jsonData, encoding: .utf8) ?? "")"))
            }
            return .success(responseObject)
        }
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    /// @Returns - DataRequest
    /// completionHandler handles JSON Array [T]
    @discardableResult func responseCollection<T: Decodable>(
        queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void
        ) -> Self {
        
        let responseSerializer = DataResponseSerializer<[T]> { (_, response: HTTPURLResponse?, data: Data?, error: Error?) in
            
            if let error = error {
                return .failure(BackendError.network(error: error))
            }
            
            let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
            guard case let .success(jsonData) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error ?? NSError(domain: "Can't find alamofire result error", code: -1, userInfo: nil)))
            }
            
            let decoder = JSONDecoder()
            guard let responseArray = try? decoder.decode([T].self, from: jsonData) else {
                return .failure(BackendError.objectSerialization(reason: "JSON array could not be serialized \(String(data: jsonData, encoding: .utf8) ?? "")"))
            }
            
            return .success(responseArray)
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

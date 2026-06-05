//
//  Configuration.swift
//  Cloutgrid
//
//  Created by Afthash on 18/3/2026.
//

import Foundation

enum APIConfig {
    case development
    case production
    
    static let current: APIConfig = .development
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://127.0.0.1:8000"
            
        case .production:
            return "https://api.cloutgrid.com"
        }
    }
}

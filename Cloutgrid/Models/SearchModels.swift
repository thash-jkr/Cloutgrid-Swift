//
//  SearchModels.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import Foundation

struct AllUsersResponse: Codable {
    let creators: [UserContainer]
    let businesses: [UserContainer]
}

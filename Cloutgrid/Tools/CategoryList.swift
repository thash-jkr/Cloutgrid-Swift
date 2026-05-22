//
//  CategoryList.swift
//  Cloutgrid
//
//  Created by Afthash on 16/3/2026.
//

import Foundation

struct CategoryList: Identifiable, Hashable {
    let id = UUID()
    let value: String
    let label: String
    
    static func label(_ value: String) -> String {
        return allOptions.first(where: {$0.value == value})?.label ?? "Choose one"
    }
    
    static let allOptions: [CategoryList] = [
        CategoryList(value: "art", label: "Art and Photography"),
        CategoryList(value: "automotive", label: "Automotive"),
        CategoryList(value: "beauty", label: "Beauty and Makeup"),
        CategoryList(value: "business", label: "Business"),
        CategoryList(value: "diversity", label: "Diversity and Inclusion"),
        CategoryList(value: "education", label: "Education"),
        CategoryList(value: "entertainment", label: "Entertainment"),
        CategoryList(value: "fashion", label: "Fashion"),
        CategoryList(value: "finance", label: "Finance"),
        CategoryList(value: "food", label: "Food and Beverage"),
        CategoryList(value: "gaming", label: "Gaming"),
        CategoryList(value: "health", label: "Health and Wellness"),
        CategoryList(value: "home", label: "Home and Gardening"),
        CategoryList(value: "outdoor", label: "Outdoor and Nature"),
        CategoryList(value: "parenting", label: "Parenting and Family"),
        CategoryList(value: "pets", label: "Pets"),
        CategoryList(value: "sports", label: "Sports and Fitness"),
        CategoryList(value: "technology", label: "Technology"),
        CategoryList(value: "travel", label: "Travel"),
        CategoryList(value: "videography", label: "Videography")
    ]
}

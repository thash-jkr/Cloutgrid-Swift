//
//  JobModels.swift
//  Cloutgrid
//
//  Created by Afthash on 2/4/2026.
//

import Foundation

struct QuestionModel: Codable, Identifiable, Hashable {
    let id: Int
    let content: String
    let job: Int
}

struct AnswerModel: Codable, Identifiable, Hashable {
    let id: Int
    let content: String
    let application: Int
    let question: Int
}

struct JobModel: Codable, Identifiable, Hashable {
    let id: Int
    let postedBy: UserContainer
    let questions: [QuestionModel]
    var isApplied: Bool
    let title: String
    let description: String
    let requirements: String
    let targetCreator: String
    
    enum CodingKeys: String, CodingKey {
        case id, questions, title, description, requirements
        
        case postedBy = "posted_by"
        case isApplied = "is_applied"
        case targetCreator = "target_creator"
    }
    
    static let previewQuestion1: QuestionModel = .init(
        id: 1,
        content: "Why are you a good fit for this role?",
        job: 100
    )
    
    static let previewQuestion2: QuestionModel = .init(
        id: 2,
        content: "Please share links to your recent work.",
        job: 100
    )
}

struct ApplicationModel: Codable, Identifiable, Hashable {
    let id: Int
    let creator: UserContainer
    let job: JobModel
    let answers: [AnswerModel]
    
    static let previewQuestion1: AnswerModel = .init(
        id: 1,
        content: "I am a great fit for this role because I am a great problem solver and I am always eager to learn.",
        application: 100,
        question: 1
    )
    
    static let previewQuestion2: AnswerModel = .init(
        id: 2,
        content: "https://github.com/afthash/Cloutgrid",
        application: 100,
        question: 2
    )
}

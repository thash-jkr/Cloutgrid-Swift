//
//  Questions.swift
//  Cloutgrid
//
//  Created by Afthash on 2/4/2026.
//

import SwiftUI

struct Questions: View {
    @Environment(JobManager.self) private var collab
    
    @Binding var path: NavigationPath
    var questions: [QuestionModel]
    
    @State private var answers: [Int: String] = [:]
    
    var body: some View {
        List {
            Section {
                ForEach(questions) {q in
                    VStack {
                        Text(q.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter your answer here:", text: Binding(
                            get: { answers[q.id] ?? "" },
                            set: { answers[q.id] = $0 }
                        ), axis: .vertical)
                            .lineLimit(5...10)
                            .padding(.vertical, 5)
                            .customField()
                    }
                }
            } header: {
                Text(
                    "Answer these questions:"
                )
                .foregroundStyle(Color.secondary)
                .font(.system(size: 13))
            } footer: {
                Button {
                    Task {
                        await collab
                            .submitApplication(
                                id: questions[0].job,
                                answers: answers
                            )
                        
                        if collab.errorMessage == nil {
                            path.removeLast()
                        }
                    }
                } label: {
                    Text("Submit")
                        .customButton()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    Questions(
        path: .constant(NavigationPath()),
        questions: [JobModel.previewQuestion1, JobModel.previewQuestion2]
    )
        .environment(JobManager())
}

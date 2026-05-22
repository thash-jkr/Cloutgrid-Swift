//
//  Answers.swift
//  Cloutgrid
//
//  Created by Afthash on 18/5/2026.
//

import SwiftUI

struct Answers: View {
    @Environment(JobManager.self) private var collab
    
    @Binding var path: NavigationPath
    var creator: UserContainer
    var questions: [QuestionModel]
    var answers: [AnswerModel]
    
    var body: some View {
        List {
            Section {
                ForEach(questions) {q in
                    VStack {
                        Text(q.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(
                            answers.first(where: { $0.question == q.id })
                                .map { $0.content } ?? ""
                        )
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                        .customField()
                    }
                }
            } header: {
                Text(
                    "Application Responses:"
                )
                .foregroundStyle(Color.secondary)
                .font(.system(size: 13))
            } footer: {
                Button {
                    path.append(creator)
                } label: {
                    Text("Creator Profile").customButton()
                }
                .padding(.vertical)
            }
        }
    }
}

#Preview {
    Answers(
        path: .constant(NavigationPath()),
        creator: PostModel.creatorPreview,
        questions: [JobModel.previewQuestion1, JobModel.previewQuestion2],
        answers: [
            ApplicationModel.previewQuestion1,
            ApplicationModel.previewQuestion2
        ]
    )
    .environment(JobManager())
}

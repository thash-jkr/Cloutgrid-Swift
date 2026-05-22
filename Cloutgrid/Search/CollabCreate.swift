//
//  CollabCreate.swift
//  Cloutgrid
//
//  Created by Afthash on 29/4/2026.
//

import SwiftUI

struct CollabCreate: View {
    @Environment(JobManager.self) private var collab
    
    @Binding var path: NavigationPath
    @Binding var selectedTab: TabIdentifier
    
    private struct CollabQuestionModel: Identifiable, Equatable {
        let id = UUID()
        var content: String
    }
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var requirements: String = ""
    @State private var category: String = ""
    @State private var categorySheet: Bool = false
    
    @State private var question: CollabQuestionModel = .init(content: "")
    @State private var questions: [CollabQuestionModel] = []
    
    private var sheetContent: some View {
        VStack {
            NavigationStack {
                List(CategoryList.allOptions) {item in
                    Button {
                        category = item.value
                        categorySheet = false
                    } label: {
                        HStack {
                            Text(item.label)
                                .foregroundStyle(
                                    category == item.value ? Color.second : Color.primary
                                )
                                .fontWeight(
                                    category == item.value ? .bold
                                    : .regular)
                            Spacer()
                            
                            if category == item.value {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.second)
                            }
                        }
                    }
                }
                .navigationTitle("Choose your target creator")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private var sectionOne: some View {
        Section {
            VStack(spacing: 5) {
                HStack {
                    Text("Title:").font(.subheadline)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField("Enter a title for your collab", text: $title)
                    .frame(height: 45)
                    .customField()
            }
            
            VStack {
                HStack {
                    Text("Description:").font(.subheadline)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField(
                    "Enter a detailed description about what you're looking for in a collaboration with a creator",
                    text: $description,
                    axis: .vertical
                )
                    .lineLimit(5...10)
                    .padding(.vertical, 5)
                    .customField()
            }
            
            VStack {
                HStack {
                    Text("Requirements:").font(.subheadline)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField(
                    "Enter the specific requirements, separated by commas \",\"",
                    text: $requirements,
                    axis: .vertical
                )
                    .lineLimit(5...10)
                    .padding(.vertical, 5)
                    .customField()
            }
            
            VStack(spacing: 5) {
                Text("Target creator:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                
                Button {
                    categorySheet = true
                } label: {
                    HStack {
                        Text(CategoryList.label(category))
                            .foregroundStyle(Color.primary)
                        
                        Spacer()
                        
                        if category.isEmpty {
                            Image(systemName: "arrow.down.square")
                                .font(.title2)
                        }
                    }
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                    .customField()
                }
                .sheet(isPresented: $categorySheet) {
                    sheetContent
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.fraction(0.7)])
                }
            }
        }
    }
    
    private var sectionTwo: some View {
        Section {
            VStack {
                HStack {
                    Text("Questions (optional):").font(.subheadline)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField(
                    "Optionally enter any questions you have for the creator. You can enter a question, then click \"Add Question\" to add it to the list. You can add multiple questions.",
                    text: $question.content,
                    axis: .vertical
                )
                .lineLimit(5...10)
                .padding(.vertical, 5)
                .customField()
                
                Button {
                    questions.append(question)
                    question = .init(content: "")
                } label: {
                    Text("Add question")
                        .customButton(disabled: question.content.isEmpty)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .disabled(question.content.isEmpty)
                .buttonStyle(.borderless)
                
                if !questions.isEmpty {
                    VStack {
                        Divider()
                        
                        Text("Added questions:")
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(
                            Array(questions.enumerated()),
                            id: \.element.id
                        ) { index, value in
                            HStack {
                                Text("\(index + 1). \(value.content)")
                                
                                Spacer()
                                
                                Button {
                                    questions.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 5)
                            
                            if value != questions.last {
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } footer: {
            Button {
                Task {
                    let finalQuestions: [String] = questions.map(\.content)
                    
                    await collab
                            .createJob(
                                title: title,
                                description: description,
                                requirements: requirements,
                                target_creator: category,
                                questions: finalQuestions
                            )
                    
                    if collab.errorMessage == nil {
                        path.removeLast()
                        selectedTab = .jobs
                    }
                }
            } label: {
                Text("Create").customButton()
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
        }
    }
    
    var body: some View {
        List {
            sectionOne
            
            sectionTwo
        }
        .navigationTitle("Create Collaboration")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CollabCreate(
            path: .constant(NavigationPath()),
            selectedTab: .constant(.post)
        )
            .environment(JobManager())
    }
}

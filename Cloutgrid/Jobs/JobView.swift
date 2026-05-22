//
//  JobView.swift
//  Cloutgrid
//
//  Created by Afthash on 25/3/2026.
//

import SwiftUI

struct JobView: View {
    @Environment(JobManager.self) private var collab
    @Environment(AuthManager.self) private var auth

    @Binding var jobPath: NavigationPath
    
    @State var selectedJob: JobModel?
    @State var markedJob: JobModel?
    @State var reportContent: String = ""
    @State private var showReportAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    private func JobDetail(job: JobModel) -> some View {
        ScrollView {
            Text(job.title)
                .font(.title)
                .bold()
                .padding(20)
                .multilineTextAlignment(.center)
            
            HStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Posted by:")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                    Text(job.postedBy.profile.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                Button {
                    selectedJob = nil
                    jobPath.append(job.postedBy)
                } label: {
                    Text("Business Profile").customButton()
                }
                
                Spacer()
                
                Button {
                    if job.questions.count > 0 {
                        let questionsToPass = job.questions
                        selectedJob = nil
                        jobPath.append(questionsToPass)
                    } else {
                        Task {
                            await collab
                                .submitApplication(id: job.id, answers: [:])
                            selectedJob = nil
                        }
                    }
                } label: {
                    Text(job.isApplied ? "Applied" : "Apply")
                        .customButton(disabled: job.isApplied)
                }
                .disabled(job.isApplied)
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            VStack(alignment: .leading) {
                Text("About the role:").bold()
                
                Text(job.description)
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading) {
                Text("Requirements:").bold()
                
                ForEach(job.requirements.split(separator: ","), id: \.self) { req in
                    HStack(alignment: .top) {
                        Text("•")
                        
                        Text(String(req).trimmingCharacters(in: .whitespaces))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func JobApplicants(job: JobModel) -> some View {
        VStack {
            if collab.applications.count > 0 {
                NavigationStack {
                    List {
                        if job.questions.count == 0 {
                            Text("This collaboration does not have any questions.")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        } else {
                            Text("Select a creator to view their responses to your questions.")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                        
                        ForEach(collab.applications) { application in
                            Button {
                                selectedJob = nil
                                
                                if job.questions.count > 0 {
                                    jobPath.append(application)
                                } else {
                                    jobPath.append(application.creator)
                                }
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: APIConfig.current.baseURL + application.creator.profile.profilePhoto)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 50)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(application.creator.profile.name)
                                            .font(.system(size: 15, weight: .medium))
                                        
                                        Text(
                                            CategoryList.label(application.creator.area ?? "")
                                        )
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Applications")
                    .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                Empty(
                    type: "collab",
                    message: "No applications yet",
                    isLoading: collab
                        .isLoading)
            }
        }
        .task(id: job.id) {
            await collab.fetchApplications(job: job)
        }
        .onDisappear() {
            collab.applications.removeAll()
        }
    }
    
    private func JobRow(job: JobModel) -> some View {
        Button {
            selectedJob = job
        } label: {
            HStack {
                if let user = auth.user {
                    AsyncImage(
                        url: URL(
                            string: auth.type == "creator" ? job.postedBy.profile.profilePhoto : (
                                APIConfig
                                    .current.baseURL + user.profile.profilePhoto)
            
                        )
                    ) {image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }.frame(width: 50)
                }
                
                VStack(alignment: .leading) {
                    Text(job.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.dualBlack)
                    
                    Text(job.postedBy.profile.name)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .swipeActions {
            if auth.type == "creator" {
                Button {
                    showReportAlert = true
                } label: {
                    Label("Report", systemImage: "exclamationmark.triangle.fill")
                }
                .tint(.red)
            } else {
                Button {
                    showDeleteAlert = true
                    markedJob = job
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
    }
    
    var body: some View {
        VStack {
            if collab.jobs.count > 0 {
                AnyView(
                    List {
                        ForEach(collab.jobs) { job in
                            JobRow(job: job)
                            .alert("Report Collaboration", isPresented: $showReportAlert) {
                                TextField(
                                    "Reason (e.g., Spam, Harassment)",
                                    text: $reportContent,
                                    axis: .vertical
                                )
                                
                                Button("Submit", action: {})
                                Button("Cancel", role: .cancel) { reportContent = "" }
                            } message: {
                                Text("Please let us know why you'd like to report this collaboration.")
                            }
                        }
                    }
                    .refreshable {
                        if auth.type == "creator" {
                            await collab.fetchJobs()
                        } else {
                            await collab.fetchBusinessJobs()
                        }
                    }
                )
            } else {
                AnyView(
                    Empty(
                        type: "collab",
                        message: auth.type == "creator" ? "No new collaborations available" : "You have no new collaborations posted",
                        isLoading: collab.isLoading
                    )
                )
            }
        }
        .alert(
            "Delete Collaboration",
            isPresented: $showDeleteAlert,
            presenting: markedJob,
        ) { job in
            Button("Delete", role: .destructive, action: {
                Task {
                    await collab.deleteJob(id: job.id)
                }
            })
            Button("Cancel", role: .cancel) { }
        } message: { job in
            Text(
                "Are you sure you want to delete this collaboration? You cannot undo this and you will lose all the application data."
            )
        }
        .sheet(item: $selectedJob) { job in
            if auth.type == "creator" {
                JobDetail(job: job)
                    .presentationDetents([.fraction(0.7), .fraction(1)])
                    .presentationDragIndicator(.visible)
            } else {
                JobApplicants(job: job)
                    .presentationDetents([.fraction(0.7), .fraction(1)])
                    .presentationDragIndicator(.visible)
            }
        }
        .task {
            if auth.type == "creator" {
                await collab.fetchJobs()
            } else {
                await collab.fetchBusinessJobs()
            }
        }
    }
}

#Preview {
    JobView(jobPath: .constant(NavigationPath()))
        .environment(JobManager())
        .environment(AuthManager())
}


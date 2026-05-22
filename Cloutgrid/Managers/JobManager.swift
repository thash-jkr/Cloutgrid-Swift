//
//  JobManager.swift
//  Cloutgrid
//
//  Created by Afthash on 2/4/2026.
//

import SwiftUI

@Observable
class JobManager {
    var jobs: [JobModel] = []
    var applications: [ApplicationModel] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    func jsonStringify(_ array: [String]) -> String? {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(array)
            
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to stringify array: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func fetchJobs() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: [JobModel] = try await APIService.shared.request(
                endpoint: "/jobs/",
                method: "GET",
                body: nil,
                requireAuth: true,
                fullURL: false
            )
            
            self.jobs = response
            self.isLoading = false
            self.errorMessage = nil
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchBusinessJobs() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: [JobModel] = try await APIService.shared.request(
                endpoint: "/jobs/my-jobs/",
                method: "GET",
                body: nil,
                requireAuth: true,
                fullURL: false
            )
            
            self.jobs = response
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchApplications(job: JobModel) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: [ApplicationModel] = try await APIService.shared.request(
                endpoint: "/jobs/my-jobs/\(job.id)/",
                method: "GET",
                body: nil,
                requireAuth: true,
            )
            
            self.applications = response
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func createJob(title: String, description: String, requirements: String, target_creator: String, questions: [String]) async {
        self.isLoading = true
        self.errorMessage = nil
        
        if title.isEmpty || description.isEmpty || requirements.isEmpty || target_creator.isEmpty {
            ToastManager.shared.showToast(message: "Please fill in all fields", isSuccess: false)
            return self.isLoading = false
        }
        
        var data: [String: String] = [:]
        
        data["title"] = title
        data["description"] = description
        data["requirements"] = requirements
        data["target_creator"] = target_creator
        data["questions"] = jsonStringify(questions)
        
        do {
            let (multipartBody, boundary) = APIService.shared.multipartBodyBuilder(
                image: nil,
                imageKey: nil,
                params: data
            )
            
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/jobs/",
                method: "POST",
                body: nil,
                requireAuth: true,
                contentType: "multipart/form-data; boundary=\(boundary)",
                rawData: multipartBody
            )
            
            ToastManager.shared.showToast(message: "Job created successfully", isSuccess: true)
            self.isLoading = false
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(Constants.errorText)",
                    isSuccess: false
                )
        }
    }
    
    @MainActor
    func deleteJob(id: Int) async {
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/jobs/\(id)/",
                method: "DELETE",
                body: nil,
                requireAuth: true
            )
            
            jobs.removeAll(where: { $0.id == id })
            applications.removeAll()
            
            ToastManager.shared.showToast(message: "Collab deleted successfully", isSuccess: true)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func submitApplication(id: Int, answers: [Int: String]) async {
        self.isLoading = true
        self.errorMessage = nil
        
        let newAnswers = Dictionary(
            uniqueKeysWithValues: answers.map { ("\($0.key)", $0.value)
        })
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/jobs/\(id)/apply/",
                method: "POST",
                body: ["answers": newAnswers],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "Application submitted successfully",
                    isSuccess: true
                )
            
            if let i = jobs.firstIndex(where: { $0.id == id }) {
                jobs[i].isApplied = true
            }
            
            self.isLoading = false
            self.errorMessage = nil
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(Constants.errorText)",
                    isSuccess: false
                )
        }
    }
}

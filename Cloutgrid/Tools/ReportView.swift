//
//  ReportView.swift
//  Cloutgrid
//
//  Created by Afthash on 15/4/2026.
//

import SwiftUI

struct ReportView: View {
    let title: String
    let content: String
    
    @State var message: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField(
                content,
                text: $message,
                axis: .vertical
            )
            .lineLimit(5...10)
            .padding(.vertical, 10)
            .customField()
            
            Button {
                ToastManager.shared
                    .showToast(message: "Report submitted", isSuccess: true)
                ReportManager.shared.show = false
            } label: {
                Text("Submit").customButton(disabled: message == "")
            }.disabled(message == "")
        }
        .padding(20)
        .background(Color.dualWhite)
        .cornerRadius(25)
        .padding(20)
    }
}

#Preview {
    ReportView(title: "Report Post", content: "Do you think this post violated our terms and conditions, let us know about it via this form")
}

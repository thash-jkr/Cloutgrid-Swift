//
//  ToastView.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isSuccess ? .green : .red)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.dualWhite)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    ToastView(message: "Good", isSuccess: true)
}

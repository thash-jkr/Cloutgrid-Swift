//
//  Constants.swift
//  Cloutgrid
//
//  Created by Afthash on 15/3/2026.
//

import Foundation
import SwiftUI

struct Constants {
    static let creatorText = "Creator"
    static let businessText = "Business"
    static let errorText = "Unexpected error occurred"
}

struct HomeCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 250, minHeight: 180)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.homeCardLeft, .homeCardRight]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
    }
}

extension View {
    func homeCard() -> some View {
        self.modifier(HomeCard())
    }
}

extension Text {
    func heading1() -> some View {
        self
            .font(.title)
            .bold()
    }
}

extension Text {
    func heading2() -> some View {
        self
            .font(.title2)
            .bold()
    }
}

extension Text {
    func heading3() -> some View {
        self
            .font(.title3)
            .bold()
    }
}

extension Text {
    func heading4() -> some View {
        self
            .font(.system(size: 12, weight: .regular))
    }
}

extension Text {
    func regular1() -> some View {
        self
            .font(.system(size: 16))
    }
}

extension Text {
    func regular2() -> some View {
        self
            .font(.system(size: 14))
    }
}

extension Text {
    func footerText() -> some View {
        self
            .font(.system(size: 12, weight: .regular))
    }
}

extension Text {
    func customButton(disabled: Bool = false) -> some View {
        self
            .font(.system(size: 13))
            .bold()
            .padding(.horizontal)
            .frame(height: 35)
            .background(disabled ? Color.disabled : Color.first)
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .foregroundStyle(Color(.white))
    }
}

extension View {
    func customField(disabled: Bool = false) -> some View {
        self
            .padding(.horizontal, 10)
            .background(Color.textfield)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.system(size: 14))
            .foregroundStyle(disabled ? Color.secondary : Color.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.primary,
                        lineWidth: 1
                    )
            )
    }
}

extension Text {
    func customTag() -> some View {
        self
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.second)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.bottom, 15)
    }
}

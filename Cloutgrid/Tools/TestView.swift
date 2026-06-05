//
//  TestView.swift
//  Cloutgrid
//
//  Created by Afthash on 9/4/2026.
//

import SwiftUI
import WebKit

struct LegacyWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct TestView: View {
    var body: some View {
        LegacyWebView(url: URL(string: "https://www.apple.com")!)
            .edgesIgnoringSafeArea(.bottom)
    }
}



#Preview {
    TestView()
}

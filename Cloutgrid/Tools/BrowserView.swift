//
//  BrowserView.swift
//  Cloutgrid
//
//  Created by Afthash on 5/6/2026.
//

import SwiftUI
import WebKit

struct BrowserView: View {
    var url: URL
    
    private func webContent(url: URL) -> some View {
        NavigationStack {
            if #available(iOS 26.0, *) {
                WebView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                LegacyWebView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }
    
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
    
    var body: some View {
        webContent(url: url)
    }
}

#Preview {
    BrowserView(url: URLRequest(url: URL(string: "https://cloutgrid.com")!).url!)
}

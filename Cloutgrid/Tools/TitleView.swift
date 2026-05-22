//
//  titleView.swift
//  Cloutgrid
//
//  Created by Afthash on 25/3/2026.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Clout").foregroundStyle(Color.first).heading2()
            Text("grid").foregroundStyle(Color.second).heading2()
        }
    }
}

#Preview {
    TitleView()
}

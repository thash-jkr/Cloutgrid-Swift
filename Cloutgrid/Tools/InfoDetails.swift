//
//  InfoDetails.swift
//  Cloutgrid
//
//  Created by Afthash on 9/4/2026.
//

import SwiftUI

struct InfoDetails: View {
    let title: String?
    let description: String
    var detent: CGFloat = 0.3
    
    init(title: String? = nil, description: String, detent: CGFloat = 0.3) {
        self.title = title
        self.description = description
        self.detent = detent
    }
    
    var body: some View {
        List {
            Section {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 5)
            } header: {
                Text(title ?? "")
                    .font(.headline)
                    .textCase(.none)
            }
        }
        .presentationDetents([.fraction(detent)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    let desc = "qqfvineuiberuvbebv iuer iurh urh prh phiue hgpiehrgiehrgieruhg eirgh  gpiuqehrgiueqhrg iuerhg iuergh ieuqrhg qiurgh iqurbgiqurbgi ubrgie rgbiebggb ibg igbiegbgjrbgkerbg iebg ierbgebg  berkgbrbgiergb irbgierbg ibg iuebrg eirbg ieu  ig ierbg iuqreg irbeug iuerb ierbg iugrb qiqirgpiqg pqirgb piurgb i   oqhrhgurgpuq hrg iurghp ighqpigh irg heqpigh iug iugh q   qrgh iurhg iqeuh gqoi ghoqirgh qir hgqiouhg iu hgpiqehgknvknv rnqrug qpieg pieqrgb i"
    InfoDetails(title: "Title", description: desc)
}

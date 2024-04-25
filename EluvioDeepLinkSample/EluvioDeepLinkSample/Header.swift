//
//  Header.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-07.
//

import SwiftUI

struct Header: View {
    @EnvironmentObject var fabric: Fabric

    var body: some View {
        HStack  {
            HStack(
                alignment:.top,
                spacing:20
            ){
                Image("e_logo")
                    .resizable()
                    .frame(
                        width:120,
                        height:120
                    )
                Text("Eluvio Wallet Link Sample")
                    .foregroundColor(Color.white.opacity(0.4))
                    .font(.title)
            }
            .frame(maxWidth: .infinity)
        }
        .focusSection()
        .frame(maxWidth: .infinity)

    }
}

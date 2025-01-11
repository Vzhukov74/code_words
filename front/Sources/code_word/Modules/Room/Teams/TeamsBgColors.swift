//
//  SwiftUIView.swift
//  project-name
//
//  Created by Vladislav Zhukov on 11.01.2025.
//

import SwiftUI

struct TeamsBgColors: View {
    var body: some View {
        HStack(spacing: 0) {
            AppColor.red
                .frame(maxWidth: .infinity)
            AppColor.blue
                .frame(maxWidth: .infinity)
        }
    }
}

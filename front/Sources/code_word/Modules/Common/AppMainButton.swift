//
//  AppMainButton.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

import SwiftUI

struct AppMainButton: View {
    
    let title: String
    let action: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(color)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(Color.black)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundStyle(Color.black)
                                .offset(x: 2, y: 2)
                        }
                }
        }
    }
}

//
//  LeaderHitnInputView.swift
//  project-name
//
//  Created by Владислав Жуков on 14.10.2024.
//

import SwiftUI

struct LeaderHitnInputView: View {
    
    @StateObject var vm: LeaderHitnInputViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                TextField("введите слово", text: $vm.text)
                HStack(spacing: 8) {
                    ForEach(1...9, id: \.self) { number in
                        NumberButton(
                            title: "\(number)",
                            action: { vm.onSelectNumber(number) },
                            color: AppColor.blue,
                            isSelect: number == vm.number
                        )
                    }
                }
            }
            Button(action: { vm.onHint() }) {
                Image("enter", bundle: .module)
                    .resizable()
                    .frame(width: 46, height: 66)
            }
            .disabled(!vm.isSendActive)
            .frame(width: 56)
        }
    }
}

private struct NumberButton: View {
    let title: String
    let action: () -> Void
    let color: Color
    let isSelect: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .foregroundStyle(isSelect ? AppColor.main : Color.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 36)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(color)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(Color.black)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.black)
                                .offset(x: 2, y: 2)
                        }
                }
        }
    }
}

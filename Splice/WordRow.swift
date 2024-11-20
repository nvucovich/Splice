//
//  WordRow.swift
//  Splice
//
//  Created by NVucovich on 11/19/24.
//

import SwiftUI

struct WordRow: View {
    let prefix: String
    @Binding var word: String
    let isActive: Bool
    let wordLength: Int
    let showCursor: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            ForEach(0..<wordLength, id: \.self) { index in
                ZStack {
                    LetterBox(
                        letter: letterAt(index),
                        isPrefix: index < 2,
                        isActive: isActive
                    )
                    
                    if showCursor && index == word.count && index >= 2 {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 2, height: 30)
                    }
                }
            }
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private func letterAt(_ index: Int) -> String {
        if index < word.count {
            return String(word[word.index(word.startIndex, offsetBy: index)])
        }
        return ""
    }
}

struct LetterBox: View {
    let letter: String
    let isPrefix: Bool
    let isActive: Bool
    
    var body: some View {
        Text(letter)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(isPrefix ? .white : .primary)
            .frame(width: 45, height: 45)
            .background(backgroundColor)
            .border(Color.blue.opacity(0.3), width: 2)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        if isPrefix {
            return .blue
        }
        if isActive {
            return .blue.opacity(0.1)
        }
        return .white
    }
}

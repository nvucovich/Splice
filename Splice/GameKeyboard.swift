import SwiftUI

struct GameKeyboard: View {
    let onKeyTap: (String) -> Void
    
    private let rows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { key in
                        KeyboardButton(key: key, onTap: onKeyTap)
                    }
                }
            }
        }
    }
}

struct KeyboardButton: View {
    let key: String
    let onTap: (String) -> Void
    
    var body: some View {
        Button(action: { onTap(key) }) {
            Text(key)
                .font(.system(size: key.count > 1 ? 12 : 18))
                .foregroundColor(.white)
                .frame(minWidth: key.count > 1 ? 50 : 30, minHeight: 50)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(8)
        }
    }
}

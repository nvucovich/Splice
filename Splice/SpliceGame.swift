import SwiftUI

struct SpliceGame: View {
    let sourceWord: String
    let wordLength: Int
    let letterPairs: [String]
    
    @State private var wordEntries: [String]
    @State private var currentRow = 0
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var showAlert = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var bestTime: TimeInterval?
    @State private var showInvalidWordAlert = false
    @State private var isValidating = false
    @Environment(\.dismiss) private var dismiss
    
    init(sourceWord: String) {
        self.sourceWord = sourceWord.uppercased()
        self.wordLength = sourceWord.count
        
        var pairs: [String] = []
        for i in 0..<(sourceWord.count - 1) {
            let startIndex = sourceWord.index(sourceWord.startIndex, offsetBy: i)
            let endIndex = sourceWord.index(sourceWord.startIndex, offsetBy: i + 2)
            pairs.append(String(sourceWord[startIndex..<endIndex]))
        }
        self.letterPairs = pairs
        self._wordEntries = State(initialValue: pairs.map { $0 })
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button("Back") {
                    timer?.invalidate()
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "Time: %.1f seconds", currentTime))
                        .font(.headline)
                        .monospacedDigit()
                    
                    if let best = bestTime {
                        Text(String(format: "Best: %.1f seconds", best))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .monospacedDigit()
                    }
                }
            }
            .padding()
            
            Text(sourceWord)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom)
            
            // Word entry grid
            VStack(spacing: 12) {
                ForEach(0..<letterPairs.count, id: \.self) { index in
                    WordRow(
                        prefix: letterPairs[index],
                        word: $wordEntries[index],
                        isActive: currentRow == index,
                        wordLength: wordLength,
                        onTap: { currentRow = index }
                    )
                }
            }
            .padding()
            
            Spacer()
            
            GameKeyboard(onKeyTap: handleKeyTap)
                .padding()
        }
        .overlay {
            if isValidating {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .onAppear {
            loadBestTime()
            startTime = Date()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Splice Complete!", isPresented: $showAlert) {
            Button("New Game") {
                timer?.invalidate()
                dismiss()
            }
        } message: {
            VStack {
                Text("Time: \(String(format: "%.1f seconds", currentTime))")
                if let best = bestTime {
                    if currentTime < best {
                        Text("New Best Time! 🎉")
                            .bold()
                    } else {
                        Text("Best: \(String(format: "%.1f seconds", best))")
                    }
                } else {
                    Text("First completion! 🎉")
                }
            }
        }
        .alert("Invalid Word", isPresented: $showInvalidWordAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a valid English word.")
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let start = startTime else { return }
            if endTime == nil {
                currentTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    private func handleKeyTap(_ key: String) {
        guard currentRow < letterPairs.count else { return }
        
        if key == "⌫" {
            if wordEntries[currentRow].count > 2 {
                wordEntries[currentRow].removeLast()
            }
        } else if wordEntries[currentRow].count < wordLength {
            wordEntries[currentRow] += key
            
            // Auto-validate when word is complete
            if wordEntries[currentRow].count == wordLength {
                Task {
                    await validateAndAdvance(currentRow)
                }
            }
        }
    }
    
    private func validateAndAdvance(_ index: Int) async {
        isValidating = true
        let isValid = await WordManager.validateWord(wordEntries[index])
        isValidating = false
        
        if !isValid {
            playErrorHaptic()
            showInvalidWordAlert = true
            wordEntries[index] = letterPairs[index] // Reset to just the prefix
            return
        }
        
        playHaptic()
        
        if index < letterPairs.count - 1 {
            currentRow = index + 1
        } else {
            endTime = Date()
            currentTime = endTime!.timeIntervalSince(startTime!)
            updateBestTime(currentTime)
            timer?.invalidate()
            showAlert = true
        }
    }
    
    private func loadBestTime() {
        bestTime = UserDefaults.standard.double(forKey: "bestTime_\(sourceWord)")
        if bestTime == 0 {
            bestTime = nil
        }
    }
    
    private func updateBestTime(_ time: TimeInterval) {
        if let best = bestTime {
            if time < best {
                bestTime = time
                UserDefaults.standard.set(time, forKey: "bestTime_\(sourceWord)")
            }
        } else {
            bestTime = time
            UserDefaults.standard.set(time, forKey: "bestTime_\(sourceWord)")
        }
    }
    
    private func playHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func playErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

struct WordRow: View {
    let prefix: String
    @Binding var word: String
    let isActive: Bool
    let wordLength: Int
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            ForEach(0..<wordLength, id: \.self) { index in
                LetterBox(
                    letter: letterAt(index),
                    isPrefix: index < 2,
                    isActive: isActive
                )
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

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
    @State private var showCursor = false
    @State private var showStatsView = false
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
                Button(action: { dismiss() }) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                }
                
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
            
            Text("Source: \(sourceWord)")
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
                        showCursor: showCursor && currentRow == index,
                        onTap: { currentRow = index }
                    )
                }
            }
            .padding()
            
            Spacer()
            
            GameKeyboard(onKeyTap: handleKeyTap)
                .padding()
        }
        .alert("Splice Complete!", isPresented: $showAlert) {
            Button("View Stats") {
                timer?.invalidate()
                showStatsView = true
            }
        }
        .navigationDestination(isPresented: $showStatsView) {
            SpliceStatsView(
                completedWords: wordEntries,
                timeCompleted: currentTime
            )
        }
        .alert("Invalid Word", isPresented: $showInvalidWordAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(wordEntries[currentRow] == sourceWord ?
                "You cannot use the source word as an answer." :
                "Please enter a valid English word.")
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
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                showCursor.toggle()
            }
        }
        .onDisappear {
            timer?.invalidate()
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
        
        // Check if word matches source word
        if wordEntries[index] == sourceWord {
            playErrorHaptic()
            showInvalidWordAlert = true
            wordEntries[index] = letterPairs[index]
            return
        }
        
        if !isValid {
            playErrorHaptic()
            showInvalidWordAlert = true
            wordEntries[index] = letterPairs[index]
            return
        }
        
        playHaptic()
        
        if index < letterPairs.count - 1 {
            currentRow = index + 1
        } else {
            endTime = Date()
            currentTime = endTime!.timeIntervalSince(startTime!)
            updateBestTime(currentTime)
            
            // Save completed game data
            UserDefaults.standard.set(wordEntries, forKey: "lastCompletedWords")
            UserDefaults.standard.set(currentTime, forKey: "lastCompletedTime")
            UserDefaults.standard.set(Date(), forKey: "lastPlayedDate")
            
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

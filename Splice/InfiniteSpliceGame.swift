import SwiftUI

struct InfiniteSpliceGame: View {
    @State private var showStatsView = false
    @State private var currentWord: String
    @State private var letterPairs: [String]
    @State private var wordEntries: [String]
    @State private var currentRow = 0
    @State private var score: Int = 0
    @State private var isGameOver = false
    @State private var gameOverReason = ""
    @State private var usedWords: Set<String> = []
    @State private var showInvalidWordAlert = false
    @State private var isValidating = false
    @State private var showCursor = false
    @State private var showingSurrenderConfirmation = false
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "infiniteHighScore")
    @Environment(\.dismiss) private var dismiss
    
    static private func generateLetterPairs(from word: String) -> [String] {
        var pairs: [String] = []
        for i in 0..<(word.count - 1) {
            let startIndex = word.index(word.startIndex, offsetBy: i)
            let endIndex = word.index(word.startIndex, offsetBy: i + 2)
            pairs.append(String(word[startIndex..<endIndex]))
        }
        return pairs
    }
    
    init() {
        let startWord = WordManager.getWordOfTheDay()
        let pairs = InfiniteSpliceGame.generateLetterPairs(from: startWord)
        _currentWord = State(initialValue: startWord)
        _letterPairs = State(initialValue: pairs)
        _wordEntries = State(initialValue: pairs)
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
                
                Text("Score: \(score)")
                    .font(.headline)
                    .monospacedDigit()
                if highScore > 0 {
                    Text("Best: \(highScore)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .monospacedDigit()
                }
            }
            .padding()
            
            Text("Source: \(currentWord)")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom)
            
            // Word rows
            VStack(spacing: 12) {
                ForEach(0..<letterPairs.count, id: \.self) { index in
                    WordRow(
                        prefix: letterPairs[index],
                        word: $wordEntries[index],
                        isActive: currentRow == index,
                        wordLength: currentWord.count,
                        showCursor: showCursor && currentRow == index,
                        onTap: { currentRow = index }
                    )
                }
                
                // Surrender button
                Button(action: {
                    showingSurrenderConfirmation = true
                }) {
                    Text("Surrender")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
            .padding()
            
            Spacer()
            
            GameKeyboard(onKeyTap: handleKeyTap)
                .padding()
        }
        .navigationDestination(isPresented: $showStatsView) {
            InfiniteStatsView(
                score: score,
                gameOverReason: gameOverReason,
                isHighScore: score > highScore
            )
        }
        // Replace the Game Over alert with this:
        .alert("Game Over!", isPresented: $isGameOver) {
            Button("View Stats") {
                showStatsView = true
            }
        }
        .alert("Invalid Word", isPresented: $showInvalidWordAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a valid English word.")
        }
        .alert("Surrender Confirmation", isPresented: $showingSurrenderConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Surrender", role: .destructive) {
                gameOverReason = "Game Over! You surrendered."
                endGame()
            }
        } message: {
            Text("Are you sure you want to surrender? Your current score is \(score).")
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
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                showCursor.toggle()
            }
        }
    }
    
    private func handleKeyTap(_ key: String) {
        guard currentRow < letterPairs.count else { return }
        
        if key == "⌫" {
            if wordEntries[currentRow].count > 2 {
                wordEntries[currentRow].removeLast()
            }
        } else if wordEntries[currentRow].count < currentWord.count {
            wordEntries[currentRow] += key
            
            if wordEntries[currentRow].count == currentWord.count {
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
            wordEntries[index] = letterPairs[index]
            return
        }
        
        // Check if word has been used before
        if usedWords.contains(wordEntries[index]) {
            gameOverReason = "Game Over! You repeated the word: \(wordEntries[index])"
            endGame()
            return
        }
        
        playHaptic()
        usedWords.insert(wordEntries[index])
        
        // Only update score and change the source word if this is the last pair
        if index == letterPairs.count - 1 {
            // Update score and current word
            score += 1
            currentWord = wordEntries[index]
            
            // Generate new letter pairs and reset entries
            let newPairs = InfiniteSpliceGame.generateLetterPairs(from: currentWord)
            letterPairs = newPairs
            wordEntries = newPairs
            currentRow = 0
            
            // Check if any of the new letter pairs can form valid words
            for pair in letterPairs {
                if !TwoLetterValidator.isValid(pair) {
                    gameOverReason = "Game Over! No valid words start with: \(pair)"
                    endGame()
                    return
                }
            }
        } else {
            // Move to next row
            currentRow = index + 1
        }
    }
    
    private func endGame() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "infiniteHighScore")
        }
        isGameOver = true
    }
    
    private func resetGame() {
        let startWord = WordManager.getWordOfTheDay()
        currentWord = startWord
        letterPairs = InfiniteSpliceGame.generateLetterPairs(from: startWord)
        wordEntries = letterPairs
        currentRow = 0
        score = 0
        usedWords = []
        isGameOver = false
        gameOverReason = ""
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

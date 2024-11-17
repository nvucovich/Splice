import SwiftUI

struct SpliceStatsView: View {
    let completedWords: [String]
    let timeCompleted: TimeInterval
    @Environment(\.dismiss) private var dismiss
    
    // Hardcoded global stats for demonstration
    private let globalStats: [Double] = [45.2, 38.7, 62.1, 29.4, 55.8]
    // Hardcoded percentile (percentage of players beaten)
    private let percentileBeat: Double = 73.5
    
    var body: some View {
        VStack {
            Text("Congratulations!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 4) {
                Text("Your time: \(String(format: "%.1f", timeCompleted))s")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Beat \(String(format: "%.1f", percentileBeat))% of global players!")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
            
            // Word stats grid
            VStack(spacing: 12) {
                ForEach(0..<completedWords.count, id: \.self) { index in
                    StatRow(
                        word: completedWords[index],
                        globalPercentage: globalStats[safe: index] ?? 0.0
                    )
                }
            }
            .padding()
            
            Spacer()
            
            // Return home button
            Button(action: {
                dismiss()
            }) {
                Text("Return Home")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true) // This hides the back button
    }
}

struct StatRow: View {
    let word: String
    let globalPercentage: Double
    
    var body: some View {
        VStack(spacing: 4) {
            // Word display
            HStack {
                ForEach(0..<word.count, id: \.self) { index in
                    Text(String(word[word.index(word.startIndex, offsetBy: index)]))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(index < 2 ? .white : .primary)
                        .frame(width: 45, height: 45)
                        .background(index < 2 ? Color.blue : Color.white)
                        .border(Color.blue.opacity(0.3), width: 2)
                        .cornerRadius(8)
                }
            }
            
            // Global stats
            Text("\(String(format: "%.1f", globalPercentage))% of players chose this word")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

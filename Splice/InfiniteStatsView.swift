//
//  InfiniteStatsView.swift
//  Splice
//
//  Created by NVucovich on 11/19/24.
//

import SwiftUI

struct InfiniteStatsView: View {
    let score: Int
    let gameOverReason: String
    let isHighScore: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Hardcoded global rankings for demonstration
    private let globalRankings = [
        15, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1
    ]
    
    private var percentileBeat: Double {
        let totalPlayers = globalRankings.count
        let playersBeat = globalRankings.filter { $0 < score }.count
        return Double(playersBeat) / Double(totalPlayers) * 100
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Game Over!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(gameOverReason)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Score section
            VStack(spacing: 8) {
                Text("Words Spliced: \(score)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if isHighScore {
                    Text("🎉 New High Score! 🎉")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                
                Text("Beat \(String(format: "%.1f", percentileBeat))% of players today!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            // Distribution chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Rankings")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ForEach(globalRankings.sorted(by: >), id: \.self) { ranking in
                    HStack {
                        Text("\(ranking) words")
                            .frame(width: 80, alignment: .leading)
                        
                        Rectangle()
                            .fill(ranking == score ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: getBarWidth(for: ranking), height: 24)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
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
        .padding()
        .navigationBarBackButtonHidden(true)
    }
    
    private func getBarWidth(for score: Int) -> CGFloat {
        let maxScore = globalRankings.max() ?? 1
        let maxWidth: CGFloat = 200
        return (CGFloat(score) / CGFloat(maxScore)) * maxWidth
    }
}

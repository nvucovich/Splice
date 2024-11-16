import SwiftUI

struct HomeView: View {
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("SPLICE")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.blue)
                
                Text("Daily Word Challenge")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showGame = true
                }) {
                    Text("Play Today's Challenge")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play:")
                        .font(.headline)
                    
                    Text("1. A new word appears each day")
                    Text("2. Create valid words starting with each pair of letters")
                    Text("3. All words must be the same length as the daily word")
                    Text("4. Click any row to type your word")
                    Text("5. Complete all words as fast as you can!")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1)))
                .padding()
            }
            .navigationDestination(isPresented: $showGame) {
                SpliceGame(sourceWord: WordManager.getWordOfTheDay())
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

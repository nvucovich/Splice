import SwiftUI

struct HomeView: View {
    @State private var showGame = false
    @State private var showInfiniteGame = false
    @State private var showStats = false
    @State private var hasPlayedToday = false
    @State private var lastCompletedWords: [String] = []
    @State private var lastCompletedTime: TimeInterval = 0
    private let DevMode = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("SPLICE")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.blue)
                
                Text("Daily Word Challenge")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(spacing: 16) {
                    if !hasPlayedToday || DevMode {
                        Button(action: {
                            showGame = true
                            if !DevMode {
                                hasPlayedToday = true
                                UserDefaults.standard.set(Date(), forKey: "lastPlayedDate")
                            }
                        }) {
                            Text("Play Today's Challenge")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            loadLastGame()
                            showStats = true
                        }) {
                            Text("View Stats")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        showInfiniteGame = true
                    }) {
                        Text("Infinite Mode")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play:")
                        .font(.headline)
                    
                    Text("1. A new word appears each day")
                    Text("2. Create valid words starting with each pair of letters")
                    Text("3. All words must be the same length as the daily word")
                    Text("4. Click any row to type your word")
                    Text("5. Complete all words as fast as you can!")
                    
                    Text("Infinite Mode:")
                        .font(.headline)
                        .padding(.top)
                    Text("• Each valid word becomes the next challenge")
                    Text("• Score points for each word")
                    Text("• Game ends if you repeat a word or can't continue")
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
            .navigationDestination(isPresented: $showInfiniteGame) {
                InfiniteSpliceGame()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $showStats) {
                SpliceStatsView(
                    completedWords: lastCompletedWords,
                    timeCompleted: lastCompletedTime
                )
                .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                if !DevMode {
                    checkIfPlayedToday()
                }
                if hasPlayedToday {
                    loadLastGame()
                }
            }
        }
    }
    
    private func checkIfPlayedToday() {
        if let lastPlayed = UserDefaults.standard.object(forKey: "lastPlayedDate") as? Date {
            let calendar = Calendar.current
            hasPlayedToday = calendar.isDate(lastPlayed, inSameDayAs: Date())
        }
    }
    
    private func loadLastGame() {
        if let words = UserDefaults.standard.stringArray(forKey: "lastCompletedWords") {
            lastCompletedWords = words
        }
        lastCompletedTime = UserDefaults.standard.double(forKey: "lastCompletedTime")
    }
}

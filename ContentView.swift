//
//  ContentView.swift
//  2048
//
//  Created by Ivan Jiang on 12/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameLogic = GameLogic()
    @AppStorage("highScore") private var highScore = 0
    
    let spacing: CGFloat = 8
    let cornerRadius: CGFloat = 8
    
    // Sakura theme colors
    let sakuraPink = Color(red: 255/255, green: 183/255, blue: 197/255)
    let sakuraDarkPink = Color(red: 255/255, green: 138/255, blue: 162/255)
    
    var body: some View {
        ZStack {
            // Background image
            Image("sakura_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6)
            
            // Main content
            VStack(spacing: 12) {
                // Title
                Text("2048")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(sakuraDarkPink)
                    .padding(.top, 4)
                
                // Scores
                HStack(spacing: 16) {
                    ScoreView(title: "SCORE", score: gameLogic.score, backgroundColor: sakuraPink)
                    ScoreView(title: "BEST", score: max(highScore, gameLogic.score), backgroundColor: sakuraPink)
                }
                .padding(.horizontal, 4)
                
                // Game board
                GameBoard(gameLogic: gameLogic, spacing: spacing)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    .padding(spacing)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(cornerRadius)
                    .shadow(color: sakuraPink.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Controls
                HStack(spacing: 12) {
                    Button(action: gameLogic.newGame) {
                        Label("New", systemImage: "arrow.clockwise")
                            .font(.callout.bold())
                            .foregroundColor(sakuraDarkPink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .background(sakuraPink.opacity(0.2))
                    .cornerRadius(12)
                    
                    Button(action: gameLogic.undo) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .font(.callout.bold())
                            .foregroundColor(sakuraDarkPink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .background(sakuraPink.opacity(0.2))
                    .cornerRadius(12)
                    .opacity(gameLogic.canUndo ? 1 : 0.5)
                    .disabled(!gameLogic.canUndo)
                }
            }
            .padding(8)
        }
        .gesture(DragGesture()
            .onEnded { gesture in
                let translation = gesture.translation
                let horizontalAmount = abs(translation.width)
                let verticalAmount = abs(translation.height)
                
                if horizontalAmount > verticalAmount {
                    if translation.width > 0 {
                        gameLogic.move(.right)
                    } else {
                        gameLogic.move(.left)
                    }
                } else {
                    if translation.height > 0 {
                        gameLogic.move(.up)
                    } else {
                        gameLogic.move(.down)
                    }
                }
            }
        )
        .onChange(of: gameLogic.score) { newScore in
            if newScore > highScore {
                highScore = newScore
            }
        }
    }
}

struct ScoreView: View {
    let title: String
    let score: Int
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.caption2.bold())
                .foregroundColor(.white)
            Text("\(score)")
                .font(.system(.title3, design: .rounded).bold())
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
        }
        .frame(width: 80)
        .frame(minHeight: 44)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .cornerRadius(8)
        .shadow(color: backgroundColor.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct GameBoard: View {
    @ObservedObject var gameLogic: GameLogic
    let spacing: CGFloat
    
    var body: some View {
        Grid(horizontalSpacing: spacing/1.5, verticalSpacing: spacing/1.5) {
            ForEach(0..<4) { row in
                GridRow {
                    ForEach(0..<4) { column in
                        let tile = gameLogic.board[row][column]
                        TileView(value: tile?.value ?? 0)
                            .id(tile?.id ?? "\(row),\(column)")
                    }
                }
            }
        }
    }
}

struct TileView: View {
    let value: Int
    
    var backgroundColor: Color {
        switch value {
        case 0: return Color(.systemGray6)
        case 2: return Color(red: 255/255, green: 223/255, blue: 229/255)
        case 4: return Color(red: 255/255, green: 200/255, blue: 210/255)
        case 8: return Color(red: 255/255, green: 183/255, blue: 197/255)
        case 16: return Color(red: 255/255, green: 157/255, blue: 177/255)
        case 32: return Color(red: 255/255, green: 138/255, blue: 162/255)
        case 64: return Color(red: 255/255, green: 114/255, blue: 143/255)
        case 128: return Color(red: 255/255, green: 97/255, blue: 131/255)
        case 256: return Color(red: 255/255, green: 66/255, blue: 107/255)
        case 512: return Color(red: 255/255, green: 33/255, blue: 81/255)
        case 1024: return Color(red: 255/255, green: 0/255, blue: 54/255)
        case 2048: return Color(red: 220/255, green: 20/255, blue: 60/255)
        default: return Color(red: 190/255, green: 20/255, blue: 60/255)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: backgroundColor.opacity(0.3), radius: 2, x: 0, y: 1)
            
            if value > 0 {
                Text("\(value)")
                    .font(.system(
                        value > 100 ? .body : value > 1000 ? .caption : .title3,
                        design: .rounded
                    ).bold())
                    .foregroundColor(value <= 4 ? .gray : .white)
                    .minimumScaleFactor(0.4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: value)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    ContentView()
}

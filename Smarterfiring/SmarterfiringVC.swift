import SwiftUI
import Combine

// MARK: - Tiny Models
struct TinyPosition: Equatable {
    var x: Int
    var y: Int
}

enum TinyDirection: String, CaseIterable {
    case up, down, left, right
}

struct TinyDragon: Identifiable {
    let id = UUID()
    var position: TinyPosition
    var direction: TinyDirection
    var isHit: Bool = false
}


// MARK: - Tiny Views
struct TinyGameView: View {
    @StateObject private var tinyGameState = TinyGameState()
    @State private var showInfo = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            
            Image("bb")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0) // 👈 This will keep other views (like a large text) in the frame
                .edgesIgnoringSafeArea(.all)
            
            
            if tinyGameState.showInstructions {
                TinyInstructionView(tinyGameState: tinyGameState)
            } else if tinyGameState.isGameOver {
                TinyGameOverView(tinyGameState: tinyGameState)
            } else {
                VStack {
                    TinyHeaderView(tinyGameState: tinyGameState)
                    
                    TinyGameBoardView(tinyGameState: tinyGameState)
                        .frame(width: 300, height: 300)
                    
                    TinyControlsView(tinyGameState: tinyGameState)
                    
                    Spacer()
                }
                .onAppear()
                {
                    tinyGameState.tinyFire()
                }
                .padding()
            }
        }
       
        .sheet(isPresented: $showInfo) {
            TinyInfoView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.custom("PressStart2P-Regular", size: 20))
                }
            }
        }
    }
}

struct TinyHeaderView: View {
    @ObservedObject var tinyGameState: TinyGameState
    
    var body: some View {
        HStack {
            VStack {
                Text("Score: \(tinyGameState.score)")
                    .font(.custom("PressStart2P-Regular", size: 14))
                    .foregroundColor(.white)
                
                Text("Time: \(tinyGameState.timeRemaining)s")
                    .font(.custom("PressStart2P-Regular", size: 14))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: { tinyGameState.tinyStartGame() }) {
                Text("Restart")
                    .font(.custom("PressStart2P-Regular", size: 14))
                    .padding(8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct TinyGameBoardView: View {
    @ObservedObject var tinyGameState: TinyGameState
    let gridSize = 5
    
    var body: some View {
        ZStack {
            // Grid background
      //      GridBackgroundView(gridSize: gridSize)
            
            
            Image("cc")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0) // 👈 This will keep other views (like a large text) in the frame
                .edgesIgnoringSafeArea(.all)

            GridBackgroundView(gridSize: gridSize)

            
            // Player character
            TinyCharacterView(direction: tinyGameState.tinyDirection)
                .position(tinyPositionToCGPoint(tinyGameState.tinyPosition))
            
            // Fire direction indicator
            TinyFireDirectionView(direction: tinyGameState.tinyDirection)
                .position(tinyPositionToCGPoint(tinyGameState.tinyPosition))
                .offset(x: tinyFireOffset().width, y: tinyFireOffset().height)
            
            // Dragons
            ForEach(tinyGameState.dragons) { dragon in
                TinyDragonView(direction: dragon.direction, isHit: dragon.isHit)
                    .position(tinyPositionToCGPoint(dragon.position))
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
    
    private func tinyPositionToCGPoint(_ position: TinyPosition) -> CGPoint {
        let cellSize = 300 / gridSize
        return CGPoint(
            x: CGFloat(position.x * cellSize + cellSize / 2),
            y: CGFloat(position.y * cellSize + cellSize / 2)
        )
    }
    
    private func tinyFireOffset() -> CGSize {
        let offset = 30
        switch tinyGameState.tinyDirection {
        case .up: return CGSize(width: 0, height: -offset)
        case .down: return CGSize(width: 0, height: offset)
        case .left: return CGSize(width: -offset, height: 0)
        case .right: return CGSize(width: offset, height: 0)
        }
    }
}

struct GridBackgroundView: View {
    let gridSize: Int
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = geometry.size.width / CGFloat(gridSize)
            
            // Draw grid lines
            Path { path in
                for i in 0...gridSize {
                    // Vertical lines
                    path.move(to: CGPoint(x: CGFloat(i) * cellSize, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i) * cellSize, y: geometry.size.height))
                    
                    // Horizontal lines
                    path.move(to: CGPoint(x: 0, y: CGFloat(i) * cellSize))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: CGFloat(i) * cellSize))
                }
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
}

struct TinyCharacterView: View {
    let direction: TinyDirection
    
    var body: some View {
        ZStack {
//            Image("up1")
        //    Circle()
             //   .fill(Color.blue)
          //      .frame(width: 30, height: 30)
            
            // Direction indicator
            Image(tinyDirectionIcon())
                .foregroundColor(.white)
                .tint(.red)
                .font(.system(size: 12))
                .frame(width: 30, height: 30)
        }
    }
    
    private func tinyDirectionIcon() -> String {
        switch direction {
        case .up: return "up1"
        case .down: return "down1"
        case .left: return "left1"
        case .right: return "right1"
        }
    }
}

struct TinyDragonView: View {
    let direction: TinyDirection
    let isHit: Bool
    
    var body: some View {
        ZStack {
            Image(systemName: isHit ? "burst.fill" : "flame.fill")
                .foregroundColor(isHit ? .yellow : .red)
                .font(.system(size: 20))
                .scaleEffect(isHit ? 1.5 : 1.0)
                .animation(isHit ? .easeOut(duration: 0.3) : .default, value: isHit)
            
            if !isHit {
                Image(systemName: tinyDirectionIcon())
                    .foregroundColor(.black)
                    .font(.system(size: 10))
                    .offset(x: 0, y: 15)
            }
        }
    }
    
    private func tinyDirectionIcon() -> String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

struct TinyFireDirectionView: View {
    let direction: TinyDirection
    
    var body: some View {
        Image(systemName: "flame.fill")
            .foregroundColor(.red)
            .font(.system(size: 15))
            .opacity(0.7)
    }
}

struct TinyControlsView: View {
    @ObservedObject var tinyGameState: TinyGameState
    
    var body: some View {
        VStack(spacing: 10) {
            // Fire button
            Button(action: { tinyGameState.tinyFire() }) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
                    .frame(width: 80, height: 80)
                    .background(Circle().fill(Color.red.opacity(0.7)))
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.bottom, 20)
            
            // Direction controls
            VStack(spacing: 5) {
                Button(action: { tinyGameState.tinyMove(direction: .up) }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20))
                        .frame(width: 60, height: 40)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                }
                
                HStack(spacing: 5) {
                    Button(action: { tinyGameState.tinyMove(direction: .left) }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .frame(width: 60, height: 40)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(10)
                    }
                    
                    Spacer().frame(width: 60)
                    
                    Button(action: { tinyGameState.tinyMove(direction: .right) }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .frame(width: 60, height: 40)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(10)
                    }
                }
                
                Button(action: { tinyGameState.tinyMove(direction: .down) }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 20))
                        .frame(width: 60, height: 40)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                }
            }
            .foregroundColor(.white)
        }
    }
}

struct TinyInstructionView: View {
    @ObservedObject var tinyGameState: TinyGameState
    @State private var currentPage = 0
    
    let instructions = [
        "Welcome to Smarterfiring!",
        "Move your character with the arrow buttons",
        "Tap the fire button to shoot flames",
        "Hit dragons coming from the opposite direction",
        "Score points for each dragon you hit",
        "You have 2 minutes to score as much as possible!"
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            
            
            Image("bb")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0) // 👈 This will keep other views (like a large text) in the frame
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("HOW TO PLAY")
                    .font(.custom("PressStart2P-Regular", size: 24))
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                
                // Animated instruction content
                ZStack {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        if index == currentPage {
                            VStack {
                                Image(systemName: tinyIconForPage(index))
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .padding()
                                    .transition(.scale.combined(with: .opacity))
                                
                                Text(instructions[index])
                                    .font(.custom("PressStart2P-Regular", size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .transition(.opacity)
                            }
                            .animation(.easeInOut(duration: 0.5), value: currentPage)
                        }
                    }
                }
                .frame(height: 200)
                
                HStack {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.gray)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    if currentPage < instructions.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        tinyGameState.showInstructions = false
                        tinyGameState.tinyStartGame()
                    }
                }) {
                    Text(currentPage < instructions.count - 1 ? "NEXT" : "START GAME")
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
    
    private func tinyIconForPage(_ page: Int) -> String {
        switch page {
        case 0: return "gamecontroller"
        case 1: return "arrow.up.left.and.arrow.down.right"
        case 2: return "flame.fill"
        case 3: return "burst.fill"
        case 4: return "star.fill"
        case 5: return "clock.fill"
        default: return "info.circle"
        }
    }
}

struct TinyGameOverView: View {
    @ObservedObject var tinyGameState: TinyGameState
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            
            Image("bb")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0) // 👈 This will keep other views (like a large text) in the frame
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("GAME OVER")
                    .font(.custom("PressStart2P-Regular", size: 30))
                    .foregroundColor(.white)
                    .padding()
                
                Text("Your Score: \(tinyGameState.score)")
                    .font(.custom("PressStart2P-Regular", size: 24))
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { tinyGameState.tinyStartGame() }) {
                        Text("Play Again")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: tinyShareScore) {
                        Text("Share Score")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private func tinyShareScore() {
        let activityVC = UIActivityViewController(
            activityItems: ["I scored \(tinyGameState.score) points in Smarterfiring! Can you beat my score?"],
            applicationActivities: nil
        )
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
}

struct TinyInfoView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Smarterfiring")
                        .font(.custom("PressStart2P-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Text("Smarterfiring is a fast-paced action game where you control a tiny character and shoot fire at incoming dragons.")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(.white)
                    
                    Text("Game Rules:")
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Move your character with the arrow buttons")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Tap the fire button to shoot flames")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Only dragons coming from the opposite direction can be hit")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Each hit dragon gives you 10 points")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Game lasts for 2 minutes")
                        }
                    }
                    .font(.custom("PressStart2P-Regular", size: 12))
                    .foregroundColor(.white)
                    
                    Text("Tips:")
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Position yourself in the center for better coverage")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Watch the dragons' directions carefully")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Time your shots to hit multiple dragons")
                        }
                    }
                    .font(.custom("PressStart2P-Regular", size: 12))
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}


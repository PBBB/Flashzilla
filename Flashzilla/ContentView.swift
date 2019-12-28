//
//  ContentView.swift
//  Flashzilla
//
//  Created by Issac Penn on 2019/12/20.
//  Copyright © 2019 Issac Penn. All rights reserved.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var showingEditingScreen = false
    @State private var showingSettingsScreen = false
    @State private var showingAlert = false
    @State private var engine: CHHapticEngine?
    @State private var reuseWrongCards = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Time: \(timeRemaining >= 0 ? timeRemaining : 0)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black)
                        .opacity(0.75)
                )
                
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: self.cards[index]) { isAnswerRight in
                            withAnimation {
                                self.removeCard(at: index, isAnswerRight: isAnswerRight)
                            }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
//                .anima
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.showingSettingsScreen = true
                    }) {
                        Image(systemName: "gear")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    
                    
                    Button(action: {
                        self.showingEditingScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()

                    HStack {
                        
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, isAnswerRight: false)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, isAnswerRight: true)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                        
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .background(EmptyView().sheet(isPresented: $showingEditingScreen, onDismiss: resetCards, content: { EditCards() })
        .background(EmptyView().sheet(isPresented: self.$showingSettingsScreen, onDismiss: resetCards) {
            SettingsView(reuseWrongCards: self.$reuseWrongCards)
        })
        )
        
        .onAppear {
            self.resetCards()
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            do {
                self.engine = try CHHapticEngine()
                try self.engine?.start()
            } catch let error {
                fatalError("Engine Creation Error: \(error)")
            }
        }
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else if self.timeRemaining == 0 {
                self.showingAlert = true
                self.timeRemaining = -1
                guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
                
                let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
                let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.1)
                
                let intensity3 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let sharpness3 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
                let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity3, sharpness3], relativeTime: 0.2)
                
                do {
                    let pattern = try CHHapticPattern(events: [event, event2, event3], parameters: [])
                    let player = try self.engine?.makePlayer(with: pattern)
//                    self.engine?.start(completionHandler: nil)
                    try player?.start(atTime: 0)
//                    self.engine?.stop(completionHandler: nil)
                } catch let error {
                    fatalError("Engine Play Error: \(error)")
                }
                
                
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Time Up!"), message: nil, dismissButton: .default(Text("OK")) {
                self.resetCards()
            })
        }
    }
    
    func removeCard(at index: Int, isAnswerRight: Bool) {
        guard index >= 0 else { return }
        if reuseWrongCards {
            if isAnswerRight {
                cards.remove(at: index)
            } else {
                let wrongCard = cards.remove(at: index)
                cards.insert(wrongCard, at: 0)
            }
           
        } else {
            cards.remove(at: index)
        }
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
            .environment(\.accessibilityEnabled, true)
    }
}

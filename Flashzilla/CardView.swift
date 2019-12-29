//
//  CardView.swift
//  Flashzilla
//
//  Created by Issac Penn on 2019/12/22.
//  Copyright © 2019 Issac Penn. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    let card: Card
    var removal: ((Bool) -> Void)? = nil
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator()
    

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                        .opacity(1 - Double(abs(offset.width / 50)))
            )
            .modifier(CardBackgroundColor(differentiateWithoutColor: differentiateWithoutColor, offset: offset))
                .shadow(radius: 10)
            
            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(DragGesture()
        .onChanged { gesture in
            self.offset = gesture.translation
            self.feedback.prepare()
        }
        .onEnded { _ in
                if abs(self.offset.width) > 100 {
                    if self.offset.width > 0 {
                        self.feedback.notificationOccurred(.success)
                        self.removal?(true)
                        self.offset = .zero
                    } else {
                        self.feedback.notificationOccurred(.error)
                        self.removal?(false)
                        self.offset = .zero
                    }
                } else {
                    self.offset = .zero
                }
            }
        )
            .onTapGesture {
                self.isShowingAnswer.toggle()
        }
        .animation(.spring())
    }
}

struct CardBackgroundColor: ViewModifier {
    let differentiateWithoutColor: Bool
    let offset:CGSize
    
    var backgroundColor: Color {
        if offset.width > 0 {
            return .green
        } else if offset.width == 0 {
            return .white
        } else {
            return .red
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(backgroundColor)
        )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}

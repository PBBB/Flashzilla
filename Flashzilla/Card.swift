//
//  Card.swift
//  Flashzilla
//
//  Created by Issac Penn on 2019/12/22.
//  Copyright © 2019 Issac Penn. All rights reserved.
//

struct Card: Codable {
    let prompt: String
    let answer: String

    static var example: Card {
        return Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
    }
}

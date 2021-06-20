//
//  Model.swift
//  twich_game_bar
//
//  Created by NewUSER on 20.06.2021.
//

import Foundation

struct Response: Decodable {
    var top: [Top]
}


struct Top: Decodable {
    var game: Game
    var viewers: Int
    var channels: Int
}

struct Game:Decodable {
    var _id: Int
    var name: String
}



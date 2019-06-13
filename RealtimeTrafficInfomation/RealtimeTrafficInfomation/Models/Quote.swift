//
//  Quote.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/6.
//  Copyright © 2019 jlai. All rights reserved.
//

import Foundation

struct Quote: Codable {
    let text: String
    let author: String
    let title: String
    let date: String
    let image: String
    let copyright: String
}

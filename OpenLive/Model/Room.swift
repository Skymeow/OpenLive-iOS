//
//  Room.swift
//  OpenLive
//
//  Created by Sky Xu on 2/8/18.
//  Copyright © 2018 Agora. All rights reserved.
//

import Foundation

struct Rooms: Codable {
    let rooms: [Room]
}

struct Room: Codable {
    let name: String
    let id: String
    let owner: String
    let topic: String
    
//    init(json: [String :Any]) {
//        roomId = (json["roomId"] as? String)!
//        roomName = (json["roomName"] as? String)!
//        userName = (json["userName"] as? String)!
//        topic = (json["topic"] as? String)!
//    }
    init(dict: [String: AnyObject]) {
        name = dict["name"] as! String
        id = dict["id"] as! String
        owner = dict["owner"] as! String
        topic = dict["topic"] as! String
    }
    
    func toDict() -> [String: AnyObject] {
        return [
            "name": name as AnyObject,
            "id": id as AnyObject,
            "owner": owner as AnyObject,
            "topic": topic as AnyObject
        ]
    }
}

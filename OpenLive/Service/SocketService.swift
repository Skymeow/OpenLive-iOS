//
//  SocketService.swift
//  OpenLive
//
//  Created by Sky Xu on 2/8/18.
//  Copyright © 2018 Agora. All rights reserved.
//

import Foundation
import SocketIO
import UIKit

class SocketService: NSObject {
    static let instance = SocketService()
    
    override init() {
        super.init()
    }
    
//  ?  connectParams(["token": ""])
    
    let manager = SocketManager(socketURL: URL(string: Config.serverUrl)!, config: [.log(true), .compress])
    
//    only initialize socket when we call this service instance so we can fix manager property not initalized before runtime issue
   lazy var socket: SocketIOClient = manager.defaultSocket
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func addChannel(id: String, name: String, owner: String, topic: String, completion: @escaping (Bool) -> ()) {
        let room = Room(dict: ["name": name as AnyObject,
                               "id": id as AnyObject,
                               "owner": owner as AnyObject,
                               "topic": topic as AnyObject])
        socket.emit("create_room", room.toDict())
    }
    
    // MARK: get data from service once socket connected
    func getChannel(completion: @escaping (Bool) -> ()) {
//        listening for event
            self.socket.emit("get_rooms")
            socket.on("get_rooms") {(data, ack) in
//                self.socket.emit("get_rooms")
//           make sure we get back a list of rooms
//                let json = try JSONSerialization.jsonObject(with: data[0], options: .allowFragments) as! [Any]
//                let result = try? JSONDecoder().decode([Rooms].self, from: data) as! [String: Any]
//                guard let rooms = json.rooms else { return }
//        guard let rooms = data as? Any else {return}
//                print("YOOOOOOOOO \(rooms)")
        completion(true)
        }
    }
    
}

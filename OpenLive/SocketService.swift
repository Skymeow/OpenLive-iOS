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
    
    func addChannel(Id: String, name: String, userName: String, completion: @escaping (Bool) -> ()) {
        socket.emit("create_room", ["name": name, "id": Id, "owner": userName, "topic": "weather"])
    }
    
    // MARK: get data from service once socket connected
//    func getChannel(completion: @escaping (Bool) -> ()) {
    //        socket.on(clientEvent: .connect) { (data, ack) in
////            parseout channel objects
//            
//
//        }
//    }
}

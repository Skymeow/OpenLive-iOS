//
//  WatchViewController.swift
//  Streaming
//
//  Created by Sky Xu on 1/22/18.
//  Copyright © 2018 Sky Xu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class WatchViewController: UIViewController {
//    let urlString: String = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    let urlString: String = "https://271dd7.entrypoint.cloud.wowza.com/app-a804/ngrp:99639922_all/playlist.m3u8"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playVideo(_ sender: Any) {
        guard let url = URL(string: urlString) else {
            return
        }
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: url)
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player
        
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
    }
        
}

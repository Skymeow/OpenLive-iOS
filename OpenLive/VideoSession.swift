//
//  VideoSession.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class VideoSession: NSObject {
    var uid: Int64 = 0
    var hostingView: UIView!
    var canvas: AgoraRtcVideoCanvas!
    
    init(uid: Int64) {
        self.uid = uid
        
        hostingView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //session hosting view set to top left (0,0) w/ a width & height of 100
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        //tells iOS not to create Auto Layout constraints automatically
       
        // Step 12 -> Initialize the AgoraRtcVideoCanvas object
        canvas = AgoraRtcVideoCanvas()
        // Step 12 -> Assign the object's uid that is passed in as a parameter ---> UInt(uid)
         canvas.uid = UInt(uid)
        // Step 12 -> Assign the object's view property to the view above (hostingView)
        canvas.view = hostingView
        // Step 12 -> Assign the object's render mode property to .render_hidden
         canvas.renderMode = .render_Hidden
        
        
        // WHAT IS RENDER MODE HIDDEN?
        // If video size is different than that of the display window,
        // crops the borders of the video (if the video is bigger)
        // or stretch the video (if the video is smaller) to fit it in the window
        
    }
}

extension VideoSession {
    static func localSession() -> VideoSession {
        return VideoSession(uid: 0)
    } // Called if user is broadcaster... assigns unique random ID to broadcaster
}

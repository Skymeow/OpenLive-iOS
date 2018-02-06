//
//  LiveRoomViewController.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

protocol LiveRoomVCDelegate: NSObjectProtocol {
    func liveVCNeedClose(_ liveVC: LiveRoomViewController)
}

class LiveRoomViewController: UIViewController {
    
    @IBOutlet weak var roomNameLabel: UILabel!
    //Label for the room
    
    @IBOutlet weak var remoteContainerView: UIView!
    //Remote container view (1 UIView for all views - layout logic in VideoViewLayout.swift)
    
    @IBOutlet weak var broadcastButton: UIButton!
    //Button to start broadcast
    
    @IBOutlet var sessionButtons: [UIButton]!
    //Array of UIButtons on the bottom left hand side
    
    @IBOutlet weak var audioMuteButton: UIButton!
    //Button to mute the broadcast
        
    var roomName: String!
    //String to get room name from previous VC
    
    var clientRole = AgoraRtcClientRole.clientRole_Audience {
        didSet {
            updateButtonsVisiablity()
        }
    } // Sets the member's role to Audience Member (updates the button images - see updateButtonsVisibility() below)
    
    var videoProfile: AgoraRtcVideoProfile!
    //video Profile to set Quality/FrameR (retrieved from previous VC)
    
    weak var delegate: LiveRoomVCDelegate?
    
    //Step 2 -> Create the AgoraRtcEngineKit object
    
    fileprivate var isBroadcaster: Bool {
        return clientRole == .clientRole_Broadcaster
    } //boolean variable to see if the member is broadcaster role
    
    fileprivate var isMuted = false {
        didSet {
            //Step 12 -> mute local audio based on the value of isMuted
            audioMuteButton?.setImage(UIImage(named: isMuted ? "btn_mute_cancel" : "btn_mute"), for: .normal)
        }
    }
    //variable to see if the user is muted or not
    //if member IS Muted, show the unmute img. If the member is NOT muted, show the mute img.
    //UIControlState controls the state of the button (normal, selected)

    
    fileprivate var videoSessions = [VideoSession]() {
        didSet {
            guard remoteContainerView != nil else {
                return
            }
            updateInterface(withAnimation: true)
        }
    }
    // VideoSessions is a helper class to manage the # of broadcasters in the channel
    // Updates the interface based on # of broadcasters (see updateInterface() below)
    
    fileprivate var fullScreenSession: VideoSession? {
        didSet {
            if fullScreenSession != oldValue && remoteContainerView != nil {
                updateInterface(withAnimation: true)
            }
        }
    }
    
    fileprivate let viewLayouter = VideoViewLayouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomNameLabel.text = roomName
        updateButtonsVisiablity()
        loadAgoraKit()
    }
    
    //MARK: - user action
    @IBAction func doSwitchCameraPressed(_ sender: UIButton) {
        //Step 13 -> switch camera on button click
    }
    
    @IBAction func doMutePressed(_ sender: UIButton) {
        isMuted = !isMuted
    }
    
    @IBAction func doBroadcastPressed(_ sender: UIButton) {
        if isBroadcaster {
            //Step 13 => If the member is a broadcaster, changes the clientRole to Audience (.clientRole_Audience)
            if fullScreenSession?.uid == 0 {
                fullScreenSession = nil
            }
        } else {
            //Step 13 => If the member is a broadcaster, changes the clientRole to Broadcaster (.clientRole_Broadcaster)
        }
        
        //Step 13 => Set client Role here based on the updated clientRole value
        updateInterface(withAnimation :true)
    }
    
    @IBAction func doDoubleTapped(_ sender: UITapGestureRecognizer) {
        if fullScreenSession == nil {
            if let tappedSession = viewLayouter.responseSession(of: sender, inSessions: videoSessions, inContainerView: remoteContainerView) {
                fullScreenSession = tappedSession
            }
        } else {
            fullScreenSession = nil
        }
    } //Gesture Recognizer for Double Tap, Full session
    
    @IBAction func doLeavePressed(_ sender: UIButton) {
        leaveChannel()
    } //Leave channel when X is clicked
}


//MARK: - Agora Media SDK
private extension LiveRoomViewController {
    
    func loadAgoraKit() {
        // Step 2 -> Initialize ‘AgoraRtcEngineKit’ object
        // Step 3 -> Set Channel Profile
        // Step 4 -> Enable Video
        // Step 5 -> Set video profile (using videoProfile variable from previous VC)
        // Step 6 -> Set client role (using clientRole variable)
        // Step 7 -> Enable dual stream mode
    
        addLocalSession()
        
        let sucessCode = 1
        // Step 9 -> Join channel passing in the generated Dynamic Token (or App ID for demo purposes) & roomName variable
        // Update successCode to equal the returned Integer result of the joinChannel call.
        
         if sucessCode == 0 {
            setIdleTimerActive(false)
            //Step 10 -> Enable Speakerphone by passing in true value for setEnableSpeakerphone()
         } else {
            DispatchQueue.main.async(execute: {
                self.alert(string: "Join channel failed: \(sucessCode)")
            })
         }
        
    }
    func leaveChannel() {
        setIdleTimerActive(true)
        
        //Step 11 -> Unbind the local video view
        //Step 11 -> Leave the channel
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        } //remove each session from superview (UIView container)
        
        videoSessions.removeAll()
        //Removes all video sessions from the array of VideoSessions
        
        delegate?.liveVCNeedClose(self)
    }
    
}

private extension LiveRoomViewController {
   
    func updateButtonsVisiablity() {
        guard let sessionButtons = sessionButtons else {
            return
        } //sessionButtons = array of UIButtons (bottom left)
        
        broadcastButton?.setImage(UIImage(named: isBroadcaster ? "btn_join_cancel" : "btn_join"), for: UIControlState())
        //if member IS broadcaster, show the cancel button. If the member is NOT broadcaster, show the join button.
        //UIControlState controls the state of the button (normal, selected)
        
        for button in sessionButtons {
            button.isHidden = !isBroadcaster
        } //if member IS NOT broadcaster, the buttons are NOT hidden
    }
    
    
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
    
    func alert(string: String) {
        guard !string.isEmpty else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

private extension LiveRoomViewController {
    func updateInterface(withAnimation animation: Bool) {
        if animation {
            UIView.animate(withDuration: 0.3, animations: { [weak self] _ in
                self?.updateInterface()
                self?.view.layoutIfNeeded()
            })
        } else {
            updateInterface()
        }
    }
    // function with UIAnimations
    
    func updateInterface() {
        var displaySessions = videoSessions //# of video sessions (broadcasters) = # of display sessions for the view
       
        if !isBroadcaster && !displaySessions.isEmpty {
            displaySessions.removeFirst()
        }
        
        viewLayouter.layout(sessions: displaySessions, fullScreenSession: fullScreenSession, inContainer: remoteContainerView)
        setStreamType(forSessions: displaySessions, fullScreenSession: fullScreenSession)
    }
    
    func setStreamType(forSessions sessions: [VideoSession], fullScreenSession: VideoSession?) {
        if let fullScreenSession = fullScreenSession {
            for session in sessions {
                //This method allows the application to adjust the corresponding video stream type according to the size of the video windows to save bandwidth and calculation resources.
                //.videoStream_High -> high resolution, high frame rated (based on videoProfile)
                //.videoStream_Low -> low resolution, low frame rate
                //Step 8 => If the videoSession is a fullscreenSession, choose to recieve high stream, the others to recieve the low stream
            }
        } else {
            for session in sessions {
                //Step 8 => Since none of the sessions are a fullscreenSession, choose to recieve high stream for all videoSessions
                //.videoStream_High -> high resolution, high frame rate (based on videoProfile)
            }
        }
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        videoSessions.append(localSession)
        //Step 11 => Set up the local video by grabbing the local videoSession's canvas value
    }
    
    func fetchSession(ofUid uid: Int64) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(ofUid uid: Int64) -> VideoSession {
        if let fetchedSession = fetchSession(ofUid: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
}

extension LiveRoomViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let userSession = videoSession(ofUid: Int64(uid))
        //Step 11 -> Take the canvas of the videoSession and use it to set up the remote video
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let _ = videoSessions.first {
            updateInterface(withAnimation: false)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraRtcUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() {
            if session.uid == Int64(uid) {
                indexToDelete = index
            }
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            
            if deletedSession == fullScreenSession {
                fullScreenSession = nil
            }
        }
    }
}

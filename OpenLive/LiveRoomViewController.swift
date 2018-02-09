//
//  LiveRoomViewController.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
//import Alamofire
import SocketIO

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
   
    // MARK: this is Channel ID , has to be unique
    var roomId: String?
    
    var roomName: String!
    
    var clientRole = AgoraRtcClientRole.clientRole_Audience {
        didSet {
            updateButtonsVisiablity()
        }
    } // Sets the member's role to Audience Member (updates the button images - see updateButtonsVisibility() below)
    
    var videoProfile: AgoraRtcVideoProfile!
    //video Profile to set Quality/FrameR (retrieved from previous VC)
    
    weak var delegate: LiveRoomVCDelegate?
    
    // MARK: ! S2 Create the AgoraRtcEngineKit object
    var rtcEngine : AgoraRtcEngineKit!
    
    fileprivate var isBroadcaster: Bool {
        return clientRole == .clientRole_Broadcaster
    } //boolean variable to see if the member is broadcaster role
    
    fileprivate var isMuted = false {
        didSet {
            //Step 13 -> mute local audio based on the value of isMuted
            rtcEngine?.muteLocalAudioStream(isMuted)
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
        rtcEngine?.switchCamera()
    }
    
    @IBAction func doMutePressed(_ sender: UIButton) {
        isMuted = !isMuted
    }
    
//    switch client role
    @IBAction func doBroadcastPressed(_ sender: UIButton) {
        if isBroadcaster {
            clientRole = .clientRole_Audience
            if fullScreenSession?.uid == 0 {
                fullScreenSession = nil
            }
        } else {
            clientRole = .clientRole_Broadcaster
        }
        // Set client Role here based on the updated clientRole value
        rtcEngine.setClientRole(clientRole, withKey: nil)
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
    
    // MARK: connect to  engine and channel room
    func loadAgoraKit() {
        
        //   MARK: S2 initialize the class of engine to be a singleton instance
        rtcEngine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        // Step 3 -> Set Channel Profile
        rtcEngine.setChannelProfile(.channelProfile_LiveBroadcasting)
        // Step 7 -> Enable dual stream mode
        rtcEngine.enableDualStreamMode(true)
        // Step 4 -> Enable Video
        rtcEngine.enableVideo()
        // Step 5 -> Set video profile (using videoProfile variable from previous VC)
        rtcEngine.setVideoProfile(videoProfile, swapWidthAndHeight: true)
        rtcEngine.setVideoQualityParameters(false)
        
        // Step 6 -> Set client role (using clientRole variable)
        rtcEngine.setClientRole(clientRole, withKey: nil)
        
        //  MARK: IMPORTANT TO UPDATE FRAME
//        return 0 when this method is called successfully, or negative value when this method failed
        if isBroadcaster {
            rtcEngine.startPreview()
        }
        
        addLocalSession()
        
        // MARK:( Join channel ) and create unique roomId
        roomId = UUID().uuidString
        let successCode = rtcEngine.joinChannel(byKey: KeyCenter.AppId, channelName: roomId!, info: nil, uid: 0, joinSuccess: nil)
        
        // MARK: Success code: 0 when executed successfully, and return negative value when failed.
        if successCode == 0 {
            setIdleTimerActive(false)
            //Step 10 -> Enable Speakerphone by passing in true value for setEnableSpeakerphone()
            rtcEngine.setEnableSpeakerphone(true)
            
            //   MARK: sent room id and infos to socket
            SocketService.instance.addChannel(Id: roomId!, name: roomName, userName: "sky", completion: { (success) in
                print("success emit data")
                self.dismiss(animated: true, completion: nil)
            })
           
         } else {
            DispatchQueue.main.async(execute: {
                self.alert(string: "Join channel failed: \(successCode)")
            })
         }
    }
    
    
    
    // MARK:   leave channel
    func leaveChannel() {
        setIdleTimerActive(true)
        
        //Step 11 -> Unbind the local video view
        //Step 11 -> Leave the channel
        rtcEngine.setupLocalVideo(nil)
        rtcEngine.leaveChannel(nil)
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        } //remove each session from superview (UIView container)

        //Removes all video sessions from the array of VideoSessions
        videoSessions.removeAll()
        
        delegate?.liveVCNeedClose(self)
    }
    
}

// MARK: private EXtension of update UI due to different member detection
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

// MARK:  extension of liveRoomVC's UI
private extension LiveRoomViewController {
    func updateInterface(withAnimation animation: Bool) {
        if animation {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
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
        if fullScreenSession != nil {
            for session in sessions {
                //MARK: Step 8 => If the videoSession is a fullscreenSession, choose to recieve high stream, the others to recieve the low stream
            rtcEngine.setRemoteVideoStream(UInt(session.uid), type: (session == fullScreenSession ? .videoStream_High : .videoStream_Low))
                
            }
        } else {
            for session in sessions {
                //.videoStream_High -> high resolution, high frame rate (based on videoProfile)
                rtcEngine.setRemoteVideoStream(UInt(session.uid), type: .videoStream_High)
            }
        }
    }
    
    // MARK: Set up the local video canvas
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        videoSessions.append(localSession)
        rtcEngine.setupLocalVideo(localSession.canvas)
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

//MARK: Engine Delegate

extension LiveRoomViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let userSession = videoSession(ofUid: Int64(uid))
        //  MARK:  Set remote video view in rtcEngine callback
        rtcEngine.setupRemoteVideo(userSession.canvas)
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

# Step 2) Create & Initialize 'AgoraRtcEngineKit' object
### Create the 'AgoraRtcEngineKit' object and initialize it class as a singleton instance [Line 135]
```swift
import AgoraRtcEngineKit
var rtcEngine : AgoraRtcEngineKit!
func loadAgoraKit() {
rtcEngine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppID, delegate: self)
}
```
# Step 3) Set Channel Profile
### Set the Channel Profile to Live Broadcast [Line 136]
```swift
rtcEngine.setChannelProfile(.channelProfile_LiveBroadcasting)
```
# Step 4) Enable Video Mode
### Enables video data to be sent to stream, without this -> Audio Only [Line 137]
```swift
rtcEngine.enableVideo()
```

# Step 5) Set video profile
### Sets the video encoding (FPS / Resolution) [Line 138]
```swift
engine.setVideoProfile(videoProfile, swapWidthAndHeight:true)
```

# Step 6) Set user role
### Tells RtcEngine which role the member is: Audience or Broadcaster [Line 139]
```
rtcEngine.setClientRole(clientRole, withKey: nil)
```

# Step 7) Enable dual stream mode
### Allows the ability to have two different types of stream modes (high and low) [Line 140]
```
rtcEngine.enableDualStreamMode(true)
```

# Step 8) Set Remote Video Stream
### Adjust stream type based on size of UI windows to save bandwidth & calculation resources (in setStreamType()) [Line 236]
```swift
rtcEngine.setRemoteVideoStream(UInt(session.uid),type:(session == fullScreenSession ?  .videoStream_High : .videoStream_Low))

rtcEngine.setRemoteVideoStream(UInt(session.uid),type: .videoStream_High)
```

# Step 9) Join Channel
### Join the channel with App ID as Key (unsecure alternative instead of Dynamic Key - demo purposes only) [Line 145]
```swift
let successCode = rtcEngine.joinChannel(byKey: KeyCenter.AppID, channelName: roomName, info: nil, uid: 0, joinSucess: nil)
```

# Step 10) Enable Speakerphone
### Allows the remote audio to be played through the speakerphone [Line 150]
```swift
rtcEngine.enableSpeakerphone(true)
```

# Step 11) Leave Channel
### Stop the local preview, unbind the view, and leave the channel ( in leaveChannel( ) ) [Line 161]
```swift
rtcEngine.setupLocalVideo(nil)
rtcEngine.leaveChannel(nil)
```

# Step 12) Set the local/remote video view
### VideoSession is an object that contains the information regarding an individual video session [VideoSession,swift, Line 26]
```swift
var canvas: AgoraRtcVideoCanvas!

canvas = AgoraRtcVideoCanvas()
canvas.uid = Uint(uid)
canvas.renderMode = .render_Hidden
canvas.view = hostingView
```

### Set remote video view in rtcEngine callback (didJoinedOfUid) [Line 278]
```swift
rtcEngine.setupRemoteVideo(userSession.canvas)
```

### Set local video view in addLocalSession() [Line 252]
```swift
rtcEngine.setupLocalVideo(localSession.canvas)
```

# Step 13) Setup additional features
### Switch camera (toggle front/back) [Line 94]
```swift
@IBAction func doSwitchCameraPressed (_sender:UIButton) {
rtcEngine?.switchCamera()
}
```

### Mute Local Audio Stream (don't send audio stream) [Line 55]
```swift
fileprivate var isMuted = false {
didSet {
rtcEngine?.muteLocalAudioStream(isMuted)
}
}
```

### Join broadcast (audience member joins as Guest broadcaster) [Line 103]
```swift
@IBAction func doBroadcastPressed(_sender:UIButton) {
if isBroadcaster{
clientRole = .clientRole_Audience
} else {
clientRole = .clientRole_Broadcaster
}
rtcEngine.setClientRole(clientRole, withKey: nil)
}
```


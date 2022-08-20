# RDPHotkeyHelper
RDPHotkeyHelper is an AutoHotkey script which redirects media keys to the local machine while working within a remote desktop session. It works with Microsoft's standard remote desktop connection and the Microsoft store app.
Using media keys on the remote host is still possible by simply holding down ctrl or alt when pressing the media key.  

### Important notes
- Window detection is language dependent in order to also support the store app. If your client is not detected, replace [` - Remote Desktop`](https://github.com/neon-dev/RDPHotkeyHelper/blob/main/RDPHotkeyHelper.ahk#L14) with your localized window title suffix.
- Since this is what I use personally, there are some features included which some might want to disable:  
The volume mute key will mute the default microphone instead of the output device. This can be changed by replacing `Volume_Mute::ToggleMicrophoneMute()` with `Volume_Mute::PassToLocalMachine()`.  
Also the menu key which usually opens the context menu is remapped to open the calculator instead. This can be disabled by deleting the line with `AppsKey::OpenCalculator()`.

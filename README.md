# RDPHotkeyHelper
RDPHotkeyHelper is an AutoHotkey script which redirects media keys to the local machine while working within a remote desktop session. It works with Microsoft's standard remote desktop connection and the Microsoft store app.
Using media keys on the remote host is still possible by simply holding down ctrl or alt when pressing the media key.  

### Note
Window detection is language dependent in order to also support the store app. If your client is not detected, replace [` - Remote Desktop`](https://github.com/neon-dev/RDPHotkeyHelper/blob/main/RDPHotkeyHelper.ahk#L13) with your localized window title suffix.
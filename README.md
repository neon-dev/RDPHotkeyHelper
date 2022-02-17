# RDPHotkeyHelper
RDPHotkeyHelper is an AutoHotkey script which redirects media keys to the local machine while working within a remote desktop session. It works with Microsoft's standard remote desktop connection and the Microsoft store app.
Using media keys on the remote host is still possible by simply holding down ctrl or alt when pressing the media key.  
**Note**: The volume mute key will mute the default microphone instead of the output device. This can be changed by replacing `Volume_Mute::ToggleMicrophoneMute()` with `Volume_Mute::PassToLocalMachine()`.  
Also the menu key which usually opens the context menu is remapped to open the calculator instead. This can be disabled by deleting the line with `AppsKey::OpenCalculator()`.

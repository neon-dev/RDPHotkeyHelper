;@Ahk2Exe-SetMainIcon rhh.ico
;@Ahk2Exe-Set FileVersion, 1.2.0.0
;@Ahk2Exe-Set ProductVersion, 1.2.0.0
;@Ahk2Exe-PostExec "MPRESS.exe" "%A_WorkFileName%" -q -x, 0,, 1, 1

#SingleInstance Force
KeyHistory(0)
If (!A_IsCompiled && FileExist("rhh.ico")) {
  TraySetIcon("rhh.ico")
}
A_IconTip := "RDP Hotkey Helper"
Tray:= A_TrayMenu
Tray.Delete()
Tray.Add("Exit", Exit)
ExeNamesPattern := "i)\\(mstsc|msrdc|ApplicationFrameHost|VMConnect)\.exe$"
SetTitleMatchMode("RegEx")
While true {
  global RdpHwnd := 0
  WinWaitActive("ahk_exe " ExeNamesPattern)
  RdpHwnd := WinExist("A")
  Suspend(true) ; rebind all hotkeys, otherwise they won't work in RDP fullscreen mode
  Suspend(false)
  Sleep(250)
  WinWaitNotActive("ahk_id " RdpHwnd)
}

#UseHook
Volume_Mute::PassToLocalMachine()
Volume_Down::PassToLocalMachine()
Volume_Up::PassToLocalMachine()
Media_Next::PassToLocalMachine()
Media_Prev::PassToLocalMachine()
Media_Stop::PassToLocalMachine()
Media_Play_Pause::PassToLocalMachine()

PassToLocalMachine() {
  If (RdpHwnd == 0 || WinExist("A") != RdpHwnd) {
    Send("{" A_ThisHotKey "}")
    Return
  }
  WM_APPCOMMAND := 0x0319
  If (A_ThisHotKey = "Volume_Mute")
    PostMessage(WM_APPCOMMAND, 0, 8<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_VOLUME_MUTE
  Else If (A_ThisHotKey = "Volume_Down")
    PostMessage(WM_APPCOMMAND, 0, 9<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_VOLUME_DOWN
  Else If (A_ThisHotKey = "Volume_Up")
    PostMessage(WM_APPCOMMAND, 0, 10<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_VOLUME_UP
  Else If (A_ThisHotKey = "Media_Next")
    PostMessage(WM_APPCOMMAND, 0, 11<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_MEDIA_NEXTTRACK
  Else If (A_ThisHotKey = "Media_Prev")
    PostMessage(WM_APPCOMMAND, 0, 12<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_MEDIA_PREVIOUSTRACK
  Else If (A_ThisHotKey = "Media_Stop")
    PostMessage(WM_APPCOMMAND, 0, 13<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_MEDIA_STOP
  Else If (A_ThisHotKey = "Media_Play_Pause")
    PostMessage(WM_APPCOMMAND, 0, 14<<16, , "ahk_class Shell_TrayWnd") ; APPCOMMAND_MEDIA_PLAY_PAUSE
}

Exit(*) {
  ExitApp()
}

;@Ahk2Exe-SetMainIcon rhh.ico
;@Ahk2Exe-AddResource rhh_mic_muted.ico, 160
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set ProductVersion, 1.0.0.0

#SingleInstance Force
#NoEnv
#KeyHistory 0
UpdateTrayIcon(GetMicDeviceId())
Menu, Tray, Tip, RDP Hotkey Helper
Menu, Tray, NoStandard
Menu, Tray, Add, Exit

global RdpWindowTitle := % (SubStr(A_Language, -1) = "07" ? " - Remotedesktop" : " - Remote Desktop") ; matches both classic RDP client and the app from the Microsoft store
SetTitleMatchMode, 2
DetectHiddenWindows, On
While true {
  WinWaitActive, %RdpWindowTitle%
  Suspend, On ; rebind all hotkeys, otherwise they won't work in RDP fullscreen mode
  Suspend, Off
  Sleep, 250
  SetNumLockState, On ; the remote desktop client disables num lock upon first connection for some reason
  WinWaitNotActive, %RdpWindowTitle%
}

#UseHook
Volume_Mute::ToggleMicrophoneMute()
Volume_Down::PassToLocalMachine()
Volume_Up::PassToLocalMachine()
Media_Next::PassToLocalMachine()
Media_Prev::PassToLocalMachine()
Media_Stop::PassToLocalMachine()
Media_Play_Pause::PassToLocalMachine()
AppsKey::OpenCalculator() ;Launch_App2
!^Down:: send {RAlt down}{XButton2}{RAlt up} ; Ctrl + Alt + Down

PassToLocalMachine() {
  WinGetText, ActiveWindowTitle, A
  If Not InStr(ActiveWindowTitle, RdpWindowTitle) {
    Send {%A_ThisHotKey%}
    Return
  }
  WM_APPCOMMAND := 0x0319
  If (A_ThisHotKey = "Media_Play_Pause")
    PostMessage, WM_APPCOMMAND, 0, 14<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_MEDIA_PLAY_PAUSE
  Else If (A_ThisHotKey = "Media_Stop")
    PostMessage, WM_APPCOMMAND, 0, 13<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_MEDIA_STOP
  Else If (A_ThisHotKey = "Media_Prev")
    PostMessage, WM_APPCOMMAND, 0, 12<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_MEDIA_PREVIOUSTRACK
  Else If (A_ThisHotKey = "Media_Next")
    PostMessage, WM_APPCOMMAND, 0, 11<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_MEDIA_NEXTTRACK
  Else If (A_ThisHotKey = "Volume_Up")
    PostMessage, WM_APPCOMMAND, 0, 10<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_VOLUME_UP
  Else If (A_ThisHotKey = "Volume_Down")
    PostMessage, WM_APPCOMMAND, 0, 9<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_VOLUME_DOWN
  Else If (A_ThisHotKey = "Volume_Mute")
    PostMessage, WM_APPCOMMAND, 0, 8<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_VOLUME_MUTE
}

ToggleMicrophoneMute() {
  WM_APPCOMMAND := 0x0319
  SendMessage, WM_APPCOMMAND, 0, 24<<16,, ahk_class Shell_TrayWnd ; APPCOMMAND_MICROPHONE_VOLUME_MUTE

  MicDeviceId := GetMicDeviceId()
  If (MicDeviceId > 0) {
    UpdateTrayIcon(MicDeviceId)
    SoundGet, microphone_mute, , mute, MicDeviceId
	HideTrayTip()
	SetTimer, HideTrayTip, -2500
	Sleep, 50
	TrayTip, , % (microphone_mute = "Off" ? "🎤 unmuted" : "🎤 muted"), , 0x10
  }
}

HideTrayTip() {
  TrayTip
}

UpdateTrayIcon(MicDeviceId) {
  SoundGet, microphone_mute, , mute, MicDeviceId
  If Not (A_IsCompiled) {
    try {
	  Menu, Tray, Icon, % microphone_mute = "Off" ? "rhh.ico" : "rhh_mic_muted.ico"
	}
  } Else {
    If (microphone_mute = "Off")
      Menu, Tray, Icon, *
	Else
	  Menu, Tray, Icon, %A_ScriptFullPath%, -160
  }
}

; Source: https://github.com/C-Peck/Mic-Manager/blob/master/MicManager.ahk
GetMicDeviceId() {
  mixerId := 0
  enum := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
  if VA_IMMDeviceEnumerator_EnumAudioEndpoints(enum, 2, 9, devices) >= 0 {
    VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(enum, 1, 0, device) ;1 for capture devices, 0 for playback devices
    VA_IMMDevice_GetId(device, default_id)
    ObjRelease(device)
    VA_IMMDeviceCollection_GetCount(devices, count)
    Loop % count
    {
      if VA_IMMDeviceCollection_Item(devices, A_Index-1, device) < 0
        continue
      VA_IMMDevice_GetId(device, id)
	  ObjRelease(device)
      
      if (id == default_id) {
        mixerId := A_Index
		break
      }
    }
	ObjRelease(devices)
  }
  ObjRelease(enum)
  return mixerId
}

VA_IMMDeviceEnumerator_EnumAudioEndpoints(this, DataFlow, StateMask, ByRef Devices) {
  return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "int", DataFlow, "uint", StateMask, "ptr*", Devices)
}

VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(this, DataFlow, Role, ByRef Endpoint) {
  return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "int", DataFlow, "int", Role, "ptr*", Endpoint)
}

VA_IMMDevice_GetId(this, ByRef Id) {
  hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "uint*", Id)
  Id := StrGet(ptr := Id, "UTF-16")
  DllCall("ole32\CoTaskMemFree", "ptr", ptr)
  return hr
}

VA_IMMDeviceCollection_GetCount(this, ByRef Count) {
  return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "uint*", Count)
}

VA_IMMDeviceCollection_Item(this, Index, ByRef Device) {
  return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", Index, "ptr*", Device)
}

OpenCalculator() {
  WS_CAPTION := 0xC00000
  WinGet, RdpWindowStyle, Style, %RdpWindowTitle%
  If RdpWindowStyle & WS_CAPTION = 0 ; check if RDP client is in fullscreen mode (no title bar)
    Send {Launch_App2}
  Else
    Run calc.exe ; Send {Launch_App2} doesn't work locally for some reason
}

Exit:
ExitApp

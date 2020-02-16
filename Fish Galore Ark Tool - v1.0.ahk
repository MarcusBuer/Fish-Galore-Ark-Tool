;; =============================================================================
;; 	Author: Bruno Nascimento
;; 	GitHub: https://github.com/Mechanically
;; 	Game: 	Ark: Survival Evolved
;; 	Description: 	
;;	This tool automates the fishing aspect of the game by analysing the screen
;;  to identify which key is being required by the game and simulate the keypress.
;;  Automatically modifies the Gamma value of the game engine to increase the 
;;  contrast (making identification easier), cycles between rods to increase 
;;  the time which the tool can run autonomously, and when a fish is captured 
;;  it saves a screenshot so the user can check the catches.
;;
;;
;; 														Credits to: 
;;
;;	 	* Spencer J Potts
;; 		Contribution: 
;;	 	  Methodology for detecting letters and Catch message
;; 		  Points for the resolution 1920x1080
;; 		GitHub: https://github.com/SpencerJPotts
;;
;;		* Linear Spoon
;;		Contribution:
;;			CaptureScreen() Script, used to save screenshots
;; 		GitHub: https://github.com/LinearSpoon/
;;
;; =============================================================================
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;													Enviroment Settings
#NoEnv
Process, Priority, , High
#SingleInstance, Force
#MaxThreadsPerHotkey 4
SendMode Input
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;														 	 Includes
#Include, CaptureScreen().ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;													 		Admin Check
If not A_IsAdmin {
  DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """", str, A_WorkingDir, int, 1)
  ExitApp
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;												  	Global Variables
global isFishing      := False
global fishingGamma       := 1
global regularGamma     := 2.2
global isSwitchingRods :=False
global firstRod           := 1
global currentRod         := 1 
global maxRod             := 1
global LetterColor := 0xFFFFFF
global KeystrokeDelay   := 250
global wX, global wY,		global qX, global qY,		global zX, global zY
global xX, global xY,		global aX, global aY,		global dX, global dY
global eX, global eY,		global sX, global sY,		global cX, global cY
global ScreenX:=0,  ScreenY:=0
global Guiln1, global Guiln2, global Guiln3, global Guiln4, Global LastKeypress
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 											Instantiate Visual Elements
UpdateGUI()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 										Position Config - Resolution Based
setResolution() {
	ScreenX := A_ScreenWidth, ScreenY := A_ScreenHeight
	if (ScreenX= 1920) && (ScreenY= 1080) {
    Guiln3:= "Resolution detected: [" ScreenX "x" ScreenY "]`n"
		wX := 1113, wY := 868,		qX := 1181, qY := 1016,		zX := 1158, zY := 973
		xX := 1167, xY := 972,		aX := 1162, aY := 970 ,		dX := 1192, dY := 906
		eX := 1186, eY := 998,		sX := 1161, sY := 917 ,		cX := 1135, cY := 918
	} else if (ScreenX= 1366) && (ScreenY= 768) {
    Guiln3:= "Resolution detected: [" ScreenX "x" ScreenY "]`n"
		wX := 788 , wY := 616,		qX := 840 , qY := 722,		zX := 824 , zY := 692
		xX := 830 , xY := 692,		aX := 827 , aY := 688,		dX := 847 , dY := 647
		eX := 841 , eY := 655,		sX := 826 , sY := 652,		cX := 808 , cY := 653
	} else if (ScreenX= 1680) && (ScreenY= 1050) {
    Guiln3:= "Resolution detected: [" ScreenX "x" ScreenY "]`n"
		wX := 1323 , wY := 834,		qX := 1302 , qY := 916,		zX := 1215 , zY := 899
		xX := 1291 , xY := 823,		aX := 1254 , aY := 839,		dX := 1292 , dY := 852
		eX := 1275 , eY := 858,		sX := 1219 , sY := 885,		cX := 1220 , cY := 865
	} else if (ScreenX/ScreenY = 16/9) { 
		;; If the resolution is not supported, but it's 16:9 ratio, try to interpolate new key positions
		Guiln3:= "Resolution not supported - trying to interpolate to [" ScreenX "x" ScreenY "]`n"
		wX := 788*(1366/ScreenX) , wY := 616*(768/ScreenY)
		qX := 840*(1366/ScreenX) , qY := 722*(768/ScreenY)
		zX := 824*(1366/ScreenX) , zY := 692*(768/ScreenY)
		xX := 830*(1366/ScreenX) , xY := 692*(768/ScreenY)
		aX := 827*(1366/ScreenX) , aY := 688*(768/ScreenY)
		dX := 847*(1366/ScreenX) , dY := 647*(768/ScreenY)
		eX := 841*(1366/ScreenX) , eY := 655*(768/ScreenY)
		sX := 826*(1366/ScreenX) , sY := 652*(768/ScreenY)
		cX := 808*(1366/ScreenX) , cY := 653*(768/ScreenY)
	} else {
    Guiln3:= "Resolution [" ScreenX "x" ScreenY "] is not supported yet.`nPlease take screenshots of every letter (A,C,D,E,Q,S,W,X,Z)`nand send using an issue on GitHub.`n"
    isFishing:=False
    isSwitchingRods:=False
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 																Hotkeys
f3::
  if !isSwitchingRods && isFishing {
    isSwitchingRods:=True
    SoundBeep, 750, 200
  } else {
    isSwitchingRods:=False
    SoundBeep, 440, 200 
  }
  UpdateGUI()
  return

f4::
  if (firstRod<maxRod) {
    firstRod++
  }
  else {
    firstRod:=1
  }
  UpdateGUI()
  return

f5::
  SwitchRods()
  UpdateGUI()
  return

f6::
  if ((maxRod>=firstRod) and (maxRod<9)) {
    maxRod++
  } else {
    maxRod:=firstRod
  }
  UpdateGUI()
  return

f2:: 
	;; Toggles between Enabling/Disabling the Macro
  ;; Should be the last hotkey since it has no return when enabled, and leads to the loop
  if !isFishing {
    setResolution()
    isFishing := True
    isSwitchingRods := False
    SoundBeep, 750, 200
    AdjustGamma(fishingGamma)
  } else {
    isFishing := False
    isSwitchingRods := False
    SoundBeep, 440, 200
    UpdateGUI()
    AdjustGamma(regularGamma)
    return
  }
  UpdateGUI()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																 Methods
UpdateGUI() {
  if isSwitchingRods && isFishing {
    Guiln2:= "Switch Rods: Enabled [F3]`n   Initial Rod:     " firstRod " [F4]`n   Current Rod: " currentRod " [F5]`n   Last Rod:       " maxRod " [F6]`n"
  } else {
    if isFishing {
			Guiln2:= "Switch Rods: Disabled [F3]`n"
    } 
  }
	if (LastKeypress=="") {
    Guiln4:= ""
  } else {
		Guiln4:= "Last Letter: "%LastKeypress% ;; Clear Last Keypress
  }
  if isFishing {
    Guiln1:= "`nFishing Enabled  [F2]`n"
		 Menu, Tray, Icon, %A_WorkingDir%\Fishing.ico
  } else {
    Guiln1:= "`nFishing Disabled [F2]`n"
		Guiln2:= "" ;; Clear Rod Switching Tooltip
		Guiln3:= "" ;; Clear Resolution Message
 		Guiln4:= "" ;; Clear Last Keypress
		 Menu, Tray, Icon, %A_WorkingDir%\notFishing.ico
  }
	ToolTip, %Guiln1% %Guiln2% %Guiln3% %Guiln4% , 0, 0, 1
}

AdjustGamma(gamma) {
  Send {Tab}
  Sleep 50
  Send gamma %gamma%
  Sleep 50
  Send {Enter}
  Sleep 50
}

TakeScreenshot() {
	FormatTime, date,, dd.MM.yyyy-HH.mm.ss
	IfNotExist, Catches
		FileCreateDir, Catches
	CaptureScreen(1, False, A_scriptDir "/Catches/" date ".png", 80)
}

SendTimed(keystroke) {
	LastKeypress:=keystroke
	Send, %keystroke%
	Sleep, KeystrokeDelay
}

LookForLetter(posX,posY) {
	PixelSearch retX, retY, posX, posY, posX, posY, LetterColor, 3, Fast
	if (ErrorLevel = 0)
		return True
	else
		return False
}

SwitchRods() {
  if isSwitchingRods {
  currentRod++
  if (currentRod > maxRod) {
    currentRod := firstRod
  }
  Send, %currentRod%
  }
  UpdateGUI()
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 																	Main Loop
while isFishing {
	;;Auto Recast Rod
	PixelSearch, retX, retY, ScreenX/4, 0, ScreenX/4 + ScreenX/2, ScreenY/4, 0x7FFD03, 3, Fast ;; Look for a green writting on the top of the screen
  if (ErrorLevel = 0)	{
		Tooltip, , , , 2 ;; Clear Last Keymatch
		Sleep, 2000
		TakeScreenshot()
    SwitchRods()
   	Sleep, 3000
   	MouseClick, left
  }
	
	if LookForLetter(aX,aY) { ;; Search for "A"
	  SendTimed("a") 
	}	else if LookForLetter(zX,zY) {	;; Seach for "Z"
		SendTimed("z")
	} else if LookForLetter(qX,qY) {	;;Search for "Q"
		SendTimed("q")
	} else if LookForLetter(wX,wY) {  ;;Search for "W"
		SendTimed("w")
	} else if LookForLetter(xX,xY) {  ;;Search for "X"
		SendTimed("x")
	} else if LookForLetter(dX,dY) {  ;;Search for "D"
		SendTimed("d")
	} else if LookForLetter(eX, eY) { ;;Search for "E"
		if !LookForLetter(aX, aY) { ;; not A
		if !LookForLetter(zX, zY) { ;; not Z
		if !LookForLetter(wX, wY) { ;; not W
		if !LookForLetter(xX, xY) { ;; not X
		if !LookForLetter(dX, dY) { ;; not D
		if !LookForLetter(qX, qY) { ;; not Q
		SendTimed("e")
		}}}}}}
	} else if LookForLetter(sX, sY) { ;;Search for "S"
		if !LookForLetter(aX, aY) { ;; not A
		if !LookForLetter(zX, zY) { ;; not Z
		if !LookForLetter(wX, wY) { ;; not W
		if !LookForLetter(xX, xY) { ;; not X
		if !LookForLetter(dX, dY) { ;; not D
		if !LookForLetter(qX, qY) { ;; not Q
			SendTimed("s")
	  }
		}}}}}
	} else if LookForLetter(cX, cY) { ;;Search for "C"
		if !LookForLetter(aX, aY) { ;; not A
		if !LookForLetter(zX, zY) { ;; not Z
		if !LookForLetter(wX, wY) { ;; not W
		if !LookForLetter(xX, xY) { ;; not X
		if !LookForLetter(dX, dY) { ;; not D
		if !LookForLetter(qX, qY) { ;; not Q
			SendTimed("c")
		}
	}}}}}}
}
return

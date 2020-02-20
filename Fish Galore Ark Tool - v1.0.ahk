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
;;		* Steve Gray (Lexikos)
;;		Contribution:
;;			PixelColorSimple() Script, used to check letters while minimized
;;		GitHub: https://github.com/Lexikos
;;
;;    * HinkerLoden
;;		Contribution:
;;			F_RGB_Compare() Script, used to compare the letter colors
;;			F_ColorHex2RGB() Script, used to transform HEX colors codes in RGB
;;		GitHub: https://github.com/HinkerLoden
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
global isShowingMessage := True
global isFishing      := False
global fishingGamma       := 1
global regularGamma     := 2.2
global isSwitchingRods :=False
global firstRod           := 1
global currentRod         := 1 
global maxRod             := 2
global LetterColor := 0xFFFFFF
global KeystrokeDelay   := 250
global wX, global wY,		global qX, global qY,		global zX, global zY
global xX, global xY,		global aX, global aY,		global dX, global dY
global eX, global eY,		global sX, global sY,		global cX, global cY
global ScreenX,  ScreenY
global isMaximizing := False
global greenLine := 0.0444444
global mouseX, global mouseY
global active_id
global msgIsFishing, global msgSwitchRod, global msgResolution, global isMaximizing, global msgLastKeypress, Global LastKeypress
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 											Instantiate Visual Elements
UpdateGUI()
Menu, Tray, Standard
Menu, Tray, Add
Menu, Tray, Add, Hide Info, ShowInfo
Menu, Tray, Add, Enable Fishing, EnableFishing
Menu, Tray, Add, Maximize when you catch a fish, MaximizeOnCatch
Menu, Tray, Tip, Fish Galore Ark Tool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 										Position Config - Resolution Based
setResolution() {
	ScreenX := A_ScreenWidth, ScreenY := A_ScreenHeight
	if (ScreenX= 1920) && (ScreenY= 1080) {
    msgResolution:= "Resolution detected: [" ScreenX "x" ScreenY "]`n"
		wX := 1113, wY := 868,		qX := 1181, qY := 1016,		zX := 1158, zY := 973
		xX := 1167, xY := 972,		aX := 1162, aY := 970 ,		dX := 1192, dY := 906
		eX := 1186, eY := 998,		sX := 1161, sY := 917 ,		cX := 1135, cY := 918
	} else if (ScreenX= 1366) && (ScreenY= 768) {
    msgResolution:= "Resolution detected: [" ScreenX "x" ScreenY "]`n"
		wX := 788 , wY := 616,		qX := 840 , qY := 722,		zX := 824 , zY := 692
		xX := 830 , xY := 692,		aX := 827 , aY := 688,		dX := 847 , dY := 647
		eX := 841 , eY := 655,		sX := 826 , sY := 652,		cX := 808 , cY := 653
	} else if (ScreenX= 1680) && (ScreenY= 1050) {
    msgResolution:= "Resolution detected: [" ScreenX "x" ScreenY "]`n"
		wX := 1323 , wY := 834,		qX := 1302 , qY := 916,		zX := 1215 , zY := 899
		xX := 1291 , xY := 823,		aX := 1254 , aY := 839,		dX := 1292 , dY := 852
		eX := 1275 , eY := 858,		sX := 1219 , sY := 885,		cX := 1220 , cY := 865
	} else if (ScreenX/ScreenY = 16/9) { 
		;; If the resolution is not supported, but it's 16:9 ratio, try to interpolate new key positions
		msgResolution:= "Resolution not supported - trying to interpolate to [" ScreenX "x" ScreenY "]`n"
		wX := 788*(1366/ScreenX) , wY := 616*(768/ScreenY)
		qX := 840*(1366/ScreenX) , qY := 722*(768/ScreenY)
		zX := 824*(1366/ScreenX) , zY := 692*(768/ScreenY)
		xX := 830*(1366/ScreenX) , xY := 692*(768/ScreenY)
		aX := 827*(1366/ScreenX) , aY := 688*(768/ScreenY)
		dX := 847*(1366/ScreenX) , dY := 647*(768/ScreenY)
		eX := 841*(1366/ScreenX) , eY := 655*(768/ScreenY)
		sX := 826*(1366/ScreenX) , sY := 652*(768/ScreenY)
		cX := 808*(1366/ScreenX) , cY := 653*(768/ScreenY)
	} else if (ScreenX/ScreenY = 16/10) { 
		;; If the resolution is not supported, but it's 16:10 ratio, try to interpolate new key positions
		msgResolution:= "Resolution not supported - trying to interpolate to [" ScreenX "x" ScreenY "]`n"
		wX := 1323 , wY := 834,		qX := 1302 , qY := 916,		zX := 1215 , zY := 899
		xX := 1291 , xY := 823,		aX := 1254 , aY := 839,		dX := 1292 , dY := 852
		eX := 1275 , eY := 858,		sX := 1219 , sY := 885,		cX := 1220 , cY := 865
		wX := 1323*(1680/ScreenX) , wY := 834*(1050/ScreenY)
		qX := 1302*(1680/ScreenX) , qY := 916*(1050/ScreenY)
		zX := 1215*(1680/ScreenX) , zY := 899*(1050/ScreenY)
		xX := 1291*(1680/ScreenX) , xY := 823*(1050/ScreenY)
		aX := 1254*(1680/ScreenX) , aY := 839*(1050/ScreenY)
		dX := 1292*(1680/ScreenX) , dY := 852*(1050/ScreenY)
		eX := 1275*(1680/ScreenX) , eY := 858*(1050/ScreenY)
		sX := 1219*(1680/ScreenX) , sY := 885*(1050/ScreenY)
		cX := 1220*(1680/ScreenX) , cY := 865*(1050/ScreenY)
	} else {
    msgResolution:= "Resolution [" ScreenX "x" ScreenY "] is not supported yet.`nPlease take screenshots of every letter (A,C,D,E,Q,S,W,X,Z)`nand send using an issue on GitHub.`n"
    isFishing:=False
    isSwitchingRods:=False
		isMaximizing:=False
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 																Hotkeys
f1::
	if isShowingMessage {
		isShowingMessage := False
	}	else {
		isShowingMessage := True
	}
	UpdateGUI()
	return

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
  if isFishing {
		if (firstRod<maxRod-1) {
			firstRod++
		}
		else {
			firstRod:=1
		}
	}
  UpdateGUI()
  return

f5::
	if isFishing {
		SwitchRods()
	}
  UpdateGUI()
  return

f6::
	if isFishing {
		if ((maxRod>=firstRod) and (maxRod<9)) {
			maxRod++
		} else {
			maxRod:=firstRod+1
		}
	}
  UpdateGUI()
  return

f7::
	if isFishing {
			if isMaximizing {
			isMaximizing := False
		} else {
			isMaximizing := True
		}
	}
	UpdateGUI()
	return

f2:: 
	;; Toggles between Enabling/Disabling the Macro
  ;; Should be the last hotkey since it has no return when enabled, and leads to the loop
  if !isFishing {
		WinGet, active_id, ID, A
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
	if (isMaximizing && isFishing) {
		msgMaximizing:= "[F7] Don't maximize Ark when catch a fish`n"
	} else {
		msgMaximizing:= "[F7] Maximize Ark when you catch a fish`n"
	}
  if isSwitchingRods && isFishing {
    msgSwitchRod:= "[F3] Switch Rods: Enabled`n     [F4] Initial Rod:     " firstRod "`n     [F5] Current Rod: " currentRod " `n     [F6] Last Rod:       " maxRod " `n"
  } else {
    if isFishing {
			msgSwitchRod:= "[F3] Switch Rods: Disabled`n"
    } 
  }
	if (LastKeypress="") {
    msgLastKeypress:= "" ;; Clear Last Keypress
  } else {
		msgLastKeypress:= "Last Letter: " LastKeypress "`n  "
  }
  if isFishing {
    msgIsFishing:= "[F2] Fishing Enabled`n"
		 Menu, Tray, Icon, %A_WorkingDir%\Fishing.ico
  } else {
		msgIsShowing:= "`n [F1] Hide Info`n"	
    msgIsFishing:= "[F2] Fishing Disabled`n"
		msgSwitchRod:= "" ;; Clear Rod Switching Tooltip
		msgResolution:= "" ;; Clear Resolution Message
 		msgLastKeypress:= "" ;; Clear Last Keypress
		msgMaximizing:="" ;; Clear Maximizing Message
		 Menu, Tray, Icon, %A_WorkingDir%\notFishing.ico
  }
	if isShowingMessage {
		msgIsShowing:= "`n [F1] Hide Info`n"	
		ToolTip, %msgIsShowing% %msgIsFishing% %msgSwitchRod% %msgMaximizing% %msgResolution% %msgLastKeypress%, 0, 0, 1
	}	else {
		ToolTip, , , , 1
	}
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
	LastKeypress:= keystroke
	UpdateGUI()
	if isMaximizing {
		OpenArk()
	}
	ControlSend, , %keystroke%, ahk_class UnrealWindow
	Sleep, KeystrokeDelay
}

OpenArk() {
	MouseGetPos, mouseX, mouseY
	if ((mouseX>ScreenX/2 - 5*ScreenX/100 && mouseX<ScreenX/2 + 5*ScreenX/100) && (mouseY>ScreenY/2 - 5*ScreenY/100 && mouseY<ScreenY/2 + 5*ScreenY/100)) {
		WinActivate, ahk_class UnrealWindow ;
	}
}

LookForLetter(posX,posY) {
	;; If windows is active use easy method, otherwise use more hardware intensive method
	if WinActive("ahk_class UnrealWindow") { 
		PixelSearch retX, retY, posX, posY, posX, posY, LetterColor, 3, Fast
		if (ErrorLevel = 0)
			return True
		else
			return False
	} else {
		colorPixel := PixelColorSimple(posX,PosY,active_id)
		red := F_ColorHex2RGB(colorPixel,"red")
		green := F_ColorHex2RGB(colorPixel,"green")
		blue := F_ColorHex2RGB(colorPixel,"blue")
		wred := F_ColorHex2RGB(LetterColor,"red")
		wgreen := F_ColorHex2RGB(LetterColor,"green")
		wblue := F_ColorHex2RGB(LetterColor,"blue")
		isColor := F_RGB_Compare(red, green, blue, wred, wgreen, wblue, 100 )
		return isColor
	}
}

PixelColorSimple(pc_x, pc_y, pc_wID) {
  if pc_wID
  {
    pc_hDC := DllCall("GetDC", "UInt", pc_wID)
    pc_fmtI := A_FormatInteger
    SetFormat, IntegerFast, Hex
    pc_c := DllCall("GetPixel", "UInt", pc_hDC, "Int", pc_x, "Int", pc_y, "UInt")
    pc_c := pc_c >> 16 & 0xff | pc_c & 0xff00 | (pc_c & 0xff) << 16
    pc_c .= ""
    SetFormat, IntegerFast, %pc_fmtI%
    DllCall("ReleaseDC", "UInt", pc_wID, "UInt", pc_hDC)
    return pc_c
  }
}

F_RGB_Compare(InputColorRed, InputColorGreen, InputColorBlue,CompareColorRed,CompareColorGreen,CompareColorBlue,Colorvariations)
{
RedVarDown 	:=	CompareColorRed	-	Colorvariations
RedVarUp 	:=	CompareColorRed	+	Colorvariations
GreenVarDown :=	CompareColorGreen	-	Colorvariations
GreenVarUp 	 :=	CompareColorGreen	+	Colorvariations
BlueVarDown :=	CompareColorBlue	-	Colorvariations
BlueVarUp	:=	CompareColorBlue	+	Colorvariations

If (InputColorRed	>=	RedVarDown) AND (InputColorRed 	<=	RedVarUP)
	Red := true

If (InputColorGreen	>=	GreenVarDown) AND (InputColorGreen 	<=	GreenVarUp)
	Green := true 

If (InputColorBlue	>=	BlueVarDown) AND (InputColorBlue 	<=	BlueVarUp)
	Blue := true

if (Red AND Green AND Blue == 1)	
	return True
else 
	return False 
}

F_ColorHex2RGB(HexInput,ColorAsked) { ;	Convert hex Color 2 RGB	
	SetFormat Integer, D
	if (ColorAsked = "red") {
		Color_12 := SubStr(HexInput, 1 ,2) . SubStr(HexInput, 3 ,2)
		Red 	:=  	Color_12	+	0
		return Red
	} else if (ColorAsked = "green") {
		Color_34 := SubStr(HexInput, 1 ,2) . SubStr(HexInput, 5 ,2)
		Green 	:=  	Color_34	+	0
		return Green
	} else if (ColorAsked = "blue") {
		Color_56 := SubStr(HexInput, 1 ,2) . SubStr(HexInput, 7 ,2)
		Blue 	:= 		Color_56	+	0
		return Blue
	}
	return
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

RecastCheckColor(posX,PosY) {
	colorPixel := PixelColorSimple(posX,PosY,active_id)
	red := F_ColorHex2RGB(colorPixel,"red")
	green := F_ColorHex2RGB(colorPixel,"green")
	blue := F_ColorHex2RGB(colorPixel,"blue")
	Gred := F_ColorHex2RGB(0x7FFD03,"red")
	Ggreen := F_ColorHex2RGB(0x7FFD03,"green")
	Gblue := F_ColorHex2RGB(0x7FFD03,"blue")
	isColor := F_RGB_Compare(red, green, blue, Gred, Ggreen, Gblue, 100 )
	return isColor
}

reCast() {
	if WinActive("ahk_class UnrealWindow") {
		PixelSearch, retX, retY, ScreenX/4, 0, ScreenX/4 + ScreenX/2, ScreenY/4, 0x7FFD03, 3, Fast
		if !ErrorLevel	{
			LastKeypress:=""
			UpdateGUI()
			Sleep, 2000
			TakeScreenshot()
			SwitchRods()
			Sleep, 3000
			SetControlDelay -1
			ControlClick, x100 y100 , ahk_class UnrealWindow,,,,Pos
		}
	} else {
		startX := 1*ScreenX/3
		endX 	 := 2*ScreenX/3
		divs   := (endX - startX) / 10
		Check00 := RecastCheckColor(startX+divs*0  ,  ScreenY*greenLine)
		Check01 := RecastCheckColor(startX+divs*1  ,  ScreenY*greenLine)
		Check02 := RecastCheckColor(startX+divs*2  ,  ScreenY*greenLine)
		Check03 := RecastCheckColor(startX+divs*3  ,  ScreenY*greenLine)
		Check04 := RecastCheckColor(startX+divs*4  ,  ScreenY*greenLine)
		Check05 := RecastCheckColor(startX+divs*5  ,  ScreenY*greenLine)
		Check06 := RecastCheckColor(startX+divs*6  ,  ScreenY*greenLine)
		Check07 := RecastCheckColor(startX+divs*7  ,  ScreenY*greenLine)
		Check08 := RecastCheckColor(startX+divs*8  ,  ScreenY*greenLine)
		Check09 := RecastCheckColor(startX+divs*9  ,  ScreenY*greenLine)
		Check10 := RecastCheckColor(startX+divs*10 ,  ScreenY*greenLine)
		if (Check00 Or Check01 or Check02 or Check03 or Check04 or Check05 or Check06 or Check07 or Check08 or Check09 or Check10) {
			LastKeypress:=""
			Sleep, 2000
			TakeScreenshot()
			SwitchRods()
			Sleep, 3000
			SetControlDelay -1
			ControlClick, x100 y100 , ahk_class UnrealWindow,,,,Pos
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 																	Main Loop
while isFishing {
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
	reCast()		
}
return
ShowInfo:
	if isShowingMessage {
		isShowingMessage:=False
		UpdateGUI()
		Menu, Tray, Rename , Hide Info , Show Info
	} else {
		isShowingMessage:=True
		UpdateGUI()
		Menu, Tray, Rename , Show Info , Hide Info
	}
return

EnableFishing:
	if isFishing {
		isFishing:=False
		UpdateGUI()
		Menu, Tray, Rename , Disable Fishing , Enable Fishing
		
	} else {
		isFishing:=True
		UpdateGUI()
		Menu, Tray, Rename , Enable Fishing , Disable Fishing
	}
return
MaximizeOnCatch:
	if isMaximizing {
		isMaximizing:=False
		UpdateGUI()
		Menu, Tray, Rename , Don't Maximize when you catch a Fish , Maximize when you catch a Fish
	} else {
		isMaximizing:=True
		UpdateGUI()
		Menu, Tray, Rename , Maximize when you catch a Fish , Don't Maximize when you catch a Fish
	}
return
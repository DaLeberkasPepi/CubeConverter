#NoEnv
#IfWinActive, Diablo III ; || 暗黑破壞神III
#SingleInstance Force

SendMode Input
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client

global D3ScreenResolution
, ScreenMode
, ColumnCount := 0
, RowCount := 0
, CurrentMode
, Cycles := 0
, Globalsleep := 50

F1::
	;MsgBox, Ctrl+5 uses 1-slot items in the cube.`nCtrl+6 uses 2-slot items in the cube.`nU cancels the current cube action.
	#ctrls = 2  ;How many Hotkey controls to add?
	
	Loop,% #ctrls 
	{
		If (%A_Index% == 1)
			Gui, Add, Text, xm, Hotkey for 1 Slot Items:
		If (%A_Index% == 2)
			Gui, Add, Text, xm, Hotkey for 2 Slot Items:
		IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%	;Check for saved hotkeys in INI file.
		If savedHK%A_Index%                                      				;Activate saved hotkeys if found.
			Hotkey,% savedHK%A_Index%, Label%A_Index%                			;Remove tilde (~) and Win (#) modifiers...
		StringReplace, noMods, savedHK%A_Index%, ~                 				;They are incompatible with hotkey controls (cannot be shown).
		StringReplace, noMods, noMods, #,,UseErrorLevel           	   			;Add hotkey controls and show saved hotkeys.
		Gui, Add, Hotkey, x+5 vHK%A_Index% gGuiLabel, %noMods%        			;Add checkboxes to allow the Windows key (#) as a modifier...
		Gui, Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win  			;Check the box if Win modifier is used.
	}                                                                	
	Gui, Show,,CubeConverter Hotkeys
Return

Label1:
	IfWinNotActive, CubeConverter Hotkeys
	{
		global ItemSize := 1
		KanaisCube()
	}
Return

Label2:
	IfWinNotActive, CubeConverter Hotkeys
	{
		global ItemSize := 2
		KanaisCube()
	}
Return

KanaisCube()
{
	WinGetPos, , , DiabloWidth, DiabloHeight, Diablo III
	If (D3ScreenResolution != DiabloWidth*DiabloHeight)
	{
		;all needed coordinates to use the Kanais Cube, all coordinates are based on a resolution of 3440x1440 and calculated later to the used resolution
		global Fill := [957, 1121, 2]
		, Transmute := [315, 1106, 2]
		, TopLeftInv := [2753, 748, 3]
		, InvSize := [668, 394, 4]
		, SwitchPages := [180, 180, 4]
		, SwitchPagesLeft
		, SwitchPagesRight
		, Columns := 10
		, Rows := 6
		, SlotX
		, SlotY

		;convert coordinates for the used resolution of Diablo III
		ScreenMode := isWindowFullScreen("Diablo III")
		ConvertCoordinates(Fill)
		ConvertCoordinates(Transmute)
		ConvertCoordinates(TopLeftInv)
		ConvertCoordinates(InvSize)
		ConvertCoordinates(SwitchPages)

		;calculate all other needed coordinates of the base coordinates that where converted into the used Diablo III resolution
		SlotX := Round(InvSize[1]/Columns)
		SlotY := Round(InvSize[2]/Rows)
		TopLeftInv[1] := TopLeftInv[1]+SlotX/2
		TopLeftInv[2] := TopLeftInv[2]+SlotY/2
		SwitchPagesLeft := [Fill[1]-SwitchPages[1], Fill[2]]
		SwitchPagesRight := [Fill[1]+SwitchPages[1], Fill[2]]
	}
	
	If (ColumnCount == 9) && (RowCount >= 6)
	{
		ColumnCount := 0
		RowCount := 0
		Cycles := 0
	}
	If (ColumnCount >= 10) && (RowCount == 4)
	{
		ColumnCount := 0
		RowCount := 0
		Cycles := 0
	}
	If (CurrentMode != "") && (CurrentMode != ItemSize)
	{
		ColumnCount := 0
		RowCount := 0
		Cycles := 0
	}
	
	Loop
	{
		++Cycles
		CurrentMode := ItemSize
		XClick := TopLeftInv[1]+SlotX*(ColumnCount)
		YClick := TopLeftInv[2]+SlotY*(RowCount)
		MouseClick, right, XClick, YClick
		If (ItemSize == 2)
		{
			ColumnCount++
 			If (ColumnCount > 9) && (RowCount < 4)
			{
				ColumnCount := 0
				RowCount := RowCount + ItemSize
			}
		}
		Else
		{
			RowCount++
			If (RowCount > 5) && (ColumnCount < 9)
			{
				RowCount := 0
				ColumnCount := ColumnCount + ItemSize
			}
		}
		Sleep % Globalsleep
		MouseClick, left, Fill[1], Fill[2]
		Sleep % Globalsleep
		MouseClick, left, Transmute[1], Transmute[2]
		Sleep % Globalsleep + 125
		MouseClick, left, SwitchPagesRight[1], SwitchPagesRight[2]
		Sleep % Globalsleep
		MouseClick, left, SwitchPagesLeft[1], SwitchPagesLeft[2]
		Sleep % Globalsleep
	}	Until Cycles>=Columns*Rows/ItemSize or GetKeyState("U","P")
}


ConvertCoordinates(ByRef Array)
{
	WinGetPos, , , DiabloWidth, DiabloHeight, Diablo III
	D3ScreenResolution := DiabloWidth*DiabloHeight

 	If (ScreenMode == false)
 	{
		DiabloWidth := DiabloWidth-16
		DiabloHeight := DiabloHeight-39
	}

	Position := Array[3]

	;Pixel is always relative to the middle of the Diablo III window
  If (Position == 1)
  	Array[1] := Round(Array[1]*DiabloHeight/1440+(DiabloWidth-3440*DiabloHeight/1440)/2, 0)

  ;Pixel is always relative to the left side of the Diablo III window or just relative to the Diablo III windowheight
  If Else (Position == 2 || Position == 4)
		Array[1] := Round(Array[1]*(DiabloHeight/1440), 0)

	;Pixel is always relative to the right side of the Diablo III window
	If Else (Position == 3)
		Array[1] := Round(DiabloWidth-(3440-Array[1])*DiabloHeight/1440, 0)

	Array[2] := Round(Array[2]*(DiabloHeight/1440), 0)
}

isWindowFullScreen(WinID)
{
   ;checks if the specified window is full screen

	winID := WinExist( winTitle )
	If ( !winID )
		Return false

	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %winTitle%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

GuiLabel:
	If %A_GuiControl% in +,^,!,+^,+!,^!,+^!    ;If the hotkey contains only modifiers, return to wait for a key.
		return
	If InStr(%A_GuiControl%,"vk07")            ;vk07 = MenuMaskKey (see below)
		GuiControl,,%A_GuiControl%, % lastHK      ;Reshow the hotkey, because MenuMaskKey clears it.
	Else
		validateHK(A_GuiControl)
return

validateHK(GuiControl) 
{
	global lastHK
	Gui, Submit, NoHide
	lastHK := %GuiControl%                     ;Backup the hotkey, in case it needs to be reshown.
	num := SubStr(GuiControl,3)                ;Get the index number of the hotkey control.
	If (HK%num% != "") 						   ;If the hotkey is not blank...
	{                       
		StringReplace, HK%num%, HK%num%, SC15D, AppsKey      ;Use friendlier names,
		StringReplace, HK%num%, HK%num%, SC154, PrintScreen  ;  instead of these scan codes.
		If CB%num%                                ;  If the 'Win' box is checked, then add its modifier (#).
			HK%num% := "#" HK%num%
		If !RegExMatch(HK%num%,"[#!\^\+]")        ;  If the new hotkey has no modifiers, add the (~) modifier.
			HK%num% := "~" HK%num%                   ;    This prevents any key from being blocked.
		checkDuplicateHK(num)
	}
	If (savedHK%num% || HK%num%)               ;Unless both are empty,
		setHK(num, savedHK%num%, HK%num%)         ;  update INI/GUI
}

checkDuplicateHK(num)
{
	global #ctrls
	Loop,% #ctrls
	If (HK%num% = savedHK%A_Index%) 
	{
		dup := A_Index
		Loop,6 
		{
			GuiControl,% "Disable" b:=!b, HK%dup%   ;Flash the original hotkey to alert the user.
			Sleep,200
		}
		GuiControl,,HK%num%,% HK%num% :=""       ;Delete the hotkey and clear the control.
		break
	}
}

setHK(num,INI,GUI) 
{
	If INI                           ;If previous hotkey exists,
		Hotkey, %INI%, Label%num%, Off  ;  disable it.
	If GUI                           ;If new hotkey exists,
		Hotkey, %GUI%, Label%num%, On   ;  enable it.
	IniWrite,% GUI ? GUI:null, Hotkeys.ini, Hotkeys, %num%
	savedHK%num%  := HK%num%
}

#MenuMaskKey vk07                 ;Requires AHK_L 38+
#If ctrl := HotkeyCtrlHasFocus()
	*AppsKey::                       ;Add support for these special keys,
	*BackSpace::                     ;  which the hotkey control does not normally allow.
	*Delete::
	*Enter::
	*Escape::
	*Pause::
	*PrintScreen::
	*Space::
	*Tab::
	modifier := ""
	If GetKeyState("Shift","P")
		modifier .= "+"
	If GetKeyState("Ctrl","P")
		modifier .= "^"
	If GetKeyState("Alt","P")
		modifier .= "!"
	Gui, Submit, NoHide             ;If BackSpace is the first key press, Gui has never been submitted.
	If (A_ThisHotkey == "*BackSpace" && %ctrl% && !modifier)   ;If the control has text but no modifiers held,
		GuiControl,,%ctrl%                                       ;  allow BackSpace to clear that text.
	Else                                                     ;Otherwise,
		GuiControl,,%ctrl%, % modifier SubStr(A_ThisHotkey,2)  ;  show the hotkey.
	validateHK(ctrl)
	return
#If

HotkeyCtrlHasFocus() 
{
	GuiControlGet, ctrl, Focus       ;ClassNN
	If InStr(ctrl,"hotkey") 
	{
		GuiControlGet, ctrl, FocusV     ;Associated variable
	Return, ctrl
	}
}
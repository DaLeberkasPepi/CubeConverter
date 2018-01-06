#NoEnv
#IfWinActive, Diablo III ;|| 暗黑破壞神III
#SingleInstance Force

SendMode Input
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client

global ColumnCount := 0
, RowCount := 0
, Cycles := 0

global D3ScreenResolution
,NativeDiabloHeight := 1440
,NativeDiabloWidth := 3440
,#ctrls = 3

IfNotExist, Hotkeys.ini
	FileAppend,
(
[Settings]
Globalsleep=50
[Hotkeys]
1=^5
2=^6
3=^7
), Hotkeys.ini

IniRead, Globalsleep, Hotkeys.ini, Settings, Globalsleep, 50
Loop,% #ctrls 
{
	If (A_Index == 1)
		GUI, Add, Text, xm, Hotkey for 1 Slot Items:
		
	If (A_Index == 2)
		GUI, Add, Text, xm, Hotkey for 2 Slot Items:
	
	If (A_Index == 3)
		GUI, Add, Text, xm, Hotkey for Inventoryclear:
	
	IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%	;Check for saved hotkeys in INI file.
	
	If savedHK%A_Index%                                      				;Activate saved hotkeys if found.
		Hotkey,% savedHK%A_Index%, Label%A_Index%                			;Remove tilde (~) and Win (#) modifiers...
	
	StringReplace, noMods, savedHK%A_Index%, ~                 				;They are incompatible with hotkey controls (cannot be shown).
	StringReplace, noMods, noMods, #,,UseErrorLevel           	   			;Add hotkey controls and show saved hotkeys.
	GUI, Add, Hotkey, x+5 vHK%A_Index% gGuiLabel, %noMods%        			;Add checkboxes to allow the Windows key (#) as a modifier...
	GUI, Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win  			;Check the box if Win modifier is used.
}   
GUI, Add, Text, xm, [ms] for Globalsleep:
GUI, Add, Edit, x+5 w35 vGlobalsleep, %Globalsleep%
GUI, Submit
IniWrite, %Globalsleep%, Hotkeys.ini, Settings, Globalsleep
Return

F1::
	GUI, Show,,CubeConverter Hotkeys
Return

GuiClose:
	GUIControlGet, Globalsleep
	IniWrite, %Globalsleep%, Hotkeys.ini, Settings, Globalsleep
	GUI, Hide
Return

ESC::Reload
Return

Label1:		;Hotkey for 1 Slot Items
	IfWinNotActive, CubeConverter Hotkeys
	{
		global ItemSize := 1
		KanaisCube("KanaisCube")
	}
Return

Label2:		;Hotkey for 2 Slot Items
	IfWinNotActive, CubeConverter Hotkeys
	{
		global ItemSize := 2
		KanaisCube("KanaisCube")
	}
Return

Label3:		;Hotkey for Inventoryclear
	IfWinNotActive, CubeConverter Hotkeys
	{
		If (ItemSize == "")
			global ItemSize := 1
		KanaisCube("Blacksmith")
	}
Return

KanaisCube(Setting)
{
	GUIControlGet, Globalsleep
	
	GetClientWindowInfo("Diablo III", DiabloWidth, DiabloHeight, DiabloX, DiabloY)
	
	If (D3ScreenResolution != DiabloWidth*DiabloHeight)
	{
		;all needed coordinates to use the Kanais Cube, all coordinates are based on a resolution of 3440x1440 and calculated later to the used resolution
		global Fill := [957, 1121, 2]
		, Transmute := [315, 1106, 2]
		, TopLeftInv := [2753, 748, 3]
		, InvSize := [668, 394, 4]
		, SwitchPages := [180, 180, 4]
		, Salvage := [220, 390, 2]
		, SwitchPagesLeft
		, SwitchPagesRight
		, Columns := 10
		, Rows := 6
		, SlotX
		, SlotY

		;convert coordinates for the used resolution of Diablo III
		ConvertCoordinates(Fill)
		ConvertCoordinates(Transmute)
		ConvertCoordinates(TopLeftInv)
		ConvertCoordinates(InvSize)
		ConvertCoordinates(SwitchPages)
		ConvertCoordinates(Salvage)

		;calculate all other needed coordinates of the base coordinates that where converted into the used Diablo III resolution
		SlotX := Round(InvSize[1]/Columns)
		SlotY := Round(InvSize[2]/Rows)
		TopLeftInv[1] := TopLeftInv[1]+SlotX/2
		TopLeftInv[2] := TopLeftInv[2]+SlotY/2
		SwitchPagesLeft := [Fill[1]-SwitchPages[1], Fill[2]]
		SwitchPagesRight := [Fill[1]+SwitchPages[1], Fill[2]]
	}

	ColumnCount := 0
	RowCount := 0
	Cycles := 0
	
	If (Setting == "Blacksmith")
		MouseClick, left, Salvage[1], Salvage[2]
	
	Loop
	{
		++Cycles
		XClick := TopLeftInv[1]+SlotX*(ColumnCount)
		YClick := TopLeftInv[2]+SlotY*(RowCount)
		
		If (Setting == "KanaisCube")
			MouseClick, right, XClick, YClick
		
		If (Setting == "Blacksmith")
		{
			global AdjustedSleep := Max(Globalsleep - 35, 3)
			Sleep % AdjustedSleep
			MouseClick, left, XClick, YClick
		}
		
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
		
		If (Setting == "KanaisCube")
		{
			Sleep % Globalsleep
			MouseClick, left, Fill[1], Fill[2]
			Sleep % Globalsleep
			MouseClick, left, Transmute[1], Transmute[2]
			Sleep % Globalsleep + 125
			MouseClick, left, SwitchPagesRight[1], SwitchPagesRight[2]
			Sleep % Globalsleep
			MouseClick, left, SwitchPagesLeft[1], SwitchPagesLeft[2]
			Sleep % Globalsleep
		}
		
		If (Setting == "Blacksmith")
		{
		
			Sleep % AdjustedSleep
			Send, {Enter}
		}
	}	Until Cycles>=Columns*Rows/ItemSize
}

ConvertCoordinates(ByRef Array)
{
	GetClientWindowInfo("Diablo III", DiabloWidth, DiabloHeight, DiabloX, DiabloY)
	
	D3ScreenResolution := DiabloWidth*DiabloHeight
	
	Position := Array[3]

	;Pixel is always relative to the middle of the Diablo III window
	If (Position == 1)
  	Array[1] := Round(Array[1]*DiabloHeight/NativeDiabloHeight+(DiabloWidth-NativeDiabloWidth*DiabloHeight/NativeDiabloHeight)/2, 0)

	;Pixel is always relative to the left side of the Diablo III window or just relative to the Diablo III windowheight
	If Else (Position == 2 || Position == 4)
		Array[1] := Round(Array[1]*(DiabloHeight/NativeDiabloHeight), 0)

	;Pixel is always relative to the right side of the Diablo III window
	If Else (Position == 3)
		Array[1] := Round(DiabloWidth-(NativeDiabloWidth-Array[1])*DiabloHeight/NativeDiabloHeight, 0)

	Array[2] := Round(Array[2]*(DiabloHeight/NativeDiabloHeight), 0)
}

GetClientWindowInfo(ClientWindow, ByRef ClientWidth, ByRef ClientHeight, ByRef ClientX, ByRef ClientY)
{
	hwnd := WinExist(ClientWindow)
	VarSetCapacity(rc, 16)
	DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
	ClientWidth := NumGet(rc, 8, "int")
	ClientHeight := NumGet(rc, 12, "int")

	WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, %ClientWindow%
	ClientX := Floor(WindowX + (WindowWidth - ClientWidth) / 2)
	ClientY := Floor(WindowY + (WindowHeight - ClientHeight - (WindowWidth - ClientWidth) / 2))
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
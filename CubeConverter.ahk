#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#IfWinActive, Diablo III
CoordMode, Mouse, Client
global D3ScreenResolution
, ScreenMode

^5::
	global ItemSize := 1
	KanaisCube()
	Return

^6::
	global ItemSize := 2
	KanaisCube()
	Return

F1::
MsgBox, Ctrl+5 uses 1-slot items in the cube.`nCtrl+6 uses 2-slot items in the cube.`nU cancels the current cube action.

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
		SlotX	:= Round(InvSize[1]/Columns)
		SlotY := Round(InvSize[2]/Rows)
		TopLeftInv[1] := TopLeftInv[1]-SlotX/2
		TopLeftInv[2] := TopLeftInv[2]+SlotY/2
		SwitchPagesLeft := [Fill[1]-SwitchPages[1], Fill[2]]
		SwitchPagesRight := [Fill[1]+SwitchPages[1], Fill[2]]
	}

	Loop
	{
		RowCount := (Floor((A_Index-1)/Columns))*ItemSize
		StringRight, ColumnCount, A_Index, 1
		If (ColumnCount == 0)
			ColumnCount := 10
		XClick := TopLeftInv[1]+SlotX*(ColumnCount)
		YClick := TopLeftInv[2]+SlotY*(RowCount)
		MouseClick, right, XClick, YClick
		Sleep, 50
		MouseClick, left, Fill[1], Fill[2]
		Sleep, 50
		MouseClick, left, Transmute[1], Transmute[2]
		Sleep, 175
		MouseClick, left, SwitchPagesRight[1], SwitchPagesRight[2]
		Sleep, 50
		MouseClick, left, SwitchPagesLeft[1], SwitchPagesLeft[2]
		Sleep, 50
	}	Until A_Index>=Columns*Rows/ItemSize or GetKeyState("U","P")
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
	Tooltip, WinID %WinID% winTitle %winTitle%, 100, 400, 4
	If ( !winID )
		Return false

	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %winTitle%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

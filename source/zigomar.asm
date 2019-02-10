.386
.model flat,stdcall
option casemap:none
include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib gdi32.lib

WM_SHELLNOTIFY equ WM_USER+5
IDI_TRAY 			equ 0
IDM_RED 			equ 10011
IDM_GREEN 			equ 10012
IDM_BLUE 			equ 10013
IDM_SH_CLOCK 			equ 10015
IDM_QUIT 			equ 10030
BMP_B0				equ 300
BMP_B1				equ 310
BMP_G0				equ 400
BMP_G1				equ 410
BMP_R0				equ 500
BMP_R1				equ 510
MUTEX_ALL_ACCESS		equ 1F0001h

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
ClassName 		db "ZigomarWinClass",0
AppName  		db "Zigomar Utilities",0
ShowString		db "Show Clock",0
HideString		db "Hide Clock",0
MNU_Clock		db "Binary Clock",0
MNU_RedThm		db "Red Theme",0
MNU_GrnThm		db "Green Theme",0
MNU_BluThm		db "Blue Theme",0
MNU_Close		db "Close Zigomar",0
yesterDay		dw 77
MutexAtt		SECURITY_ATTRIBUTES <SIZEOF SECURITY_ATTRIBUTES,NULL,TRUE>

.data?
hInstance		dd ?
hPopupMenu		dd ?
hClockMenu		dd ?
hRegion			dd ?
hBMP_B0			dd ?
hBMP_B1			dd ?
hBMP_R0			dd ?
hBMP_R1			dd ?
hBMP_G0			dd ?
hBMP_G1			dd ?
S0			dw ?
S1			dw ?
M0			dw ?
M1			dw ?
H0			dw ?
H1			dw ?
toDay			dw ?
hCellOFF		dd ?
hCellON			dd ?
hPT			dd ?
hMutex			dd ?

TimeNow			SYSTEMTIME <>	; Current time
note 			NOTIFYICONDATA <>

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke OpenMutex,MUTEX_ALL_ACCESS,FALSE,addr AppName
	.if eax==NULL
		invoke CreateMutex,addr MutexAtt,TRUE, addr AppName
		mov hMutex,eax
		invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	.endif
	invoke ExitProcess,eax
	
TimeGet proc
	invoke GetLocalTime, ADDR TimeNow
	mov cx,10
	mov ax,TimeNow.wHour
	div cl
	mov bx,ax
	and ax,255
	mov H1,ax
	shr bx,8
	mov H0,bx
	mov ax,TimeNow.wMinute
	div cl
	mov bx,ax
	and ax,255
	mov M1,ax
	shr bx,8
	mov M0,bx
	mov ax,TimeNow.wSecond
	div cl
	mov bx,ax
	and ax,255
	mov S1,ax
	shr bx,8
	mov S0,bx
	mov ax,TimeNow.wDay
	mov toDay,ax
	Ret
TimeGet endp


MakeRegions proc hWnd:HWND
	;
	invoke CreateRectRgn,62,30,70,38
	mov hRegion,eax
	invoke CreateRectRgn,62,20,70,28
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR
	invoke CreateRectRgn,62,10,70,18
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,62,0,70,8
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,52,30,60,38
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,52,20,60,28
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,52,10,60,18
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	;
	invoke CreateRectRgn,36,30,44,38
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR
	invoke CreateRectRgn,36,20,44,28
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR
	invoke CreateRectRgn,36,10,44,18
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,36,0,44,8
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,26,30,34,38
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,26,20,34,28
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,26,10,34,18
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	;
	invoke CreateRectRgn,10,30,18,38
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR
	invoke CreateRectRgn,10,20,18,28
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR
	invoke CreateRectRgn,10,10,18,18
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,10,0,18,8
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,0,30,8,38
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	invoke CreateRectRgn,0,20,8,28
	invoke CombineRgn,hRegion,hRegion,eax,RGN_OR	
	;
	invoke SetWindowRgn,hWnd,hRegion,0
	Ret
MakeRegions endp

GoToTray proc hWnd:HWND, Visibility:DWORD
	mov note.cbSize,sizeof NOTIFYICONDATA
	push hWnd
	pop note.hwnd
	mov note.uID,IDI_TRAY
	mov note.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP
	mov note.uCallbackMessage,WM_SHELLNOTIFY
	invoke TimeGet
	xor ebx,ebx
	mov bx,toDay
	add bx,1000
	invoke LoadIcon,hInstance,ebx
	mov note.hIcon,eax
	invoke lstrcpy,addr note.szTip,addr AppName
	invoke ShowWindow,hWnd,Visibility
	invoke Shell_NotifyIcon,NIM_ADD,addr note
	Ret
GoToTray endp

PainCell proc hMemDC:HDC,hDC:DWORD,X:WORD,Y:WORD,rect:RECT,hCell0:DWORD,hCell1:DWORD
	mov 	eax,hCell0
	test   	S0,1
	jz 	   	@LS0
	mov 	eax,hCell1
	@LS0:
	invoke 	SelectObject,hMemDC,eax
	invoke 	BitBlt,HDC ptr hDC,X,Y,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
	Ret
PainCell endp

ChangeCell proc NewCell:DWORD
	push eax
	push ebx
	.if NewCell==IDM_BLUE
		mov eax,hBMP_B0
		mov ebx,hBMP_B1
	.elseif NewCell==IDM_GREEN
		mov eax,hBMP_G0
		mov ebx,hBMP_G1
	.elseif NewCell==IDM_RED
		mov eax,hBMP_R0
		mov ebx,hBMP_R1	
	.endif
	mov hCellOFF,eax
	mov hCellON,ebx
	pop ebx
	pop eax
	Ret
ChangeCell endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	
	; class init
	mov wc.cbSize,SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra,NULL
	mov wc.cbWndExtra,NULL
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground,COLOR_APPWORKSPACE
	mov wc.lpszMenuName,NULL
	mov wc.lpszClassName,OFFSET ClassName

	; icon and cursor load
	invoke LoadIcon,hInst,200
	mov wc.hIcon,eax
	mov wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	;
	;loading bitmaps
	invoke LoadBitmap,hInst,BMP_B0
	mov hBMP_B0,eax
	invoke LoadBitmap,hInst,BMP_B1
	mov hBMP_B1,eax
	
	invoke LoadBitmap,hInst,BMP_G0
	mov hBMP_G0,eax
	invoke LoadBitmap,hInst,BMP_G1
	mov hBMP_G1,eax
	
	invoke LoadBitmap,hInst,BMP_R0
	mov hBMP_R0,eax
	invoke LoadBitmap,hInst,BMP_R1
	mov hBMP_R1,eax
	
	;class registration and window creation
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_NOACTIVATE + WS_EX_TOPMOST + WS_EX_TOOLWINDOW ,ADDR ClassName,ADDR AppName,
           WS_POPUP + WS_VISIBLE,CW_USEDEFAULT,CW_USEDEFAULT,70,38,NULL,NULL,hInst,NULL
     	mov hwnd,eax

	;popup menu creation
	invoke CreatePopupMenu
	mov hClockMenu,eax
	invoke AppendMenu,hClockMenu,MF_STRING,IDM_RED,addr MNU_RedThm
	invoke AppendMenu,hClockMenu,MF_STRING,IDM_GREEN,addr MNU_GrnThm
	invoke AppendMenu,hClockMenu,MF_STRING,IDM_BLUE,addr MNU_BluThm
	invoke AppendMenu,hClockMenu,MF_SEPARATOR,NULL,NULL
	invoke AppendMenu,hClockMenu,MF_STRING,IDM_SH_CLOCK,addr HideString
	invoke CreatePopupMenu
	mov hPopupMenu,eax	
	invoke AppendMenu,hPopupMenu,MF_POPUP,hClockMenu,addr MNU_Clock
	invoke AppendMenu,hPopupMenu,MF_SEPARATOR,NULL,NULL
	invoke AppendMenu,hPopupMenu,MF_STRING,IDM_QUIT,addr MNU_Close
		
	;init appearance
	invoke ChangeCell,IDM_GREEN
	invoke ModifyMenu,hClockMenu,IDM_GREEN,MF_STRING + MF_CHECKED,IDM_GREEN,addr MNU_GrnThm
	
	;show window and initialize menu
	invoke GoToTray,hwnd,SW_NORMAL

	;message loop
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw

	;end
	mov eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL pt:POINT
	LOCAL rect:RECT
	LOCAL ps:PAINTSTRUCT 
	LOCAL hDC:HDC 
	LOCAL hMemDC:HDC
		
	.if uMsg==WM_CREATE
		invoke MakeRegions,hWnd
		invoke SetTimer, hWnd, 1, 500, NULL
	    	  		  		
	.elseif uMsg==WM_TIMER
		invoke TimeGet
		xor ebx,ebx
		mov bx,toDay
		.if bx != yesterDay
			mov yesterDay,bx
			add bx,1000
			invoke LoadIcon,hInstance,ebx
			mov note.hIcon,eax
			invoke Shell_NotifyIcon,NIM_MODIFY,addr note
		.endif		
		invoke GetClientRect,hWnd,addr rect
		invoke InvalidateRect,hWnd,addr rect,FALSE
		invoke SendMessage,hWnd,WM_PAINT,NULL,NULL
	
	.elseif uMsg==WM_PAINT
	
	    invoke BeginPaint,hWnd,addr ps 
      	mov hDC,eax 
     	invoke CreateCompatibleDC,hDC 
     	mov hMemDC,eax
     	invoke SelectObject,hMemDC,hPT
      	invoke GetClientRect,hWnd,addr rect    	
	
	mov eax,hCellOFF
    	test S0,1
    	jz @LS1
	mov eax,hCellON
    	@LS1:
   		invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,62,30,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test S0,2
    		jz @LS2
		mov eax,hCellON
    	@LS2:
   		invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,62,20,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test S0,4
    		jz @LS3
		mov eax,hCellON
    	@LS3:
   	 	invoke 	SelectObject,hMemDC,eax
    		invoke 	BitBlt,hDC,62,10,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY      			
		mov eax,hCellOFF
    		test S0,8
    		jz @LS4
		mov eax,hCellON
    	@LS4:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,62,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test S1,1
    		jz @HS1
		mov eax,hCellON
    	@HS1:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,52,30,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test S1,2
    		jz @HS2
		mov eax,hCellON
    	@HS2:
   	 	invoke 	SelectObject,hMemDC,eax
    		invoke 	BitBlt,hDC,52,20,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test S1,4
    		jz @HS3
		mov eax,hCellON
    	@HS3:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,52,10,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M0,1
    		jz @LM1
		mov eax,hCellON
    	@LM1:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,36,30,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M0,2
    		jz @LM2
		mov eax,hCellON
    	@LM2:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,36,20,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M0,4
    		jz @LM3
		mov eax,hCellON
    	@LM3:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,36,10,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M0,8
    		jz @LM4
		mov eax,hCellON
    	@LM4:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,36,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M1,1
    		jz @HM1
		mov eax,hCellON
    	@HM1:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,26,30,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M1,2
    		jz @HM2
		mov eax,hCellON
    	@HM2:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,26,20,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test M1,4
    		jz @HM3
		mov eax,hCellON
    	@HM3:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,26,10,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test H0,1
    		jz @LH1
		mov eax,hCellON
    	@LH1:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,10,30,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test H0,2
    		jz @LH2
		mov eax,hCellON
    	@LH2:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,10,20,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test H0,4
    		jz @LH3
		mov eax,hCellON
    	@LH3:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,10,10,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test H0,8
    		jz @LH4
		mov eax,hCellON
    	@LH4:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,10,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test H1,1
    		jz @HH1
		mov eax,hCellON
    	@HH1:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,0,30,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		mov eax,hCellOFF
    		test H1,2
    		jz @HH2
		mov eax,hCellON
    	@HH2:
   	 	invoke SelectObject,hMemDC,eax
    		invoke BitBlt,hDC,0,20,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		invoke EndPaint,hWnd,addr ps
		invoke DeleteDC,hMemDC
		invoke DeleteDC,hDC
		
	.elseif uMsg==WM_DESTROY
		invoke DestroyMenu,hPopupMenu
		invoke CloseHandle,hMutex
		invoke PostQuitMessage,NULL
	
	.elseif uMsg==WM_COMMAND
		.if lParam==0
			mov eax,wParam
			.if ax==IDM_SH_CLOCK
				invoke IsWindowVisible,hWnd
				.if eax == FALSE
    				invoke ShowWindow,hWnd,SW_SHOWNOACTIVATE
					invoke ModifyMenu,hPopupMenu,IDM_SH_CLOCK,MF_BYCOMMAND,IDM_SH_CLOCK,addr HideString
				.else
					invoke ShowWindow,hWnd,SW_HIDE
					invoke ModifyMenu,hPopupMenu,IDM_SH_CLOCK,MF_BYCOMMAND,IDM_SH_CLOCK,addr ShowString 			
				.endif 
				
			.elseif ax==IDM_QUIT
				invoke Shell_NotifyIcon,NIM_DELETE,addr note
				invoke DestroyWindow,hWnd
				
			.elseif ax==IDM_RED
				invoke ChangeCell,IDM_RED
				invoke ModifyMenu,hClockMenu,IDM_RED,MF_STRING + MF_CHECKED,IDM_RED,addr MNU_RedThm
				invoke ModifyMenu,hClockMenu,IDM_GREEN,MF_STRING + MF_UNCHECKED,IDM_GREEN,addr MNU_GrnThm
				invoke ModifyMenu,hClockMenu,IDM_BLUE,MF_STRING + MF_UNCHECKED,IDM_BLUE,addr MNU_BluThm
				invoke GetClientRect,hWnd,addr rect
				invoke InvalidateRect,hWnd,addr rect,FALSE
				invoke SendMessage,hWnd,WM_PAINT,NULL,NULL
				
			.elseif ax==IDM_GREEN
				invoke ChangeCell,IDM_GREEN
				invoke ModifyMenu,hClockMenu,IDM_GREEN,MF_STRING + MF_CHECKED,IDM_GREEN,addr MNU_GrnThm
				invoke ModifyMenu,hClockMenu,IDM_RED,MF_STRING + MF_UNCHECKED,IDM_RED,addr MNU_RedThm
				invoke ModifyMenu,hClockMenu,IDM_BLUE,MF_STRING + MF_UNCHECKED,IDM_BLUE,addr MNU_BluThm
				invoke GetClientRect,hWnd,addr rect
				invoke InvalidateRect,hWnd,addr rect,FALSE		
				invoke SendMessage,hWnd,WM_PAINT,NULL,NULL
				
			.elseif ax==IDM_BLUE
				invoke ChangeCell,IDM_BLUE
				invoke ModifyMenu,hClockMenu,IDM_BLUE,MF_STRING + MF_CHECKED,IDM_BLUE,addr MNU_BluThm
				invoke ModifyMenu,hClockMenu,IDM_RED,MF_STRING + MF_UNCHECKED,IDM_RED,addr MNU_RedThm
				invoke ModifyMenu,hClockMenu,IDM_GREEN,MF_STRING + MF_UNCHECKED,IDM_GREEN,addr MNU_GrnThm
				invoke GetClientRect,hWnd,addr rect
				invoke InvalidateRect,hWnd,addr rect,FALSE				
				invoke SendMessage,hWnd,WM_PAINT,NULL,NULL
			.endif
			
		.endif
		
	.elseif uMsg==WM_SHELLNOTIFY
		.if wParam==IDI_TRAY
			.if lParam==WM_RBUTTONDOWN
				invoke GetCursorPos,addr pt
				invoke SetForegroundWindow,hWnd
				invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,NULL,hWnd,NULL
				invoke PostMessage,hWnd,WM_NULL,0,0
			.elseif lParam==WM_LBUTTONDBLCLK
					invoke SendMessage,hWnd,WM_COMMAND,IDM_SH_CLOCK,0
			.endif
		.endif
		
	.elseif uMsg==WM_LBUTTONDBLCLK
		invoke SendMessage,hWnd,WM_COMMAND,IDM_SH_CLOCK,0
		
	.elseif uMsg==WM_LBUTTONDOWN
		invoke SetForegroundWindow,hWnd
		invoke SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,lParam
		
	.elseif uMsg==WM_RBUTTONDOWN
		invoke GetCursorPos,addr pt
		invoke SetForegroundWindow,hWnd
		invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,NULL,hWnd,NULL
		invoke PostMessage,hWnd,WM_NULL,0,0

	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.endif
	xor eax,eax
	ret
WndProc endp

end start

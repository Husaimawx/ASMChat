INCLUDE ./client.inc
.386
.model flat,stdcall
option casemap:none

include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include comctl32.inc
includelib comctl32.lib
include msvcrt.inc
includelib msvcrt.lib
include ole32.inc
includelib ole32.lib

.data
hInstance dd ?
hWinMain dd ?
hFont dd ?
hBrush dd ?
hListView dd ?
hUsernameEdit dd ? 
hPasswordEdit dd ? 
;hSendButton dd ?
;hEdit dd ?
;hNewEdit dd ?
;ptrCurUser dd 0
;ptrUsers dd 0
;ptrBuffer dd 0

.const
szTitle db 'Hello, World!', 0
szLogWindow db 'LogWindow',0
szLogin db 'Log in', 0
szLogon db 'Log on', 0
szUsername db 'Username', 0
szSuccess db ' success!', 0
szStatic db 'STATIC',0
szPassword db 'Password', 0
szFailed db ' failed!', 0
szEdit db 'EDIT',0
szButton db 'BUTTON',00

strUsername db 128 DUP(0)
strPassword db 128 DUP(0)

.code
LogProc PROC USES ebx esi edi, hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD  ;窗口过程
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hDc

	mov eax, uMsg

	.if eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax

		invoke GetClientRect, hWnd, addr @stRect

		invoke DrawText, @hDc, addr szTitle, -1, addr @stRect, DT_SINGLELINE or DT_CENTER or DT_VCENTER  ;这里将显示szTitle里的字符串
		invoke EndPaint, hWnd, addr @stPs
	
	.elseif eax == WM_CLOSE  ;窗口关闭消息
		invoke DestroyWindow, hWinMain
		invoke PostQuitMessage, NULL

	.elseif eax == WM_CREATE  ;创建窗口  下面代码表示创建一个按钮，其中button字符串值是'button'，在数据段定义，表示要创建的是一个按钮，showButton表示该按钮上的显示信息
		mov eax, hWnd
		mov hWinMain,eax

		invoke GetStockObject, DEFAULT_GUI_FONT
		mov hFont, eax
		invoke GetStockObject, DKGRAY_BRUSH
		mov hBrush, eax

 		invoke CreateWindowEx,NULL, addr szStatic, addr szUsername,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or SS_CENTERIMAGE, 20, 20, 60, 20,
		hWnd, 0, hInstance,NULL
		invoke SendMessage, eax, WM_SETFONT, hFont,	0

		invoke CreateWindowEx, NULL, addr szEdit, NULL,\
		WS_CHILD or WS_VISIBLE or WS_BORDER or SS_CENTERIMAGE, 90, 20, 210, 20,\  
		hWnd, 0, hInstance, NULL
		mov hUsernameEdit, eax
		invoke SendMessage, hUsernameEdit, WM_SETFONT, hFont, 0

		invoke CreateWindowEx,NULL, addr szStatic, addr szPassword,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or SS_CENTERIMAGE, 20, 60, 60, 20,
		hWnd, 0,hInstance,NULL
		invoke SendMessage, eax, WM_SETFONT, hFont, 0

		invoke CreateWindowEx, NULL, addr szEdit, NULL,\
		WS_CHILD or WS_VISIBLE or WS_BORDER or ES_PASSWORD or SS_CENTERIMAGE, 90, 60, 210, 20,\
		hWnd, 0, hInstance, NULL
		mov hPasswordEdit, eax
		invoke SendMessage, hPasswordEdit, WM_SETFONT, hFont, 0

		invoke CreateWindowEx, NULL, addr szButton, addr szLogin,\
		WS_TABSTOP or WS_VISIBLE or WS_CHILD or BS_DEFPUSHBUTTON, 50, 95, 80, 23,
		hWnd, 1, hInstance,NULL
		invoke SendMessage, eax, WM_SETFONT, hFont, 0

		invoke CreateWindowEx, NULL, addr szButton, addr szLogon,\
		WS_TABSTOP or WS_VISIBLE or WS_CHILD or BS_DEFPUSHBUTTON, 210, 95, 80, 23,
		hWnd, 2, hInstance,NULL
		invoke SendMessage, eax, WM_SETFONT, hFont, 0

	.elseif eax == WM_COMMAND  ;点击时候产生的消息是WM_COMMAND
		mov eax, wParam  ;其中参数wParam里存的是句柄，如果点击了一个按钮，则wParam是那个按钮的句柄
		.if eax == 1
			invoke GetWindowText, hUsernameEdit, addr strUsername, 128
			invoke GetWindowText, hPasswordEdit, addr strPassword, 128
			invoke crt_strlen, addr strUsername
			.if eax == 0
				jmp L1
			.endif
			invoke crt_strlen, addr strPassword
			.if eax == 0
				jmp L1
			.endif
			mov edi, eax

			;invoke chat_login, addr strUsername, addr strPassword
			.if eax == 1
				invoke DestroyWindow, hWinMain
				invoke PostQuitMessage, NULL
				;invoke ClientMain
			.else
				invoke MessageBox, hWinMain, addr szFailed, addr szTitle, MB_OK
			.endif
		.elseif eax == 2
			invoke GetWindowText, hUsernameEdit, addr strUsername, 128
			invoke GetWindowText, hPasswordEdit, addr strPassword, 128
			invoke crt_strlen, addr strUsername
			.if eax == 0
				jmp L1
			.endif
			invoke crt_strlen, addr strPassword
			.if eax == 0
				jmp L1
			.endif

			;invoke chat_sign_in, addr strUsername, addr strPassword
			.if eax == 1
				invoke MessageBox, hWinMain, addr szSuccess, addr szTitle, MB_OK
			.else
				invoke MessageBox, hWinMain, addr szFailed, addr szTitle, MB_OK
			.endif
		.endif
	.else  ;否则按默认处理方法处理消息
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.endif
L1:
	mov eax, 0
	ret
LogProc ENDP


ViewEntry PROC
    local @stWndClass:WNDCLASSEX  ;定义了一个结构变量，它的类型是WNDCLASSEX，一个窗口类定义了窗口的一些主要属性，图标，光标，背景色等，这些参数不是单个传递，而是封装在WNDCLASSEX中传递的。
	local @stMsg:MSG	;还定义了stMsg，类型是MSG，用来作消息传递的

	invoke GetModuleHandle, NULL  ;得到应用程序的句柄，把该句柄的值放在hInstance中，句柄是什么？简单点理解就是某个事物的标识，有文件句柄，窗口句柄，可以通过句柄找到对应的事物
	mov hInstance, eax
	invoke RtlZeroMemory, addr @stWndClass,sizeof @stWndClass  ;将stWndClass初始化全0

	;这部分是初始化stWndClass结构中各字段的值，即窗口的各种属性
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov @stWndClass.hIcon, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov @stWndClass.hCursor, eax
	mov eax, hInstance
	mov @stWndClass.hInstance, eax
	mov @stWndClass.cbSize, sizeof WNDCLASSEX
	mov @stWndClass.style, CS_HREDRAW or CS_VREDRAW
	mov @stWndClass.lpfnWndProc,offset LogProc
	mov @stWndClass.hbrBackground, COLOR_WINDOW
	mov @stWndClass.lpszClassName,offset szLogWindow
	invoke RegisterClassEx, addr @stWndClass  ;注册窗口类，注册前先填写参数WNDCLASSEX结构

	invoke CreateWindowEx, WS_EX_CLIENTEDGE,\  ;建立窗口
			offset szLogWindow,offset szLogin,\  ;szClassName和szCaptionMain是在常量段中定义的字符串常量
			WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 340, 180, \	;szClassName是建立窗口使用的类名字符串指针
			NULL,NULL,hInstance,NULL		;如果改成'button'那么建立的将是一个按钮，szCaptionMain代表的则是窗口的名称，该名称会显示在标题栏中

	invoke ShowWindow, hWinMain, SW_SHOWNORMAL  ;显示窗口
	invoke UpdateWindow, hWinMain  ;刷新窗口客户区

	.while TRUE  ;进入无限的消息获取和处理的循环
		invoke GetMessage,addr @stMsg, 0, 0, 0  ;从消息队列中取出第一个消息，放在stMsg结构中
		.break .if eax==0  ;如果是退出消息，eax将会置成0，退出循环
		invoke TranslateMessage,addr @stMsg  ;这是把基于键盘扫描码的按键 信息转换成对应的ASCII码，如果消息不是通过键盘输入的，这步将跳过
		invoke DispatchMessage,addr @stMsg  ;这条语句的作用是找到该窗口程序的窗口过程，通过该窗口过程来处理消息
	.endw
	ret
ViewEntry ENDP


LoginCallback PROC, code: DWORD
    mov eax, code
    ret
LoginCallback ENDP


RegisterCallback PROC, code: DWORD
    mov eax, code
    ret
RegisterCallback ENDP


SendTextCallback PROC, code: DWORD
    mov eax, code
    ret
SendTextCallback ENDP


AddFriendCallback PROC, code: DWORD
    mov eax, code
    ret
AddFriendCallback ENDP


NotificationListener PROC, code: DWORD
    mov eax, code
    ret
NotificationListener ENDP



END


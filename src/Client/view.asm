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

public hWinMain
.data
hInstance dd ?
hWinMain dd ?
hFont dd ?
hBrush dd ?
hListView dd ?
hUsernameEdit dd ? 
hPasswordEdit dd ? 
hSendButton dd ?
hEdit dd ?
hNewEdit dd ?
ptrCurUser dd 0
ptrUsers dd 0
ptrBuffer dd 0
strUsername db 128 DUP(0)
strPassword db 128 DUP(0)
.const
szTitle db 'Message', 0
szLogWindow db 'LogWindow',0
szLogin db 'Log in', 0
szLogon db 'Log on', 0
szUsername db 'Username', 0
szSuccess db ' success!', 0
szStatic db 'STATIC',0
szPassword db 'Password', 0
szFailed db ' failed!', 0
szEdit db 'EDIT',0
szButton db 'BUTTON',0
szClientWindow db 'ClientWindow',0
szClient db 'LetsChat', 0

debug BYTE "debug", 0dh, 0ah, 0

.code

ClientProc PROC USES ebx esi edi, hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	@DBPRINT FMT_STRING_ENDL, ADDR debug
	ret
ClientProc ENDP

ClientMain PROC  ;���ڳ���
	local @stWndClass:WNDCLASSEX  ;������һ���ṹ����������������WNDCLASSEX��һ�������ඨ���˴��ڵ�һЩ��Ҫ���ԣ�ͼ�꣬��꣬����ɫ�ȣ���Щ�������ǵ������ݣ����Ƿ�װ��WNDCLASSEX�д��ݵġ�
	local @stMsg:MSG	;��������stMsg��������MSG����������Ϣ���ݵ�

	;invoke GetModuleHandle, NULL  ;�õ�Ӧ�ó���ľ�����Ѹþ����ֵ����hInstance�У������ʲô���򵥵�������ĳ������ı�ʶ�����ļ���������ھ��������ͨ������ҵ���Ӧ������
	mov hInstance, eax
	invoke RtlZeroMemory, addr @stWndClass,sizeof @stWndClass  ;��stWndClass��ʼ��ȫ0

	;�ⲿ���ǳ�ʼ��stWndClass�ṹ�и��ֶε�ֵ�������ڵĸ�������
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov @stWndClass.hIcon, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov @stWndClass.hCursor, eax
	mov eax, hInstance
	mov @stWndClass.hInstance, eax
	mov @stWndClass.cbSize, sizeof WNDCLASSEX
	mov @stWndClass.style, CS_HREDRAW or CS_VREDRAW
	mov @stWndClass.lpfnWndProc,offset ClientProc
	mov @stWndClass.hbrBackground, COLOR_WINDOW
	mov @stWndClass.lpszClassName,offset szClientWindow
	invoke RegisterClassEx, addr @stWndClass  ; ע�ᴰ���࣬ע��ǰ����д����WNDCLASSEX�ṹ

	invoke CreateWindowEx, WS_EX_CLIENTEDGE,\  ; ��������
			offset szClientWindow,offset szClient,\  ; szClassName��szCaptionMain���ڳ������ж�����ַ�������
			WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 960, 640, \	;szClassName�ǽ�������ʹ�õ������ַ���ָ��
			NULL,NULL,hInstance,NULL		; ����ĳ�'button'��ô�����Ľ���һ����ť��szCaptionMain��������Ǵ��ڵ����ƣ������ƻ���ʾ�ڱ�������

	invoke ShowWindow, hWinMain, SW_SHOWNORMAL  ; ��ʾ����
	invoke UpdateWindow, hWinMain  ; ˢ�´��ڿͻ���

	.while TRUE  ;�������޵���Ϣ��ȡ�ʹ����ѭ��
		invoke GetMessage,addr @stMsg, 0, 0, 0  ;����Ϣ������ȡ����һ����Ϣ������stMsg�ṹ��
		.break .if eax==0  ; ������˳���Ϣ��eax�����ó�0���˳�ѭ��
		invoke TranslateMessage,addr @stMsg  ;���ǰѻ��ڼ���ɨ����İ�����Ϣת���ɶ�Ӧ��ASCII�룬�����Ϣ����ͨ����������ģ��ⲽ������
		invoke DispatchMessage,addr @stMsg  ;���������������ҵ��ô��ڳ���Ĵ��ڹ��̣�ͨ���ô��ڹ�����������Ϣ
	.endw
	ret
ClientMain ENDP


LogProc PROC USES ebx esi edi, hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD  ;���ڹ���
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hDc

	mov eax, uMsg

	.if eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax

		invoke GetClientRect, hWnd, addr @stRect
		invoke EndPaint, hWnd, addr @stPs
	
	.elseif eax == WM_CLOSE  ;���ڹر���Ϣ
		invoke DestroyWindow, hWinMain
		invoke PostQuitMessage, NULL

	.elseif eax == WM_CREATE  ;��������  ��������ʾ����һ����ť������button�ַ���ֵ��'button'�������ݶζ��壬��ʾҪ��������һ����ť��showButton��ʾ�ð�ť�ϵ���ʾ��Ϣ
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

	.elseif eax == WM_COMMAND  ;���ʱ���������Ϣ��WM_COMMAND
		mov eax, wParam  ;���в���wParam�����Ǿ������������һ����ť����wParam���Ǹ���ť�ľ��
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

			invoke DispatchLogin, addr strUsername, addr strPassword
			.if eax == 610h
				invoke DestroyWindow, hWinMain
				invoke PostQuitMessage, NULL
				invoke ClientMain
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

			invoke DispatchRegister, addr strUsername, addr strPassword
			.if eax == 610h
				invoke MessageBox, hWinMain, addr szSuccess, addr szTitle, MB_OK
			.else
				invoke MessageBox, hWinMain, addr szFailed, addr szTitle, MB_OK
			.endif
		.endif
	.else  ;����Ĭ�ϴ�����������Ϣ
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.endif
L1:
	mov eax, 0
	ret
LogProc ENDP


ViewEntry PROC
    local @stWndClass:WNDCLASSEX  ;������һ���ṹ����������������WNDCLASSEX��һ�������ඨ���˴��ڵ�һЩ��Ҫ���ԣ�ͼ�꣬��꣬����ɫ�ȣ���Щ�������ǵ������ݣ����Ƿ�װ��WNDCLASSEX�д��ݵġ�
	local @stMsg:MSG	;��������stMsg��������MSG����������Ϣ���ݵ�

	invoke GetModuleHandle, NULL  ;�õ�Ӧ�ó���ľ�����Ѹþ����ֵ����hInstance�У������ʲô���򵥵�������ĳ������ı�ʶ�����ļ���������ھ��������ͨ������ҵ���Ӧ������
	mov hInstance, eax
	invoke RtlZeroMemory, addr @stWndClass,sizeof @stWndClass  ;��stWndClass��ʼ��ȫ0

	;�ⲿ���ǳ�ʼ��stWndClass�ṹ�и��ֶε�ֵ�������ڵĸ�������
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
	invoke RegisterClassEx, addr @stWndClass  ;ע�ᴰ���࣬ע��ǰ����д����WNDCLASSEX�ṹ

	invoke CreateWindowEx, WS_EX_CLIENTEDGE,\  ;��������
			offset szLogWindow,offset szLogin,\  ;szClassName��szCaptionMain���ڳ������ж�����ַ�������
			WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 340, 180, \	;szClassName�ǽ�������ʹ�õ������ַ���ָ��
			NULL,NULL,hInstance,NULL		;����ĳ�'button'��ô�����Ľ���һ����ť��szCaptionMain��������Ǵ��ڵ����ƣ������ƻ���ʾ�ڱ�������

	invoke ShowWindow, hWinMain, SW_SHOWNORMAL  ;��ʾ����
	invoke UpdateWindow, hWinMain  ;ˢ�´��ڿͻ���

	.while TRUE  ;�������޵���Ϣ��ȡ�ʹ����ѭ��
		invoke GetMessage,addr @stMsg, 0, 0, 0  ;����Ϣ������ȡ����һ����Ϣ������stMsg�ṹ��
		.break .if eax==0  ;������˳���Ϣ��eax�����ó�0���˳�ѭ��
		invoke TranslateMessage,addr @stMsg  ;���ǰѻ��ڼ���ɨ����İ��� ��Ϣת���ɶ�Ӧ��ASCII�룬�����Ϣ����ͨ����������ģ��ⲽ������
		invoke DispatchMessage,addr @stMsg  ;���������������ҵ��ô��ڳ���Ĵ��ڹ��̣�ͨ���ô��ڹ�����������Ϣ
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


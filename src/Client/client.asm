;*********** Client Entry **********;
INCLUDE ./client.inc


.code
Main PROC
    ;LOCAL localTime: SYSTEMTIME
    .data
    sockfd       DWORD 0
    connectokMsg BYTE "[Client connect to server ok]", 0dh, 0ah, 0
    .code

    ;INVOKE GetLocalTime, ADDR localTime

    ;INVOKE DispatchConnect, ADDR defaultServerIP, defaultServerPort
    ;@EXIT_FAILED_IF_NOT_OK
    ;mov    sockfd, ebx
    ;INVOKE crt_printf, ADDR connectokMsg

    INVOKE ViewEntry
    ;INVOKE CreateThread, NULL, 0, OFFSET DealwithServerMessage, NULL, 0, NULL
    ;.IF eax == 0
        ;INVOKE Util_Exit, 1
    ;.ENDIF

    ;INVOKE DispatchLogin, ADDR user404, ADDR pswd404
    ;INVOKE DispatchLogin, ADDR user0, ADDR pswd0
    ;INVOKE DispatchLogin, ADDR user0, ADDR pswd1
    ;INVOKE DispatchRegister, ADDR user0, ADDR pswd0
    ;INVOKE DispatchRegister, ADDR user404, ADDR pswd404
    ;INVOKE DispatchDisconnect

    ;INVOKE Util_Exit, 0
    ret
Main ENDP



END Main

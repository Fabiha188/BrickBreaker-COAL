INCLUDE Irvine32.inc
INCLUDE Macros.inc

includelib Winmm.lib
PlaySoundA PROTO,
        pszSound:PTR BYTE, 
        hmod:DWORD, 
        fdwSound:DWORD


COORD STRUCT
    X WORD ? ; Column coordinate
    Y WORD ? ; Row coordinate
COORD ENDS

SMALL_RECT STRUCT
    Left WORD ?
    Top WORD ?
    Right WORD ?
    Bottom WORD ?
SMALL_RECT ENDS







    DrawPaddle MACRO x:REQ, y:REQ
    mov eax,white+(lightgray shl 4)				;set text color
    call SetTextColor
    mGotoxy x, y
    mWrite "               "
  
    ENDM

      ErasePaddle MACRO x:REQ, y:REQ
    mov eax,lightRed+(black shl 4)				;set text color
    call SetTextColor
    mGotoxy x, y
    mWrite "               "
  
    ENDM


DrawBox MACRO x:REQ, y:REQ, width:REQ, height:REQ, color:REQ, outlineColor:REQ
    local heightLoop, outlineTopBottom, drawRow

    push eax
    push ecx
    push edx
    push ebx

    ; Set outline color for top and bottom
    mov eax, outlineColor
    shl eax, 4                          ; Multiply by 16 for background
    add eax, outlineColor               ; Add background color
    call SetTextColor

    ; Draw top outline
                      
    mGotoxy x, y                       ; Go to x, y (top row)
    mWriteSpace width+2                ; Draw top line

    ; Set interior color
    mov eax, color
    shl eax, 4
    add eax, color
    call SetTextColor

    ; Draw interior with outline on the sides
    mov ecx, height                     ; Set height loop counter
    dec ecx                             ; Top and bottom rows are handled separately
    xor ebx, ebx
    mov bl, y
    inc bl                              ; Move to the row below the top outline

heightLoop:
    mGotoxy x, bl                       ; Go to x, y (current row)
    ; Draw left outline
    mov eax, outlineColor
    shl eax, 4
    add eax, outlineColor
    call SetTextColor
    mWrite "  "                          ; Draw left outline character

    ; Draw interior spaces
    mov eax, color
    shl eax, 4
    add eax, color
    call SetTextColor
    mWriteSpace width-2                     ; Draw interior spaces

    ; Draw right outline
    mov eax, outlineColor
    shl eax, 4
    add eax, outlineColor
    call SetTextColor
    mWrite "  "                          ; Draw right outline character

    inc bl                              ; Move to next row
    loop heightLoop                     ; Repeat until height is done

    ; Draw bottom outline
    mov eax, outlineColor
    shl eax, 4
    add eax, outlineColor
    call SetTextColor
    mov bl, y
    add bl, height - 1                  ; Bottom row: y + height - 1
    mGotoxy x, bl                       ; Go to bottom row
    mWriteSpace width                     ; Draw bottom line

    ; Reset the color to default (light gray text on black background)
    mov eax,white+(black shl 4)
    call SetTextColor
    pop ebx
    pop edx
    pop ecx
    pop eax
ENDM




.data

; sound k lie 
SND_ALIAS    DWORD 00010000h
SND_RESOURCE DWORD 00040005h
SND_FILENAME DWORD 00002000h


; screen sizing
SCREEN_WIDTH EQU 120
SCREEN_HEIGHT EQU 30
hConsoleOutput DWORD ?
bufferSize COORD <SCREEN_WIDTH, SCREEN_HEIGHT>
smallRect SMALL_RECT <0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1>




playerName BYTE 10 DUP(?)
nameMsg BYTE "What's your name?  ",0
arrow BYTE '+',0
arrowX BYTE ?
arrowY BYTE ?
lives BYTE 6
score DWORD 0
ballX BYTE 62  ; initial x position of the ball
ballY BYTE 24   ; initial y position of the ball
ballDx BYTE 1  ; right (x increases when moving right on the screen))
ballDy BYTE -1  ; up (y decreases when moving up the screen))
ballSpeed DWORD ? ; the delay/milliseconds btwn ball's movements
paddleX BYTE 55 ; initial x position of the paddle
paddleY BYTE 26 ; y position of the paddle
paused BYTE 0 ; game paused flag (0 = not paused, 1 = paused)
BRICKS_ROWS EQU 3
BRICKS_PER_ROW EQU 7
BRICK_WIDTH EQU 14
BRICK_HEIGHT EQU 1
BRICK_STEP EQU 15
bricksStatus BYTE BRICKS_ROWS * BRICKS_PER_ROW DUP(1) ; 0 for break, 1for level1,2 for level2, 3 for level3 varying with breaking power
endKeyPressed BYTE 0
difficulty BYTE ? ;  1:easy, 2:medium, 3:hard, 0: mainmeniu pe wapis
playAgain BYTE ?  ; 0 for no, 1 for yes
currentLevel BYTE 1 ; got 3levels 
levelCleared BYTE 0
highestScore DWORD 0



JumpSound BYTE "Jumping.wav",0
bgMusic BYTE "gameMusic.wav",0
levelUp BYTE "final.wav",0
negative BYTE "NegativeGuitar.wav",0
lose BYTE "LoseFail.wav",0
menuSelect BYTE "select.wav",0
hitSound BYTE "ballHit.wav",0
winSound BYTE "win.wav",0








 wlcm1 byte                        "__        __     _                                _____      ",0
 wlcm2 byte                        "\ \      / /___ | |  ___  ___   _ __ ___    ___  |_   _|___  ",0
 wlcm3 byte                        " \ \ /\ / // _ \| | / __|/ _ \ | '_ ` _ \  / _ \   | | / _ \ ",0
 wlcm4 byte                        "  \ V  V /|  __/| || (__| (_) || | | | | ||  __/   | || (_) |",0
 wlcm5 byte                        "   \_/\_/  \___||_| \___|\___/ |_| |_| |_| \___|   |_| \___/ ",0
                                                              

 
intro1 byte      " ____         _        _      ____                    _",0               
intro2 byte      "|  _ \       (_)      | |    |  _ \                   | |",0              
intro3 byte      "| |_) | _ __  _   ___ | | __ | |_) | _ __ ___   __ _  | | __ ___   _ __",0 
intro4 byte      "|  _  || '__|| | / __|| |/ / |  _ || '__|/ _ \ /  _` || |/ // _ \| '__|",0
intro5 byte      "| |_) || |   | || (__ |   |  | |_) || |  | __/ | (_| ||    |  __/| |",0   
intro6 byte      "|____/ |_|   |_| \___||_|\_\ |____/ |_|   \___| \__,_||_|\_\\___||_|",0   
		
menu1 BYTE " __  __    _    ___ _   _      __  __ _____ _   _ _   _ ",0
menu2 BYTE "|  \/  |  / \  |_ _| \ | |    |  \/  | ____| \ | | | | |",0
menu3 BYTE "| |\/| | / _ \  | ||  \| |    | |\/| |  _| |  \| | | | |",0
menu4 BYTE "| |  | |/ ___ \ | || |\  |    | |  | | |___| |\  | |_| |",0
menu5 BYTE "|_|  |_/_/   \_\___|_| \_|    |_|  |_|_____|_| \_|\___/ ",0


                
inst1 byte " ___              _                       _    _                    ",0
inst2 byte "|_ _| _ __   ___ | |_  _ __  _   _   ___ | |_ (_)  ___   _ __   ___ ",0
inst3 byte " | | | '_ \ / __|| __|| '__|| | | | / __|| __|| | / _ \ | '_ \ / __|",0
inst4 byte " | | | | | |\__ \| |_ | |   | |_| || (__ | |_ | || (_) || | | |\__ \",0
inst5 byte "|___||_| |_||___/ \__||_|    \__,_| \___| \__||_| \___/ |_| |_||___/",0

gmovr1 byte "  ____     _     __  __  _____       ___ __     __ _____  ____  ",0
gmovr2 byte " / ___|   / \   |  \/  || ____|     / _ \\ \   / /| ____||  _ \ ",0
gmovr3 byte "| |  _   / _ \  | |\/| ||  _|      | | | |\ \ / / |  _|  | |_) |",0
gmovr4 byte "| |_| | / ___ \ | |  | || |___     | |_| | \ V /  | |___ |  _  | ",0
gmovr5 byte " \____|/_/   \_\|_|  |_||_____|     \___/   \_/   |_____||_| \_\",0

 hghs1 byte " _   _  _         _      ____                              ",0
 hghs2 byte "| | | |(_)  __ _ | |__  / ___|   ___  ___   _ __  ___  ___ ",0
 hghs3 byte "| |_| || | / _` || '_ \ \___ \  / __|/ _ \ | '__|/ _ \/ __|",0
 hghs4 byte "|  _  || || (_| || | | | ___) || (__| (_) || |  |  __/\__ \",0
 hghs5 byte "|_| |_||_| \__, ||_| |_||____/  \___|\___/ |_|   \___||___/",0
 hghs6 byte "           |___/                                           ",0

 winner1 BYTE "__        __ ___ _   _ _   _ _____ ____  ",0
winner2 BYTE " \ \      / /|_ _| \ | | \ | | ____|  _ \ ",0
winner3 BYTE "  \ \ /\ / /  | ||  \| |  \| | |___| |_) |",0
winner4 BYTE "   \ V  V /   | || |\  | |\  | |___|  _ |",0
winner5 BYTE "    \_/\_/   |___|_| \_|_| \_|_____|_| \_\",0




.code

; bhaee screen sizing horhi hai
SetFixedConsoleSize PROC

INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hConsoleOutput, eax
    INVOKE SetConsoleScreenBufferSize, hConsoleOutput, bufferSize
    mov al,1
    INVOKE SetConsoleWindowInfo, hConsoleOutput, al, ADDR smallRect

   ret
SetFixedConsoleSize ENDP


PlaySoundRelative PROC, soundFile:PTR BYTE

pushad
    INVOKE PlaySoundA, soundFile, NULL, 20001h  ; SND_ASYNC + SND_FILENAME

popad

    ret
PlaySoundRelative ENDP


StopSound PROC
    INVOKE PlaySoundA, NULL, NULL, 0
    ret
StopSound ENDP





; welcome+mainmenu or aghe ka sara loop

Screen1 PROC

INVOKE PlaySoundRelative,ADDR bgMusic   ; address of bgmusic(PTR Required)

DrawBox 0,0,118,30,black,black ; macro func


 

mov eax,Red+(black shl 4)				;set text color
call SetTextColor


    mGotoxy 25,8
    mov eax, 200
         call Delay
    mWriteString wlcm1
    mov eax,lightcyan+(black shl 4)				;set text color
call SetTextColor
    mGotoxy 25,9
    mov eax,200
         call Delay
    mWriteString wlcm2
    mGotoxy 25,10
             call Delay
    mWriteString wlcm3
    mGotoxy 25,11
             call Delay
    mWriteString wlcm4
    mGotoxy 25,12
             call Delay
    mWriteString wlcm5
    mGotoxy 25,13
             call Delay
    mWriteString intro1
    mGotoxy 25,14
             call Delay
    mWriteString intro2
    mGotoxy 25,15
             call Delay
    mWriteString intro3
    mGotoxy 25,16
             call Delay
    mWriteString intro4
    mGotoxy 25,17
             call Delay
    mWriteString intro5
    mGotoxy 25,18
             call Delay
             mov eax,red+(black shl 4)				;set text color
call SetTextColor
    mWriteString intro6
    mgotoxy 45,21
    mov eax,yellow+(black shl 4)				;set text color
call SetTextColor
    mwrite"Press Any Key to Play!"
    call readchar
    call clrscr

    DrawBox 0,0,118,30,yellow,yellow

    mGotoxy 50,14
             mov eax,black+(yellow shl 4)				;set text color

    call SetTextColor
    mwriteString nameMsg
    mGotoxy 42,16
    mov eax,red+(white shl 4)				;set text color

    call SetTextColor
    mwrite"                                   "


    nameLoop:
           mGotoxy 54, 16

     mov eax,red+(white shl 4)
    call SetTextColor
    mReadString playerName,10
    cmp eax,0
    jne valid
    mgotoxy 35, 18
    mov eax,red+(yellow shl 4)
    call SetTextColor
    mwrite "Error: Enter Name First! Press Any Key to Continue..."
    call ReadChar
    mov eax,white+(yellow shl 4)
    call SetTextColor
    mGotoxy 35,18
    mWrite "                                                     "
    
    
    
    mGotoxy 54,16
    jmp nameLoop

    valid:
     mov eax,lightRed+(white shl 4)
    call SetTextColor
    call clrscr

    call StopSound
    
    gotoMenu:

                 INVOKE PlaySoundRelative,ADDR bgMusic
    DrawBox 0,0,118,30,black,black
     mov eax,lightcyan+(black shl 4)				;set text color
     call SetTextColor

           mov eax,300

     mGotoxy 35,8
     call Delay
     mWriteString menu1
     mGotoxy 35,9
     
       call Delay

     mWriteString menu2
     mGotoxy 35,10
     call Delay
     mWriteString menu3
     mGotoxy 35,11
     call Delay
     mWriteString menu4
     mGotoxy 35,12
     call Delay
  
     mWriteString menu5
     
     mov eax,yellow+(black shl 4)				;set text color
     call SetTextColor
     mGotoxy 55,15
     call Delay
     mWrite "Start Game"
     mGotoxy 55,17
      call Delay
     mwrite "Instructions"
     mGotoxy 55,19
     call Delay
     mwrite "HighScores"
     
     mGotoxy 55,21
         call Delay

     mwrite "Exit"

     mov arrowX,52
     mov arrowY,15
     mGotoxy arrowX,arrowY
     mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     mwriteString arrow
     mGotoxy 50,24

     menuLoop: ; arrow ki position change hori hai 
          
     call ReadChar
     cmp al, 'w'
     je moveUp
     cmp al, 's'
     je moveDown
     cmp al, 0DH ; enter
     je selectOption
     jmp menuLoop

     moveUp:
     call StopSound
     INVOKE PlaySoundRelative,ADDR menuSelect
     mov al,arrowY
     cmp al,15
  
     je menuLoop
     mov eax,lightRed+(black shl 4)				;set text color
     call SetTextColor
       mgotoxy arrowX,arrowY
     mwrite " "
     sub byte ptr [arrowY],2
   
   mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     mGotoxy arrowX,arrowY
     mwriteString arrow
     mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     jmp menuLoop

     moveDown:
     call StopSound
          INVOKE PlaySoundRelative,ADDR menuSelect
     mov al,arrowY
     cmp al,21
     
     je menuLoop	
     mov eax,lightRed+(black shl 4)				;set text color
     call SetTextColor
     mgotoxy arrowX,arrowY
     mwrite " "
     add byte ptr [arrowY],2
     
     mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     mGotoxy arrowX,arrowY
     mwriteString arrow
     mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     jmp menuLoop

     selectOption:
     cmp arrowY,15
     je startGame
     cmp arrowY,17
     je showInstructions
     cmp arrowY,19
     je showHighScores
     cmp arrowY,21
     je exitGame
     jmp menuLoop

     startGame:
               INVOKE PlaySoundRelative,ADDR jumpSound
     call DifficultyScreen
     cmp difficulty, 0
     je gotoMenu
       cmp difficulty,1
     je easy
     cmp difficulty,2
     je med
     cmp difficulty,3
     je hard

     easy:
     mov ballSpeed,60
     jmp game

     med:
     mov ballSpeed,45
     jmp game

     hard:
     mov ballSpeed,35
     jmp game

     game:
   
   
     DrawBox 0,0,118,30,black,gray

     mov paused,0
     mov lives,6
     mov score,0
     mov paddleX, 55
     mov paddleY, 26
     mov ballX, 62
     mov ballY, 24
     mov ballDx, 1
     mov ballDy, -1

     mov currentLevel,1
    call ResetBricks
    call setBrickPower

    LevelLoop:
    call levelGame
    cmp levelCleared,1
    jne GameEnded
    inc currentLevel
    cmp currentLevel,3
    jle NextLevel
    mov currentLevel,1
    call WinningScreen
    jmp GameEnded

    NextLevel:

    call EraseLevelCompleted
    ErasePaddle paddleX,paddleY

    cmp currentLevel, 3
    je incLives
   

     reset:

    mov paddleX, 55
    mov paddleY, 26
    mov ballX, 62
    mov ballY, 24
    mov ballDx, 1
    mov ballDy, -1
    call ResetBricks
    call setBrickPower
    mov levelCleared, 0
    jmp LevelLoop

    
     incLives:
    inc lives
    jmp reset

    GameEnded:
    jmp gotoMenu
     

     showInstructions:
               INVOKE PlaySoundRelative,ADDR jumpSound
     DrawBox 0,0,118,30,black,gray
     mov eax,yellow+(black shl 4)				;set text color
     call SetTextColor
     mgotoxy 30,5
     mWriteString inst1
     mGotoxy 30,6
      mWriteString inst2
      mGotoxy 30,7
      mWriteString inst3
      mGotoxy 30,8
      mWriteString inst4
      mGotoxy 30,9
      mWriteString inst5
      mov eax,brown+(black shl 4)	;set text color
      call SetTextColor

      mgotoxy 40,12
      mWrite "1. Use 'A'to move paddle to left!"
      mgotoxy 40,14
      mWrite "2. Use 'D'to move paddle to right!"
      mgotoxy 40,16
      mWrite "3. Press 'S' to pause/resume the game!"
      mgotoxy 40,18
      mWrite "4. Press 'E' to end the game!"
      mov eax,white+(gray shl 4)				;set text color
      call SetTextColor
      mGotoxy 40,22
      mWrite "  Press any key to return to menu  "
      call ReadChar
                     INVOKE PlaySoundRelative,ADDR jumpSound

      jmp gotoMenu


     showHighScores:
               INVOKE PlaySoundRelative,ADDR jumpSound
               call highScoreScreen
     jmp gotoMenu

     exitGame:
                    INVOKE PlaySoundRelative,ADDR jumpSound
     INVOKE ExitProcess, 0 
      ret

      mov eax,lightRed+(white shl 4)				;set text color
      call SetTextColor
      ret

Screen1 ENDP


DrawBall PROC, x:BYTE, y:BYTE, color:DWORD
    mov eax, color
    call SetTextColor
    mGotoxy x, y
    mWrite "0"
    mov eax, yellow+(black shl 4) ; Reset to default color
    call SetTextColor
    ret
DrawBall ENDP


LevelGame PROC

push ebp
mov ebp,esp
pushad

mov levelCleared,0



    mov eax,yellow+(black shl 4)				;set text color
    call SetTextColor
    mgotoxy 5,2
    mwrite "Level:"
    movzx eax, currentLevel
    call WriteDec
    mgotoxy 50,2
    mwrite "Lives: "
    movzx eax,lives
    call WriteDec
    mgotoxy 90,2
    mwrite "Score: "
    mov eax,score
    call WriteDec

    DrawPaddle paddleX,paddleY
     mov eax,yellow+(black shl 4)				;set text color
    call SetTextColor
    mgotoxy 10,5
    call DrawBlockRows
    invoke DrawBall, ballX, ballY, white+(black shl 4)
    mgotoxy 50,28

    gameLoop:
    call ReadKeyIfAny
    cmp endKeyPressed,1
    je endLevel
    

   
    cmp paused,1
    je gameLoop
    call moveBall ; main procedure
    mov eax, ballSpeed
    call Delay
    cmp levelCleared,1
    je endLevel
    cmp lives,0
    jne gameLoop
    call GameOver
    jmp endLevel

    mov eax,yellow+(black shl 4)				;set text color
    call SetTextColor

    endLevel:
    mov endKeyPressed,0
    popad
    pop ebp
    ret

  
   
   
    
LevelGame ENDP

DrawBlock PROC, x_axis:BYTE, y_axis:BYTE, textcolor:DWORD
    LOCAL temp:DWORD        ; Declare local variable

    mov ebx, BRICK_WIDTH            ; Block width (14 spaces)
    mov temp, ebx           ; Copy loop counter into temp
    mov eax, textcolor      ; Set block color
    call SetTextColor

block_loop:
   mgotoxy x_axis, y_axis ; 

    mov al, ' '             ; Write space character for block
    call WriteChar

    inc x_axis              ; Move to the next column
    dec temp                ; Decrement loop counter
    cmp temp, 0             ; Check if done
    jne block_loop          ; Continue if temp != 0

    mov eax, lightred+(black shl 4) ; Reset to default color
    call SetTextColor
    ret
DrawBlock ENDP


DrawBlockRows PROC
    LOCAL x_axis:BYTE
    LOCAL y_axis:BYTE

    mov x_axis, 10          ; Initial X position for first block
    mov y_axis, 5           ; Initial Y position for first row

    ; Draw Row 1
    mov ecx, BRICKS_PER_ROW              ; Number of blocks in a row
row1_loop:
    invoke DrawBlock, x_axis, y_axis, white+(magenta shl 4)
    add x_axis,  BRICK_STEP        ; Move to the next block
    loop row1_loop

    ; Draw Row 2
    mov x_axis, 10          ; Reset X position for second row
    mov al, y_axis; Move down to the next row
    add al,2
    mov y_axis, al
    mov ecx, BRICKS_PER_ROW
row2_loop:
    invoke DrawBlock, x_axis, y_axis,  white+(yellow shl 4)
    add x_axis, BRICK_STEP
    loop row2_loop

    ; Draw Row 3
    mov x_axis, 10          ; Reset X position for third row
    mov al, y_axis              ; Move down to the next row
    add al,2
    mov y_axis, al
    mov ecx, BRICKS_PER_ROW
row3_loop:
    invoke DrawBlock, x_axis, y_axis,  white+(green shl 4)
    add x_axis, BRICK_STEP
    loop row3_loop

    ret
DrawBlockRows ENDP

moveBall PROC
    mov eax, white+(black shl 4)
    call SetTextColor
    mGotoxy ballX, ballY
    mwrite " "  ; erase current ball

    mov al, ballX
    add al, ballDx
    mov ballX, al

    mov al, ballY
    add al, ballDy
    mov ballY, al

    ; Check for wall collisions
    ; Left wall
    cmp ballX, 1
    jne checkRightWall
    mov ballX,2
    neg ballDx
    jmp checkTopWall

checkRightWall:
    cmp ballX, 117
    jne checkTopWall
    mov ballX,116
    neg ballDx
    jmp checkTopWall

checkTopWall:
    cmp ballY, 4
    jne checkBottomWall
    mov ballY,5
    neg ballDy
    jmp checkPaddleCollision


checkBottomWall:
    cmp ballY, 28
    jne checkPaddleCollision
    ; Ball missed the paddle
                   INVOKE PlaySoundRelative,ADDR negative
    dec lives
    mov eax, yellow+(black shl 4)
    call SetTextColor
    mGotoxy 50,2
    mwrite "Lives: "
    movzx eax,lives
    call WriteDec
    ; Reset ball position (reset paddle ki position pr hona chaiye paddlex or ballx mn 7 ka difference hai or paddley or bally mn 2 ka so )

    mov al, paddleX
    add al,7
    mov ballX, al
    mov al,paddleY
    sub al,2
    mov ballY, al
mov ballDx,1
mov ballDy, -1
    jmp RedrawBall

checkPaddleCollision:
    mov al,ballY
    cmp al, paddleY
    jne DoBrickCollision

    mov al,ballX
    cmp al, paddleX
    jl DoBrickCollision
    mov al, paddleX
    add al, 15
    cmp al, ballX
    jl DoBrickCollision
    neg ballDy
    jmp RedrawBall

DoBrickCollision:
    call BrickCollision

RedrawBall:
    invoke DrawBall, ballX, ballY, white+(black shl 4)
    ret

moveBall ENDP

BrickCollision PROC

    pushad
    mov esi, offset bricksStatus
    xor edi,edi
    mov bh, 5; y
    mov bl,10; x 

    mov ecx, BRICKS_ROWS ; 3 rows

RowLoop:
    push ecx
    mov ecx, BRICKS_PER_ROW ; 7
    mov bl,10 ; x 

BrickLoop:

    mov al, [esi + edi]

    cmp al,0 
    jle skipBrick

    mov al, ballY
    cmp al,bh
    jl skipBrick
    mov dl,bh
    add dl, BRICK_HEIGHT
    cmp al,dl
    jge skipBrick

    mov al, ballX
    cmp al, bl
    jl skipBrick

    mov dl, bl
    add dl, BRICK_WIDTH
    cmp al, dl
    jge skipBrick

    INVOKE PlaySoundRelative, ADDR hitSound
    ; Collision detected x or y fono equal hyn 
    ; Update brick status
    dec byte ptr [esi+edi]
    mov al, byte ptr [esi+edi]
    cmp al,0
    jg stillAlive

   
    mov eax, yellow+( black shl 4)
    call SetTextColor

    label1:
    push ebx
    push ecx

    mov dl,bl
    mov ecx, BRICK_WIDTH

EraseBrickLoop:
    mGotoxy dl, bh
    mwrite " "
    inc dl
    loop EraseBrickLoop

    pop ecx
    pop ebx

    call CheckLevelClear
   

stillAlive:

  
    neg ballDy

    mov eax, score
   add score,5
    mGotoxy 97,2
    mov eax, score
    call writeDec

    jmp nextBrick

skipBrick:
    inc edi
    add bl, BRICK_STEP

nextBrick:
    dec ecx
    jnz BrickLoop

    pop ecx
    add bh,2    
    mov bl,10
    dec ecx
    jnz RowLoop

    popad
    ret
BrickCollision ENDP


ReadKeyIfAny PROC

call ReadKey
jz noKeyPressed

cmp al, 'e'
je finish
cmp al, 'E'
je finish

cmp al, 'a'
je movePaddleLeft
cmp al, 'A'
je movePaddleLeft
cmp al, 'd'
je movePaddleRight
cmp al, 'D'
je movePaddleRight
cmp al, 's'
je TogglePause
cmp al, 'S'
je TogglePause


ret

movePaddleLeft:
ErasePaddle paddleX, paddleY
sub paddleX,2
cmp paddleX,2
jge paddleLeftDraw
mov paddleX,2
paddleLeftDraw:
DrawPaddle paddleX, paddleY
jmp noKeyPressed

movePaddleRight:
ErasePaddle paddleX,paddleY
add paddleX,2
cmp paddleX,103
jle paddleRightDraw
mov paddleX,103
paddleRightDraw:
DrawPaddle paddleX, paddleY
jmp noKeyPressed

TogglePause:
cmp paused,0
je pauseScreen
mov paused,0
call ErasePauseScreen
jmp noKeyPressed

pauseScreen:
mov paused,1
call PauseBox

noKeyPressed:
ret

finish:
mov endKeyPressed,1
jmp noKeyPressed

ReadKeyIfAny ENDP


PauseBox PROC

DrawBox 45,12,30,8,black,black
 
 mov eax, blue+(black shl 4)
call SetTextColor
mgotoxy 55,15
mWrite "Game Paused!"
mov eax, red+(black shl 4)
call SetTextColor
mgotoxy 52,16
mwrite " (Press S to resume) "

ret
PauseBox ENDP

ErasePauseScreen PROC
               INVOKE PlaySoundRelative,ADDR jumpSound

mov eax, yellow+(black shl 4)
call setTextColor

mov ecx,8
mov dh,12

EraseLoop:
mgotoxy 45, dh
mWrite "                                "
inc dh
loop EraseLoop
ret
ErasePauseScreen ENDP


ResetBricks PROC
    mov al, currentLevel
    mov ecx, BRICKS_ROWS * BRICKS_PER_ROW
    mov esi, offset bricksStatus
SetLoop:
    mov byte ptr [esi], al
    inc esi
    loop SetLoop
    ret
ResetBricks ENDP

DifficultyScreen PROC


    DrawBox 0,0,118,30,black,black
     mov eax,lightcyan+(black shl 4)				;set text color
     call SetTextColor

     mGotoxy 35,8
     mWriteString menu1
     mGotoxy 35,9
     mWriteString menu2
     mGotoxy 35,10
     mWriteString menu3
     mGotoxy 35,11
     mWriteString menu4
     mGotoxy 35,12
     mWriteString menu5


       mov eax,yellow+(black shl 4)				;set text color
     call SetTextColor
     mGotoxy 55,15
     mWrite "Easy"
     mGotoxy 55,17
     mwrite "Medium"
     mGotoxy 55,19
     mwrite "Hard"
     mGotoxy 55,21
     mwrite "Back to Main Menu"
   
     mov arrowX,52
     mov arrowY,15
     mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     mGotoxy arrowX,arrowY
     mwriteString arrow
     mGotoxy 50,24

     menuLoop:
     call ReadChar
     cmp al, 'w'
     je moveUp
     cmp al, 's'
     je moveDown
     cmp al, 0DH
     je selectOption
     jmp menuLoop

     moveUp:
               INVOKE PlaySoundRelative,ADDR menuSelect
     mov al,arrowY
     cmp al,15
  
     je menuLoop
     mov eax,lightRed+(black shl 4)				;set text color
     call SetTextColor
       mgotoxy arrowX,arrowY
     mwrite " "
     sub byte ptr [arrowY],2
   
   mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     mGotoxy arrowX,arrowY
     mwriteString arrow
     
     jmp menuLoop

     moveDown:
               INVOKE PlaySoundRelative,ADDR menuSelect
     mov al,arrowY
     cmp al,21
     
     je menuLoop	
     mov eax,lightRed+(black shl 4)				;set text color
     call SetTextColor
     mgotoxy arrowX,arrowY
     mwrite " "
     add byte ptr [arrowY],2
     
     mov eax,lightRed+(white shl 4)				;set text color
     call SetTextColor
     mGotoxy arrowX,arrowY
     mwriteString arrow
     
     jmp menuLoop

     selectOption:
     cmp arrowY,15
     je easySelected
     cmp arrowY,17
     je mediumSelected
     cmp arrowY,19
     je hardSelected
     cmp arrowY,21
     je back

     easySelected:
               INVOKE PlaySoundRelative,ADDR jumpSound
     mov difficulty,1
     ret

     mediumSelected:
               INVOKE PlaySoundRelative,ADDR jumpSound
     mov difficulty,2
     ret

     hardSelected:
               INVOKE PlaySoundRelative,ADDR jumpSound
     mov difficulty,3
     ret

     back:
                    INVOKE PlaySoundRelative,ADDR jumpSound
     mov difficulty, 0
     ret


DifficultyScreen ENDP

GameOver PROC

mov eax, score
cmp eax,highestScore
jle Skip
mov highestScore, eax
Skip:

               INVOKE PlaySoundRelative,ADDR lose

 DrawBox 0,0,118,30,black,black
     mov eax,red+(black shl 4)				;set text color
     call SetTextColor

      mGotoxy 30,11
     mWriteString gmovr1
     mGotoxy 30,12
     mWriteString gmovr2
     mGotoxy 30,13
     mWriteString gmovr3
     mGotoxy 30,14
     mWriteString gmovr4
     mGotoxy 30,15
     mWriteString gmovr5

     mgotoxy 46, 19
     mov eax, yellow+(black shl 4)
     call setTextcolor
     mwrite "Do you want to play again? "
     mgotoxy 56,21
     mwrite "Yes"
     mgotoxy 56,23
     mwrite "No"
     mov arrowX, 53
     mov arrowY,21
     mgotoxy arrowX, arrowY
     mwriteString arrow

     choice:
     call ReadChar
     cmp al, 'w'
     je moveUp
     cmp al, 'd'
     je moveDown
     cmp al, 0DH
     je select

     moveUp:
               INVOKE PlaySoundRelative,ADDR menuSelect
     mov al,arrowY
     cmp al,21
  
     je choice
     mov eax,white+(black shl 4)				;set text color
     call SetTextColor
       mgotoxy arrowX,arrowY
     mwrite " "
     sub byte ptr [arrowY],2
   
   
     mGotoxy arrowX,arrowY
     mwriteString arrow
     mov eax,white+(black shl 4)				;set text color
     call SetTextColor
     jmp choice

     moveDown:
               INVOKE PlaySoundRelative,ADDR menuSelect
     mov al,arrowY
     cmp al,23
     
     je choice	
     mov eax,white+(black shl 4)				;set text color
     call SetTextColor
     mgotoxy arrowX,arrowY
     mwrite " "
     add byte ptr [arrowY],2
     
     
     mGotoxy arrowX,arrowY
     mwriteString arrow
     mov eax,white+(black shl 4)				;set text color
     call SetTextColor
     jmp choice

     select:
     cmp arrowY, 21
     je goBack
     cmp arrowY,23
     je over

     goBack:
     INVOKE PlaySoundRelative,ADDR jumpSound
     ret

     over:
     INVOKE ExitProcess,0
     ret

GameOver ENDP

setBrickPower PROC

pushad
mov ecx, BRICKS_ROWS * BRICKS_PER_ROW
mov esi, offset bricksStatus
mov al, currentLevel

fillLoop:
mov [esi],al
inc esi
loop fillLoop

popad
ret

setBrickPower ENDP

CheckLevelClear PROC
pushad


mov esi,offset bricksStatus
mov ecx, BRICKS_ROWS * BRICKS_PER_ROW

CheckLoop:
mov al,[esi]
cmp al,0
jg NotClear
inc esi
loop CheckLoop


mov levelCleared,1
call ShowLevelCompleted

NotClear:
popad
ret

CheckLevelClear ENDP

ShowLevelCompleted PROC

pushad
               INVOKE PlaySoundRelative,ADDR levelUp
DrawBox 40,12,40,6,brown,brown
mov eax, black+(brown shl 4)
call SetTextColor

mgotoxy 52,14
mwrite "Level Completed!"
mgotoxy 46,15
mwrite "Press Any Key to Continue..."
call ReadChar
popad
ret

ShowLevelCompleted ENDP

EraseLevelCompleted PROC

pushad
mov eax, yellow+(black shl 4)
call SetTextColor

mov ecx, 6
mov dh,12

L1:
mgotoxy 40,dh
 mWrite "                                           "
 inc dh
 loop L1

 popad
 ret
 
 EraseLevelCompleted ENDP


 highScoreScreen PROC

  DrawBox 0,0,118,30,black,gray
     mov eax,yellow+(black shl 4)				;set text color
     call SetTextColor

     mGotoxy 35,8
     mWriteString hghs1
     mGotoxy 35,9
     mWriteString hghs2
     mGotoxy 35,10
     mWriteString hghs3
     mGotoxy 35,11
     mWriteString hghs4
     mGotoxy 35,12
     mWriteString hghs5
     mGotoxy 35,13
     mWriteString hghs6
     mGotoxy 45,15


      mov eax,brown+(black shl 4)				;set text color
     call SetTextColor

     mWrite "Player Name: "
     mwriteString playerName
     mgotoXy 45, 17
     mwrite "Your Last Score: "
     mov eax, score
     call writeDec

     mgotoxy 45, 18
     mwrite "Highest Score (Current Session Only): "
     mov eax, highestScore
     call WriteDec

     mgotoxy 45,21
      mov eax,white+(gray shl 4)				;set text color
     call SetTextColor

     mwrite "  Press Any Key to Continue...  "
     call ReadChar
     

     ret

  highScoreScreen ENDP

  LoadingScreen PROC

    DrawBox 0,0,118,30,black,black
     mov eax,black+(brown shl 4)				;set text color
     call SetTextColor
    
     mgotoxy 15,15
      mov eax, 200
     call Delay
     mwrite "                                       Loading Game.....                                      "
     mov eax, white+ (black shl 4)
     call  Settextcolor
     mgotoxy 43, 21
     mwrite "This may take a several seconds..."

     mov eax, 3000
     call Delay
     call clrscr
     ret

  LoadingScreen ENDP

  WinningScreen PROC

  INVOKE PlaySoundRelative, ADDR winSound

   DrawBox 0,0,118,30,black,black
     mov eax,red+(black shl 4)				;set text color
     call SetTextColor

      mGotoxy 35,11
     mWriteString winner1
     mGotoxy 35,12
     mWriteString winner2
     mGotoxy 35,13
     mWriteString winner3
     mGotoxy 35,14
     mWriteString winner4
     mGotoxy 35,15
     mWriteString winner5
     mGotoxy 35,19
     mov eax, yellow+(black shl 4)
     call setTextColor
     call waitMsg
     call ReadChar
     INVOKE PlaySoundRelative, ADDR JumpSound
     ret


  WinningScreen ENDP


main PROC

call SetFixedConsoleSize
;call LoadingScreen
call Screen1

exit
main ENDP
END main 
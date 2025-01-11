#SingleInstance, Off
#KeyHistory, 0
#NoEnv
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
CoordMode, Pixel, Screen
ListLines, Off
Process, Priority, , High
SetDefaultMouseSpeed, 0
SetControlDelay, -1
SetBatchLines, -1
SetMouseDelay, -1
SetKeyDelay, -1
SetWinDelay, -1
#MaxThreads 255
#MaxThreadsPerHotkey 255
#MaxHotkeysPerInterval 2147483647
#Persistent
flag = 1

Loop, %0%  ; 연결/드롭 파일 확인
{
    filedropped .= %A_Index% " "
}

;#############################################################################

appname = P23's FlowQuill
appversion = 0.6.0
appbuilddate = 2025년 1월 11일
appupdatedetails = `n*ImageSearch 탭 추가`n　이미지 찾기 기능이 추가되었습니다.`n*트레이 아이콘 기능 추가`n　트레이 아이콘으로 최소화하는 기능을 추가했습니다.`n*스크립트 저장 에러 핸들링 개선`n　기존에 기존 파일을 확인하지 않고 그대로 새 내용을`n　작성하던 문제 수정.`n　권한 부족으로 인한 저장 실패 메시지 추가.`n*'클릭하여 위치 기록' 개선`n　기존의 가시성이 떨어졌던 위치 기록을 개선했습니다.`n*주요 GUI 요소 변경`n　스크립트 시작/중단 버튼을 추가했습니다.`n　그 외 몇 가지 버튼 배열 수정.`n*ImageSearch 탭 관련 문서 연결 버튼 추가`n　Info -> ImageSearch 문서에서 찾을 수 있습니다.`n*몇몇 오탈자 수정

listvar := {}

RegRead, winX, HKCU, SOFTWARE\P23Soft\%appname%, winX
RegRead, winY, HKCU, SOFTWARE\P23Soft\%appname%, winY
if (winX = "" || winY = "")
{
	winX = 0
	winY = 0
	RegWrite, REG_DWORD, HKCU, SOFTWARE\P23Soft\%appname%, winX, %xts%
	RegWrite, REG_DWORD, HKCU, SOFTWARE\P23Soft\%appname%, winY, %xty%
}

;#############################################################################

Menu, Tray, NoStandard
Menu, Tray, Tip, %appname% 메뉴 열기 (%A_Hour%-%A_Min%-%A_Sec%)
Menu, Tray, Add, 메인 창 열기, GuShow
Menu, Tray, Add
Menu, Tray, Add, 매크로 저장, SaveMacro
Menu, Tray, Add, 매크로 불러오기, LoadMacro
Menu, Tray, Add
Menu, Tray, Add, 프로그램 정보, AppInfo
Menu, Tray, Add
Menu, Tray, Add, 종료, GuiClose
Menu, Tray, NoIcon

Menu, FileMenu, Add, &매크로 저장	Ctrl+S, 	SaveMacro
Menu, FileMenu, Add, &매크로 불러오기	Ctrl+O, LoadMacro
Menu, FileMenu, Add
Menu, FileMenu, Add, 트레이로 최소화, 			MinimizeToTray
Menu, FileMenu, Add
Menu, FileMenu, Add, &프로그램 종료	Alt+F4, 	GuiClose
Menu, MainMenu, Add, File, :FileMenu

Menu, InfoMenu, Add, Mouse 문서, 				OpenMouseDocs
Menu, InfoMenu, Add, Wikipedia의 베지에 곡선,	OpenBezierDocs
Menu, InfoMenu, Add, Send 문서, 				OpenSendDocs
Menu, InfoMenu, Add, SoundPlay 문서, 			OpenSoundPlayDocs
Menu, InfoMenu, Add, Run 문서, 					OpenRunDocs
Menu, InfoMenu, Add
Menu, InfoMenu, Add, ImageSearch 문서, 		OpenImageSearchDocs
Menu, InfoMenu, Add, Message Box 문서, 		OpenMsgBoxDocs
Menu, InfoMenu, Add, Loop 문서, 			OpenLoopDocs
Menu, InfoMenu, Add, If 문서, 				OpenIfDocs
Menu, InfoMenu, Add, Sleep(Delay) 문서, 	OpenDelayDocs
Menu, InfoMenu, Add, Window 관련 문서, 		OpenWindowDocs
Menu, InfoMenu, Add
Menu, InfoMenu, Add, Github 페이지 방문 / 업데이트 확인, GoGithub
Menu, InfoMenu, Add, &프로그램 정보	F1, AppInfo
Menu, MainMenu, Add, Info, :InfoMenu

Menu, EditMenu, Add, &라인 위로 이동	Ctrl+R,		BTN_Up
Menu, EditMenu, Add, &라인 아래로 이동	Ctrl+F,		BTN_Down
Menu, EditMenu, Add, 라인 복사,						BTN_Copy
Menu, EditMenu, Add, 라인 붙여넣기,					BTN_Paste
Menu, EditMenu, Add
Menu, EditMenu, Add, &라인 삭제	Ctrl+Delete,		BTN_Delete

Gui, Add, StatusBar
SB_SetText("GUI 구성 중")
imt_cx = 0
imt_cy = 0

;#############################################################################

Gui, Block:+AlwaysOnTop
Gui, Block:Font, s48 Bold, Arial
Gui, Block:Color, 000000, 000000
Gui, Block:Add, Text, % "x"0 " y"0 " w"A_ScreenWidth + 200 " h"A_ScreenHeight + 200 " Center 0x200 cFFFFFF vRealRecord gRealRecord", 준비 중...

;#############################################################################

Gui, Menu, MainMenu
Gui, Margin, 12, 12
Gui, Add, ListBox, x12 y9 w600 h580 AltSubmit vLineList gListG HScroll
Gui, Add, GroupBox, x622 y499 w490 h90, 매크로 단축키 지정 및 라인 수정
Gui, Add, Text, x632 y519 w70 h60 Right, `n라인 위로`n`n라인 아래로
Gui, Add, Button, x702 y519 w30 h30 Disabled vBTN_Up gBTN_Up, ↑
Gui, Add, Button, x702 y549 w30 h30 Disabled vBTN_Down gBTN_Down, ↓
Gui, Add, Button, x742 y519 w100 h30 Disabled vBTN_Copy gBTN_Copy, 라인 복사
Gui, Add, Button, x742 y549 w100 h30 Disabled vBTN_Paste gBTN_Paste, 라인 붙여넣기
Gui, Add, Text, x852 y524 w100 h20 0x200, 단축키 지정:
Gui, Add, Hotkey, x922 y524 w94 h20 vScriptExploter, ^+1
Gui, Add, Button, x852 y545 w165 h34 vSetHotkey gSetHotkey, 스크립트 단축키 지정
Gui, Add, Button, x1022 y519 w80 h30 vBTN_RUN gRunScript, 실행
Gui, Add, Button, x1022 y549 w80 h30 vBTN_STP +Disabled gStopScript, 중단
Gui, Add, Tab2, x622 y9 w490 h480 vTB2 gTB2, Mouse|Bezier Move|Send|SoundPlay|Run|ImageSearch|Message Box|Loop|If|Delay|Window

;############################################# Mouse 탭

Gui, Tab, Mouse
Gui, Add, Text, x632 y59 w470 h80, Mouse 도움말:`n마우스 이동과 마우스 클릭과 같은 기본 기능들입니다.`n`n마우스 이동 (단순)은 지정한 좌표로만 이동합니다.`n범위 내 이동은 좌상단과 우하단 좌표 사이 어딘가에 랜덤으로 이동합니다.`n이동 속도는 작을 수록 빠르고`, 0은 순간이동`, 100이라면 가능한 느리게 이동합니다.
Gui, Add, GroupBox, x632 y149 w120 h140, 클릭
Gui, Add, Button, x642 y169 w100 h30 gAL_LB, 좌클릭 추가
Gui, Add, Button, x642 y209 w100 h30 gAL_WB, 휠 클릭 추가
Gui, Add, Button, x642 y249 w100 h30 gAL_RB, 우클릭 추가

Gui, Add, GroupBox, x762 y149 w340 h140, 마우스 이동 (단순)
Gui, Add, Button, x772 y169 w90 h110 vBTN_MousePos1 gGP_MousePos1, 클릭하여`n`n위치 기록
Gui, Add, GroupBox, x872 y169 w120 h50, X 좌표
Gui, Add, Edit, x882 y189 w100 h20 +Center 0x200 -VScroll vED_MNX, 0
Gui, Add, GroupBox, x872 y229 w120 h50, Y 좌표
Gui, Add, Edit, x882 y249 w100 h20 +Center 0x200 -VScroll vED_MNY, 0
Gui, Add, Text, x1002 y169 w90 h50 +Center vCurPos1, 현재 좌표:`n`nx`ny
Gui, Add, Button, x1002 y229 w90 h50 gAL_MNMove, 라인 추가

Gui, Add, GroupBox, x632 y299 w470 h140, 마우스 범위 내 이동
Gui, Add, GroupBox, x642 y319 w220 h110, 범위 좌상단
Gui, Add, Text, x652 y339 w100 h20 +Center 0x200, X 좌표:
Gui, Add, Edit, x762 y339 w90 h20 +Center 0x200 -VScroll vED_SX, 0
Gui, Add, Text, x652 y369 w100 h20 +Center 0x200, Y 좌표:
Gui, Add, Edit, x762 y369 w90 h20 +Center 0x200 -VScroll vED_SY, 0
Gui, Add, Button, x652 y399 w200 h20 vBTN_MNS gBTN_MNS, 클릭하여 위치 기록 (S)

Gui, Add, GroupBox, x872 y319 w220 h110, 범위 우하단
Gui, Add, Text, x882 y339 w100 h20 +Center 0x200, X 좌표:
Gui, Add, Edit, x992 y339 w90 h20 +Center 0x200 -VScroll vED_EX, 0
Gui, Add, Text, x882 y369 w100 h20 +Center 0x200, Y 좌표:
Gui, Add, Edit, x992 y369 w90 h20 +Center 0x200 -VScroll vED_EY, 0
Gui, Add, Button, x882 y399 w200 h20 vBTN_MNE gBTN_MNE, 클릭하여 위치 기록 (E)

Gui, Add, GroupBox, x832 y431 w270 h48
Gui, Add, Text, x833 y431 w268 h10
Gui, Add, Button, x842 y439 w250 h30 gBTN_AMM, 범위 내 마우스 이동 추가

Gui, Add, Text, x632 y449 w120 h30 Center 0x200, 마우스 이동 속도:
Gui, Add, Edit, x762 y449 w60 h30 Center 0x200 -VScroll vED_Speed1 gSetMouseSpeed1, 5

;############################################# Bezier Move 탭

Gui, Tab, Bezier Move
Gui, Add, Text, x632 y59 w470 h170, Bezier Move 도움말:`n직선으로 마우스가 이동하는 Mouse 메뉴와 달리`,`n곡선을 그리며 마우스를 이동하는 기능입니다.`n베지에 곡선 수식을 이용해서 마우스로 곡선을 그리며 이동합니다.`n`n좌상단과 우하단 범위 내 랜덤 위치로 이동합니다.`n`n이동 곡률: 0~10 사이의 값으로`,`n0에 가까울 수록 직선`, 반대로 10에 가까울 수록 큰 곡선을 그리며 이동합니다.`n`n곡선 방향: U(위)나 D(아래) 방향으로 곡선을 그립니다. R(랜덤)`n`n*각 시작/끝 지점인 [범위 좌상단]과 [범위 우하단] 값을 필수로 지정해야 합니다.
Gui, Add, GroupBox, x632 y239 w470 h150, 베지에 이동
Gui, Add, GroupBox, x642 y259 w220 h120, 범위 좌상단
Gui, Add, Text, x652 y279 w100 h20 +Center 0x200, X 좌표:
Gui, Add, Edit, x762 y279 w90 h20 +Center 0x200 -VScroll vED_BSX, 0
Gui, Add, Text, x652 y309 w100 h20 +Center 0x200, Y 좌표:
Gui, Add, Edit, x762 y309 w90 h20 +Center 0x200 -VScroll vED_BSY, 0
Gui, Add, Button, x652 y339 w200 h30 vBTN_MBS gBTN_MBS, 클릭하여 위치 기록 (BS)
Gui, Add, GroupBox, x872 y259 w220 h120 , 범위 우하단
Gui, Add, Text, x882 y279 w100 h20 +Center 0x200, X 좌표:
Gui, Add, Edit, x992 y279 w90 h20 +Center 0x200 -VScroll vED_BEX, 0
Gui, Add, Text, x882 y309 w100 h20 +Center 0x200, Y 좌표:
Gui, Add, Edit, x992 y309 w90 h20 +Center 0x200 -VScroll vED_BEY, 0
Gui, Add, Button, x882 y339 w200 h30 vBTN_MBE gBTN_MBE, 클릭하여 위치 기록 (BE)
Gui, Add, Button, x632 y399 w470 h40 gBTN_ABM, 베지에 이동 추가
Gui, Add, Text, x632 y449 w120 h30 +Center 0x200, 마우스 이동 속도:
Gui, Add, Edit, x762 y449 w50 h30 Center 0x200 -VScroll Range0-200 vED_Speed2 gSetMouseSpeed2, 5
Gui, Add, Text, x822 y449 w80 h30 +Center 0x200, 이동 곡률:
Gui, Add, Edit, x912 y449 w50 h30 +Center 0x200 -VScroll Range0-10 vCurveRate gSetCurveRate, 5
Gui, Add, Text, x972 y449 w64 h30 +Center 0x200, 곡선 방향:
Gui, Add, DropDownList, x1042 y454 w60 h80 +Center Choose3 vCurveDir, U|D|R

;############################################# Send 탭

Gui, Tab, Send
Gui, Add, Text, x632 y59 w470 h90, Send 도움말:`n키보드나 마우스 버튼을 에뮬레이팅합니다.`n`n{키 Down}과 같이 입력하여 누르고`,`n{키 Up}과 같이 입력하여 뗄 수 있습니다.`n`n(Info에서 Send 문서 참고)
Gui, Add, GroupBox, x632 y159 w470 h300, Send
Gui, Add, Edit, x642 y179 w190 h30 +Center 0x200 -VScroll vED_KTS, {d Down}
Gui, Add, Button, x842 y179 w250 h30 gBTN_AKS, Send 추가

Gui, Add, Button, x642 y219 w150 h30 vBTN_KS11 gBTN_KST, Ctrl + C 추가
Gui, Add, Button, x792 y219 w150 h30 vBTN_KS12 gBTN_KST, Ctrl + V 추가
Gui, Add, Button, x942 y219 w150 h30 vBTN_KS13 gBTN_KST, Ctrl + X 추가

Gui, Add, Button, x642 y259 w150 h30 vBTN_KS21 gBTN_KST, 실행취소 추가
Gui, Add, Button, x792 y259 w150 h30 vBTN_KS22 gBTN_KST, 다시 실행 추가
Gui, Add, Button, x942 y259 w150 h30 vBTN_KS23 gBTN_KST, 스크린샷 추가

Gui, Add, Button, x642 y299 w150 h30 vBTN_KS31 gBTN_KST, 파일 탐색기 추가
Gui, Add, Button, x792 y299 w150 h30 vBTN_KS32 gBTN_KST, 바탕화면 보기 추가
Gui, Add, Button, x942 y299 w150 h30 vBTN_KS33 gBTN_KST, 클립보드 열기 추가

Gui, Add, Button, x642 y339 w150 h30 vBTN_KS41 gBTN_KST, 작업관리자 추가
Gui, Add, Button, x792 y339 w150 h30 vBTN_KS42 gBTN_KST, Alt + Tab 추가
Gui, Add, Button, x942 y339 w150 h30 vBTN_KS43 gBTN_KST, Ctrl + Tab 추가

Gui, Add, Button, x642 y379 w150 h30 vBTN_KS51 gBTN_KST, 새 창 열기 추가
Gui, Add, Button, x792 y379 w150 h30 vBTN_KS52 gBTN_KST, 닫은 창 복구 추가
Gui, Add, Button, x942 y379 w150 h30 vBTN_KS53 gBTN_KST, 창 닫기 추가

Gui, Add, Button, x642 y419 w150 h30 vBTN_KS61 gBTN_KST, Enter 추가
Gui, Add, Button, x792 y419 w150 h30 vBTN_KS62 gBTN_KST, BackSpace 추가
Gui, Add, Button, x942 y419 w150 h30 vBTN_KS63 gBTN_KST, Window 키 추가

;############################################# SoundPlay 탭

Gui, Tab, SoundPlay
Gui, Add, Text, x632 y59 w470 h90, SoundPlay 도움말:`nmp3나 wav파일과 같은 음원을 재생합니다.`n`n[Wait]에 체크하여 음원 재생이 끝날 때까지 대기합니다.`n체크되어있지 않을 경우`, 대기하지 않고 다음 라인으로 넘어갑니다.`n`n음원 파일이 존재하지 않는 경우`, 재생되지 않습니다.
Gui, Add, Edit, x632 y159 w430 h20 0x200 -VScroll vED_SND, [...] 버튼을 눌러 음원 선택
Gui, Add, Button, x1062 y158 w40 h22 gBTN_SSN, ...
Gui, Add, Button, x632 y189 w470 h40 gBTN_ASN, SoundPlay 추가
Gui, Add, Text, x632 y239 w470 h10 +Center 0x200 cDCDCDC, ──────────────────────────────────────────────────────────────────
Gui, Add, Button, x632 y259 w230 h40 gBTN_AWI, Windows Info 효과음 추가
Gui, Add, Button, x872 y259 w230 h40 gBTN_AWE, Windows Error 효과음 추가
Gui, Add, CheckBox, x1002 y449 w100 h30 vCK_WIT, Wait

;############################################# Run 탭

Gui, Tab, Run
Gui, Add, Text, x632 y59 w470 h90, Run 도움말:`n웹사이트 url 또는 컴퓨터 파일을 엽니다.`n`nurl을 추가해서 웹사이트를 띄울 수도 있습니다.`n프로그램 실행 시 PC에 기본값으로 설정된 연결 프로그램으로 열립니다.`n`n프로그램인 경우 ""로 감싸면 뒤에 명령 인수를 추가할 수 있습니다.
Gui, Add, Edit, x632 y159 w430 h20 0x200 -VScroll vED_RUN, https://some.cool.website.here/
Gui, Add, Button, x1062 y158 w40 h22 gBTN_SRL, ...
Gui, Add, Button, x632 y189 w470 h40 gBTN_ARL, Run 추가

;############################################# ImageSearch 탭

Gui, Tab, ImageSearch
Gui, Add, Text, x632 y59 w470 h90, ImageSearch 도움말:`n화면에 내에서 지정된 이미지를 찾는 기능입니다.`n`nisimage 변수에는 이미지가 발견됐는지 저장되고`,`ntx와 ty에는 각각 찾은 이미지의 x와 y 좌표가 저장됩니다.`n`n이미지를 찾지 못 했다면 tx와 ty는 비워집니다.
Gui, Add, Progress, x632 y159 w430 h220 c9F9F9F BackgroundA1A1A1 Range0-1, 1 ;	b
Gui, Add, Text, x642 y169 w420 h210 cBBBBBB BackgroundTrans vTXT_CMT, cx와 cy에는 이미지를 발견한 경우`,`ntx와 ty에 각 수치를 더하여 저장합니다.`n이를 활용하면 클릭할 지점을 보정할 수 있습니다.`n`n현재:`ncx = tx + 0`ncy = ty + 0
Gui, Add, Progress, x846 y244 w2 h50 cCCCCCC BackgroundCCCCCC Range0-1, 1 ;		v
Gui, Add, Progress, x822 y268 w50 h2 cCCCCCC BackgroundCCCCCC Range0-1, 1 ;		h
Gui, Add, Picture, x847 y269 BackgroundTrans w-1 h100 vIMG_TAR
Gui, Add, Progress, x845 y267 w4 h4 cFF0000 BackgroundBB0000 Range0-1 vClickPos, 1
Gui, Add, Button, x1072 y199 w30 h30 gBTN_IMT, △
Gui, Add, Button, x1072 y239 w30 h30 gBTN_IMT, ↑
Gui, Add, Button, x1072 y279 w30 h30 gBTN_IMT, ↓
Gui, Add, Button, x1072 y319 w30 h30 gBTN_IMT, ▽
Gui, Add, Button, x772 y389 w30 h30 gBTN_IMT, ◁
Gui, Add, Button, x812 y389 w30 h30 gBTN_IMT, ←
Gui, Add, Button, x852 y389 w30 h30 gBTN_IMT, →
Gui, Add, Button, x892 y389 w30 h30 gBTN_IMT, ▷
Gui, Add, Edit, x632 y429 w339 h20 vED_IMT, 이미지이름.png
Gui, Add, Button, x971 y428 w32 h22 gBTN_IMS, ...
Gui, Add, Text, x632 y458 w45 h20 0x200 gIMG_TOL, 허용(i):
Gui, Add, Slider, x682 y458 w150 h20 Range0-100 TickInterval50 ToolTip vSLD_TOL, 10
Gui, Add, Text, x842 y458 w80 h20 0x200 gIMG_TRN, 배경 제거(i):
Gui, Add, DropDownList, x922 y458 w80 vDDL_COL, |White|Black|Red|Green|Blue
Gui, Add, Button, x1011 y428 w92 h52 gBTN_AIS, ImageSearch 추가

;############################################# Message Box 탭

Gui, Tab, Message Box
Gui, Add, Text, x632 y59 w470 h80 , Message Box 도움말:`n사용자에게 특정 메시지를 출력하여 보여줍니다.`n`nTimeout이 비어있거나 0이면 자동으로 닫히지 않습니다. (초 단위)`n`nAlways on top에 체크하면 메시지가 항상 위에 고정됩니다.
Gui, Add, Edit, x632 y149 w470 h20 -VScroll vED_MST, Message Box 제목
Gui, Add, Edit, x632 y179 w470 h150 vED_MSP, Message Box 내용
Gui, Add, GroupBox, x632 y339 w100 h50, Timeout
Gui, Add, Edit, x642 y359 w80 h20 -VScroll +Center vED_MMS, 0
Gui, Add, GroupBox, x742 y339 w120 h50, Always on top
Gui, Add, CheckBox, x752 y359 w100 h20 vCK_AOT, Always on top
Gui, Add, Button, x872 y339 w230 h50 vBTN_MGT gBTN_MGT, MsgBox 테스트
Gui, Add, Button, x632 y399 w470 h80 vBTN_MGA gBTN_MGA, MsgBox 추가

;############################################# Loop 탭

Gui, Tab, Loop
Gui, Add, Text, x632 y59 w470 h74, Loop 도움말:					(강제 중단: Ctrl + Shift + Del)`nLoop를 이용하면 지정된 구간의 라인을 반복 실행할 수 있습니다.`n`nCount 값으로 반복 횟수를 지정할 수 있고`,`n0으로 두면 수동으로 매크로를 정지시키기 전까지 무한 반복합니다.`n
Gui, Add, GroupBox, x632 y139 w170 h50, 반복 횟수
Gui, Add, Text, x642 y159 w50 h20 +0x200, Count:
Gui, Add, Edit, x692 y159 w102 h20 +Center -VScroll vED_LCT
Gui, Add, UpDown, Range0-999 Range0-999, 5
Gui, Add, Button, x812 y139 w140 h50 gBTN_LPO, Loop 열기 추가
Gui, Add, Button, x962 y139 w140 h50 gBTN_LPC, Loop 닫기 추가

;############################################# If 탭

Gui, Tab, If
Gui, Add, Text, x632 y59 w470 h120, If 도움말:`n조건문의 참/거짓 여부를 확인하는 조건문 기능입니다.`n조건이 참인 경우에만 범위 내 명령어들을 실행합니다.`n`n=	(같음)`,		!=	(같지 않음)`,`n>	(왼쪽이 큼)`,	<	(왼쪽이 작음)`,`n>=	(크거나 같음)`,	<=	(작거나 같음)`n`n기본 내장 변수들도 사용할 수 있습니다. (Info에서 If 문서 참고)
Gui, Add, Text, x631 y209 w202 h50 cDCDCDC Center, │`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│
Gui, Add, Text, x901 y209 w202 h50 cDCDCDC Center, │`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│`n│
Gui, Add, Text, x744 y254 w248 h10 +Center 0x200 cDCDCDC, ──────────────────────────────────────────────────────────────────
Gui, Add, Edit, x631 y189 w202 h20 0x200 Center -VScroll vED_LVR, 100
Gui, Add, DropDownList, x842 y189 w50 Choose4 vDDL_CMP, =|!=|>|<|>=|<=
Gui, Add, Edit, x901 y189 w202 h20 0x200 Center -VScroll vED_RVR, 200
Gui, Add, Button, x722 y248 w22 h22 vBTN_LAR gBTN_LAR, ↑
Gui, Add, Button, x992 y248 w22 h22 vBTN_RAR gBTN_RAR, ↑
Gui, Add, Text, x766 y228 w200 h20 Center 0x200 Disabled, ｖ 빠른 변수 지정 ｖ
Gui, Add, DropDownList, x766 y248 w200 Choose1 vDDL_SVR, current_line|depth|index|isvalid|isimage|tx|ty|cx|cy|A_ScreenWidth|A_ScreenHeight|A_ScriptDir|A_WorkingDir|A_Clipboard|A_ClipboardAll|A_ComputerName|A_Language|A_Hour|A_Min|A_MSec|A_Now|A_Sec|A_DD|A_MM|A_YYYY
Gui, Add, Button, x631 y278 w232 h42 gBTN_AIF, 조건문 추가
Gui, Add, Button, x872 y278 w232 h42 gBTN_LPC, 조건문 닫기 추가
Gui, Add, Text, x631 y329 w470 h140, current_line`n현재 실행되고 있는 스크립트 줄 번호`n`ndepth`n현재 루프의 깊이`n`nindex`n현재 루프의 인덱스(실행 회차)`n`nisvalid`n조건문이 true인지 false인지

;############################################# Delay 탭

btndlttrg = 250
Gui, Tab, Delay
Gui, Add, Text, x632 y59 w470 h90, Delay 도움말:`n입력한 대기 시간 동안 대기합니다.`n1 초는 1`,000 밀리초입니다.`n`n범위시작-범위끝으로 표현하여`,`n주어진 범위 내에서 무작위하게 대기할 수 있습니다.`n예시: 250-500	(250에서 500 사이 난수)
Gui, Add, GroupBox, x632 y159 w190 h50, 대기 시간
Gui, Add, Edit, x642 y179 w97 h20 +Center -VScroll vED_DLY, %btndlttrg%
Gui, Add, DropDownList, x741 y179 w72 h80 0x200 Choose1 vDDL_MSM gMultiplyMS, 밀리초|초|분
Gui, Add, Button, x832 y159 w270 h50 vBTN_DLY gBTN_DLY, 250ms 대기 추가

;############################################# Window 탭

Gui, Tab, Window
Gui, Add, Text, x632 y59 w470 h40 , Window 도움말:`n창 관리와 관련된 기능들입니다.`nWaitSeconds 값으로 최대 얼마까지 대기할지 지정합니다. (일부 항목에만 적용)
Gui, Add, GroupBox, x632 y109 w470 h90 , 공통 적용 값
Gui, Add, Edit, x642 y129 w450 h20 -VScroll vED_WNM, [창 정보 가져오기] 버튼으로 창 좌표 및 이름을 가져올 수 있습니다.
Gui, Add, Button, x642 y159 w230 h30 vBTN_GWN gBTN_GWN, 창 정보 가져오기
Gui, Add, Text, x882 y159 w90 h30 +Center 0x200, WaitSeconds:
Gui, Add, Edit, x972 y159 w120 h30 +Center 0x200 -VScroll vED_WWS, 10


Gui, Add, Button, x632 y209 w150 h30 vBTN_W11 gWNTB_TOT, WinActivate 추가
Gui, Add, Text, x632 y239 w150 h30 +Center 0x200, 창을 활성화합니다.

Gui, Add, Button, x792 y209 w150 h30 vBTN_W12 gWNTB_TOT, WinClose 추가
Gui, Add, Text, x792 y239 w150 h30 +Center 0x200, 창을 닫습니다.

Gui, Add, Button, x952 y209 w150 h30 vBTN_W13 gWNTB_TOT, WinKill 추가
Gui, Add, Text, x952 y239 w150 h30 +Center 0x200, 창을 강제로 닫습니다.



Gui, Add, Button, x632 y279 w150 h30 vBTN_W21 gWNTB_TOT, WinWait 추가
Gui, Add, Text, x632 y309 w150 h30 +Center 0x200, 창 로딩을 기다립니다.

Gui, Add, Button, x792 y279 w150 h30 vBTN_W22 gWNTB_TOT, WaitActivate 추가
Gui, Add, Text, x792 y309 w150 h30 +Center 0x200, 창 활성화를 기다립니다.

Gui, Add, Button, x952 y279 w150 h30 vBTN_W23 gWNTB_TOT, WaitNotActivate 추가
Gui, Add, Text, x952 y309 w150 h30 +Center 0x200, 창 비활성화를 기다립니다.


Gui, Add, GroupBox, x632 y349 w470 h130, WinMove
Gui, Add, Text, x642 y369 w40 h20 +Center 0x200, X:
Gui, Add, Edit, x682 y369 w90 h20 +Center 0x200 -VScroll vED_WWX, 0
Gui, Add, Text, x782 y369 w40 h20 +Center 0x200, Y:
Gui, Add, Edit, x822 y369 w90 h20 +Center 0x200 -VScroll vED_WWY, 0
Gui, Add, Text, x642 y399 w40 h20 +Center 0x200, W:
Gui, Add, Edit, x682 y399 w90 h20 +Center 0x200 -VScroll vED_WWW
Gui, Add, Text, x782 y399 w40 h20 +Center 0x200, H:
Gui, Add, Edit, x822 y399 w90 h20 +Center 0x200 -VScroll vED_WWH

Gui, Add, Button, x922 y369 w170 h50 gBTN_AWM, WinMove 추가
Gui, Add, Text, x642 y434 w450 h30 +Center 0x200 +Center -0x200 +Center, 창에 X 가로`, Y 세로`, W 너비`, H 높이를 지정합니다.`nW나 H 값을 비워두면 너비나 높이를 수정하지 않습니다.

;############################################# Gui 구성 마무리 및 Show

Gui, Show, x%winX% y%winY%, %appname% [v%appversion%]

OnMessage(0x0204, "WM_RBUTTONDOWN")
SB_SetText(" GUI 구성 및 디스플레이 완료")
flag=
if (filedropped != "")
{
	IfInString, filedropped, .fqm
	{
		IfExist, %filedropped%
		{
			MsgBox, 4132, %appname% - Load Macro, %filedropped%`n파일을 명령 인수로 전달받았습니다.`n`n매크로를 불러오시겠습니까?
			IfMsgBox, No
			{
				SetTimer, GetCurrentCoord, 250
				return
			}
			MacroLoad(filedropped)
		}
	}
}
SetTimer, GetCurrentCoord, 250
return

;############################################# 버튼별 g라벨

;####################### 사용자 지정 GUI v라벨과 g라벨

;########### Tab2 비의존 GUI

GetReady:
SetTimer, GetReady, Off
SetTimer, SB_SetCoord, 1
GuiControl, , %tbutton%, 기록할 위치에 마우스 좌클릭
GuiControl, Block:, RealRecord, 기록할 위치에 마우스 좌클릭
return

RealRecord:
MouseGetPos, temporary_saved_x1, temporary_saved_y1
GuiControl, 1:, %xedt%, %temporary_saved_x1%
GuiControl, 1:, %yedt%, %temporary_saved_y1%
GuiControl, 1:, %tbutton%, %bname%
SetTimer, SB_SetCoord, Off
SB_SetText("	[x" . temporary_saved_x1 . " y" . temporary_saved_y1 . " 좌상단 좌표 기록함")
Gui, Block:Hide
return

TB2:
Gui, Submit, NoHide
if (TB2 = "Mouse")
{
	SetTimer, GetCurrentCoord, 250
}
else
{
	SetTimer, GetCurrentCoord, Off
}
return

SetMouseSpeed1:
if (script_working = 1)
	return
Gui, Submit, NoHide
GuiControl, , ED_Speed2, %ED_Speed1%
if (ED_Speed1 = "")
{
	GuiControl, , ED_Speed1, 5
	GuiControl, , ED_Speed2, 5
	Send, ^a
}
if (ED_Speed1 > 100)
{
	GuiControl, , ED_Speed1, 100
	GuiControl, , ED_Speed2, 100123
	Send, {End}
}
else if (ED_Speed1 < 0)
{
	GuiControl, , ED_Speed1, 0
	GuiControl, , ED_Speed2, 0
	Send, ^a
}
return

SetMouseSpeed2:
if (script_working = 1)
	return
Gui, Submit, NoHide
GuiControl, , ED_Speed1, %ED_Speed2%
if (ED_Speed2 = "")
{
	GuiControl, , ED_Speed1, 5
	GuiControl, , ED_Speed2, 5
	Send, ^a
}
if (ED_Speed2 > 100)
{
	GuiControl, , ED_Speed1, 100
	GuiControl, , ED_Speed2, 100
	Send, {End}
}
else if (ED_Speed2 < 0)
{
	GuiControl, , ED_Speed1, 0
	GuiControl, , ED_Speed2, 0
	Send, ^a
}
return

SetCurveRate:
if (script_working = 1)
	return
Gui, Submit, NoHide
if (CurveRate = "")
{
	GuiControl, , CurveRate, 5
	Send, ^a
}
if (CurveRate > 10)
{
	GuiControl, , CurveRate, 10
	Send, {End}
}
else if (CurveRate < 0)
{
	GuiControl, , CurveRate, 0
	Send, ^a
}
return

MultiplyMS:
Gui, Submit, NoHide
if (flagg = 1)
	return
flagg = 1
if (DDL_MSM = "초")
	multiplier = 1000
else if (DDL_MSM = "분")
	multiplier = 60000
else
	multiplier = 1
if (A_GuiContent = "")
{
	A_GuiContent := ED_DLY
}
StringSplit, parts, A_GuiContent, -
if (parts0 > 1)
{
	A_GuiContent := parts1 "-" parts2
	btndlttrg := parts1 * multiplier "-" parts2 * multiplier
	GuiControl, , ED_DLY, %A_GuiContent%
	if (A_GuiControl != "DDL_MSM")
	{
		org_inp=
		Send, {End}
	}
}
else
{
	btndlttrg := A_GuiContent * multiplier
}
GuiControl, , BTN_DLY, %btndlttrg%ms 대기 추가
Sleep, 50
flagg=
return

ListG:
if (script_working = 1)
	return
Gui, Submit, NoHide
AdvancedStatusBar()
return

~^r::
BTN_Up:
if (script_working = 1)
	return
IfWinNotActive, %appname% [v%appversion%]
{
	return
}
ListBox_Move_Up()
return

~^f::
BTN_Down:
if (script_working = 1)
	return
IfWinNotActive, %appname% [v%appversion%]
{
	return
}
ListBox_Move_Down()
return

BTN_Copy:
if (script_working = 1)
	return
IfWinNotActive, %appname% [v%appversion%]
{
	return
}
if (listvar.MaxIndex() = "" || listvar.MaxIndex() = 0)
{
	return
}
temporary_saved_line := ListBox_Copy()
return

BTN_Paste:
if (script_working = 1 || temporary_saved_line = "")
	return
IfWinNotActive, %appname% [v%appversion%]
{
	return
}
ListBox_Paste()
return

~^Delete::
BTN_Delete:
if (script_working = 1 || listvar.MaxIndex() = "" || listvar.MaxIndex() = 0)
	return
IfWinNotActive, %appname% [v%appversion%]
{
	return
}
ListBox_Delete()
return

;########### Mouse 탭

AL_LB:
if (script_working = 1)
	return
ListBox_Batch_Process("[SEND]  {LButton}", "LineList", " 좌클릭 추가")
return

AL_WB:
if (script_working = 1)
	return
ListBox_Batch_Process("[SEND]  {MButton}", "LineList", " 휠 클릭 추가")
return

AL_RB:
if (script_working = 1)
	return
ListBox_Batch_Process("[SEND]  {RButton}", "LineList", " 우클릭 추가")
return

GP_MousePos1:
if (script_working = 1)
	return
RecordCoord("BTN_MousePos1", "ED_MNX", "ED_MNY", "클릭하여`n`n위치 기록")
return

AL_MNMove:
Gui, Submit, NoHide
if (script_working = 1)
	return
ListBox_Batch_Process("[MOUSE MOVE]  x" . ED_MNX . " y" . ED_MNY . " s" . ED_Speed1, "LineList", "x" . ED_MNX . " y" . ED_MNY . " 좌표로 이동 추가")
return

BTN_MNS:
if (script_working = 1)
	return
RecordCoord("BTN_MNS", "ED_SX", "ED_SY", "클릭하여 위치 기록 (S)")
return

BTN_MNE:
if (script_working = 1)
	return
RecordCoord("BTN_MNE", "ED_EX", "ED_EY", "클릭하여 위치 기록 (E)")
return

BTN_AMM:
if (script_working = 1)
	return
Gui, Submit, NoHide
if (ED_SX > ED_EX || ED_SY > ED_EY)
{
	Gui, +Disabled
	SoundPlay, *16
	MsgBox, 4112, %appname% (fail), 좌상단 좌표가 우하단 좌표 값보다 작아서 진행이 취소되었습니다., 5
	SB_SetText("	좌상단 좌표가 우하단 좌표 값보다 작아서 진행이 취소되었습니다.")
	Gui, -Disabled
	return
}
ListBox_Batch_Process("[MOUSE MOVE+]  sx" . ED_SX . " sy" . ED_SY . " ex" . ED_EX . " ey" . ED_EY . " s" ED_Speed1, "LineList", "sx" . ED_SX . " sy" . ED_SY . " ex" . ED_EX . " ey" . ED_EY . " s" ED_Speed1 . " 범위 내 마우스 이동 추가")
return

;########### Bezier Move 탭

BTN_MBS:
if (script_working = 1)
	return
RecordCoord("BTN_MBS", "ED_BSX", "ED_BSY", "클릭하여 위치 기록 (BS)")
return

BTN_MBE:
if (script_working = 1)
	return
RecordCoord("BTN_MBE", "ED_BEX", "ED_BEY", "클릭하여 위치 기록 (BE)")
return

BTN_ABM:
if (script_working = 1)
	return
Gui, Submit, NoHide
if (ED_BSX > ED_BEX || ED_BSY > ED_BEY)
{
	Gui, +Disabled
	SoundPlay, *32
	MsgBox, 4112, %appname% (fail), 좌상단 좌표가 우하단 좌표 값보다 작아서 진행이 취소되었습니다., 5
	SB_SetText("	좌상단 좌표가 우하단 좌표 값보다 작아서 진행이 취소되었습니다.")
	Gui, -Disabled
	return
}
ListBox_Batch_Process("[BEZIER MOVE]  sx" . ED_BSX . " sy" . ED_BSY . " ex" . ED_BEX . " ey" . ED_BEY . " s" ED_Speed2 . " c" . CurveRate . " d" . CurveDir, "LineList", "sx" . ED_BSX . " sy" . ED_BSY . " ex" . ED_BEX . " ey" . ED_BEY . " s" ED_Speed2 .  " c" . CurveRate . " d" . CurveDir . " 범위 내 마우스 이동 추가")
return

;########### Send 탭

BTN_AKS:
Gui, Submit, NoHide
if (ED_KTS = "" || script_working = 1)
	return
ListBox_Batch_Process("[SEND]  " . ED_KTS, "LineList", "Send " . ED_KTS . " 추가")
return

BTN_KST:
if (script_working = 1)
	return
if (A_GuiControl = "BTN_KS11")
	commandtoadd = ^c
else if (A_GuiControl = "BTN_KS12")
	commandtoadd = ^v
else if (A_GuiControl = "BTN_KS13")
	commandtoadd = ^x
else if (A_GuiControl = "BTN_KS21")
	commandtoadd = ^z
else if (A_GuiControl = "BTN_KS22")
	commandtoadd = ^+z
else if (A_GuiControl = "BTN_KS23")
	commandtoadd = {PrintScreen}
else if (A_GuiControl = "BTN_KS31")
	commandtoadd = #e
else if (A_GuiControl = "BTN_KS32")
	commandtoadd = #d
else if (A_GuiControl = "BTN_KS33")
	commandtoadd = #v
else if (A_GuiControl = "BTN_KS41")
	commandtoadd = ^+{Esc}
else if (A_GuiControl = "BTN_KS42")
	commandtoadd = !{Tab}
else if (A_GuiControl = "BTN_KS43")
	commandtoadd = ^{Tab}
else if (A_GuiControl = "BTN_KS51")
	commandtoadd = ^t
else if (A_GuiControl = "BTN_KS52")
	commandtoadd = ^+t
else if (A_GuiControl = "BTN_KS53")
	commandtoadd = ^w
else if (A_GuiControl = "BTN_KS61")
	commandtoadd = {Enter}
else if (A_GuiControl = "BTN_KS62")
	commandtoadd = {BackSpace}
else if (A_GuiControl = "BTN_KS63")
	commandtoadd = ^{Esc}
else {
	commandtoadd=
	SoundPlay, *48
	MsgBox, 4128, %appname% (???), 대체 무슨 버튼을 누르신 겁니까`, 휴먼?, 3
	return
}
ListBox_Batch_Process("[SEND]  " . commandtoadd, "LineList", "Send " . commandtoadd . " 추가")
return

;########### SoundPlay 탭

BTN_SSN:
if (script_working = 1)
	return
Gui, +Disabled
SetTimer, GetCurrentCoord, Off
FileSelectFile, filetoplay, 1, , %appname% - SoundPlay로 추가하고픈 음원 파일을 선택해주세요., 음원 파일 (*.wav; *.mp3)
if (ErrorLevel = 1 "" || filetoplay = "")
{
	Gui, -Disabled
	return
}
GuiControl, , ED_SND, %filetoplay%
SetTimer, GetCurrentCoord, 250
Gui, -Disabled
return

BTN_ASN:
if (script_working = 1)
	return
Gui, Submit, NoHide
Gui, +Disabled
SetTimer, GetCurrentCoord, Off
SoundPlay, *32
IfNotExist, %ED_SND%
{
	MsgBox, 308, %appname% (caution), %ED_SND%`n파일이 존재하지 않거나`, 읽을 권한이 없는 것 같습니다.`n`n이대로 진행하시겠습니까?
	IfMsgBox, No
	{
		Gui, -Disabled
		return
	}
}
if (CK_WIT = 1)
{
	ListBox_Batch_Process("[PLAY]  w1 " . ED_SND, "LineList", ED_SND . " SoundPlay 추가")
}
else
{
	ListBox_Batch_Process("[PLAY]  w0 " . ED_SND, "LineList", ED_SND . " SoundPlay 추가")
}
SetTimer, GetCurrentCoord, 250
Gui, -Disabled
return

BTN_AWI:
if (script_working = 1)
	return
IfInString, A_GuiControl, Info
{
	beeptoadd = *64
}
BTN_AWE:
if (script_working = 1)
	return
if (beeptoadd = "")
{
	beeptoadd = *16
}
Gui, Submit, NoHide
if (CK_WIT = 1)
{
	ListBox_Batch_Process("[PLAY]  w1 " . beeptoadd, "LineList", beeptoadd . " SoundPlay 추가")
}
else
{
	ListBox_Batch_Process("[PLAY]  w0 " . beeptoadd, "LineList", beeptoadd . " SoundPlay 추가")
}
beeptoadd=
return

;########### Run 탭

BTN_SRL:
SetTimer, GetCurrentCoord, Off
Gui, +Disabled
FileSelectFile, target_name, , , %appname% - Run에 추가하고픈 파일을 선택해주세요.
if (ErrorLevel = 1 || target_name = "")
{
	Gui, -Disabled
	return
}
Gui, -Disabled
GuiControl, , ED_RUN, %target_name%
SetTimer, GetCurrentCoord, 250
return

BTN_ARL:
Gui, Submit, NoHide
ListBox_Batch_Process("[RUN]  " . ED_RUN, "LineList", ED_RUN . " Run 추가")
return

;########### ImageSearch 탭

BTN_IMT:
GuiControlGet, ClickPos, Pos, ClickPos
if (A_GuiControl = "↑")
	GuiControl, Move, ClickPos, % "y"ClickPosY - 1
else If (A_GuiControl = "↓")
	GuiControl, Move, ClickPos, % "y"ClickPosY + 1
else If (A_GuiControl = "←")
	GuiControl, Move, ClickPos, % "x"ClickPosX - 1
else If (A_GuiControl = "→")
	GuiControl, Move, ClickPos, % "x"ClickPosX + 1
else if (A_GuiControl = "△")
	GuiControl, Move, ClickPos, % "y"ClickPosY - 10
else If (A_GuiControl = "▽")
	GuiControl, Move, ClickPos, % "y"ClickPosY + 10
else If (A_GuiControl = "◁")
	GuiControl, Move, ClickPos, % "x"ClickPosX - 10
else If (A_GuiControl = "▷")
	GuiControl, Move, ClickPos, % "x"ClickPosX + 10
GuiControlGet, ClickPos, Pos, ClickPos
if (ClickPosX < 630)
	GuiControl, Move, ClickPos, x630
else if (ClickPosX > 1060)
	GuiControl, Move, ClickPos, x1060
if (ClickPosY < 157)
	GuiControl, Move, ClickPos, y157
else if (ClickPosY > 377)
	GuiControl, Move, ClickPos, y377
GuiControlGet, ClickPos, Pos, ClickPos
imt_cx := ClickPosX - 845
imt_cy := ClickPosY - 267
todisplayimt = cx와 cy에는 이미지를 발견한 경우`,`ntx와 ty에 각 수치를 더하여 저장합니다.`n이를 활용하면 클릭할 지점을 보정할 수 있습니다.`n`n현재:`ncx = tx + %imt_cx%`ncy = ty + %imt_cy%
GuiControl, , TXT_CMT, %todisplayimt%
return

BTN_IMS:
SetTimer, GetCurrentCoord, Off
Gui, +Disabled
FileSelectFile, target_image, , , %appname% - ImageSearch에 추가하고픈 이미지를 선택해주세요., Image File (*.png; *.jpg; *.bmp)
if (ErrorLevel = 1 || target_image = "")
{
	Gui, -Disabled
	return
}
if (itgs = "")
	itgs = 1
else
	itgs++
Gui, Add, Picture, x2222 vPic%itgs%, %target_image%
GuiControlGet, ps, Pos, Pic%itgs%
GuiControl, , ED_IMT, %target_image%
if (psh > 110)
{
	r := 110 * 100 / psh
	th := Round(psh * (r / 100))
	tw := Round(psw * (r / 100))
	if (tw > 215)
	{
		r := 215 * 100 / psw
		tw := Round(psw * (r / 100))
		th := Round(psh * (r / 100))
	}
	psw := tw
	tw=
	psh := th
	th=
	r := Round(r)
	GuiControl, , TXT_CMT, 이미지가 너무 커서 %r% `%크기로 축소했습니다.`n*실제 cx와 cy값에는 원래 이미지 크기대로 계산됩니다.
	r=
}
GuiControl, Move, IMG_TAR, w%psw% h%psh%
Gui, -Disabled
SetTimer, GetCurrentCoord, 250
GuiControl, , IMG_TAR, %target_image%
GuiControl, Hide, Pic%itgs%
psx=
psy=
psw=
psh=
return

IMG_TOL:
MsgBox, 64, %appname% - Info, 기존 이미지에서 몇 `%까지의 오차를 허용할지 결정하는 값입니다.`n`n일반적으로 0`%~10`% 정도의 허용 오차를 권장합니다.`n경우에 따라서 ~50`%까지도 사용하기도 합니다.`n`n(이미지가 발견되지 않는 경우가 잦다면 이 값을 올려보세요.)
return

IMG_TRN:
MsgBox, 64, %appname% - Info, 이미지에서 제거할 배경색입니다.`n배경색을 제거하지 않아도 되는 경우 비워두세요.`n`nWhite:	#FFFFFF`nBlack:	#000000`nRed:	#FF0000`nGreen:	#00FF00`nBlue:	#0000FF
return

BTN_AIS:
Gui, Submit, NoHide
; ImageSearch, OutputVarX, OutputVarY, X1, Y1, X2, Y2, ImageFile
xn := "x+"imt_cx " y+"imt_cy
xn := xn " *" Round(255 * (SLD_TOL / 100))
if (DDL_COL != "")
	xn := xn " *Trans" DDL_COL
xn := xn " " ED_IMT
ListBox_Batch_Process("[IMGSRC]  " . xn, "LineList", xn . " 이미지서치 추가")
return

;########### Message Box 탭

BTN_MGT:
if (script_working = 1)
	return
Gui, Submit, NoHide
if (CK_AOT = 1)
{
	MsgBox, 262144, % ResolveVariables(ED_MST), % ResolveVariables(ED_MSP), %ED_MMS%
}
else
{
	MsgBox, , % ResolveVariables(ED_MST), % ResolveVariables(ED_MSP), %ED_MMS%
}
return

BTN_MGA:
if (script_working = 1)
	return
Gui, Submit, NoHide
ListBox_Batch_Process("[MSGBOX]  s" . ED_MMS . " a" . CK_AOT . " t(" . ED_MST . ")ㅤp(" . StringToLiteral(ED_MSP) . ")", "LineList", "MessageBox s" . ED_MMS . " a" . CK_AOT . " t(" . ED_MST . ")ㅤp(" . StringToLiteral(ED_MSP) . ")" . "  추가")
return

;####################### Loop 탭

BTN_LPO:
if (script_working = 1)
	return
Gui, Submit, NoHide
ListBox_Batch_Process("[LOOP]  " . ED_LCT, "LineList", ED_LCT . "번 루프 열기 추가")
return

BTN_LPC:
if (script_working = 1)
	return
ListBox_Batch_Process("}", "LineList", "} 추가")
return

;####################### If 탭

BTN_LAR:
Gui, Submit, Nohide
GuiControl, , ED_LVR, `%%DDL_SVR%`%
return

BTN_RAR:
Gui, Submit, Nohide
GuiControl, , ED_RVR, `%%DDL_SVR%`%
return

BTN_AIF:
Gui, Submit, Nohide
ListBox_Batch_Process("[IF]  " . ED_LVR . "ㅤ" . DDL_CMP . "ㅤ" . ED_RVR, "LineList", "조건문 " . ED_LVR . DDL_CMP . ED_RVR . " 추가")
return

;####################### Delay 탭

BTN_DLY:
if (script_working = 1)
	return
ListBox_Batch_Process("[DELAY]  " . btndlttrg, "LineList", btndlttrg . "ms 딜레이 추가")
return

;####################### Window 탭

BTN_GWN:
if (script_working = 1)
	return
Gui, +Disabled
GuiControl, , BTN_GWN, 대상 창을 클릭해주세요.
KeyWait, LButton, D
Sleep, 200
WinGetTitle, twin_title, a
WinGetPos, twin_x, twin_y, twin_w, twin_h, %twin_title%
GuiControl, , ED_WNM, %twin_title%
GuiControl, , ED_WWX, %twin_x%
GuiControl, , ED_WWY, %twin_y%
GuiControl, , ED_WWW, %twin_w%
GuiControl, , ED_WWH, %twin_h%
twin_title=
twin_x=
twin_y=
twin_w=
twin_h=
GuiControl, , BTN_GWN, 창 정보 가져오기
Gui, -Disabled
return

WNTB_TOT:
if (script_working = 1)
	return
Gui, Submit, NoHide
if (A_GuiControl = "BTN_W11") ; WinActivate
{
	WNTB_CMD = [W_ACT]  %ED_WNM%
	WNTB_LOG = %ED_WNM% 창 활성화 추가
}
else if (A_GuiControl = "BTN_W12") ; WinClose
{
	WNTB_CMD = [W_CLS]  %ED_WNM%
	WNTB_LOG = %ED_WNM% 창 닫기 추가
}
else if (A_GuiControl = "BTN_W13") ; WinKill
{
	WNTB_CMD = [W_KIL]  %ED_WNM%
	WNTB_LOG = %ED_WNM% 창 강제종료 추가
}
else if (A_GuiControl = "BTN_W21") ; WinWait
{
	WNTB_CMD = [W_WAI]  %ED_WNM%
	WNTB_LOG = %ED_WNM% 창 기다리기 추가
}
else if (A_GuiControl = "BTN_W22") ; WinWaitActivate
{
	WNTB_CMD = [W_WAC]  s%ED_WWS% %ED_WNM%
	WNTB_LOG = %ED_WNM% 창 활성 기다리기 추가
}
else if (A_GuiControl = "BTN_W23") ; WinWaitNotActivate
{
	WNTB_CMD = [W_WNA]  s%ED_WWS% %ED_WNM%
	WNTB_LOG = %ED_WNM% 창 비활성 기다리기 추가
}
else
{
	return
}
ListBox_Batch_Process(WNTB_CMD, "LineList", WNTB_LOG)
WNTB_CMD=
WNTB_LOG=
return

BTN_AWM:
if (script_working = 1)
	return
Gui, Submit, NoHide
ListBox_Batch_Process("[W_MOV]  x" . ED_WWX . " y" . ED_WWY . " w" . ED_WWW . " h" . ED_WWH . " " . ED_WNM, "LineList", "x" . ED_WWX . " y" . ED_WWY . " w" . ED_WWW . " h" . ED_WWH . " " . ED_WNM . " 창 이동 추가")
return

;####################### Menu와 기본 GUI 버튼

SaveMacro:
if (script_working = 1 || listvar.MaxIndex() = "" || listvar.MaxIndex() = 0)
	return
SetTimer, GetCurrentCoord, Off
Gui, Hide
InputBox, target_name, %appname% - 매크로 저장, 매크로의 이름을 적어주세요.`n이 이름은 컴퓨터에 매크로를 저장할 파일 이름으로도 사용됩니다.`n`n(비어있으면 현재 날짜와 시간으로 자동 생성됩니다.)
Gui, Show
SetTimer, GetCurrentCoord, 250
if (ErrorLevel = 1)
	return
if (target_name = "")
	target_name = %A_YYYY%-%A_MM%-%A_DD%-%A_Hour%_%A_Min%_%A_Sec%-v%appversion%
MacroSave(target_name)
return

LoadMacro:
if (script_working = 1)
	return
SetTimer, GetCurrentCoord, Off
Gui, Hide
IfExist, %A_ScriptDir%\macros
	FileSelectFile, target_name, , %A_ScriptDir%\macros, FlowQuill에 불러올 FQM 파일을 선택해주세요., FlowQuillMacro (*.fqm)
else
	FileSelectFile, target_name, , , FlowQuill에 불러올 FQM 파일을 선택해주세요., FlowQuillMacro (*.fqm)
SetTimer, GetCurrentCoord, 250
if (ErrorLevel = 1 || target_name = "")
{
	Gui, Show
	return
}
MsgBox, 4420, %appname% - Load Macro, 선택한 FQM 파일에서 매크로를 읽어오려합니다.`n이 작업을 수행하면 현재 인터페이스에 구성된 매크로가 삭제됩니다.`n(진행하기 전`, 매크로 저장을 권장합니다.)`n`n진행하시겠습니까?
IfMsgBox, No
{
	Gui, Show
	return
}
SB_SetText("매크로 불러오는 중:		" . target_name)
MacroLoad(target_name)
SB_SetText("매크로를 불러왔습니다:		" . target_name)
Gui, Show
return

GuShow:
Gui, Show
Menu, Tray, NoIcon
return

MinimizeToTray:
Menu, Tray, Icon
Gui, Hide
return

GuiClose:
WinGetPos, xts, yts, , , %appname% [v%appversion%]
RegWrite, REG_DWORD, HKCU, SOFTWARE\P23Soft\%appname%, winX, %xts%
RegWrite, REG_DWORD, HKCU, SOFTWARE\P23Soft\%appname%, winY, %yts%
ExitApp

Nothing:
return

OpenMouseDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/MouseMove.htm
return

OpenBezierDocs:
Run, https://w.wiki/CQTL
return

OpenSendDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/Send.htm#%EB%A7%A4%EA%B0%9C%EB%B3%80%EC%88%98
return

OpenSoundPlayDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/SoundPlay.htm
return

OpenRunDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/Run.htm
return

OpenImageSearchDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/ImageSearch.htm
return

OpenMsgBoxDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/MsgBox.htm
return

OpenLoopDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/Loop.htm
return

OpenIfDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/IfExpression.htm
return

OpenDelayDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/Sleep.htm
return

OpenWindowDocs:
Run, https://autohotkeykr.sourceforge.net/docs/commands/WinActivate.htm
return

AppInfo:
MsgBox, 4160, %appname% [v%appversion%] - 정보, 제작: P23 (PPPurple23)`n`n문의 연락처: pppurple23@proton.me`n`n빌드된 날짜: %appbuilddate%`n버전: %appversion%`n`n`n업데이트 내용: %appupdatedetails%
return

GoGithub:
Run, https://github.com/PPPurple23/P23s_FlowQuill
return

;############################################# 함수 및 기타

SetHotkey:
Gui, Submit, NoHide
if (keyready != 1)
{
	GuiControl, +Disabled, ScriptExploter
	GuiControl, +Disabled, SetHotkey
	GuiControl, , SetHotkey, ...
	Hotkey, $%ScriptExploter%, RunScript
	Sleep, 1000
	GuiControl, , SetHotkey, 스크립트 단축키 삭제
	GuiControl, -Disabled, SetHotkey
	keyready = 1
}
else
{
	GuiControl, +Disabled, SetHotkey
	GuiControl, , SetHotkey, ...
	Hotkey, $%ScriptExploter%, RunScript, Off
	Sleep, 1000
	GuiControl, , SetHotkey, 스크립트 단축키 지정
	GuiControl, -Disabled, SetHotkey
	GuiControl, -Disabled, ScriptExploter
	keyready = 0
}
return

RunScript:
if (listvar.MaxIndex() = "" || listvar.MaxIndex() = 0 || script_working = 1)
	return
SB_SetText("	매크로 실행 준비 중..")
GuiControl, +Disabled, BTN_RUN
GuiControl, -Disabled, BTN_STP
script_working = 1
current_line = 1
depth = 0
SB_SetText("	매크로 진입 중..")
Loop
{
	line_content := listvar[current_line]
	if (line_content = "}")
	{
		com = }
	}
	else
	{
		StringGetPos, comlen, line_content, ]
		comlen++
		StringLeft, com, line_content, %comlen%
		StringTrimLeft, com, com, 1
		StringTrimRight, com, com, 1
		StringTrimLeft, params, line_content, % comlen + 2
		if (com = "SEND" || com = "LOOP" || com = "DELAY" || com = "W_ACT" || com = "W_CLS" || com = "W_KIL" || com = "W_WAI" || com = "RUN")
		{
			param1 := params
		}
		else if (com = "IF")
		{
			Loop, Parse, params, ㅤ
			{
				param%A_Index% := A_LoopField
				temp_param := param%A_Index%
			}
		}
		else if (com != "MSGBOX" && com != "W_WAC" && com != "W_WNA" && com != "PLAY" && com != "W_MOV" && com != "IMGSRC")
		{
			Loop, Parse, params, %A_Space%
			{
				param%A_Index% := A_LoopField
				temp_param := param%A_Index%
			}
			if (com ="MOUSE MOVE")
			{
				TrimCorner(param1, 1)
				TrimCorner(param2, 1)
				TrimCorner(param3, 1)
			}
			else if (com ="MOUSE MOVE+")
			{
				TrimCorner(param1, 2)
				TrimCorner(param2, 2)
				TrimCorner(param3, 2)
				TrimCorner(param4, 2)
				TrimCorner(param5, 1)
			}
			else if (com ="BEZIER MOVE")
			{
				TrimCorner(param1, 2)
				TrimCorner(param2, 2)
				TrimCorner(param3, 2)
				TrimCorner(param4, 2)
				TrimCorner(param5, 1)
				TrimCorner(param6, 1)
				TrimCorner(param7, 1)
			}
		}
		else
		{
			if (com = "MSGBOX")
			{
				SplitByCustomChars("param1", params, "a")
				SplitByCustomChars("param2", params, "t")
				SplitByCustomChars("param3", params, "ㅤp")
				StringTrimLeft, params, params, 1
				param4 := params
				TrimCorner(param1, 1)
				TrimCorner(param2, 1)
				TrimCorner(param3, 2, 1)
				TrimCorner(param4, 2, 1)
			}
			else if (com = "W_WAC" || com = "W_WNA" || com = "PLAY")
			{
				SplitByCustomChars("param1", params, " ")
				StringTrimLeft, params, params, 1
				param2 := params
				TrimCorner(param1, 1)
			}
			else if (com = "W_MOV")
			{
				SplitByCustomChars("param1", params, "y") ; x
				SplitByCustomChars("param2", params, "w") ; y
				SplitByCustomChars("param3", params, "h") ; w
				SplitByCustomChars("param4", params, " ") ; h
				StringTrimLeft, params, params, 1
				param5 := params
				TrimCorner(param1, 1, 1)
				TrimCorner(param2, 1, 1)
				TrimCorner(param3, 1, 1)
				TrimCorner(param4, 1)
			}
			else if (com = "IMGSRC")
			{
				SplitByCustomChars("param1", params, "y+") ; x
				SplitByCustomChars("param2", params, "*") ; y
				param3 := params
				TrimCorner(param1, 2, 1)
				TrimCorner(param2, 2, 1)
			}
		}
	}
	SB_SetText("	" . current_line . "번 라인 처리 중")
	; 인터프리터 시작 지점
	if (endscript = 1)
	{
		endscript=
		break
	}
	else if (com = "}")
	{
		if (isvalid != "")
		{
			isvalid=
		}
		else
		{
			if (loop_%depth%_depth_index = 1)
				exit_of_depth_%depth% := current_line
			loop_%depth%_depth_index += 1
			index := loop_%depth%_depth_index
			current_line := return_of_loop_%depth% - 1
			if (loop_%depth%_depth_index > exit_condition_%depth%)
			{
				current_line := exit_of_depth_%depth%
				loop_%depth%_depth_index=
				exit_condition_%depth%=
				exit_of_depth_%depth%=
				return_of_loop_%depth%=
				depth--
				if (depth < 0)
					break
			}
		}
	}
	else if (isvalid = "false")
	{
		; mute commands
	}
	else if (com = "LOOP")
	{
		depth++
		return_of_loop_%depth% := current_line + 1
		exit_condition_%depth% := param1
		if (param1 = 0)
			exit_condition_%depth% = 2147483647
		loop_%depth%_depth_index = 1
		index = 1
	}
	else if (com = "IF")
	{
		; param1	cmp	param3
		ResolveVariables(param1)
		ResolveVariables(param3)
		if (param2 = "=" && param1 = param3)
			isvalid = true
		else if (param2 = "!=" && param1 != param3)
			isvalid = true
		else if (param2 = ">" && param1 > param3)
			isvalid = true
		else if (param2 = "<" && param1 < param3)
			isvalid = true
		else if (param2 = ">=" && param1 >= param3)
			isvalid = true
		else if (param2 = "<=" && param1 <= param3)
			isvalid = true
		else
			isvalid = false
	}
	else if (com = "SEND")
	{
		; (text to send)
		ResolveVariables(param1)
		Send, %param1%
	}
	else if (com = "MOUSE MOVE")
	{
		; x	y	s(peed)
		ResolveVariables(param1)
		ResolveVariables(param2)
		MouseMove, %param1%, %param2%, %param3%
	}
	else if (com = "MOUSE MOVE+")
	{
		; sx	sy	ex	ey	s(peed)
		ResolveVariables(param1)
		ResolveVariables(param2)
		ResolveVariables(param3)
		ResolveVariables(param4)
		Random, tx, %param1%, %param3%
		Random, ty, %param2%, %param4%
		MouseMove, %tx%, %ty%, %param5%
		tx=
		ty=
	}
	else if (com = "BEZIER MOVE")
	{
		; sx	sy	ex	ey	s(peed)	c(urv's rate)	d(irection of curv)
		ResolveVariables(param1)
		ResolveVariables(param2)
		ResolveVariables(param3)
		ResolveVariables(param4)
		Random, tx, %param1%, %param3%
		Random, ty, %param2%, %param4%
		BezierMouseMove(tx, ty, , , Round(param6 / 10, 1), param5, param7)
		tx=
		ty=
	}
	else if (com = "PLAY")
	{
		; w(ait)	file
		ResolveVariables(param2)
		IfExist, %param2%
		{
			if (param1 = 1)
				SoundPlay, %param2%, wait
			else
				SoundPlay, %param2%
		}
		else
		{
			MsgBox, 4112, %appname% (fail), %param2% 파일이 존재하지 않거나`, 읽을 권한이 없습니다.`n`n[확인]버튼을 누르면 이후 코드가 실행됩니다., 30
		}
	}
	else if (com = "RUN")
	{
		; (url or file to run)
		ResolveVariables(param1)
		Run, %param1%
	}
	else if (com = "IMGSRC")
	{
		; x+	y+	(image file with options)
		ImageSearch, tx, ty, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, %param3%
		if (ErrorLevel = 0)
		{
			cx := tx + param1
			cy := ty + param2
			isimage = true
		}
		else if (ErrorLevel = 1)
		{
			cx=
			cy=
			isimage = false
		}
		else
		{
			cx=
			cy=
			isimage = error
		}
		ToolTip, %isimage%`nx: %tx%`ny: %ty%, %cx%, %cy%
	}
	else if (com = "MSGBOX")
	{
		; s(econds to close) a(lways on top) t(itle) p(rompt)
		param4 := LiteralToString(ResolveVariables(param4))
		if (param2 = 0)
			MsgBox, , % ResolveVariables(param3) , %param4%, %param1%
		else
			MsgBox, 4096, % ResolveVariables(param3) , %param4%, %param1%
	}
	else if (com = "DELAY")
	{
		; delay(in ms)
		IfNotInString, param1, -
		{
			Sleep, %param1%
		}
		else
		{
			StringSplit, parts, param1, -
			if (parts1 > parts2)
				slp := parts1
			else
				Random, slp, %parts1%, %parts2%
			Sleep, %slp%
			slp=
		}
	}
	else if (com = "W_ACT") ; 윈도우 활성화
	{
		; wintitle
		ResolveVariables(param1)
		WinActivate, %param1%
	}
	else if (com = "W_CLS") ; 윈도우 닫기
	{
		; wintitle
		ResolveVariables(param1)
		WinClose, %param1%
	}
	else if (com = "W_KIL") ; 윈도우 강제 종료
	{
		; wintitle
		ResolveVariables(param1)
		WinKill, %param1%
	}
	else if (com = "W_WAI") ; 윈도우 대기
	{
		; wintitle
		ResolveVariables(param1)
		WinWait, %param1%
	}
	else if (com = "W_WAC") ; 윈도우 활성화 대기
	{
		; s(econd to wait) wintitle
		ResolveVariables(param1)
		WinWaitActive, %param2%, , %param1%
	}
	else if (com = "W_WNA") ; 윈도우 비활성화 대기
	{
		; s(econd to wait) wintitle
		ResolveVariables(param2)
		WinWaitNotActive, %param2%, , %param1%
	}
	else if (com = "W_MOV")
	{
		; x y w h wintitle
		ResolveVariables(param5)
		WinMove, %param5%, , %param1%, %param2%, %param3%, %param4%
	}
	else
	{
		MsgBox, 4112, %appname% (unknown command), Current Line: %current_line%`nCommand: %com%`n`n알 수 없는 이유로 무슨 명령어인지 감지할 수 없습니다.`n[확인]버튼을 누르면 이후 코드를 전부 무시하고 스크립트가 중단됩니다.
		SB_SetText("	스크립트 중단됨")
		break
	}
	current_line++
	Loop ; 파라미터 메모리 릴리즈
	{
		if (param%A_Index% = "")
			break
		param%A_Index%=
	}
	if (current_line > listvar.MaxIndex())
	{
		break
	}
}
depth=
com=
converted_code=
total_lines=
current_line=
line_content=
string_send=
script_working=
GuiControl, -Disabled, BTN_RUN
GuiControl, +Disabled, BTN_STP
SB_SetText("	스크립트 종료됨")
return

*~^+Del::
StopScript:
if (script_working = 1)
{
	endscript = 1
}
return

GetCurrentCoord:
IfWinNotActive, %appname% [v%appversion%]
{
	Sleep, 500
	return
}
MouseGetPos, mpx, mpy
GuiControl, , CurPos1, 현재 좌표:`n`nx%mpx%`ny%mpy%
return

SB_SetCoord:
MouseGetPos, mmpx, mmpy
GuiControl, Block:, RealRecord, 기록할 위치에 마우스 좌클릭	x%mmpx% y%mmpy%
return

MacroSave(target_name)
{
	global listvar
	global appname
	IfNotExist, %A_ScriptDir%\macros
	{
		FileCreateDir, %A_ScriptDir%\macros
	}
	IfExist, %A_ScriptDir%\macros\%target_name%.fqm
	{
		MsgBox, 4388, %appname% - MacroSave, %target_name%.fqm`n파일이 이미 존재합니다.`n`n덮어쓰기 하겠습니까?
		IfMsgBox, No
		{
			return
		}
		FileDelete, %A_ScriptDir%\macros\%target_name%.fqm
		if (ErrorLevel = 1)
			MsgBox, 4112, %appname% - Error, 기존 파일의 삭제에 실패했습니다.`n`n관리자 권한으로 실행했는지 확인해주세요.
	}
	FileAppend, , %A_ScriptDir%\macros\%target_name%.fqm, UTF-8
	if (ErrorLevel = 1)
		MsgBox, 4112, %appname% - Error, 매크로 파일의 저장에 실패했습니다.`n`n관리자 권한으로 실행했는지 확인해주세요.
	Loop, % listvar.MaxIndex()
	{
		current_content := listvar[A_Index]
		if (A_Index = 1 && current_content = "")
		{
			FileDelete, %A_ScriptDir%\macros\%target_name%.fqm
		}
		if (A_Index = 1)
			FileAppend, %current_content%, %A_ScriptDir%\macros\%target_name%.fqm, UTF-8
		else
			FileAppend, `r%current_content%, %A_ScriptDir%\macros\%target_name%.fqm, UTF-8
	}
	MsgBox, 4160, %appname% - Saved, %target_name%.fqm`n파일에 저장했습니다., 5
}

MacroLoad(target_name)
{
	global listvar
	IfNotExist, %target_name%
	{
		SB_SetText("불러오기 취소(없는 파일이거나 권한 없음):		" . target_name)
		return
	}
	FileReadLine, cur_cont, %target_name%, 1
	StringLeft, st_txt, cur_cont, 1
	if (st_txt != "[")
	{
		SB_SetText("불러오기 취소(지원하지 않는 파일 형식):		" . target_name)
		return
	}
	listvar=
	listvar := {}
	Loop, Read, %target_name%
	{
		StringLeft, st_txt, A_LoopReadLine, 1
		if (st_txt != "[" && st_txt != "}")
		{
			SB_SetText("불러오기 실패(지원하지 않는 파일 형식):		" . target_name)
			return
		}
		listvar[A_Index] := A_LoopReadLine
	}
	ListBox_Convert_Out(listvar, "LineList")
	SB_SetText("매크로를 불러왔습니다:		" . target_name)
}

RecordCoord(TargetButton, xEdit, yEdit, ButtonName)
{
	global
	tbutton := TargetButton
	xedt := xEdit
	yedt := yEdit
	bname := ButtonName
	GuiControl, , %TargetButton%, 준비 중...
	Gui, Block:Show, % "x"-100 " y"-100 " w"A_ScreenWidth + 200 " h"A_ScreenHeight + 200 , doyouthinkyoucanskipme?srsly??
	WinSet, Transparent, 50, doyouthinkyoucanskipme?srsly??
	SetTimer, GetReady, 1
}

SplitByCustomChars(ByRef OutputVar, ByRef InputVar, SplitChar, TrimInput := "1")
{
	StringGetPos, CharPos, InputVar, %SplitChar%
	StringLeft, %OutputVar%, InputVar, %CharPos%
	if (TrimInput = 1)
		StringTrimLeft, InputVar, InputVar, %CharPos%
}

TrimCorner(ByRef InputVar, Left := "", Right := "")
{
	if not (Left = 0 || Left = "")
		StringTrimLeft, InputVar, InputVar, %Left%
	if not (Right = 0 || Right = "")
	StringTrimRight, InputVar, InputVar, %Right%
}

ListBox_Move_Up()
{
	global listvar
	GuiControlGet, targetline, , LineList
	if (targetline = 1 || targetline = "")
		return
	uparray := listvar[targetline - 1]
	downarray := listvar[targetline]
	listvar[targetline - 1] := downarray
	listvar[targetline] := uparray
	ListBox_Convert_Out(listvar, "LineList")
	GuiControl, Choose, LineList, % targetline-1
}

ListBox_Move_Down()
{
	global listvar
	GuiControlGet, targetline, , LineList
	if (targetline = listvar.MaxIndex() || targetline = "")
		return
	uparray := listvar[targetline]
	downarray := listvar[targetline + 1]
	listvar[targetline] := downarray
	listvar[targetline + 1] := uparray
	ListBox_Convert_Out(listvar, "LineList")
	GuiControl, Choose, LineList, % targetline+1
}

ListBox_Copy()
{
	global listvar
	GuiControlGet, targetline, , LineList
	if (targetline = "")
		return
	selectedline := listvar[targetline]
	Loop
	{
		StringLeft, teststring, selectedline, 1
		if (teststring = "　")
		{
			StringTrimLeft, selectedline, selectedline, 1
		}
		else
		{
			break
		}
	}
	GuiControl, -Disabled, BTN_Paste
	AdvancedStatusBar(selectedline . " 복사됨")
	return selectedline
}

ListBox_Paste()
{
	global listvar
	global temporary_saved_line
	GuiControlGet, targetline, , LineList
	if (targetline = "")
		return
	if (targetline != listvar.MaxIndex())
	{
		targetline++
		max := listvar.MaxIndex()
		Loop, % listvar.MaxIndex() - targetline + 1
		{
			up := max + 1 - A_Index
			down := max + 2 - A_Index
			listvar[down] := listvar[up]
		}
	}
	else
	{
		targetline++
	}
	listvar[targetline] := temporary_saved_line
	ListBox_Convert_Out(listvar, "LineList")
	GuiControl, Choose, LineList, % targetline
	AdvancedStatusBar(temporary_saved_line . " 붙여넣기함")
}

ListBox_Delete()
{
	global listvar
	GuiControlGet, targetline, , LineList
	if (targetline = "")
		return
	if (targetline != listvar.MaxIndex())
	{
		Loop, % listvar.MaxIndex() - targetline + 1
		{
			up := targetline - 1 + A_Index
			down := up + 1
			upte := listvar[up]
			downte := listvar[down]
			listvar[up] := listvar[down]
		}
		max := listvar.MaxIndex()
		listvar.delete(max)
	}
	else
	{
		listvar.delete(targetline)
	}
	ListBox_Convert_Out(listvar, "LineList")
	AdvancedStatusBar(targetline . "번 라인 삭제함")
	GuiControl, Choose, LineList, % targetline
}

ListBox_Batch_Process(linetoadd, targetgui, logdetail)
{
	global listvar
	ListBox_Add_Array(listvar, linetoadd)
	ListBox_Convert_Out(listvar, targetgui)
	AdvancedStatusBar(logdetail)
}

ListBox_Add_Array(inputlist, arraytoadd)
{
	global listvar
	LineCount := inputlist.MaxIndex()
	if (LineCount = "")
	{
		LineCount = 0
	}
	NextLineNumber := LineCount + 1
	listvar[NextLineNumber] := arraytoadd
}

ListBox_Convert_Out(inputlist, guitodisplay)
{
	GuiControl, , %guitodisplay%, |
	LineCount := inputlist.MaxIndex()
	Convertor_Depth=
	if (LineCount = "" || LineCount = 0)
	{
		return
	}
	Loop, % inputlist.MaxIndex()
	{
		tp := inputlist[A_Index]
		if (tp = "}")
		{
			StringTrimLeft, Convertor_Depth, Convertor_Depth, 1
		}
		else
		{
			StringLeft, teststring, tp, 6
			if (teststring = "[LOOP]" || teststring = "[IF]  ")
			{
				to_add_depth_later = 1
			}
		}
		GuiControl, , %guitodisplay%, %Convertor_Depth%%tp%
		if (to_add_depth_later = 1)
		{
			Convertor_Depth .= "　"
			to_add_depth_later=
		}
	}
	GuiControl, Choose, %guitodisplay%, % inputlist.MaxIndex()
}

AdvancedStatusBar(inputlog = "")
{
	global listvar
	global sblastlog
	GuiControlGet, ListSelectIndex, , LineList
	if (inputlog = "")
	{
		SB_SetText(listvar[ListSelectIndex] . "	(" . ListSelectIndex . " / " . listvar.MaxIndex() . ")	" . sblastlog)
	}
	else
	{
		SB_SetText(listvar[ListSelectIndex] . "	(" . ListSelectIndex . " / " . listvar.MaxIndex() . ")	" . inputlog)
		sblastlog := inputlog
	}
	GuiControl, -Disabled, BTN_Up
	GuiControl, -Disabled, BTN_Down
	GuiControl, -Disabled, BTN_Copy
}

WM_RBUTTONDOWN(wParam, lParam, msg, hwnd)
{
	global listvar
	if not (listvar.MaxIndex() > 0)
	{
		return
	}
	GuiControlGet, ctrl, Hwnd, LineList
	if (hwnd = ctrl)
	{
		Menu, EditMenu, Show
	}
}

AdvancedMouseMove(x := "0", y := "0")
{
	DllCall("mouse_event", "uint", 0x0001, "int", x, "int", y, "uint", 0, "int", 0)
}

AccurateSleep(ms)
{
	DllCall("Sleep", "UInt", ms)
}

BezierMouseMove(EndX, EndY, StartX := "", StartY := "", Curvature := 0.5, Speed := 50, CurvUDR := "R")
{
    if (StartX = "" or StartY = "") {
        MouseGetPos, CurrentX, CurrentY
        if (StartX = "")
            StartX := CurrentX
        if (StartY = "")
            StartY := CurrentY
    }
    ControlX := (StartX + EndX) / 2
    if (CurvUDR = "R")
    {
        Random, UDR, 0, 1
    }
    if (CurvUDR = "U" || UDR = 0)
    {
        ControlY := (StartY + EndY) / 2 - (Curvature * Abs(EndX - StartX))
    }
    else if (CurvUDR = "D" || UDR = 1)
    {
        ControlY := (StartY + EndY) / 2 + (Curvature * Abs(EndX - StartX))
    }
    t := 0
    Loop
    {
        x := (1-t)*(1-t)*StartX + 2*(1-t)*t*ControlX + t*t*EndX
        y := (1-t)*(1-t)*StartY + 2*(1-t)*t*ControlY + t*t*EndY
        MouseMove, %x%, %y%, %Speed%
        t += 0.01
        if (t > 1)
        {
            break
        }
    }
}

StringToLiteral(string)
{
    return StrReplace(StrReplace(string, "`r`n", "\n"), "`n", "\n")
}

LiteralToString(literal)
{
    return StrReplace(literal, "\n", "`r`n")
}

ResolveVariables(ByRef inputVar)
{
    Loop
    {
        if !RegExMatch(inputVar, "%(.*?)%", match)
		{
            break
        }
        varName := match1
        if (VarExist(varName))
            temp_var := %varName%
        else
            temp_var := ""
        StringReplace, inputVar, inputVar, % "%" varName "%" , % temp_var , All
    }
	return inputVar
}

VarExist(varName)
{
    return IsByRef(varName) || !("" = "" . %varName%)
}

CFBHaT(original_string,start,end,stol:="",etol:="")
{

	StringLen, start_length, start
	StringLen, end_length, end
    if (stol = "")
        StringGetPos, starts_start_pos, original_string, %start%
    else
        StringGetPos, starts_start_pos, original_string, %start%, %stol%
    if (etol = "")
        StringGetPos, ends_start_pos, original_string, %end%, , %starts_start_pos%
    else
        StringGetPos, ends_start_pos, original_string, %end%, %etol%, %starts_start_pos%
	starts_end_pos := starts_start_pos + start_length + 1
	ends_end_pos := ends_start_pos + end_length
	space_length := ends_start_pos - starts_end_pos + 1
	StringMid, result, original_string, %starts_end_pos%, %space_length%
	return result
}
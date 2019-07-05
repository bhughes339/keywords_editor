;
; General Info:
;
; Consolas font width chart:
;
; Font Size | Width (px)
; =========   ==========
; 10          7
; 11          8
; 12          9
; 14          10
; 
; For Edits with vertical scroll bar: add 30px to the max width
;
#NoTrayIcon
#SingleInstance On

CoordMode, Mouse, Screen

global settingsFile := RegexReplace(A_ScriptName, "\.[^.]+$", "") ".ini"
global savedFile := A_ScriptDir . "/~saved_keywords.txt"
global fSizes := {10: 7, 11: 8, 12: 9, 14: 10}
global validDateFormats := ["dd MMM yyyy", "MMM dd, yyyy", "MM/dd/yyyy", "yyyy/MM/dd"]
global fontSize
global mnemonic
global dateFormat
global defaultTemplateName := "Intl Group: Keywords"
global templates := {}
tempText =
(
Status        Date
------------------
Inhouse     -                    Interactions (to TEST):
TEST        -                    Interactions (to LIVE):
LIVE        - 
TRAIN (RFT) -                    Interactions (from TEST):

            * If there are no Interactions, please enter 'None'
             MUST include date & Mnemonic for all Interaction checking
            * Patched/Custom code: please add Peer Reviewer/Date below

Patched/Custom?         Peer Reviewer/Date:


Dev ID / DTS / Change Number
--------------------------


*Required/Caused Dev IDs: Were ALL evaluated (include Details)? 
*M-AT Standard change: Was 'Reconcile Patched Code' checked? 

Special Instructions   (Client Update?  Y/N)
--------------------
(Date done in...)   Inhouse:       TEST:      LIVE: 

Downtime
-------------

Routines impacted
-----------------

Programs/Menus/ddeffs
---------------------

 *To cut and paste into the keyword section, leave no blank lines
 *After loading the change to TEST, check against LIVE for Interactions
)
templates["Intl Group: Keywords"] := tempText
tempText =
(
Inhouse text contains program(s)/change#(s)/Dev ID(s)?
Dev ID patch/move: Were Required/Caused Dev ID(s) eval'd & documented? 
Keyword(s) filled out appropriately?
Was 'Client Update?  Y/N' field responded to?
Dev section updated?
Change number(s) contain all programs/menus/ddeff?
Code review (pgms/ddeff/menus) looks correct?
Pgms/Macros: Cust. Notes & Commented lines are thorough?  (Y/N)
ddeff/Menu changes: Documented in an included 'z...' pgm s comments?

Confirm code is documented as described, for: 
 (Custom code) 'Process' section of custom spec. has appropriate comments?
 (Loops - Data changing) as 'Custom code' and coded in a zcus program?
 (Loops - Searching/counting) in In-house text has appropriate comments?
 (Trap code) details in Keywords, and the 'Trap File?' flag is set to 'Y'es?

(For M-AT changes)
CORE customs item has been updated with this patch information?

Peer Reviewer: List your questions/concerns with their resolutions.
)
templates["Intl Group: Peer Review"] := tempText
global defaultTemplate := templates[defaultTemplateName]
global userTemplates := {}
readSettings()
Gosub InitGui
loadSavedKeywords(hEdit)
Return

; =======
; Hotkeys
; =======

!+v::
fText := getFormattedText(hEdit)
SendInput {End}{Space}
Loop, Parse, fText, `n, `r
{
    Sleep 50
    line := RTrim(A_LoopField)
    if (line == "") {
        line := " "
    }
    SendInput {Ins}
    SendInput {raw}%line%
    SendInput {Down}
}
SendInput {Ins}================================================================================{Down}{Ins}{Space}
Return

; ===========
; Subroutines
; ===========

InitGui:
Gui, Main:New, HwndMainHwnd, Keywords Editor
Gui, Font, s%fontSize% norm, Consolas

; -- File
; ---- :TemplateMenu
Gosub UpdateTemplateMenu
Menu, FileMenu, Add, Load template, :TemplateMenu

Menu, FileMenu, Add, Set mnemonic..., SetMnemonic
Menu, FileMenu, Add, Save current text as template`tCtrl+S, SaveTemplate
Menu, FileMenu, Add, Exit, MainGuiClose

; -- Actions
Menu, ActionMenu, Add, Insert date at cursor`tCtrl+D, AddDate

; -- View
; ---- :FontMenu
for key, value in fSizes {
    Menu, FontMenu, Add, %key%, FontMenuHandler
    if (key == fontSize) {
        Menu, FontMenu, Check, %key%
    }
}
Menu, ViewMenu, Add, Font size, :FontMenu

; ---- :DateFormatMenu
for index, value in validDateFormats {
    tempFormat := todayToFormat(value)
    Menu, DateFormatMenu, Add, %tempFormat%, DateFormatMenuHandler
    if (value == dateFormat) {
        Menu, DateFormatMenu, Check, %tempFormat%
    }
}
Menu, ViewMenu, Add, Date format, :DateFormatMenu

; -- Menu
Menu, MenuBar, Add, File, :FileMenu
Menu, MenuBar, Add, Actions, :ActionMenu
Menu, MenuBar, Add, View, :ViewMenu
Gui, Menu, MenuBar

Gui, Font, s%fontSize% norm, Verdana
Gui, Add, Button, xm vCopyToClip gCopyToClip, Copy to Clipboard
Gui, Add, Button, ys vKeywordTemp gKeywordsTemplate Section, Initialize with Keywords Template
GuiControlGet, CopyToClip, Main:Pos
GuiControlGet, KeywordTemp, Main:Pos
GuiControl, Main:Move, KeywordTemp, % "x" getEditWidthScroll(80) - KeywordTempW + CopyToClipX
Gui, Font, s%fontSize% norm, Consolas

Gui, Add, Edit, % "xm r30 vTextSection HwndhEdit gTextSection w" getEditWidthScroll(80)

Gui, Font, s%fontSize% bold, Verdana
Gui, Add, Text, % "xm w" getEditWidthScroll(80), ** Press Alt+Shift+V in the Keywords section of a task to paste the text above the current cursor.

Gui, Show

Hotkey, IfWinActive, ahk_id %MainHwnd%
; Add any program-specific hotkeys here

Return

; ===========
; Subroutines
; ===========

TextSection:
Edit_WriteFile(hEdit, savedFile)
Return


UpdateTemplateMenu:
Menu, TemplateMenu, Add
Menu, TemplateMenu, DeleteAll
for key, value in templates {
    Menu, TemplateMenu, Add, %key%, TemplateMenuHandler
}
Menu, TemplateMenu, Add
for key, value in userTemplates {
    Menu, TemplateMenu, Add, %key%, CustomTemplateMenuHandler
}
Return


TemplateMenuHandler:
replaceText(hEdit, templates[A_ThisMenuItem])
Return


CustomTemplateMenuHandler:
replaceText(hEdit, userTemplates[A_ThisMenuItem])
Return


FontMenuHandler:
for key, value in fSizes {
    Menu, FontMenu, Uncheck, %key%
}
fontSize := A_ThisMenuItem
IniWrite, %fontSize%, %settingsFile%, Settings, fontsize
Menu, FontMenu, Check, %fontSize%
GuiControlGet, TextSection, Main:
Gosub InitGui
GuiControl, Main:, TextSection, %TextSection%
Return


DateFormatMenuHandler:
for index, value in validDateFormats {
    Menu, DateFormatMenu, Uncheck, %index%&
}
dateFormat := validDateFormats[A_ThisMenuItemPos]
IniWrite, %dateFormat%, %settingsFile%, Settings, dateFormat
Menu, DateFormatMenu, Check, %A_ThisMenuItemPos%&
Return


SetMnemonic:
Gui Main:+OwnDialogs
InputBox, tempMnemonic, Set mnemonic, Enter your mnemonic (will be truncated to 4 characters):, , , 150, , , , , %mnemonic%
if (ErrorLevel == 0) {
    mnemonic := SubStr(tempMnemonic, 1, 4)
    IniWrite, %mnemonic%, %settingsFile%, Settings, mnemonic
}
Return


SaveTemplate:
Gui Main:+OwnDialogs
InputBox, templateName, Save template, Enter a name for your template (maximum 30 characters):, , , 150
if (ErrorLevel == 0) {
    templateName := SubStr(templateName, 1, 30)
    ; Replace "=" because of INI format
    templateName := RegExReplace(templateName, "=", "_")
    IniRead, existing, %settingsFile%, Templates, %templateName%, %A_Space%
    if (existing || userTemplates[templateName]) {
        MsgBox, 1, Template exists, There is already a template with this name. Overwrite?
        IfMsgBox, Cancel
            Return
    }
    editText := Edit_GetText(hEdit)
    userTemplates[templateName] := editText
    newText := RegExReplace(Edit_GetText(hEdit), "`r*`n", "\n")
    IniWrite, %newText%, %settingsFile%, Templates, %templateName%
}
Gosub UpdateTemplateMenu
Return


MainButtonCancel:
MainGuiClose:
FileDelete, %savedFile%
ExitApp
Return


CopyToClip:
Clipboard := getFormattedText(hEdit)
Return


KeywordsTemplate:
replaceText(hEdit, templates[defaultTemplateName])
Return


AddDate:
FormatTime, output,, %dateFormat%
output := (mnemonic) ? (output " --" mnemonic) : output
outLen := StrLen(output)
Edit_GetSel(hEdit, cPos)
rangeText := Edit_GetTextRange(hEdit, cPos, cPos+outLen)
match := RegExMatch(rangeText, "[^ ]")
if (match) {
    charLine := Edit_LineFromChar(hEdit, cPos)
    match := RegExMatch(rangeText, "P)^ *(?=\r|\n)", matchLen)
    if (match) {
        totalLen := Edit_LineLength(hEdit, charLine) + matchLen + outLen
        if (totalLen <= 80) {
            Edit_SetSel(hEdit, cPos, cPos+matchLen)
            Edit_ReplaceSel(hEdit, output)
        }
    }
} else {
    Edit_SetSel(hEdit, cPos, cPos+outLen)
    Edit_ReplaceSel(hEdit, output)
}
Return

; =========
; Functions
; =========

readSettings() {
    ; Read from keywords_editor.ini and set default settings
    IniRead, iniMnemonic, %settingsFile%, Settings, mnemonic, %A_Space%
    mnemonic := SubStr(iniMnemonic, 1, 4)
    ;
    IniRead, iniFontSize, %settingsFile%, Settings, fontsize, %A_Space%
    fontSize := (fSizes[iniFontSize]) ? iniFontSize : 12
    ;
    IniRead, iniDateFormat, %settingsFile%, Settings, dateformat, %A_Space%
    dateFormat := (HasVal(validDateFormats, iniDateFormat)) ? iniDateFormat : "dd MMM yyyy"
    ;
    IniRead, outSection, %settingsFile%, Templates
    Loop, Parse, outSection, "`r`n"
    {
        line := StrSplit(A_LoopField, "=", "", 2)
        userTemplates[line[1]] := RegExReplace(line[2], "\\n", "`n")
    }
}


getEditWidthScroll(chars) {
    return fSizes[fontSize] * chars + 32
}


getFormattedText(editHwnd) {
    Edit_FmtLines(editHwnd, True)
    ; Strip whitespace from the end of the text
    fText := RegExReplace(Edit_GetText(editHwnd), "D)\s+$", "")
    ; Format newlines to CRLF
    fText := RegExReplace(fText, "\r*\n", "`r`n")
    ; Strip whitespace from end of each line
    fText := RegExReplace(fText, "m) +$", "")
    ; Replace blank lines with a single space for Keywords pasting
    fText := RegExReplace(fText, "m)^$", " ")
    Edit_FmtLines(editHwnd, False)
    return fText
}


todayToFormat(format) {
    FormatTime, output,, %format%
    return output
}


loadSavedKeywords(editHwnd) {
    if FileExist(savedFile) {
        MsgBox, 1, Saved text found, Saved text was found from last session. Load it?
        IfMsgBox, Ok
            Edit_ReadFile(editHwnd, savedFile)
        Else
            Return
    }
}


replaceText(editHwnd, newText) {
    Gui Main:+OwnDialogs
    newText := RegExReplace(newText, "\n", "`r`n")
    trimmedText := RegExReplace(Edit_GetText(editHwnd), "Ds)^\s*(.*)\s*$", "$1")
    if (trimmedText) {
        MsgBox, 1, Text present, This will replace the current text. Are you sure?
        IfMsgBox, Ok
            Edit_SetText(editHwnd, newText)
        Else
            Return
    } else {
        Edit_SetText(editHwnd, newText)
    }
}


; https://autohotkey.com/boards/viewtopic.php?p=109617&sid=a057c8ab901a3ab88f6304b71729c892#p109617
HasVal(haystack, needle) {
    for index, value in haystack
        if (value = needle)
            return index
    if !(IsObject(haystack))
        throw Exception("Bad haystack!", -1, haystack)
    return 0
}

; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5063
#include %A_ScriptDir%\Edit\_Functions
#include Edit.ahk

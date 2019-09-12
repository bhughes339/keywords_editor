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
global templates := {}
global userTemplates := {}
global editWidth := 80

defaultTemplates()

readSettings()
Gosub InitGui
loadSavedKeywords(hEdit)
Return

; =======
; Hotkeys
; =======

!+v::
fText := Edit_Convert2Unix(getFormattedText(hEdit))
SendInput {End}{Space}
Loop, Parse, fText, `n
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
Gosub UpdateTemplateMenus
Menu, FileMenu, Add
Menu, FileMenu, DeleteAll
Menu, FileMenu, Add, Load template, :LoadTemplateMenu
Menu, FileMenu, Add, Save current text as template`tCtrl+S, SaveTemplate
Menu, FileMenu, Add, Delete custom template, :DeleteTemplateMenu
Menu, FileMenu, Add
Menu, FileMenu, Add, Exit, MainGuiClose

; -- Actions
Menu, ActionMenu, Add
Menu, ActionMenu, DeleteAll
Menu, ActionMenu, Add, Copy Keywords to clipboard`tCtrl+Shift+C, CopyToClip
Menu, ActionMenu, Add, Insert date at cursor`tCtrl+D, AddDate
Menu, ActionMenu, Add, Delete current line`tCtrl+K, DeleteLine
Menu, ActionMenu, Add, Format text`tF3, FormatText

; -- Options
Menu, OptionsMenu, Add
Menu, OptionsMenu, DeleteAll
Menu, OptionsMenu, Add, Set mnemonic..., SetMnemonic
; ---- :FontMenu
Menu, FontMenu, Add
Menu, FontMenu, DeleteAll
for key, value in fSizes {
    Menu, FontMenu, Add, %key%, FontMenuHandler
    if (key == fontSize) {
        Menu, FontMenu, Check, %key%
    }
}
Menu, OptionsMenu, Add, Font size, :FontMenu
; ---- :DateFormatMenu
GoSub UpdateDateMenu
Menu, OptionsMenu, Add, Date format, :DateFormatMenu

; -- Menu
Menu, MenuBar, Add, File, :FileMenu
Menu, MenuBar, Add, Actions, :ActionMenu
Menu, MenuBar, Add, Options, :OptionsMenu
Gui, Menu, MenuBar

Gui, Add, Edit, % "xm r30 vTextSection HwndhEdit gTextSection w" (fSizes[fontSize] * editWidth)

autoSize(hEdit, editWidth)

Gui, Show

Hotkey, IfWinActive, ahk_id %MainHwnd%
; Add any program-specific hotkeys here
^Backspace::Send ^+{Left}{Backspace}
^+Backspace::Send +{Home}{Backspace}

Return

; ===========
; Subroutines
; ===========

TextSection:
Edit_WriteFile(hEdit, savedFile)
Return


UpdateTemplateMenus:
Menu, LoadTemplateMenu, Add
Menu, LoadTemplateMenu, DeleteAll
Menu, DeleteTemplateMenu, Add
Menu, DeleteTemplateMenu, DeleteAll
for key, value in templates {
    Menu, LoadTemplateMenu, Add, %key%, TemplateMenuHandler
}
Menu, LoadTemplateMenu, Add
for key, value in userTemplates {
    Menu, LoadTemplateMenu, Add, %key%, CustomTemplateMenuHandler
    Menu, DeleteTemplateMenu, Add, %key%, DeleteTemplateHandler
}
Return

; =============
; Menu Handlers
; =============

TemplateMenuHandler:
replaceText(hEdit, templates[A_ThisMenuItem])
Return


CustomTemplateMenuHandler:
replaceText(hEdit, userTemplates[A_ThisMenuItem])
Return


DeleteTemplateHandler:
MsgBox, 1, Confirm deletion, Are you sure you want to delete template "%A_ThisMenuItem%"?
IfMsgBox, Cancel
    Return
userTemplates.Delete(A_ThisMenuItem)
IniDelete, %settingsFile%, Templates, %A_ThisMenuItem%
Gosub UpdateTemplateMenus
Return


FontMenuHandler:
if (fontSize == A_ThisMenuItem) {
    Return
}
fontSize := A_ThisMenuItem
IniWrite, %fontSize%, %settingsFile%, Settings, fontsize
savedText := Edit_GetText(hEdit)
Gosub InitGui
Edit_SetText(hEdit, savedText)
Return


UpdateDateMenu:
Menu, DateFormatMenu, Add
Menu, DateFormatMenu, DeleteAll
for index, value in validDateFormats {
    tempFormat := todayToFormat(value)
    Menu, DateFormatMenu, Add, %tempFormat%, DateFormatMenuHandler
    if (value == dateFormat) {
        Menu, DateFormatMenu, Check, %tempFormat%
    }
}
Menu, DateFormatMenu, Add
if (HasVal(validDateFormats, dateFormat)) {
    Menu, DateFormatMenu, Add, Custom..., CustomDateFormat
} else {
    tempFormat := todayToFormat(dateFormat)
    Menu, DateFormatMenu, Add, Custom: %tempFormat%, CustomDateFormat
    Menu, DateFormatMenu, Check, Custom: %tempFormat%
}
Return


DateFormatMenuHandler:
dateFormat := validDateFormats[A_ThisMenuItemPos]
IniWrite, %dateFormat%, %settingsFile%, Settings, dateFormat
GoSub UpdateDateMenu
Return


CustomDateFormat:
Gui Main:+OwnDialogs
InputBox, tempFormat, Custom date format, Enter custom date format:, , , 150, , , , , %dateFormat%
if (ErrorLevel == 0) {
    dateFormat := tempFormat
    IniWrite, %dateFormat%, %settingsFile%, Settings, dateFormat
    GoSub UpdateDateMenu
}
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
    escapedText := escapeNewlines(Edit_Convert2Unix(editText))
    IniWrite, %escapedText%, %settingsFile%, Templates, %templateName%
}
Gosub UpdateTemplateMenus
Return


MainButtonCancel:
MainGuiClose:
FileDelete, %savedFile%
ExitApp
Return


CopyToClip:
Clipboard := getFormattedText(hEdit)
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


DeleteLine:
char := Edit_LineIndex(hEdit)
len := Edit_LineLength(hEdit)
Edit_SetSel(hEdit, char, char + Edit_LineLength(hEdit) + 1)
Edit_Clear(hEdit)
Return


FormatText:
newText := Edit_GetText(hEdit)
Edit_GetSel(hEdit, startSel, endSel)
Edit_SetText(hEdit, newText)
Edit_SetSel(hEdit, startSel, endSel)
Edit_WriteFile(hEdit, savedFile)
Return


; =========
; Functions
; =========

readSettings() {
    ; Read from keywords_editor.ini and set default settings
    IniRead, iniMnemonic, %settingsFile%, Settings, mnemonic, %A_Space%
    mnemonic := SubStr(iniMnemonic, 1, 4)

    IniRead, iniFontSize, %settingsFile%, Settings, fontsize, %A_Space%
    fontSize := (fSizes[iniFontSize]) ? iniFontSize : 12

    IniRead, dateFormat, %settingsFile%, Settings, dateformat, "dd MMM yyyy"

    IniRead, outSection, %settingsFile%, Templates
    outSection := Edit_Convert2Unix(outSection)
    Loop, Parse, outSection, "`n"
    {
        matchPos := RegExMatch(A_LoopField, "^(.+?)=(.+)", match)
        if (matchPos) {
            userTemplates[match1] := RegExReplace(match2, "\\n", "`n")
        }
    }
}


autoSize(editHwnd, width) {
    Edit_SetText(editHwnd, Format("{1:090x}", 0))
    while (StrLen(Edit_GetLine(editHwnd, 0)) < width) {
        Edit_GetRect(editHwnd, rectleft, recttop, rectright, rectbottom)
        Edit_SetRect(editHwnd, rectleft-1, recttop-1, rectright+2, rectbottom+1)
    }
    Edit_GetRect(editHwnd, rectleft, recttop, rectright, rectbottom)
    Edit_SetText(editHwnd, "")

    newWidth := rectright - rectleft + 30

    GuiControl, Move, %editHwnd%, % "w" newWidth
    Edit_SetRect(editHwnd, rectleft-1, recttop-1, rectright+1, rectbottom+1)

    Gui, Font, s%fontSize% bold, Verdana
    Gui, Add, Text, % "xm w" newWidth, Press Alt+Shift+V in the Keywords section of AMS to paste above the current cursor.
    Gui, Font, s%fontSize% norm, Consolas
}


getFormattedText(editHwnd) {
    Edit_FmtLines(editHwnd, True)
    ; Strip whitespace from the end of the text
    fText := RegExReplace(Edit_GetText(editHwnd), "D)\s+$", "")
    ; Format newlines to CRLF (including soft line breaks from Edit_FmtLines)
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
            Edit_ReadFile(editHwnd, savedFile, "", True)
        Else
            Return
    }
}


replaceText(editHwnd, newText) {
    Gui Main:+OwnDialogs
    newText := Edit_Convert2DOS(newText)
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


escapeNewlines(fText) {
    fText := RegExReplace(fText, "\r", "\r")
    fText := RegExReplace(fText, "\n", "\n")
    return fText
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


defaultTemplates() {
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
}

; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5063
#include %A_ScriptDir%\Edit\_Functions
#include Edit.ahk

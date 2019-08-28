# AMS Keywords Editor Tool

## Features

* **Built-in International Group Templates** - The International Group Keywords template and Peer Review template (canned text INTLCHANGE and INTLPR respectively) are available from the **File > Load template** menu
  * If you have a suggestion for a template that you think should be added, let me know.
  
* **Custom templates** - Select **Save current text as template** to create a new template which can be loaded from the **File > Load template** menu.

* **Insert Date** - Insert the current date at the cursor. Setting your mnemonic in the menu will append it to the date.
  * Shortcut: <kbd>Ctrl</kbd>+<kbd>D</kbd>
  * **NOTE:** There must be enough whitespace to the right of the cursor to fit the date (and mnemonic if necessary)

* **Copy to Clipboard** - Copies the text to the clipboard properly formatted for pasting into the Keywords section (blank lines appended with a space, etc)

* **Paste into Keywords** - Automatically paste the text above the current line in the Keywords section
  * Shortcut: <kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd>

* **Automatic crash recovery** - If the program (or your PC) crashes, the tool will attempt to recover your Keywords the next time you start it.

## Settings

* **Set mnemonic...** - Causes the Insert Date command to include your mnemonic. Example: 27 Jun 2019 --HUGW

* **Font size** - Changes the text size of the entire program

* **Date format** - Changes the format used by the Insert Date command

## Installation

### Standalone executable (no installation required)
* Head to the [latest release page](https://github.com/bhughes339/keywords_editor/releases/latest) and download `keywords_editor.exe`

### Running with AutoHotkey

* Download [AutoHotkey](https://www.autohotkey.com) v1.1+ and install ([Link to current version download](https://www.autohotkey.com/download/ahk-install.exe))

* Run `keywords_editor.ahk`

---

Special thanks to Ann Drysdale for testing and feature recommendations!

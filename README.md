# AMS Keywords Editor Tool

## Features

* **Initialize with Keywords Template** - Replace the current text with the most recent International group Keywords template as defined in the AMS canned text.

* **Insert Date** - Insert the current date at the cursor. Setting your mnemonic in the menu will append it to the date.
  * Shortcut: <kbd>Ctrl</kbd>+<kbd>D</kbd>

* **Copy to Clipboard** - Copies the text to the clipboard properly formatted for pasting into the Keywords section (blank lines appended with a space, etc)

* **Paste into Keywords** - Automatically paste the text above the current line in the Keywords section
  * Shortcut: <kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd>

* **Automatic crash recovery** - If the program (or your PC) crashes, the tool will attempt to recover your Keywords the next time you start it.

## Settings

* **Set mnemonic...** - Causes the Insert Date command to include your mnemonic. Example: 27 Jun 2019 --HUGW

* **Save current text as template** - Overwrites the default template with the current text. Allows you to save common modifications you make to the template.

* **Text size** - Changes the text size of the entire program

* **Date format** - Changes the format used by the Insert Date command

## Installation

Download [AutoHotkey](https://www.autohotkey.com) v1.1+ and install ([Link to current version download](https://www.autohotkey.com/download/ahk-install.exe))

Run `keywords_editor.exe`
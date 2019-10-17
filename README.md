# AMS Keywords Editor Tool

Text editor designed to alleviate the issues with the AMS Keywords section. Great for inhouse and customer entries too!

## Features

* Built-in International Group templates
* Custom template support
* AMS Keywords-friendly copy/paste
* Today's date/mnemonic insertion
* Automatic crash recovery

The built-in templates are pulled from a [Github gist](https://gist.github.com/bhughes339/31b6f3f2b9cbf669d62f498208b27a52) maintained by me. It will be updated alongside any International Group template changes. Any revisions to the templates can be viewed from that link.

## Installation

#### Standalone executable (no installation required)

Head to the [latest release page](https://github.com/bhughes339/keywords_editor/releases/latest) and download `keywords_editor.exe`

#### (Advanced) Running with AutoHotkey
1) Download [AutoHotkey](https://www.autohotkey.com) v1.1+ and install ([Link to current version download](https://www.autohotkey.com/download/ahk-install.exe))
2) Run `keywords_editor.ahk`

## Usage

Load a template from the **File > Load Template...** menu, or start from scratch. Create your entry as you would in AMS—the editor will automatically wrap to 80 characters. 

To copy the contents of the editor, select **Actions > Copy Keywords to clipboard** (or use the shortcut: <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>C</kbd>). A space will automatically be added to each blank line to ensure proper pasting into the AMS Keywords section.

Alternatively, you can use the shortcut <kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd> while editing the AMS Keywords section. This will paste the contents of the editor line-by-line above the current cursor in AMS and add a separator at the end. This is useful when you have multiple change number moves in a single task.

## Options

* **Set mnemonic...** – Sets the mnemonic used by the Insert Date command
* **Font size** – Changes the text size of the entire program
* **Date format** – Changes the format used by the Insert Date command

Settings are stored in `keywords_editor.json` which resides in the same folder as the executable. 

---

Special thanks to Ann Drysdale for testing and feature recommendations!

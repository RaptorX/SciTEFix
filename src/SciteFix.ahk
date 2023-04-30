;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************

#SingleInstance
#Requires Autohotkey v2.0+ ; Prefer 64-Bit
;--
;@Ahk2Exe-SetVersion     0.1.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName SciteFix
;@Ahk2Exe-SetDescription This tool downloads and configures scite with custom user settings
/**
 * ============================================================================ *
 * @Author   : RaptorX                                                          *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : April 30, 2023                                                   *
 * @Modified : April 30, 2023                                                   *
 * ============================================================================ *
 */

if !A_IsAdmin
{
	Try Run '*RunAs ' A_ScriptFullPath
	ExitApp
}

wth        := 300
tProgress  := Gui('+ToolWindow')
pgTitle    := tProgress.Add('Text', 'Center w' wth, 'Title')
pgCtrl     := tProgress.Add('Progress', 'Range1-4 w' wth ' h3')
pgSubTitle := tProgress.Add('Text', 'Center w' wth, '0/2')
tProgress.Show()

installV2 := installScite := false
if MsgBox('Is Autohotkey v2 installed?',,'Y/N') = 'No'
{
	installV2 := true
	pgTitle.Value := 'Downloading Autohotkey'
	Download 'https://www.autohotkey.com/download/ahk-v2.exe', A_Temp '\ahk-v2.exe'
}
pgCtrl.value     := 1
pgSubTitle.value := 1 '/' 4

if MsgBox('Is Scite4Autohotkey 3.1 installed?',,'Y/N') = 'No'
{
	installScite := true
	pgTitle.Value := 'Downloading Scite4Autohotkey'
	Download 'https://github.com/fincs/SciTE4AutoHotkey/releases/download/v3.1.0/SciTE4AHK_v3.1.0_Install.exe', A_Temp '\SciTE4AHK_v3.1.0_Install.exe'
}
pgCtrl.value     := 2
pgSubTitle.value := 2 '/' 4

if installV2
{
	pgTitle.Value := 'Installing Autohotkey'
	RunWait A_Temp '\ahk-v2.exe'
}
pgCtrl.value     := 3
pgSubTitle.value := 3 '/' 4

if installScite
{
	pgTitle.Value := 'Installing Scite4Autohotkey'
	RunWait A_Temp '\SciTE4AHK_v3.1.0_Install.exe'
}
pgCtrl.value     := 4
pgSubTitle.value := 4 '/' 4

tProgress.Destroy()

sci_path := RegRead('HKLM\SOFTWARE\Classes\SciTE4AHK.Application\Shell\Open\command')
sci_path := RegExReplace(sci_path, '"%1"|"|\\[^\\]+$')

ahkPath := A_AhkPath ?? RegRead('HKLM\SOFTWARE\AutoHotkey', 'InstallDir') '\v2'
ahkPath := RegExReplace(ahkPath, '\\[^\\]+$')

main := Gui()
main.addtext(,'Autohotkey v2 Path:')
main.addedit('vAHKPath ReadOnly w350 r1', ahkPath)
browse_ahk := main.AddButton('x+m yp-1 w75', 'Browse...')

main.addtext('xm','Scite4Autohotkey Path:')
main.addedit('vSCIPath ReadOnly w350 r1', sci_path)
browse_sci := main.AddButton('x+m yp-1 w75 Section', 'Browse...')

main.AddButton('xs-' 75+10 ' y+25 w75', 'Fix').onEvent('Click', FixScite)
main.AddButton('x+m w75', 'Cancel').OnEvent('Click', (*)=>ExitApp())

browse_ahk.OnEvent('Click', PathSelect)
browse_sci.OnEvent('Click', PathSelect)

main.show()
return

PathSelect(obj, info)
{
	switch obj
	{
		case browse_ahk:
			edtCtrl := 'AHKPath'
		case browse_sci:
			edtCtrl := 'SCIPath'
	}

	main[edtCtrl].value := FileSelect('D', A_ProgramFiles)
}

FixScite(*)
{
	static user_properties :=
	(Ltrim
		'# User initialization file for SciTE4AutoHotkey
		# You are encouraged to edit this file!

		# Import the platform-specific settings
		import _platform

		# Import the settings that can be edited by the bundled properties editor
		import _config

		# Add your own settings here
		# ******************************************************************************

		# When both this and load.on.activate are set to 1, SciTE will ask if you really
		# want to reload the modified file, giving you the chance to keep the file as it is.
		# By default this property is disabled, causing SciTE to reload the file without bothering you.
		are.you.sure.on.reload=0

		# The load.on.activate property causes SciTE to check whether the current file
		# has been updated by another process whenever it is activated.
		# This is useful when another editor such as a WYSIWYG HTML editor
		# is being used in conjunction with SciTE.
		load.on.activate=1

		# Check if already open- prevent from opening multiple instances
		check.if.already.open=1

		# On Windows Vista or newer, this can be set to 1 to use the Direct2D and
		# DirectWrite APIs for higher quality antialiased drawing. The default is 0.
		technology=1

		# Set default directory to last open script
		# open.dialog.in.file.directory=1

		# Set the statusbar information
		statusbar.visible=1
		statusbar.text.1=Selc:  $(SelLength)    |    Column $(ColumnNumber)    |  \
		Line $(LineNumber) of $(NbOfLines)    |    Path: $(FilePath)    |    \
		Last Modified @ $(FileTime) on $(FileDate)  |  End of Line mode: $(EOLMode) \
		| FileAttr

		# Output Pane
		# clears output window before exuciting
		clear.before.execute=1
		# moves split screento verticle and sets default to have
		#;~ output.initial.hide=0

		# Changed verticle split to being off
		split.vertical=0
		output.vertical.size=100
		output.magnification=10
		output.scroll=1
		output.wrap=1
		# Set default format to unicode / UTF-8
		code.page=65001
		output.code.page=65001
		# Output pane end

		# If you set save.session, the list of currently opened buffers will be saved on exit in a session file.
		# When you start SciTE next time (without specifying a file name on the command line) the last session will be restored automatically.
		save.session=1

		# Setting session.bookmarks causes bookmarks to be saved in session files.
		# If you set session.folds then the folding state will be saved in session files.
		# When loading a session file bookmarks and/or folds are restored. Folding states are not restored if fold.on.open is set.
		session.bookmarks=1
		session.folds=1

		# this affects the other found words of the highlighted word / underlines all instances of that word
		highlight.current.word.indicator=style:compositionthick,colour:#0080FF,under,outlinealpha:40,fillalpha:40
		highlight.current.word=1

		# Setting save.recent causes the most recently used files list to be saved on
		# exit in the session file and read at start up.
		save.recent=1

		# Setting save.position causes the SciTE window position on the desktop to be
		# saved on exit in the session file and restored at start up.
		save.position=0

		# When set to 1, reloading a file does not delete all the undo history.
		# This is useful when load.on.activate is used in conjunction with filter commands.
		reload.preserves.undo=1

		# If this option is set, SciTE will close when its last buffer (file) has been
		# closed, e.g. with File/Close. (By default, if this option is not set, SciTE will
		# remain open and will create a new blank document when its last buffer is closed.)
		quit.on.close.last=0

		#Sets whether switching to rectangular selection mode while making a selection with the mouse is allowed
		# selection.rectangular.switch.mouse=1
		# allow mulitple selections with mouse (not in block mode) Need to hold down control
		selection.multiple=1

		# Set selection.additional.typing to 1. to allow typing, backspace and delete to
		# affect all selections including each line of rectangular selections.
		selection.additional.typing=1

		# Set selection.multipaste to 1 to paste at all selections.
		# If set to 0, the paste will only be inserted at the last selection.
		selection.multipaste=1

		# change magnification level when SciTE starts / Zoom level
		# magnification=10

		# changes the default comment insert (control d).
		comment.block.ahk1=;~

		# set  matching checking
		braces.check=1
		braces.sloppy=1

		# Setting tabbar.hide.one to 1 hides the tab bar until there is more than one tab.
		tabbar.hide.one=0

		# This setting allows choosing different ways of drawing text on Windows and OS X.
		# The appearance will depend on platform settings and, on Windows, the technology setting.
		# This setting does not currently have any effect on GTK+.
		# 0=default 1=Non-Antialiased 2=Antialiased 3=LCD Optimized
		font.quality=3

		# Chooses how the file name is displayed in the title bar.
		# When 0 (default) the file name is displayed.
		# When 1 the full path is displayed.
		# When 2 the window title displays "filename in directory".
		title.full.path=1

		# When a command execution produces error messages, and you step with F4 key
		# through the matching source lines, this option selects the line where the error occurs.
		# Most useful if the error message contains the column of error too as the
		# selection will start at the column of the error. The error message must contain
		# the column and must be understood by SciTE (currently only supported for HTML Tidy).
		# The tab size assumed by the external tool must match the tab size of your source
		# file for correct column reporting.
		error.select.line=1

		# Find and replace settings
		# Setting save.find cause the "Find what" and "Replace with" to be saved in the session file.
		#save.find=1
		# alternative find window (as strip at bottom of page)
		#find.use.strip=0

		# These properties define the initial conditions for find and replace commands.
		# The find.replace.matchcase property turns of the "Match case" option, find.replace.regexp
		# the "Regular expression" option, find.replace.wrap the "Wrap around" option and
		# find.replace.escapes the "Transform backslash expressions" option.
		find.replace.matchcase=0
		find.replace.regexp=0

		# Changing  to posix regular expression mode so do not have to escape parens
		find.replace.regexp.posix=1

		# Set defualts to not be on
		find.replace.matchcase=0
		find.replace.regexp=0
		find.replace.wrap=1
		#Transform Backslash expression
		find.replace.escapes=1

		# prevents findbox from closing if doesn`'t find searched text
		find.close.on.find=0

		# sets Replace to use what is in Find (if populated)
		find.replacewith.focus=1

		# Setting degault End of Line:  LF for Unix, CR for Mac prior to OS X  CRLF for Dos/Windows
		eol.mode=CRLF

		# set path to help file for ahk
		# command.scite.help=ahk "B:\Progs\AutoHotkey_L\AutoHotkey.chm"

		# Auto complete
		# When set to 1 and an autocompletion list is invoked and there is only one
		# element in that list then that element is automatically chosen.
		# This means that the matched element is inserted and the list is not displayed.
		autocomplete.choose.single=0

		# If this setting is 1 then when typing a word, if only one word in the
		# document starts with that string then an autocompletion list is displayed with
		# that word so it can be chosen by pressing Tab.
		autocompleteword.automatic=0
		autocomplete.*.ignorecase=1

		# If this setting is not empty, typing any of the characters will cause
		# autocompletion to complete. For example, if autocomplete.python.fillups=( 
		# and the API file for Python contains "string.replace" then typing "string.r(" 
		# will cause "string.replace(" to be inserted. The * form is used if there is no lexer specific setting.
		autocomplete.*.fillups=(

		# User defined hotkey commands
		# Get others here: http://www.scintilla.org/CommandValues.html
		user.shortcuts=\
		Ctrl+Alt+c|IDM_COPYASRTF|\
		Ctrl+Shift+C|IDM_COPYASRTF|\
		Ctrl+F1|IDM_HELP_SCITE|\
		Ctrl+PageUp|IDM_PREVFILE|\
		Ctrl+PageDown|IDM_NEXTFILE|\
		Ctrl+t|IDM_SHOWCALLTIP|\
		Ctrl+u|IDM_OPENUSERPROPERTIES|\
		F3|IDM_FIND|\
		F4|IDM_FINDNEXT|\
		Ctrl+Shift+Up|2620|\
		Ctrl+Shift+Down|2621|\
		Ctrl+Shift+t|IDM_TOGGLEOUTPUT|\
		Ctrl+Escape|IDM_STOPEXECUTE|

		# Context menu
		# Add items to SciTE`'s context menu (right click menu)
		# Get others here: http://www.scintilla.org/CommandValues.html
		user.context.menu=\
		||\
		||\
		View White Space|IDM_VIEWSPACE|\
		View End of Line|IDM_VIEWEOL|\
		||\
		Open File of Path Selected (no quotes) |IDM_OPENSELECTED|\
		Copy as RTF |IDM_COPYASRTF|\
		Copy Path of THIS File|IDM_COPYPATH|\'
	)
	
	scite_path := main['SCIPath'].value
	ahk_path := StrReplace(main['AHKPath'].value, '\v2')
	props_path := scite_path '\platforms.properties'

	old_properties := FileRead(props_path, 'UTF-8')
	new_properties := RegExReplace(old_properties, '%AhkDir%|\$\(AutoHotkeyDir\)', ahk_path)

	FileMove props_path, scite_path '\platforms.bak', true
	hFile := FileOpen(props_path, 'w-', 'UTF-8')
	hFile.Write(new_properties)
	hFile.Close()

	hFile := FileOpen(A_MyDocuments '\Autohotkey\SciTE\SciTEUser.properties', 'w-', 'UTF-8')
	hFile.Write(user_properties)
	hFile.Close()

	main.Submit()
	MsgBox 'Fixed Scite properties.`n`nOld properties were saved as: ' scite_path '\platforms.bak`n`nNow exiting.'
	ExitApp
}
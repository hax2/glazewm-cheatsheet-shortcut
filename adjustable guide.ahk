#Persistent
#NoEnv
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

^i::
    ; Hardcoded file path
    filePath := "PUT CONFIG.YAML FILE PATH HERE"
    
    ; Read the configuration file
    if FileExist(filePath) {
        FileRead, yamlContent, %filePath%
        if ErrorLevel {
            MsgBox, 48, Error, Failed to read the configuration file.
            return
        }
    } else {
        MsgBox, 48, Error, Configuration file not found at:`n%filePath%
        return
    }

    ; Parse the file starting after "keybindings:" and excluding "binding_modes:"
    cheatsheet := { "Window Focus": [], "Window Movement": [], "Resizing": [], "Window State": [], "Workspaces": [], "Miscellaneous": [] }
    inKeybindings := false
    currentCommand := ""
    Loop, Parse, yamlContent, `n, `r
    {
        line := Trim(A_LoopField)
        
        ; Start processing only after "keybindings:"
        if (line = "keybindings:") {
            inKeybindings := true
            continue
        }

        ; Stop processing if "binding_modes:" is reached
        if (inKeybindings && line = "binding_modes:") {
            break
        }

        ; Parse commands and bindings
        if inKeybindings {
            if RegExMatch(line, "^\s*- commands:\s*\[(.*?)\]$", cmdMatch) {
                currentCommand := cmdMatch1
            } else if RegExMatch(line, "^\s*bindings:\s*\[(.*?)\]$", bindMatch) {
                bindingList := bindMatch1
                Loop, Parse, bindingList, `,
                {
                    binding := Trim(A_LoopField, "`'"" ")
                    category := GetShortcutCategory(currentCommand)
                    cheatsheet[category].Push(binding ": " currentCommand)
                }
            }
        }
    }

    ; Create the GUI for the cheatsheet
    Gui, Destroy
    Gui, Color, White
    Gui, Font, s10, Segoe UI

    ; Dynamic placement for compact layout
    MaxWidth := A_ScreenWidth
    MaxHeight := A_ScreenHeight
    Columns := 2  ; Number of columns
    ColWidth := MaxWidth // Columns
    ColX := 10
    ColY := 10
    RowSpacing := 15
    SectionSpacing := 25
    CurrentColumn := 0

    for category, shortcuts in cheatsheet {
        if shortcuts.Length() > 0 {
            ; Move to next column if vertical space is exceeded
            if (ColY + (shortcuts.Length() + 2) * RowSpacing > MaxHeight) {
                CurrentColumn++
                ColX := CurrentColumn * ColWidth + 10
                ColY := 10
            }

            ; Add category heading
            Gui, Add, Text, x%ColX% y%ColY% Center, % category
            ColY += RowSpacing

            ; Add shortcuts
            for _, shortcut in shortcuts {
                Gui, Add, Text, x%ColX% y%ColY%, %shortcut%
                ColY += RowSpacing
            }
            ColY += SectionSpacing  ; Add spacing between categories
        }
    }

    ; Show the GUI fullscreen
    Gui, Show, Maximize, Cheatsheet
return

; Close the cheatsheet with Escape
Esc::
Gui, Destroy
return

; Function to group commands into categories
GetShortcutCategory(command) {
    if InStr(command, "focus --direction") || InStr(command, "wm-cycle-focus")
        return "Window Focus"
    else if InStr(command, "move --direction") || InStr(command, "move-workspace")
        return "Window Movement"
    else if InStr(command, "resize")
        return "Resizing"
    else if InStr(command, "toggle-") || InStr(command, "wm-toggle-pause")
        return "Window State"
    else if InStr(command, "workspace")
        return "Workspaces"
    else
        return "Miscellaneous"
}

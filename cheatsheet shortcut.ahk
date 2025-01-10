; Path to the image that shows the shortcuts
ShortcutsImagePath := A_ScriptDir "\shortcuts.png" ; Update this path if needed

; Hotkey to display the image
!g:: ; Alt + G
{
    ; Check if the image file exists
    if !FileExist(ShortcutsImagePath) {
        MsgBox, Error: Shortcuts image not found at %ShortcutsImagePath%.
        return
    }

    ; Get screen dimensions
    ScreenWidth := A_ScreenWidth
    ScreenHeight := A_ScreenHeight

    ; Define maximum width and height for the image (e.g., 90% of screen size)
    MaxWidth := ScreenWidth * 0.9
    MaxHeight := ScreenHeight * 0.9

    ; Get the original dimensions of the image
    ; AutoHotkey can't directly retrieve dimensions, so we assume and adjust manually
    ; Replace these dimensions with your actual image dimensions if known
    OriginalWidth := 3311
    OriginalHeight := 2851

    ; Calculate the scaling factor to maintain the aspect ratio
    ScaleWidth := MaxWidth / OriginalWidth
    ScaleHeight := MaxHeight / OriginalHeight
    Scale := (ScaleWidth < ScaleHeight ? ScaleWidth : ScaleHeight) ; Use the smaller scale

    ; Calculate the final dimensions
    FinalWidth := Floor(OriginalWidth * Scale)
    FinalHeight := Floor(OriginalHeight * Scale)

    ; Create a GUI to display the image with the calculated dimensions
    Gui, +AlwaysOnTop +Border -Caption
    Gui, Add, Picture, w%FinalWidth% h%FinalHeight% Center, %ShortcutsImagePath%
    Gui, Show, AutoSize Center
    return
}

; Hotkey to close the image (Escape key)
GuiEscape: ; Triggered when Escape is pressed
GuiClose:  ; Triggered when the GUI close button is clicked
    Gui, Destroy
    return

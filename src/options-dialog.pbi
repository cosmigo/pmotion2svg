; This module contains the code for the User Options dialog.
; ==============================================================================
;- DIALOG SETTINGS
;{==============================================================================
#EOP$ = #CRLF$ + #CRLF$
#AboutTxt$ = "pmotion2svg v" + #PLUGIN_VER$ + " (" + #PLUGIN_DATE$ + "), " +
             #Copyright$ + #EOP$ + "— " + #Repository$ + #EOP$ +
             "Inspired by the px2svg tool by Eric Meyer, Robin Cafolla, " +
             "Amelia Bellamy-Royds, Neal Brooks and ignace nyamagana butera:" + #EOP$ +
             "— https://github.com/meyerweb/px2svg"

Enumeration Windows
  #WinUserOpts
EndEnumeration

Enumeration FormFonts
  #fntLabels
EndEnumeration

Enumeration Gadgets
  #ScaleF_gTxt
  #ScaleF_gSpin
  #Padding_gTxt
  #Padding_gSpin
  #Grid_gCheck
  #Transp_gCheck
  #Confirm_gBtn
EndEnumeration

Enumeration Menus
  #WinOptsMenus
EndEnumeration

Enumeration MenuItems
  ; Info Menu Items:
  #m1_About
  #m1_Repo
  #m1_Updates
  ; SVG Optimizers Menu Items:
  #m2_SVGOMG
  #m2_SVGO
EndEnumeration
;}==============================================================================
;- OPTIONS WINDOW
; ==============================================================================
Procedure OptionsDialog()
  Shared ImageData, FileName$
  With ImageData
    LoadFont(#fntLabels,"Segoe UI", 12)
    SetGadgetFont(#PB_Default, FontID(#fntLabels))

    #WinW = 210
    #WinH = 225

    OpenWindow(#WinUserOpts, 0, 0, #WinW, #WinH, "pmotion2svg v" + #PLUGIN_VER$,
               #PB_Window_ScreenCentered)
    StickyWindow(WinOpts, #True)

    ;- Menus
    CreateMenu(#WinOptsMenus, WindowID(#WinUserOpts))
    MenuTitle("Info")
    MenuItem(#m1_About, "About")
    MenuItem(#m1_Repo, "Source repository")
    MenuItem(#m1_Updates, "Check for updates")

    MenuTitle("SVG Optimizers")
    MenuItem(#m2_SVGOMG, "SVGOMG — online SVGO GUI")
    MenuItem(#m2_SVGO, "SVGO — Node.js CLI tool")

    ;- Scale Factor Gadget
    TextGadget(#ScaleF_gTxt, 15, 15, 100, 25, "Scale Factor")
    SpinGadget(#ScaleF_gSpin, 120, 15, 60, 25, 0, 0, #PB_Spin_Numeric)
    SetGadgetAttribute(#ScaleF_gSpin, #PB_Spin_Minimum, 1)
    SetGadgetAttribute(#ScaleF_gSpin, #PB_Spin_Maximum, 255)
    SetGadgetState(#ScaleF_gSpin, \ScaleF)
    SetGadgetText(#ScaleF_gSpin, Str(\ScaleF))

    ;- Padding Gadget
    TextGadget(#Padding_gTxt, 15, 50, 100, 25, "Padding")
    SpinGadget(#Padding_gSpin, 120, 50, 60, 25, 0, 0, #PB_Spin_Numeric)
    SetGadgetAttribute(#Padding_gSpin, #PB_Spin_Minimum, 0)
    SetGadgetAttribute(#Padding_gSpin, #PB_Spin_Maximum, 255)
    SetGadgetState(#Padding_gSpin, \Padding)
    SetGadgetText(#Padding_gSpin, Str(\Padding))

    ;- Draw Grid Option Gadget
    CheckBoxGadget(#Grid_gCheck, 15, 85, 100, 25, "Draw Grid")
    SetGadgetState(#Grid_gCheck, \Grid)

    ;- Transparent Color Gadget
    CheckBoxGadget(#Transp_gCheck, 15, 120, 180, 25, "Preserve Transparency")
    If \TranspColorIndex = -1
      SetGadgetState(#Transp_gCheck, #PB_Checkbox_Unchecked)
      DisableGadget(#Transp_gCheck, #True)
    Else
      SetGadgetState(#Transp_gCheck, \PresTransp)
    EndIf

    ;- Confirmation Button Gadget
    #btnW = 80
    #btnX = ( #WinW - #btnW ) /2
    ButtonGadget(#Confirm_gBtn, #btnX, 165, #btnW, 25, "confirm", #PB_Button_Default)

    ;- /// EVENTS HANDLING ///
    Repeat
      Event = WaitWindowEvent()
      EventType = EventType()
      Select event
        Case #PB_Event_Menu ;- Menus Events
          Select EventMenu()
            Case #m1_About  ; Info » About
              MessageRequester("Plug-in Info", #AboutTxt$, #PB_MessageRequester_Info)
            Case #m1_Repo   ; Info » Source repository
              RunProgram(#Repository$)
            Case #m1_Updates; Info » Check for updates
              RunProgram(#Repository$ + "/releases")
            Case #m2_SVGOMG ; SVG Optimizers » SVGOMG online
              RunProgram("https://jakearchibald.github.io/svgomg/")
            Case #m2_SVGO   ; SVG Optimizers » SVGO CLI package
              RunProgram("https://www.npmjs.com/package/svgo")
          EndSelect
        Case #PB_Event_Gadget ;- Gadgets Events
          Select EventGadget()
            Case #ScaleF_gSpin
              ; Handle invalid manual insertions
              gTxt$ = GetGadgetText(#ScaleF_gSpin)
              gVal  = GetGadgetState(#ScaleF_gSpin)
              gVal$ = Str(gVal)
              If gVal$ <> gTxt$
                SetGadgetText(#ScaleF_gSpin, gVal$)
              EndIf
            Case #Padding_gSpin
              ; Handle invalid manual insertions
              gTxt$ = GetGadgetText(#Padding_gSpin)
              gVal  = GetGadgetState(#Padding_gSpin)
              gVal$ = Str(gVal)
              If gVal$ <> gTxt$
                SetGadgetText(#Padding_gSpin, gVal$)
              EndIf
            Case #Confirm_gBtn
              Break
          EndSelect
      EndSelect
    ForEver

    ;- /// Exit Dialog ///

    ; Update Settings
    \ScaleF = GetGadgetState(#ScaleF_gSpin)
    \Padding = GetGadgetState(#Padding_gSpin)
    \Grid = GetGadgetState(#Grid_gCheck)
    \PresTransp = GetGadgetState(#Transp_gCheck)
  EndWith

  ; Free GUI resources...
  CloseWindow(#WinUserOpts)
  FreeFont(#fntLabels)
  FreeMenu(#WinOptsMenus)
EndProcedure

; EOF ;

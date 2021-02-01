; ******************************************************************************
; This module defines the DLL procedures for basic plug-in interfaces that are
; handled in the background.
; ******************************************************************************

; ==============================================================================
;- PLUGIN SETTINGS
;{==============================================================================

Global FILE_TYPE_ID$ = "Pro_Motion_to_SVG"          ; Unique plugin identifier
Global FILE_BOX_DESCRIPTION$ = "SVG - pmotion2svg"  ; Extension UI description
Global FILE_EXTENSION$ = "svg"                      ; File extension

#PLUGIN_INTERFACE_VERSION_USED = 1

#PLUGIN_SUPPORTS_ANIMATION       = #False
#PLUGIN_SUPPORTS_PALETTE_EXTRACT = #False
#PLUGIN_SUPPORTS_READ            = #False
#PLUGIN_SUPPORTS_WRITE           = #True
#PLUGIN_SUPPORTS_WRITE_TRUECOLOR = #False

;}==============================================================================
;- PROCESSING CONTROL
;{==============================================================================

;- /// File Name Handling ///

FileName$ = #Empty$ ; Full path to the selected file.

ProcedureDLL setFilename( *filename_pnt )
  Shared FileName$
  FileName$ = PeekS( *filename_pnt )
EndProcedure

;- /// Error Handling ///

Global PLUGIN_ERROR_MSG$ = #Empty$

Macro resetError
  PLUGIN_ERROR_MSG$ = #Empty$
EndMacro

Macro setError( errString )
  PLUGIN_ERROR_MSG$ = errString
EndMacro

ProcedureDLL.i getErrorMessage()
  If PLUGIN_ERROR_MSG$ <> #Empty$
    ProcedureReturn @PLUGIN_ERROR_MSG$
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

;- /// Progress Control ///

Prototype ProtoProgressCallback( progress.l )
Global progressCallback.ProtoProgressCallback

ProcedureDLL setProgressCallback( *progressCallback )
  progressCallback = *progressCallback
EndProcedure

;}==============================================================================
;- PLUG-IN INITIALIZATION
; ==============================================================================
; These procedures are called just once when PM starts up, to gather info about
; the plug-in and its supported features.

ProcedureDLL.i initialize(*language, *version.Unicode, *animation.Ascii)
  resetError
  *version\u   = #PLUGIN_INTERFACE_VERSION_USED
  *animation\a = #PLUGIN_SUPPORTS_ANIMATION
  Shared ImageData
  resetImageData()
  ; Apply default user settings
  With ImageData
    \ScaleF     = #Default_ScaleF
    \Padding    = #Default_Padding
    \Grid       = #Default_Grid
    \PresTransp = #Default_PresTransp
  EndWith
  ProcedureReturn #Success
EndProcedure

;- /// Plug-in Info ///

ProcedureDLL.i getFileExtension()
  ProcedureReturn @FILE_EXTENSION$
EndProcedure

ProcedureDLL.i getFileTypeId()
  ProcedureReturn @FILE_TYPE_ID$
EndProcedure

ProcedureDLL.i getFileBoxDescription()
  ProcedureReturn @FILE_BOX_DESCRIPTION$
EndProcedure

;- /// Plug-in Features Support Info ///

ProcedureDLL.i isReadSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_READ
EndProcedure

ProcedureDLL.i isWriteSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE
EndProcedure

ProcedureDLL.i isWriteTrueColorSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE_TRUECOLOR
EndProcedure

ProcedureDLL.i canExtractPalette()
  ProcedureReturn #PLUGIN_SUPPORTS_PALETTE_EXTRACT
EndProcedure

; EOF ;

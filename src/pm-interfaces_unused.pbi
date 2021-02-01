; ******************************************************************************
; This module defines the DLL procedures for the plug-in import interfaces.
; Although these are not actually used by pmotion2svg, we still need to define
; them, otherwise the plugin will be rejected as invalid by PM NG. See:
; https://community.cosmigo.com/t/1018
; ******************************************************************************

ProcedureDLL.i canHandle()
  setError("Import not supported!")
  ProcedureReturn #False
EndProcedure

ProcedureDLL.i loadBasicData()
  setError("Import not supported!")
  Shared ImageData
  ProcedureReturn #Failure
EndProcedure

ProcedureDLL.i isAlphaEnabled()
  ProcedureReturn #False
EndProcedure

ProcedureDLL.l getWidth()
  ProcedureReturn 0
EndProcedure

ProcedureDLL.l getHeight()
  ProcedureReturn 0
EndProcedure

ProcedureDLL.l getTransparentColor()
  ProcedureReturn -1
EndProcedure

ProcedureDLL.l getImageCount()
  setError("Import not supported!")
  ProcedureReturn -1
EndProcedure

ProcedureDLL.i getRgbPalette()
  ProcedureReturn #Null
EndProcedure


ProcedureDLL.i loadNextImage(*colorFrame,
                             *colorFramePalette,
                             *alphaFrame,
                             *alphaFramePalette,
                             delayMs.u)
  setError("Import not supported!")
  ProcedureReturn #Failure
EndProcedure

; EOF ;

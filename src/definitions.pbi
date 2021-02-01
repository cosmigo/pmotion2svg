; ==============================================================================
;- CHECK COMPILER SETTINGS
;{==============================================================================
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows Or
           #PB_Compiler_Processor <> #PB_Processor_x86 Or
           #PB_Compiler_ExecutableFormat <> #PB_Compiler_DLL Or
           #PB_Compiler_Thread = #True
  CompilerError "WRONG COMPILER SETTINGS! " +
                "Must be Windows DLL for x86 (32 bit) not threadsafe"
CompilerEndIf

CompilerIf #PB_Compiler_Version <> #PUREBASIC_V
  CompilerWarning "This plugin was tested only on PureBasic "+ #PUREBASIC_V + "."
CompilerEndIf
;}==============================================================================
;- PMOTION2SVG DEFINITIONS
; ==============================================================================
#SCAN_HORIZONTAL = 0 : #SCAN_VERTICAL = 1

;- /// ImageData Structure ///

Structure ImageDataStruct
  ; Frame Data:
  Width.l
  Height.l
  Frames.l
  TranspColorIndex.l
  AlphaEnabled.i
  *BitMap    ; pointer to *colorFrame
  *Palette   ; pointer to *colorFramePalette

  ; User Options:
  ScaleF.i   ; Scale factor (i.e. pixel size in SVG)
  Padding.i  ; Padding around the SVG Pixel Art
  Grid.i     ; Should draw pixels grid? True/False
  PresTransp.i ; Honor transp. color or paint it?
EndStructure

ImageData.ImageDataStruct

Procedure resetImageData()
  ; ---------------------------------------------------
  ; Reset frame-related values of ImageData structure.
  ; This procedure doesn't reset user options, so they
  ; are preserved across the various export operations.
  ; ---------------------------------------------------
  Shared ImageData
  With ImageData
    \Width  = -1
    \Height = -1
    \Frames = -1
    \TranspColorIndex = -1
    \AlphaEnabled = #False
    \BitMap = #Null
    \Palette = #Null
  EndWith
EndProcedure

;- /// Default User Settings ///

#Default_ScaleF     = 5
#Default_Padding    = 0
#Default_Grid       = #False
#Default_PresTransp = #True

;- /// Helpers ///

#Success = #True
#Failure = #False

; EOF ;

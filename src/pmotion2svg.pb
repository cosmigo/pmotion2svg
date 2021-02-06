; ******************************************************************************
; *                                                                            *
; *                                pmotion2svg                                 *
; *                                                                            *
; *                         Pixel Art to SVG Exporter                          *
; *                     Cosmigo Pro Motion File I/O Plugin                     *
; *                                                                            *
;{******************************************************************************
#PLUGIN_VER$  = "1.1.0"       ; Pro Motion NG 7.2.7
#PLUGIN_DATE$ = "2021-02-06"
#PUREBASIC_V  = 573           ; PureBasic 5.73 (x86)
#Copyright$   = "© 2021 by Tristano Ajmone, MIT License."
#Repository$  =  "https://github.com/tajmone/pmotion2svg"
;}------------------------------------------------------------------------------

XIncludeFile "definitions.pbi"
XIncludeFile "pm-interfaces.pbi"
XIncludeFile "pm-interfaces_unused.pbi"
XIncludeFile "svg-funcs.pbi"
XIncludeFile "options-dialog.pbi"

; ==============================================================================
;- CORE PLUGIN STEPS
; ==============================================================================
; These procedures represent the core step of each conversion task. They're kept
; them separate from the rest of the interface and plugin procedures to make the
; code more readable.

ProcedureDLL.i beginWrite(width.l,
                          height.l,
                          transparentColor.l,
                          alphaEnabled.i,
                          numberOfFrames.l)
  resetError
  Shared ImageData
  progressCallback(1)
  resetImageData()
  ImageData\Width = width
  ImageData\Height = height
  ImageData\TranspColorIndex = transparentColor
  OptionsDialog()
  ProcedureReturn #Success
EndProcedure

ProcedureDLL.i writeNextImage(*colorFrame,
                              *colorFramePalette,
                              *alphaFrame,
                              *alphaFramePalette,
                              *rgba,
                              delayMs.u)
  resetError
  Shared ImageData, FileName$
  ImageData\BitMap  = *colorFrame
  ImageData\Palette = *colorFramePalette
  progressCallback(10)
  ; Convert bitmap to SVG string
  SVGContents$ = ConvSVG(#SCAN_HORIZONTAL)
  progressCallback(40)
  SVGContentsV$ = ConvSVG(#SCAN_VERTICAL)
  progressCallback(80)
  svgLenH = StringByteLength(SVGContents$, #PB_UTF8)
  svgLenV = StringByteLength(SVGContentsV$, #PB_UTF8)
  ; Chose SVG version that takes less memory
  If svgLenV < svgLenH
    SVGContents$ = SVGContentsV$
  EndIf
  ; Write SVG image to disk
  If CreateFile(0, FileName$, #PB_UTF8)
    WriteString(0, SVGContents$)
    CloseFile(0)
    progressCallback(90)
    ProcedureReturn #Success
  Else
    setError("Unable to write image to disk")
    ProcedureReturn #Failure
  EndIf
EndProcedure

ProcedureDLL finishProcessing()
  progressCallback(100)
EndProcedure

; EOF ;

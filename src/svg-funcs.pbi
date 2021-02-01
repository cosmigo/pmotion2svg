; ******************************************************************************
; This module defines the bitmap to SVG conversion procedures.
; ******************************************************************************

Procedure.s SVGHeader(viewBox_W, viewBox_H)
  SVGHeader$ = ~"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " +
               Str(viewBox_W) + " " + Str(viewBox_H) +
               ~"\" shape-rendering=\"crispEdges\">" + #LF$
  ProcedureReturn SVGHeader$
EndProcedure

Procedure.s GetRGBStr(colorIndex)
  Shared ImageData
  With ImageData
    RGBVal$ = StrU(PeekB(\Palette + colorIndex * 3), #PB_Byte) + ","
    RGBVal$ + StrU(PeekB(\Palette + colorIndex * 3 + 1), #PB_Byte) + ","
    RGBVal$ + StrU(PeekB(\Palette + colorIndex * 3 + 2), #PB_Byte)
  EndWith
  ProcedureReturn RGBVal$
EndProcedure

Procedure.i ConsecutivePixelsH(x, y, colorIndex.b)
  ; ------------------------------------------------------------
  ; Count the consecutive pixels of the same color along X axis.
  ; ------------------------------------------------------------
  Shared ImageData
  With ImageData
    offset = (y * \Width) + x
    consecPixels = 1
    While x + consecPixels <= \Width - 1
      nextIndex = PeekB(\BitMap + offset + consecPixels)
      If nextIndex = colorIndex
        consecPixels + 1
      Else
        Break
      EndIf
    Wend
  EndWith
  ProcedureReturn consecPixels
EndProcedure

Procedure.i ConsecutivePixelsV(x, y, colorIndex.b)
  ; ------------------------------------------------------------
  ; Count the consecutive pixels of the same color along Y axis.
  ; ------------------------------------------------------------
  Shared ImageData
  With ImageData
    offset = (y * \Width) + x
    consecPixels = 1
    While y + consecPixels <= \Height - 1
      nextIndex = PeekB(\BitMap + offset + consecPixels * \Width)
      If nextIndex = colorIndex
        consecPixels + 1
      Else
        Break
      EndIf
    Wend
  EndWith
  ProcedureReturn consecPixels
EndProcedure

Procedure.s SVGRect(x, y, w, h, fill$ = "")
  Shared ImageData
  SVGStr$ = ~"<rect x=\"" + Str(x) +
            ~"\" y=\"" + Str(y) +
            ~"\" width=\"" + Str(w) +
            ~"\" height=\"" + Str(h) + ~"\""
  If fill$ <> #Empty$
    SVGStr$ + ~" fill=\"" + fill$ + ~"\""
  EndIf
  SVGStr$ +"/>" + #LF$
  ProcedureReturn SVGStr$
EndProcedure

Procedure.s SVGPixelsStripe(x, y, len, colorIndex, direction = #SCAN_HORIZONTAL)
  ; ---------------------------------------------------------------------
  ; Draw the longest sequence of same-colored pixels as an SVG rectangle.
  ; ---------------------------------------------------------------------
  Shared ImageData
  With ImageData
    rectX = (x * \Grid) + x * \ScaleF + \Padding
    rectY = (y * \Grid) + y * \ScaleF + \Padding
    If direction = #SCAN_HORIZONTAL
      rectW = (len * \Grid) + len * \ScaleF
      rectH = \ScaleF + \Grid
    Else
      rectW = \ScaleF + \Grid
      rectH = (len * \Grid) + len * \ScaleF
    EndIf
    rectFill$ = "rgb(" + GetRGBStr(colorIndex) + ")"
    ProcedureReturn SVGRect(rectX, rectY, rectW, rectH, rectFill$)
  EndWith
EndProcedure

Procedure.s ConvSVG(direction = #SCAN_HORIZONTAL)
  ; ------------------------------------------------------------------------
  ; Convert a PM frame to an SVG image by scanning it along the X or Y axis.
  ; ------------------------------------------------------------------------
  Shared ImageData
  With ImageData
    ;- Calculate SVG viewBox Setting
    viewBox_W = \Width  * \ScaleF + (\Width  + 1) * \Grid + \Padding * 2
    viewBox_H = \Height * \ScaleF + (\Height + 1) * \Grid + \Padding * 2
    SVGContents$ = SVGHeader(viewBox_W, viewBox_H)
    SVGContents$ + ~"<g id=\"sprite\" stroke=\"none\">" + #LF$

    ; DBG: Paint viewBox background for testing purposes:
    ;   SVGContents$ + SVGRect(0, 0, viewBox_W, viewBox_H, "lavender")

    If Not \PresTransp And \TranspColorIndex <> -1
      ;- Paint Transparent Color as BG Rectangle
      rectX = \Padding
      rectY = \Padding
      rectW = (\Width  * \Grid) + \Width  * \ScaleF
      rectH = (\Height * \Grid) + \Height * \ScaleF
      rectFill$ = "rgb(" + GetRGBStr(\TranspColorIndex) + ")"
      SVGContents$ + SVGRect(rectX, rectY, rectW, rectH, rectFill$)
    EndIf
    If direction = #SCAN_HORIZONTAL
      ;- Horizontally Convert Pixel Stripes to SVG Rectangles
      For y = 0 To \height - 1
        For x = 0 To \Width - 1
          offset = (y * \Width) + x
          colorIndex.b = PeekB(\BitMap + offset)
          colorIndexL.l = colorIndex & $FF
          consecPixels = ConsecutivePixelsH(x, y, colorIndex)
          If \TranspColorIndex <> colorIndexL
            SVGContents$ + SVGPixelsStripe(x, y, consecPixels, colorIndex,
                                           #SCAN_HORIZONTAL)
          EndIf
          x + consecPixels - 1
        Next
      Next
    Else
      ;- Vertically Convert Pixel Stripes to SVG Rectangles
      For x = 0 To \Width - 1
        For y = 0 To \height - 1
          offset = (y * \Width) + x
          colorIndex.b = PeekB(\BitMap + offset)
          colorIndexL.l = colorIndex & $FF
          consecPixels = ConsecutivePixelsV(x, y, colorIndex)
          If \TranspColorIndex <> colorIndexL
            SVGContents$ + SVGPixelsStripe(x, y, consecPixels, colorIndex,
                                           #SCAN_VERTICAL)
          EndIf
          y + consecPixels - 1
        Next
      Next
    EndIf
    If \Grid
      ;- Draw Pixels Grid
      SVGContents$ + ~"<g id=\"grid\" fill=\"black\">" + #LF$
      For y = 0 To ImageData\height
        ; Horizontal grid lines:
        rectX = \Padding
        rectY = \Padding + y + y * \ScaleF
        rectW = \Width + 1 + \Width * \ScaleF
        SVGContents$ + SVGRect(rectX, rectY, rectW, 1)

        For x = 0 To \width
          ; Vertical grid lines:
          rectX = \Padding + x + x * \ScaleF
          rectY = \Padding
          rectH = \Height + 1 + \Height * \ScaleF
          SVGContents$ + SVGRect(rectX, rectY, 1, rectH)
        Next
      Next
      SVGContents$ + "</g>" + #LF$
    EndIf
  EndWith
  SVGContents$ + "</g>" + #LF$ + "</svg>" + #LF$
  ProcedureReturn SVGContents$
EndProcedure

; EOF ;

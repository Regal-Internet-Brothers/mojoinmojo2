Strict

Public

#Rem
	NOTES:
		* This module defines an 'Image' class that attempts
		to provides API compatibility with Mojo 1's 'mojo.graphics' module.
		
		It does this by housing Mojo 2's 'Image' implementation,
		referenced internally as 'Mojo2Image'.
		
		* Concepts like flags, handles, and colors are managed
		the same way as the original 'mojo.graphics' module.
#End

' Imports (Public):
' Nothing so far.

' Imports (Private):
Private

Import mojo2 ' mojo2.graphics

Import brl.databuffer

Public

' Aliases:
Alias Mojo2Image = mojo2.graphics.Image

' Constant variable(s):
Const AlphaBlend:= BlendMode.Alpha
Const AdditiveBlend:= BlendMode.Additive
Const LightenBlend:= AdditiveBlend ' Deprecated.

' Global variable(s) (Private):
Private

Global DefaultCanvas:Canvas

Global GraphicsCanvas:Canvas
Global GraphicsList:DrawList

Public

' Classes:
Class Image
	' Constant variable(s) (Public):
	Const MidHandle:= 1
	
	Const XPadding:= 2
	Const YPadding:= 4
	Const XYPadding:= (XPadding | YPadding)
	
	Const Filter:= 8 ' Texture.Filter
	Const Mipmap:= 16 ' Texture.Mipmap
	Const Managed:= 32 ' Texture.Managed
	
	' Constant variable(s) (Private):
	Private
	
	'Const FullFrame:= 65536
	
	Public
	
	' Global variable(s):
	Global DefaultFlags:= (Managed)
	
	' Functions (Private):
	Private
	
	' This command converts Mojo 1 flags to Mojo 2 flags (If applicable).
	Function NativeFlags:Int(MojoFlags:Int)
		Local NewFlags:= 0
		
		If ((MojoFlags & Filter) > 0) Then
			NewFlags |= Mojo2Image.Filter
		Endif
		
		If ((MojoFlags & Mipmap) > 0) Then
			NewFlags |= Mojo2Image.Mipmap
		Endif
		
		If ((MojoFlags & Managed) > 0) Then
			NewFlags |= Mojo2Image.Managed
		Endif
		
		#If MOJO_IMAGE_FILTERING_ENABLED
			NewFlags |= Mojo2Image.Filter
		#End
		
		Return NewFlags
	End
	
	' Behavior consistency layer (Taken from my 'resources' module):
	Function LoadImage:Mojo2Image[](Path:String, FrameCount:Int=1, Flags:Int=DefaultFlags, HandleX:Float=0.5, HandleY:Float=0.5, Padded:Bool=False)
		Return Mojo2Image.LoadFrames(Path, FrameCount, Padded, HandleX, HandleY, Flags)
	End
	
	Function LoadImage:Mojo2Image[](Path:String, FrameWidth:Int, FrameHeight:Int, FrameCount:Int, Flags:Int=DefaultFlags, HandleX:Float=0.5, HandleY:Float=0.5, PersistentOffset:Bool=True)
		Return GrabImage(Material.Load(Path, Flags, Null), 0, 0, FrameWidth, FrameHeight, FrameCount, Flags, HandleX, HandleY, PersistentOffset)
	End
	
	Function GrabImage:Mojo2Image[](I:Mojo2Image, X:Int, Y:Int, FrameWidth:Int, FrameHeight:Int, FrameCount:Int=1, Flags:Int=DefaultFlags, HandleX:Float=0.5, HandleY:Float=0.5, PersistentOffset:Bool=True)
		Return GrabImage(I.Material, X, Y, FrameWidth, FrameHeight, FrameCount, Flags, HandleX, HandleY, PersistentOffset)
	End
	
	Function GrabImage:Mojo2Image[](M:Material, X:Int, Y:Int, FrameWidth:Int, FrameHeight:Int, FrameCount:Int=1, Flags:Int=DefaultFlags, HandleX:Float=0.5, HandleY:Float=0.5, PersistentOffset:Bool=True)
		Local TW:= M.Width
		Local TH:= M.Height
		
		Local Count:= Min((TW / FrameWidth) + (TH / FrameHeight), FrameCount)
		
		Local Output:= New Mojo2Image[Count]
		
		Local AdjustedTW:= (TW-X)
		'Local AdjustedTH:= (TH-Y)
		
		For Local Entry:= 0 Until Count ' Output.Length
			Local VPos:= (Entry*FrameWidth)
			Local Row:= (VPos / AdjustedTW)
			Local IX:= (VPos Mod AdjustedTW)
			Local IY:= (Row * FrameWidth)+Y ' * FrameHeight
			
			If (PersistentOffset Or Row = 0) Then
				'IY += Y
				IX += X
			Endif
			
			Output[Entry] = New Mojo2Image(M, IX, IY, FrameWidth, FrameHeight, HandleX, HandleY)
		Next
		
		Return Output
	End
	
	Public
	
	' Constructor(s) (Private):
	Private
	
	Method New(Width:Int, Height:Int, FrameCount:Int=1, Flags:Int=DefaultFlags)
		'Flags |= Managed
		
		Self.ImageFrames = New Mojo2Image[FrameCount]
		
		Local RealFlags:= NativeFlags(Flags)
		
		For Local I:= 0 Until FrameCount
			Self.ImageFrames[I] = New Mojo2Image(Width, Height, 0.0, 0.0, RealFlags)
		Next
		
		ApplyFlags(Flags)
	End
	
	Method New(Frames:Mojo2Image[], Flags:Int=DefaultFlags)
		Self.ImageFrames = Frames
		
		ApplyFlags(Flags)
	End
	
	Public
	
	' Methods (Public):
	Method Width:Int()
		Return FirstFrame.Width
	End
	
	Method Height:Int()
		Return FirstFrame.Height
	End
	
	Method Loaded:Int()
		Return 1
	End
	
	Method Frames:Int()
		Return ImageFrames.Length
	End
	
	Method Flags:Int()
		Return Self._Flags
	End

	Method HandleX:Float()
		Return FirstFrame.HandleX*Width
	End
	
	Method HandleY:Float()
		Return FirstFrame.HandleY*Height
	End
	
	Method GrabImage:Image(X:Int, Y:Int, Width:Int, Height:Int, FrameCount:Int=1, Flags:Int=DefaultFlags)
		Return New Image(GrabImage(FirstFrame, X, Y, Width, Height, FrameCount, NativeFlags(DefaultFlags), 0.0, 0.0, True), Flags)
	End
	
	Method SetHandle:Int(TX:Float, TY:Float)
		For Local I:= 0 Until ImageFrames.Length
			ImageFrames[I].SetHandle(TX / ImageFrames[I].Width, TY / ImageFrames[I].Height)
		Next
		
		Self._Flags &= ~MidHandle
		
		' Return the default response.
		Return 0
	End
	
	' API Extension.
	Method SetHandle:Int(TX:Float, TY:Float, Optimize:Bool)
		If (Not Optimize) Then
			Return SetHandle(TX, TY)
		Endif
		
		Local HX:= (TX / FirstFrame.Width)
		Local HY:= (TY / FirstFrame.Height)
		
		For Local I:= 0 Until ImageFrames.Length
			ImageFrames[I].SetHandle(HX, HY)
		Next
		
		Self._Flags &= ~MidHandle
		
		' Return the default response.
		Return 0
	End
	
	Method Discard:Int()
		For Local I:= 0 Until ImageFrames.Length
			ImageFrames[I].Discard()
		Next
		
		ImageFrames = []
		
		' Return the default response.
		Return 0
	End
	
	Method WritePixels:Void(Pixels:Int[], X:Int, y:Int, Width:Int, Height:Int, Offset:Int=0, Pitch:Int=0)
		'If (Pitch <= 0) Then Pitch = Width
		
		' Local variable(s):
		Local Buffer:= New DataBuffer(Min(Pixels.Length, (Width*Height*4))) ' SizeOf_Integer
		
		FirstFrame.WritePixels(X, Y, Width, Height, Buffer, Offset, Pitch)
		
		Buffer.Discard()
		
		Return
	End
	
	' Methods (Private):
	Private
	
	Method ApplyFlags:Void(MojoFlags:Int, ApplyHandle:Bool=True)
		Self._Flags = MojoFlags
		
		If ((MojoFlags & MidHandle) > 0) Then
			SetHandle(Width()/2, Height()/2)
		Endif
		
		Return
	End
	
	Public
	
	' Properties (Private):
	Private
	
	Method FirstFrame:Mojo2Image() Property
		Return ImageFrames[0]
	End
	
	Public
	
	' Fields (Private):
	Private
	
	Field ImageFrames:Mojo2Image[]
	
	Field _Flags:Int
	
	Public
End

' Functions:

' Extended API:

' This will use the last 'Canvas' specified for 'Canvas' only operations.
Function InitDraw:Void(Graphics:DrawList)
	GraphicsList = Graphics
	
	Return
End

' This will assign both the global 'Canvas', and the global 'DrawList'.
Function InitDraw:Void(Graphics:Canvas)
	GraphicsCanvas = Graphics
	
	InitDraw(DrawList(GraphicsCanvas))
	
	Return
End

' This will initialize Mojo-in-Mojo2's graphical functionality.
Function InitDraw:Void()
	If (DefaultCanvas = Null) Then
		DefaultCanvas = New Canvas()
		
		Shader.SetDefaultShader(Shader.FastShader())
	Endif
	
	InitDraw(DefaultCanvas)
	
	Return
End

' This returns the current internal 'Canvas'.
Function GetCurrentCanvas:Canvas()
	Return GraphicsCanvas
End

' This returns the current internal 'DrawList'.
Function GetCurrentDrawList:DrawList()
	Return GraphicsList
End

' This converts a Mojo color (0.0 to 255.0) into a Mojo 2 / OpenGL color (0.0 to 1.0).
Function ConvertColor:Float(MojoColor:Float)
	Return (MojoColor / 255.0)
End

' This command may be used to display the current 'Canvas' and/or 'DrawList'.
Function Flip:Void()
	GraphicsCanvas.Flush()
	
	If (GraphicsList <> GraphicsCanvas) Then
		GraphicsList.Flush()
	Endif
	
	Return
End

' This provides the internal 'Material' used by the current font.
Function GetFontMaterial:Material()
	Return GraphicsList.Font.GetGlyph(65).image.Material
End

' Standard API (Behavior partially defined):
Function BeginRender:Int()
	' Reserved; do not modify.
	
	Return 0
End

Function EndRender:Int()
	' Reserved; do not modify.
	
	Return 0
End

Function LoadImage:Image(Path:String, FrameCount:Int=1, Flags:Int=Image.DefaultFlags, Padded:Bool=False)
	Return New Image(Image.LoadImage(Path, FrameCount, Image.NativeFlags(Flags), 0.0, 0.0, Padded), Flags)
End

Function LoadImage:Image(Path:String, FrameWidth:Int, FrameHeight:Int, FrameCount:Int, Flags:Int=Image.DefaultFlags) ' Padded:Bool=False
	Return New Image(Image.LoadImage(Path, FrameWidth, FrameHeight, FrameCount, Image.NativeFlags(Flags), 0.0, 0.0, True), Flags)
End

Function CreateImage:Image(Width:Int, Height:Int, FrameCount:Int=1, Flags:Int=Image.DefaultFlags)
	Return New Image(Width, Height, FrameCount, Flags)
End

Function SetColor:Int(R:Float, G:Float, B:Float)
	GraphicsList.SetColor(ConvertColor(R), ConvertColor(G), ConvertColor(B))
	
	' Return the default response.
	Return 0
End

Function GetColor:Float[]()
	Return GraphicsList.Color ' [..3]
End

' This is currently a bit of a hack:
Function GetColor:Int(Color:Float[])
	Local C:= GetColor()
	
	For Local I:= 0 Until 3 ' 4
		Color[I] = C[I]
	Next
	
	' Return the default response.
	Return 0
End

Function SetAlpha:Int(Alpha:Float)
	GraphicsList.SetAlpha(Alpha)
	
	' Return the default response.
	Return 0
End

Function GetAlpha:Float()
	Return GraphicsList.Alpha
End

Function SetBlend:Int(Mode:Int)
	GraphicsList.SetBlendMode(Mode)
	
	' Return the default response.
	Return 0
End

Function GetBlend:Int()
	Return GraphicsList.BlendMode
End

Function SetScissor:Int(X:Float, Y:Float, Width:Float, Height:Float)
	GraphicsCanvas.SetScissor(Int(X), Int(Y), Int(Width), Int(Height))
	
	' Return the default response.
	Return 0
End

Function GetScissor:Float[]()
	Local Scissor:Float[4]
	
	Local RealScissor:= GraphicsCanvas.Scissor
	
	For Local I:= 0 Until 4
		Scissor[I] = Float(RealScissor[I])
	Next
	
	Return Scissor
End

Function GetScissor:Int(Scissor:Float[])
	Local RealScissor:= GraphicsCanvas.Scissor
	
	For Local I:= 0 Until 4
		Scissor[I] = Float(RealScissor[I])
	Next
	
	' Return the default response.
	Return 0
End

Function SetMatrix:Int(M:Float[])
	SetMatrix(M[0], M[1], M[2], M[3], M[4], M[5])
	
	' Return the default response.
	Return 0
End

Function SetMatrix:Void(ix:Float, iy:Float, jx:Float, jy:Float, tx:Float, ty:Float)
	GraphicsList.SetMatrix(ix, iy, jx, jy, tx, ty)
	
	Return
End

Function GetMatrix:Float[]()
	Local M:Float[6]
	
	GetMatrix(M)
	
	Return M
End

Function GetMatrix:Int(M:Float[])
	GraphicsList.GetMatrix(M)
	
	' Return the default response.
	Return 0
End

Function PushMatrix:Int()
	GraphicsList.PushMatrix()
	
	' Return the default response.
	Return 0
End

Function PopMatrix:Int()
	GraphicsList.PopMatrix()
	
	' Return the default response.
	Return 0
End

Function Transform:Int(M:Float[])
	Transform(M[0], M[1], M[2], M[3], M[4], M[5])
	
	' Return the default response.
	Return 0
End

Function Transform:Int(ix:Float, iy:Float, jx:Float, jy:Float, tx:Float, ty:Float)
	GraphicsList.Transform(ix, iy, jx, jy, tx, ty)
	
	' Return the default response.
	Return 0
End

Function Translate:Int(X:Float, Y:Float)
	GraphicsList.Translate(X, Y)
	
	' Return the default response.
	Return 0
End

Function Scale:Int(X:Float, Y:Float)
	GraphicsList.Scale(X, Y)
	
	' Return the default response.
	Return 0
End

Function Rotate:Int(Angle:Float)
	GraphicsList.Rotate(Angle)
	
	' Return the default response.
	Return 0
End

Function Cls:Int()
	#If MOJOINMOJO2_AUTO_FLIP
		Flip()
	#End
		
	GraphicsCanvas.Clear()
	
	' Return the default response.
	Return 0
End

Function Cls:Int(R:Float, G:Float, B:Float)
	#If MOJOINMOJO2_AUTO_FLIP
		Flip()
	#End
	
	GraphicsCanvas.Clear(ConvertColor(R), ConvertColor(G), ConvertColor(B))
	
	' Return the default response.
	Return 0
End

Function DrawPoint:Int(X:Float, Y:Float)
	GraphicsList.DrawPoint(X, Y)
	
	' Return the default response.
	Return 0
End

Function DrawRect:Int(X:Float, Y:Float, Width:Float, Height:Float)
	GraphicsList.DrawRect(X, Y, Width, Height)
	
	' Return the default response.
	Return 0
End

Function DrawLine:Int(X1:Float, Y1:Float, X2:Float, Y2:Float)
	GraphicsList.DrawLine(X1, Y1, X2, Y2)
	
	' Return the default response.
	Return 0
End

Function DrawOval:Int(X:Float, Y:Float, Width:Float, Height:Float)
	GraphicsList.DrawOval(X, Y, Width, Height)
	
	' Return the default response.
	Return 0
End

Function DrawCircle:Int(X:Float, Y:Float, R:Float)
	GraphicsList.DrawCircle(X, Y, R)
	
	' Return the default response.
	Return 0
End

Function DrawEllipse:Int(X:Float, Y:Float, XR:Float, YR:Float)
	GraphicsList.DrawEllipse(X, Y, XR, YR)
	
	' Return the default response.
	Return 0
End

Function DrawPoly:Int(Vertices:Float[])
	GraphicsList.DrawPoly(Vertices)
	
	' Return the default response.
	Return 0
End

' This command is currently unfinished.
Function DrawPoly:Int(Vertices:Float[], I:Image, Frame:Int=0)
	GraphicsList.DrawPoly(Vertices, I.FirstFrame.Materials)
	
	' Return the default response.
	Return -1 ' 0
End

Function DrawImage:Int(I:Image, X:Float, Y:Float, Frame:Int=0)
	GraphicsList.DrawImage(I.ImageFrames[Frame], X, Y)
	
	' Return the default response.
	Return 0
End

Function DrawImage:Int(I:Image, X:Float, Y:Float, Rotation:Float, ScaleX:Float, ScaleY:Float, Frame:Int=0)
	GraphicsList.DrawImage(I.ImageFrames[Frame], X, Y, Rotation, ScaleX, ScaleY)
	
	' Return the default response.
	Return 0
End

Function DrawImageRect:Int(I:Image, X:Float, Y:Float, SourceX:Int, SourceY:Int, SourceWidth:Int, SourceHeight:Int, Frame:Int=0)
	GraphicsList.DrawRect(X, Y, I, SourceX, SourceY, SourceWidth, SourceHeight)
	
	' Return the default response.
	Return 0
End

Function DrawImageRect:Int(I:Image, X:Float, Y:Float, SourceX:Int, SourceY:Int, SourceWidth:Int, SourceHeight:Int, Rotation:Float, ScaleX:Float, ScaleY:Float, Frame:Int=0)
	GraphicsList.PushMatrix()
	
	GraphicsList.TranslateRotateScale(X, Y, Rotation, ScaleX, ScaleY)
	
	GraphicsList.Translate(-I.HandleX, -I.HandleY)
	
	'DrawImageRect(I, X, Y, SourceX, SourceY, SourceWidth, SourceHeight, Frame)
	GraphicsList.DrawRect(X, Y, I, SourceX, SourceY, SourceWidth, SourceHeight)
	
	GraphicsList.PopMatrix()
	
	' Return the default response.
	Return 0
End

' Largely untested; use at your own risk.
Function ReadPixels:Int(Pixels:Int[], X:Int, Y:Int, Width:Int, Height:Int, Offset:Int=0, Pitch:Int=0)
	Local Temp:= New DataBuffer((Pixels.Length-Offset)*4) ' SizeOf_Integer
	
	ReadPixels(X, Y, Width, Height, Temp, Offset, Pitch)
	
	Temp.PeekInts(0, Pixels, Offset, Count)
	
	Temp.Discard()
	
	' Return the default response.
	Return 0
End

' Fonts are not currently cached, so performance may be poor when switching fonts frequently.
' Font generation is not perfect; does not support font-generation from multiple frames. (Raw 'Material' capture)
Function SetFont:Int(Font:Image, FirstChar:Int=32)
	If (Font = Null) Then
		GraphicsList.SetFont(Null)
		
		Return 0
	Endif
	
	' Local variable(s):
	Local RealImage:= New Mojo2Image(Font.FirstFrame.Material, 0.0, 0.0)
	Local Characters:= (128 - FirstChar) ' 96
	
	Local CellWidth:= (RealImage.Width / Characters)
	Local CellHeight:= RealImage.Height
	
	Local GlyphX:= 0
	Local GlyphY:= 0
	Local GlyphWidth:= CellWidth
	Local GlyphHeight:= CellHeight
	
	Local W:= (RealImage.Width / CellWidth)
	'Local H:= (RealImage.Height / CellHeight)
	
	Local glyphs:= New Glyph[Characters]
	
	For Local I:= 0 Until Characters
		Local Y:= (I / W)
		Local X:= (I Mod W)
		
		glyphs[I] = New Glyph(RealImage, FirstChar+I, X*CellWidth+GlyphX, Y*CellHeight+GlyphY, GlyphWidth, GlyphHeight, GlyphWidth)
	Next
	
	GraphicsList.SetFont(New Font(glyphs, FirstChar, GlyphHeight))
	
	' Return the default response.
	Return 0
End

Function GetFont:Image()
	Return New Image(GetFontMaterial(), 0.0, 0.0) ' A
End

Function TextWidth:Float(Text:String)
	Return GraphicsList.Font.TextWidth(Text)
End

Function TextHeight:Float()
	Return FontHeight
End

Function FontHeight:Float()
	Return GraphicsList.Font.TextHeight
End

Function DrawText:Int(Text:String, X:Float, Y:Float, XAlign:Float=0.0, YAlign:Float=0.0)
	GraphicsList.DrawText(Text, X, Y, XAlign, YAlign)
	
	' Return the default response.
	Return 0
End

Function InvTransform:Float[](coords:Float[])
	Local m00:=   context.ix
	Local m10:=   context.jx
	Local m20:=   context.tx
	Local m01:=   context.iy
	Local m11:=   context.jy
	Local m21:=   context.ty
	
	Local det:=   m00*m11 - m01*m10
	Local idet:=  1.0/det
	
	Local r00:=  m11 * idet
	Local r10:= -m10 * idet
	Local r20:= (m10*m21 - m11*m20) * idet
	Local r01:= -m01 * idet
	Local r11:=  m00 * idet
	Local r21:= (m01*m20 - m00*m21) * idet
	'Local r22# = (m00*m11 - m01*m10) * idet ' What do I do with this?
	
	Local ix:= r00
	Local jx:= r10
	Local tx:= r20
	Local iy:= r01
	Local jy:= r11
	Local ty:= r21
	
	Local out:Float[coords.Length]
	
	For Local i:= 0 Until (coords.Length-1) Step 2
		Local x:= coords[i]
		Local y:= coords[i+1]
		
		out[i] = (x*ix + y*jx + tx)
		out[i+1] = (x*iy + y*jy + ty)
	Next
	
	Return out
End
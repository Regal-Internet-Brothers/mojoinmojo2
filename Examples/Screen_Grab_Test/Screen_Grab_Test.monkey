Strict

Public

' Imports:
Import regal.mojoinmojo2

' Classes:
Class Application Extends App
	' Methods:
	Method OnCreate:Int()
		SetUpdateRate(0) ' 60 ' 30
		
		InitDraw()
		
		screenCapture = CreateImage(DeviceWidth(), DeviceHeight(), 1, Image.MidHandle)
		
		pixelData = New Int[screenCapture.Width()*screenCapture.Height()]
		
		redraw = False
		
		Return 0
	End
	
	Method OnUpdate:Int()
		If (KeyHit(KEY_SPACE) Or KeyDown(KEY_A)) Then
			redraw = True
		Endif
		
		Return 0
	End
	
	Method OnRender:Int()
		Const RW:= 64.0
		Const RH:= 64.0
		
		If (Not redraw) Then
			Cls(0.0, 0.0, 0.0)
			
			DrawImage(screenCapture, DeviceWidth()/2, DeviceHeight()/2, 0.0, 1.0, 1.0)
		Else
			Local lastSeed:= Seed
			
			Seed = Millisecs()
			
			Cls(ToMojoColor(0.8 * Rnd(0.0, 1.0)), ToMojoColor(0.53 * Rnd(0.0, 1.0)), ToMojoColor(0.88 * Rnd(0.0, 1.0)))
			
			For Local Y:= 0 Until (DeviceHeight() / RH)
				For Local X:= 0 Until (DeviceWidth() / RW)
					SetColor(ToMojoColor(Rnd(0.0, 1.0)), ToMojoColor(Sin(X*Y)), ToMojoColor(Cos(Y+(X*RH))*Rnd(0.0, 1.0)))
					
					DrawRect(X*RW, Y*RH, RW, RH)
				Next
			Next
			
			SetAlpha(Rnd(0.0, 1.25) * 0.75)
			
			DrawImage(screenCapture, DeviceWidth()/2, DeviceHeight()/2, 0.0, Rnd(0.25, 2.0), Rnd(0.25, 2.0))
			
			SetAlpha(1.0)
			
			ReadPixels(pixelData, 0, 0, screenCapture.Width(), screenCapture.Height())
			
			screenCapture.WritePixels(pixelData, 0, 0, screenCapture.Width(), screenCapture.Height())
			
			Seed = lastSeed
			
			redraw = False
		Endif
		
		DrawText("Press SPACE to go crazy, hold A to go further.", 8.0, 8.0)
		
		Flip()
		
		Return 0
	End
	
	Method OnClose:Int()
		pixelData = []
		
		Return Super.OnClose()
	End
	
	' Fields:
	Field screenCapture:Image
	Field pixelData:Int[]
	
	Field graphics:Canvas
	
	Field redraw:Bool
End

' Functions:
Function Main:Int()
	New Application()
	
	Return 0
End
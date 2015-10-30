Strict

Public

' Imports:
Import regal.mojoinmojo2

' Classes:
Class Application Extends App Final
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		SetSwapInterval(0)
		
		InitDraw()
		
		I = LoadImage("Test.png", 1, Image.MidHandle)
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		Cls()
		
		DrawText("Hello, world.", 16.0, 16.0)
		
		PushMatrix()
		
		Local HW:= Float(I.Width() / 2)
		Local HH:= Float(I.Height() / 2)
		
		Translate(MouseX(), MouseY())
		
		Rotate(Float(Millisecs() / 10))
		
		Translate(HW, HH)
		
		DrawImage(I, -HW, -HH)
		
		PopMatrix()
		
		Local IHW:= Int(HW)
		Local IHH:= Int(HH)
		
		DrawImageRect(I, HW, HH, 0, 0, IHW, IHH)
		DrawImageRect(I, HW, HH*2, IHW, 0, IHW, IHH)
		DrawImageRect(I, HW, HH*3, IHW, IHH, IHW, IHH)
		DrawImageRect(I, HW, HH*4, 0, IHH, IHW, IHH)
		
		Flip()
		
		' Return the default response.
		Return 0
	End
	
	Field I:Image
End

' Functions:
Function Main:Int()
	New Application()
	
	' Return the default response.
	Return 0
End
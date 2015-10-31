Strict

Public

'#MOJOINMOJO2_THREADED_ASYNC = False
'#MOJO_IN_MOJO2_DEMO_REFLECTION = True

#If MOJO_IN_MOJO2_DEMO_REFLECTION
	#REFLECTION_FILTER = "regal.mojoinmojo2.*"
#End

' Imports:
Import regal.mojoinmojo2

#If MOJO_IN_MOJO2_DEMO_REFLECTION
	Import reflection
#End

' Classes:
Class Application Extends App Implements IOnLoadImageComplete Final
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		SetSwapInterval(0)
		
		InitDraw()
		
		LoadImageAsync("Test.png", 1, Image.MidHandle, Self)
		
		' Return the default response.
		Return 0
	End
	
	' Methods:
	Method OnUpdate:Int()
		UpdateAsyncEvents()
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		Cls()
		
		DrawText("Hello, world.", 16.0, 16.0)
		
		If (I = Null) Then
			DrawText("Waiting for image...", 16.0, 48.0) ' 32.0
		Else
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
		Endif
		
		Flip()
		
		' Return the default response.
		Return 0
	End
	
	' Callbacks:
	Method OnLoadImageComplete:Void(I:Image, Path:String, Source:IAsyncEventSource)
		Self.I = I
		
		Return
	End
	
	' Fields:
	Field I:Image
End

' Functions:
Function Main:Int()
	New Application()
	
	' Return the default response.
	Return 0
End
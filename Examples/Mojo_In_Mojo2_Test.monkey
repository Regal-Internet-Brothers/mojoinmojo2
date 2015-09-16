Strict

Public

' Imports:
Import mojoinmojo2

' Classes:
Class Application Extends App Final
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		
		InitDraw()
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		Cls()
		
		DrawText("Hello, world.", 16.0, 16.0)
		
		Flip()
		
		' Return the default response.
		Return 0
	End
End

' Functions:
Function Main:Int()
	New Application()
	
	' Return the default response.
	Return 0
End
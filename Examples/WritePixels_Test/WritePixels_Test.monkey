Strict

Public

' Preprocessor related:
#WRITEPIXELS_DEMO_HACK = True
'#WRITEPIXELS_DEMO_RELATIVE = True

' Imports:
Import regal.mojoinmojo2

' Classes:
Class Application Extends App
	' Constant variable(s):
	Const FrameWidth:= 64
	Const FrameHeight:= 64
	Const FrameCount:= 10
	
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		
		InitDraw()
		
		Seed = Millisecs()
		
		Self.Frame = 0
		
		#If WRITEPIXELS_DEMO_HACK
			Self.Data = CreateImage(FrameWidth*FrameCount, FrameHeight, 1)
		#Else
			Self.Data = CreateImage(FrameWidth, FrameHeight, FrameCount, Image.MidHandle)
		#End
		
		Local RawData:= New Int[FrameWidth*FrameHeight]
		
		For Local EntryNumber:= 0 Until FrameCount
			RandomizeImage(RawData)
			
			#If WRITEPIXELS_DEMO_RELATIVE
				Local I:= Self.Data.GrabImage(EntryNumber * FrameWidth, 0, FrameWidth, FrameHeight, 1)
				
				I.WritePixels(RawData, 0, 0, FrameWidth, FrameHeight)
				
				' Just a formality, this doesn't do anything right now.
				I.Discard()
			#Else
				Self.Data.WritePixels(RawData, EntryNumber * FrameWidth, 0, FrameWidth, FrameHeight)
			#End
		Next
		
		#If WRITEPIXELS_DEMO_HACK
			Self.Data = Self.Data.GrabImage(0, 0, FrameWidth, FrameHeight, FrameCount, Image.MidHandle)
		#End
		
		Return 0
	End
	
	' Methods:
	Method OnRender:Int()
		Cls()
		
		DrawImage(Data, DeviceWidth() / 2.0, DeviceHeight() / 2.0, Frame)
		
		Flip()
		
		Return 0
	End
	
	Method OnUpdate:Int()
		Frame = ((Frame + 1) Mod FrameCount)
		
		Return 0
	End
	
	Method RandomizeImage:Void(Data:Int[])
		For Local I:= 0 Until Data.Length
			Data[I] = Rnd(-2147483647, 2147483647)
		Next
		
		Return
	End
	
	' Fields:
	Field Data:Image
	Field Frame:Int
End

' Functions:
Function Main:Int()
	New Application()
	
	Return 0
End
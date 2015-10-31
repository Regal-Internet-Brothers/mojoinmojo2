Strict

Public

' Imports (Public):
Import graphics
Import asyncloaders

Import brl.asyncevent

' Imports (Private):
Private

Import brl.thread

Import mojo.data

Import opengl.gles20
'Import opengl.gles11

Public

' Classes (Private):
Private

Class AsyncImageLoaderThread Extends Thread
	' Fields:
	Field Result:Bool
	
	Field Path:String
	Field Data:DataBuffer
	Field Info:Int[]
	
	' Methods:
	Method Start:Void()
		' Create a blank buffer.
		Data = New DataBuffer ' ()
		Info = New Int[2] ' 4
		
		#If Not MOJOINMOJO2_THREADED_ASYNC
			Run__UNSAFE__()
		#Else
			Super.Start()
		#End
		
		Return
	End
	
	Method Run__UNSAFE__:Void()
		Result = (BBLoadImageData(Data, Path, Info) <> Null)
		
		Return
	End
End

Public

' Classes (Public):
Class AsyncImageLoader Extends AsyncImageLoaderThread Implements IAsyncEventSource
	' Constructor(s):
	Method New(Path:String, Frames:Int=1, Flags:Int=Image.DefaultFlags, OnComplete:IOnLoadImageComplete)
		Self.RealPath = Path
		Self.Path = FixDataPath(Path)
		Self.Frames = Frames
		Self.Flags = Flags
		Self.OnComplete = OnComplete
	End
	
	' Methods (Public):
	Method Start:Void()
		AddAsyncEventSource(Self)
		
		Super.Start()
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method UpdateAsyncEvents:Void()
		If (IsRunning()) Then
			Return
		Endif
		
		RemoveAsyncEventSource(Self)
		
		If (Result) Then
			OnComplete.OnLoadImageComplete(New Image(Data, Info, Flags), RealPath, Self)
		Else
			OnComplete.OnLoadImageComplete(Null, RealPath, Self)
		Endif
		
		Return
	End
	
	Public
	
	' Fields (Protected):
	Protected
	
	Field RealPath:String
	Field Frames:Int
	Field Flags:Int
	
	Field OnComplete:IOnLoadImageComplete
	
	Public
End
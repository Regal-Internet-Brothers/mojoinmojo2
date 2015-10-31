Strict

Public

' Preprocessor related:
#MOJOINMOJO2_THREADED_ASYNC = True ' False

' Imports (Public):

' Internal:
Import graphics
Import audio

Import asyncsoundloader

' External:
Import brl.asyncevent

' Imports (Private):
Private

' Internal:
Import asyncimageloader

Public

' Interfaces:
Interface IOnLoadImageComplete
	' Methods:
	Method OnLoadImageComplete:Void(I:Image, Path:String, Source:IAsyncEventSource)
End

' Functions:
Function LoadImageAsync:Void(Path:String, Frames:Int=1, Flags:Int=Image.DefaultFlags, OnComplete:IOnLoadImageComplete)
	Local Loader:= New AsyncImageLoader(Path, Frames, Flags, OnComplete)
	
	Loader.Start()
	
	Return
End
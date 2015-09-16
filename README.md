# mojoinmojo2
A heavily experimental API-wrapper for [Monkey](https://github.com/blitz-research/monkey) that converts Mojo 1 calls to Mojo 2.

Behavior is largely untested, and is likely unstable. If you're willing to be a guinea pig, try it out. In order to get an existing Mojo application running, you'll need to change a few things:
* First, you'll need to change all imports to 'mojo' (Main module) to 'mojoinmojo2'. In addition, you'll need to change 'mojo.graphics' to 'mojoinmojo2.graphics'. (**This step can be avoided by changing the file-structure, and editing a few files**)
* Next, you'll need to call the API-extension command 'InitDraw' in 'OnCreate'. (Before anything graphics related)
* Now, just edit 'OnRender', and add a call to 'Flip' at the end.

If you followed these steps, it should build. Nothing's guaranteed, and behavior is largely undefined. Not to mention the performance problems. Still, if you want to experiment with shaders in an existing project, this can help you do that.

**Use this module at your own risk.**

# mojoinmojo2
An experimental API-wrapper for [Monkey](https://github.com/blitz-research/monkey) that converts Mojo 1 (Graphics) calls to Mojo 2.

Many intricate behaviors of 'mojo.graphics' are untested. Some have been tested, but aren't accurate currently ([See below](#known-bugs--inconsistencies)).

If you're willing to be a guinea pig, try it out.

## Installation Guide:
Though this is an experimental module, usually associated with the '[regal](https://github.com/Regal-Internet-Brothers/regal-modules)' group of modules, this does not require any other third party modules. This rule is enforced to allow for easy portability, and usage for existing Mojo applications.

In order to get an existing Mojo application running, you'll need to do one or more of the following things:
* The first option is to change all imports to 'mojo' (Main module) to 'mojoinmojo2'. In addition, you'll need to change 'mojo.graphics' to 'mojoinmojo2.graphics'.
* The second option is to rename every use of 'mojo' in 'mojoinmojo2', then rename 'mojoinmojo2' to 'mojo'. (Less useful)

In general, that step is up to you. If you wish to use the '[regal](https://github.com/Regal-Internet-Brothers/regal-modules)' prefix, added that to uses of 'mojoinmojo2'. Usage of other sub-modules should be automatically routed when using 'mojoinmojo2', but at the same time, **code not using 'mojo.graphics'** (Or possibly 'mojo.app', and similar functionality) **won't need to be changed at all**.

After installation, you'll need to call some API-extensions:
* Call 'InitDraw', in your 'OnCreate' implementation (Before anything graphics related).
* Call 'Flip' at the end of your 'OnRender' implementation.

If you followed these steps, it should build. Nothing's guaranteed, and behavior is usually undefined, but still aiming for feature equivalence. That means things are meant to compile, and ideally, not crash. Graphical artifacts are expected. Still, if you want to experiment with shaders in an existing project, this can help you do that.

**Use this module at your own risk.**

Below is a list of known issues with this implementation of 'mojo.graphics'. Everything in that list is on the "road-map", and should be fixed.

## Known Bugs / Inconsistencies:
* "DataPitch" in 'ReadPixels' and/or 'WritePixels' is broken. (Untested to begin with)
* 'GetFont' returns what is effectively a garbage 'Image', only meant to get some less graceful use-cases working.
* Mojo 2's font is transparent, *slightly different*, and automatically imported.
* Internally, there are temporary fixes that require a font to implement **A** as a character. (Will be fixed)

## "Tested" behavior:
* 'LoadImageAsync' checks out, at least for the main demo.
* With the most recent font hack(s), the "game of life" banana works properly.
* The "fire paint" banana works very accurately.
* * Most basic bananas provided with Moneky work without an issue.

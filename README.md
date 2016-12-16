
RtMidi - D bindings
===================

This is a D port / bindings for the realtime MIDI i/o C++ RtMidi library,
version 2.2.1. 

Using a callback function is not supported. 

`example/recorder.d` is a fairly complete example of how to use it.

It has been tested on an Ubuntu Linux 15.04, however there is no OS specific code, 
so it should be portable.


Building
--------

A fork of the RtMidi library should be installed: https://github.com/remy-j-a-moueza/rtmidi with the `c-api-changes` branch. It captures C++ exceptions in C++ so that they can be rethrown in D with the right error message. 

On Linux, depending on where it is installed, running
`ldconfig /path/to/librtmidi.a` may be necessary to run the compiled
executables or else you may have to set the `LD_LIBRARY_PATH` variable.

Then `dub build` should build the library in the lib/ directory.

Change directory to example/ and run `dub build` to build the example program.

Example
-------

The example programs records notes from an instrument on port number 1 and replay them once the user press `Enter`. An exception will be thrown if no intrument is available on port #1. 
To stop the program, after the notes have been played, press `Space` then `Enter`.

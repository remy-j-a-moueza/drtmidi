
RtMidi - D bindings
===================

This is a D port / bindings for the realtime MIDI i/o C++ RtMidi library,
version 2.2.1. 

Using a callback function is not supported. 

`recorder.d` is a fairly complete example of how to use it.

It has been tested on an Ubuntu Linux 15.04, however there is no OS specific code, 
so it should be portable.


# Building # 

The RtMidi library should be installed.

On Linux, depending on where it is installed, running
`ldconfig /path/to/librtmidi.a` may be necessary to run the compiled
executables or else you may have to set the `LD_LIBRARY_PATH` variable.

Then `dub build` should build the library in the lib/ directory.

Change directory to example/ and run `dub build` to build the example program.

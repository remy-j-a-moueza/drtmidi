/**********************************************************************/
/*  A D port of the RtMidi API. 
    
    Written by Rémy Mouëza (https://github.com/remy-j-a-moueza)

    RtMidi WWW site: http://music.mcgill.ca/~gary/rtmidi/

    RtMidi: realtime MIDI i/o C++ classes
    Copyright (c) 2003-2012 Gary P. Scavone

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation files
    (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    Any person wishing to distribute modifications to the Software is
    asked to send the modifications to the original developer so that
    they can be incorporated into the canonical version.  This is,
    however, not a binding provision of this license.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
    ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
// RtMidi: Version 2.0.1

import std.string;
import std.conv;

/* Special return type. 
 * - success is true when a call went right,
 *           is false when an exception occured.
 * - errMsg can be used to throw a D exception. 
 * - value is the value to be returned from a call.
 */
struct answer (T) {
    int success;
    T value;
    const (char) * errMsg;
}

/* The C exposed RtMidi API. */
extern (C) {
    void * vchar_new ();
    void vchar_delete (void * ptr);
    size_t vchar_size (void * ptr) ;
    int vchar_empty (void * ptr);
    ubyte vchar_at (void * ptr, size_t index);
    ubyte vchar_front (void * ptr);
    ubyte vchar_back (void * ptr);
    void vchar_assign (void * ptr, size_t index, ubyte val);
    void vchar_push_back (void * ptr, ubyte val);
    void vchar_pop_back (void * ptr);
    void vchar_clear (void * ptr);

    void RtMidiIn_delete (void * ptr);
    void RtMidiOut_delete (void * ptr);


    answer!(void *) RtMidiIn_new (int api, immutable(char) * clientName, uint queueSizeLimit);
    answer!(bool) RtMidiIn_openPort (void * ptr, uint portNumber, immutable(char) * portName);
    answer!(bool) RtMidiIn_openVirtualPort (void * ptr, immutable(char) * portName);
    answer!(bool) RtMidiIn_closePort (void * ptr);
    //void RtMidiIn_setCallback (void * ptr, RtMidiCallback cb, void * userData);
    void RtMidiIn_cancelCallback (void * ptr);
    uint RtMidiIn_getPortCount (void * ptr);
    answer!(const(char)*) RtMidiIn_getPortName (void * ptr, uint portNumber);
    void RtMidiIn_ignoreTypes (void * ptr, int sysex, int time, int sense);
    answer!(double) RtMidiIn_getMessage (void * ptr, void * msgs);


    answer!(void *) RtMidiOut_new (int api, immutable(char) * clientName);
    answer!(bool) RtMidiOut_openPort (void * ptr, uint portNumber, immutable(char) * portName);
    answer!(bool) RtMidiOut_openVirtualPort (void * ptr, immutable(char) * portName);
    answer!(bool) RtMidiOut_closePort (void * ptr);
    uint RtMidiOut_getPortCount (void * ptr);
    answer!(const(char)*) RtMidiOut_getPortName (void * ptr, uint portNumber);
    answer!(bool) RtMidiOut_sendMessage (void * ptr, void * msgs);
}

/* We do not deal with callback for now. */
//alias extern (C) void function (double timeStamp, void * message, void * userData) RtMidiCallback;

/* RtMIidi::Api enumeration. */
enum  {
    UNSPECIFIED,    /* Search for a working compiled API. */
    MACOSX_CORE,    /* Macintosh OS-X Core Midi API. */
    LINUX_ALSA,     /* The Advanced Linux Sound Architecture API. */
    UNIX_JACK,      /* The Jack Low-Latency MIDI Server API. */
    WINDOWS_MM,     /* The Microsoft Multimedia MIDI API. */
    WINDOWS_KS,     /* The Microsoft Kernel Streaming MIDI API. */
    RTMIDI_DUMMY    /* A compilable but non-functional API. */
};

/* D wrapper around std::vector<unsigned char>.
 */
class vbytes {
    bool owns; /* True if we own the pointer, false otherwise. */
    void * ptr;
    
    public:

    this () {
        ptr = vchar_new ();
        owns = true;
    }

    this (void * vtr) {
        ptr = vtr; 
        owns = false; // We won't delete it in our destructor.
    }

    /* Construct from an array of unsigned bytes. */
    this (ubyte [] vals) {
        ptr = vchar_new (); 

        foreach (val; vals) {
            this.push_back (val);  
        }
    }

    ~this () {
        if (owns) vchar_delete (ptr);
    }

    size_t size () { 
        return vchar_size (ptr); 
    }
    bool empty () { 
        return 1 == vchar_empty (ptr); 
    }

    ubyte opIndex (size_t index) { 
        return ptr.vchar_at (index); 
    }
    ubyte opIndexAssign (size_t index, ubyte val) {
        ptr.vchar_assign (index, val);
        return val;
    }

    ubyte front () {
        return ptr.vchar_front ();
    }
    ubyte back () {
        return ptr.vchar_back ();
    }

    vbytes opBinary (string op : "~") (ubyte val) {
        ptr.vchar_push_back (val);
        return this;
    }
    
    void push_back (ubyte val) {
        ptr.vchar_push_back (val);
    }

    void clear () {
        ptr.vchar_clear ();
    }

    ubyte [] opCast () {
        ubyte [] ar = new ubyte [this.size];

        for (size_t i = 0; i < this.size; ++ i) {
            ar ~= this [i]; 
        }
        return ar;
    }
}

/* Exceptions throw by RtMidi. */
class RtError : Exception {
    this (string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super (msg, file, line, next); 
    }
}

class RtMidiIn {
    protected void * ptr; // Pointer to the C++ class, package visibility.
    
    public:

    this (int api = UNSPECIFIED, string clientName = "RtMidi Input Client", uint queueSizeLimit = 100) {
        answer!(void *) ans = RtMidiIn_new (api, clientName.toStringz, queueSizeLimit);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);

        this.ptr = ans.value;
    }

    ~this () {
        RtMidiIn_delete (ptr);
    }

    void openPort (uint portNumber = 0, string portName = "RtMidi Input") {
        answer!bool ans = ptr.RtMidiIn_openPort (portNumber, portName.toStringz);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }
    
    void openVirtualPort (string portName = "RtMidi Output") {
        answer!bool ans = ptr.RtMidiIn_openVirtualPort (portName.toStringz);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }

    void closePort () {
        answer!bool ans = ptr.RtMidiIn_closePort (); 
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }

    //void setCallback (RtMidiCallback callback, void * userData = null) {
    //    ptr.RtMidiIn_setCallback (callback, userData);
    //}

    uint getPortCount () {
        return ptr.RtMidiIn_getPortCount ();
    }

    string getPortName (uint portNumber) {
        answer!(const(char)*) ans = ptr.RtMidiIn_getPortName (portNumber);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);

        return ans.value.to!string;
    }

    void ignoreTypes (bool sysex, bool time, bool sense) {
        ptr.RtMidiIn_ignoreTypes (cast (int) sysex, cast (int) time, cast (int) sense); 
    }

    double getMessage (ref ubyte [] msgs) {
        vbytes vtr = new vbytes (msgs); 
        scope (exit) delete vtr; 
        answer!double ans = ptr.RtMidiIn_getMessage (vtr.ptr); 

        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);

        for (size_t i = 0; i < vtr.size; ++i) {
            msgs ~= vtr [i];
        }

        return ans.value;
    }
}

class RtMidiOut {
    protected void * ptr; // Pointer to the C++ class, package visibility.
    
    public:
    
    this (int api = UNSPECIFIED, string clientName = "RtMidi Output Client") {
        answer!(void *) ans = RtMidiOut_new (api, clientName.toStringz);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);

        this.ptr = ans.value;
    }
    
    ~this () {
        RtMidiIn_delete (ptr);
    }
    
    void openPort (uint portNumber = 0, string portName = "RtMidi Output") {
        answer!bool ans = ptr.RtMidiOut_openPort (portNumber, portName.toStringz);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }
    
    void openVirtualPort (string portName = "RtMidi Output") {
        answer!bool ans = ptr.RtMidiOut_openVirtualPort (portName.toStringz);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }
    
    void closePort () {
        answer!bool ans = ptr.RtMidiOut_closePort (); 
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }
    
    uint getPortCount () {
        return ptr.RtMidiOut_getPortCount ();
    }
    
    string getPortName (uint portNumber) {
        answer!(const(char)*) ans = ptr.RtMidiOut_getPortName (portNumber);
        
        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);

        return ans.value.to!string;
    }

    void sendMessage (ubyte [] msgs) {
        vbytes vtr = new vbytes (msgs); 
        scope (exit) delete vtr; 
        answer!bool ans = ptr.RtMidiOut_sendMessage (vtr.ptr); 

        if (! ans.success)
            throw new RtError (ans.errMsg.to!string);
    }
}



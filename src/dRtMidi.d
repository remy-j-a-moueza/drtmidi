// Written in the D programming language: http://dlang.org

/**********************************************************************/
/*  A D port of the RtMidi API. 
    
    Written by Rémy Mouëza (https://github.com/remy-j-a-moueza)

    RtMidi WWW site: http://music.mcgill.ca/~gary/rtmidi/

    RtMidi: realtime MIDI i/o C++ classes
    Copyright (c) 2003-2016 Gary P. Scavone

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

import drtmidi_c; 


/* We do not deal with callback for now. */
//alias extern (C) void function (double timeStamp, void * message, void * userData) RtMidiCallback;

/* RtMIidi::Api enumeration. */
enum  {
    UNSPECIFIED  = 0,    /* Search for a working compiled API. */
    MACOSX_CORE  = 1,    /* Macintosh OS-X Core Midi API. */
    LINUX_ALSA   = 2,     /* The Advanced Linux Sound Architecture API. */
    UNIX_JACK    = 3,      /* The Jack Low-Latency MIDI Server API. */
    WINDOWS_MM   = 4,     /* The Microsoft Multimedia MIDI API. */
    WINDOWS_KS   = 5,     /* The Microsoft Kernel Streaming MIDI API. */
    RTMIDI_DUMMY = 6   /* A compilable but non-functional API. */
};

/* D wrapper around std::vector<unsigned char>.
 */

/* Exceptions throw by RtMidi. */
class RtError : Exception {
    this (string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super (msg, file, line, next); 
    }
}

class RtMidiIn {
    protected RtMidiInPtr ptr; // Pointer to the C++ class, package visibility.
    
    public:

    this (int api = UNSPECIFIED, 
          string clientName = "RtMidi Input Client", 
          uint queueSizeLimit = 100) 
    {
        
        this.ptr = rtmidi_in_create (api, clientName.toStringz, queueSizeLimit);
        
        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }

    ~this () {
        rtmidi_in_free (ptr);
    }

    void openPort (uint portNumber = 0, string portName = "RtMidi Input") {
        ptr.rtmidi_open_port (portNumber, portName.toStringz);
        
        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }
    
    void openVirtualPort (string portName = "RtMidi Output") {
        ptr.rtmidi_open_virtual_port (portName.toStringz);

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }

    void closePort () {
        ptr.rtmidi_close_port ();

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }

    //void setCallback (RtMidiCallback callback, void * userData = null) {
    //    ptr.RtMidiIn_setCallback (callback, userData);
    //}

    uint getPortCount () {
        uint count = ptr.rtmidi_get_port_count ();
        
        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }

        return count;
    }

    string getPortName (uint portNumber) {
        string name = ptr.rtmidi_get_port_name (portNumber).to!string;

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }

        return name;
    }

    void ignoreTypes (bool sysex, bool time, bool sense) {
        ptr.rtmidi_in_ignore_types (
                cast (int) sysex, 
                cast (int) time, 
                cast (int) sense); 
    }

    double getMessage (ref ubyte [] msgs) {
        import core.stdc.stdlib : free; 
        ubyte * table;
        size_t size;
        double dt = ptr.rtmidi_in_get_message (&table, &size); 


        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }

        if (size == 0) {
            return dt;
        }

        for (size_t i = 0; i < size; ++i) {
            // beware
            msgs ~= table [i];
        }
        free (table);

        return dt;
    }
}

class RtMidiOut {
    protected RtMidiOutPtr ptr; // Pointer to the C++ class, package visibility.
    
    public:
    
    this (int api = UNSPECIFIED, string clientName = "RtMidi Output Client") {
        this.ptr = rtmidi_out_create (api, clientName.toStringz);
        
        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }
    
    ~this () {
        rtmidi_out_free (ptr);
    }
    
    void openPort (uint portNumber = 0, string portName = "RtMidi Output") {
        ptr.rtmidi_open_port (portNumber, portName.toStringz);
        
        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }
    
    void openVirtualPort (string portName = "RtMidi Output") {
        ptr.rtmidi_open_virtual_port (portName.toStringz);

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }
    
    void closePort () {
        ptr.rtmidi_close_port ();

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }
    
    uint getPortCount () {
        uint count = ptr.rtmidi_get_port_count ();

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }

        return count;
    }
    
    string getPortName (uint portNumber) {
        string name = ptr.rtmidi_get_port_name (portNumber).to!string;

        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }

        return name;
    }

    void sendMessage (ubyte [] msgs) {
        int ok = ptr.rtmidi_out_send_message (msgs.ptr, cast (int) msgs.length);
        
        if (! this.ptr.ok) {
            this.ptr.ok = true;
            throw new RtError (this.ptr.msg.to!string);
        }
    }
}



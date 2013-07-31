/**********************************************************************/
/*  A C export of the RtMidi API. 
    
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

#include "RtMidi.h"


/* Special return type. 
 * - success is true when a call went right,
 *           is false when an exception occured.
 * - errMsg can be used to throw a D exception. 
 * - value is the value to be returned from a call.
 */
template <typename T>
struct answer {
    int success;
    T value;
    const char * errMsg; 
};


/* Predefined types of return for RtMidi. */
typedef answer<RtMidiIn *> answerRtMidiIn_p; 
typedef answer<RtMidiOut *> answerRtMidiOut_p; 
typedef answer<bool> answerBool; 
typedef answer<const char *> answerConstChar_p;
typedef answer<double> answerDouble;

typedef std::vector<unsigned char> vchar; 

extern "C" {

/* Export a simplistic view of std::vector<unsigne char> */
void * vchar_new () {
    vchar * v = new vchar;
    return (void *) v;
}

void vchar_delete (void * ptr) {
    vchar * vtr = (vchar *) ptr;
    delete vtr; 
}

size_t vchar_size (void * ptr)  {
    vchar * vtr = (vchar *) ptr;
    return vtr->size ();
}

int vchar_empty (void * ptr) {
    vchar * vtr = (vchar *) ptr;
    return (int) vtr->empty ();
}

unsigned char vchar_at (void * ptr, size_t index) {
    vchar * vtr = (vchar *) ptr;
    return vtr->at (index);
}

unsigned char vchar_front (void * ptr) {
    vchar * vtr = (vchar *) ptr;
    return vtr->front ();
}

unsigned char vchar_back (void * ptr) {
    vchar * vtr = (vchar *) ptr;
    return vtr->back ();
}

void vchar_assign (void * ptr, size_t index, unsigned char val) {
    vchar * vtr = (vchar *) ptr;
    vtr->assign (index, val); 
}

void vchar_push_back (void * ptr, unsigned char val) {
    vchar * vtr = (vchar *) ptr;
    vtr->push_back (val);
}

void vchar_pop_back (void * ptr) {
    vchar * vtr = (vchar *) ptr;
    vtr->pop_back ();
}

void vchar_clear (void * ptr) {
    vchar * vtr = (vchar *) ptr;
    vtr->clear ();
}

/* RtMidi API. */
void RtMidiIn_delete (void * ptr) {
    RtMidiIn * midiIn = (RtMidiIn *) ptr; 
    
    delete midiIn ; 
}

void RtMidiOut_delete (void * ptr) {
    RtMidiOut * midiOut = (RtMidiOut *) ptr; 
    
    if (midiOut) delete midiOut ; 
}


answerRtMidiIn_p RtMidiIn_new (int api, char * clientName, unsigned int queueSizeLimit) {
    RtMidiIn * ptr;

    try {
        const std::string name     = std::string (clientName);
        ptr                  = new RtMidiIn((RtMidi::Api) api, name, queueSizeLimit);
        answerRtMidiIn_p ans = {true, ptr, ""};
        return ans; 

    } catch (RtError & error) {
        answerRtMidiIn_p ans = {false, 0, error.getMessage ().c_str ()};
        return ans;
    }
}


answerBool RtMidiIn_openPort (void * ptr, unsigned int portNumber, char * portName) {
    RtMidiIn * midi = (RtMidiIn *) ptr;

    try {
        const std::string name = std::string (portName);
        midi->openPort (portNumber, name); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}

answerBool RtMidiIn_openVirtualPort (void * ptr, char * portName) {
    RtMidiIn * midi = (RtMidiIn *) ptr;

    try {
        const std::string name = std::string (portName);
        midi->openVirtualPort (name); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}


answerBool RtMidiIn_closePort (void * ptr) {
    RtMidiIn * midi = (RtMidiIn *) ptr;

    try {
        midi->closePort (); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}

void RtMidiIn_setCallback (void * ptr, RtMidiIn::RtMidiCallback cb, void * userData) {
    RtMidiIn * midi = (RtMidiIn *) ptr;
    midi->setCallback (cb, userData);
}

void RtMidiIn_cancelCallback (void * ptr) {
    RtMidiIn * midi = (RtMidiIn *) ptr;
    midi->cancelCallback ();
}

unsigned int RtMidiIn_getPortCount (void * ptr) {
    RtMidiIn * midi = (RtMidiIn *) ptr;
    return midi->getPortCount (); 
}


answerConstChar_p RtMidiIn_getPortName (void * ptr, unsigned int portNumber) {
    RtMidiIn * midi = (RtMidiIn *) ptr;

    try {
        const std::string name = midi->getPortName (portNumber); 
        answerConstChar_p ans = {true, name.c_str (), ""};
        return ans;
    } catch (RtError & error) {
        answerConstChar_p ans = {false, 0, error.getMessage ().c_str ()};
        return ans;
    }
}

void RtMidiIn_ignoreTypes (void * ptr, int sysex, int time, int sense) {
    RtMidiIn * midi = (RtMidiIn *) ptr;
    midi->ignoreTypes ((bool) sysex, (bool) time, (bool) sense);
}

answerDouble RtMidiIn_getMessage (void * ptr, void * msgs) {
    RtMidiIn * midi = (RtMidiIn *) ptr;
    vchar * vtr = (vchar *) msgs; 

    try {
        double val = midi->getMessage (vtr);
        answerDouble ans = {true, val, ""};
        return ans;

    } catch (RtError & error) {
        answerDouble ans = {false, 0.0, error.getMessage ().c_str ()};
        return ans;
    }
}


answerRtMidiOut_p RtMidiOut_new (int api, char * clientName) {
    RtMidiOut * ptr;

    try {
        std::string name     = std::string (clientName);
        ptr                  = new RtMidiOut((RtMidi::Api) api, name);
        answerRtMidiOut_p ans = {true, ptr, ""};
        return ans; 

    } catch (RtError & error) {
        answerRtMidiOut_p ans = {false, 0, error.getMessage ().c_str ()};
        return ans;
    }
}


answerBool RtMidiOut_openPort (void * ptr, unsigned int portNumber, char * portName) {
    RtMidiOut * midi = (RtMidiOut *) ptr;

    try {
        const std::string name = std::string (portName);
        midi->openPort (portNumber, name); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}

answerBool RtMidiOut_openVirtualPort (void * ptr, char * portName) {
    RtMidiOut * midi = (RtMidiOut *) ptr;

    try {
        const std::string name = std::string (portName);
        midi->openVirtualPort (name); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}


answerBool RtMidiOut_closePort (void * ptr) {
    RtMidiOut * midi = (RtMidiOut *) ptr;

    try {
        midi->closePort (); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}

unsigned int RtMidiOut_getPortCount (void * ptr) {
    RtMidiOut * midi = (RtMidiOut *) ptr;
    return midi->getPortCount (); 
}


answerConstChar_p RtMidiOut_getPortName (void * ptr, unsigned int portNumber) {
    RtMidiOut * midi = (RtMidiOut *) ptr;

    try {
        const std::string name = midi->getPortName (portNumber); 
        answerConstChar_p ans = {true, name.c_str (), ""};
        return ans;
    } catch (RtError & error) {
        answerConstChar_p ans = {false, 0, error.getMessage ().c_str ()};
        return ans;
    }
}

answerBool RtMidiOut_sendMessage (void * ptr, void * msgs) {
    RtMidiOut * midi = (RtMidiOut *) ptr;
    vchar * vtr = (vchar *) msgs;
    
    try {
        midi->sendMessage (vtr); 
        answerBool ans = {true, true, ""};
        return ans;
    } catch (RtError & error) {
        answerBool ans = {false, false, error.getMessage ().c_str ()};
        return ans;
    }
}


} // extern "C"

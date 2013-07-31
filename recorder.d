import std.stdio; 
import std.string;
import std.math;
import std.conv;
import core.thread;
import dRtMidi;

/* iostream like interface: 
       cout << blah.blah () << endl; 
*/
private {
    struct Cout {
        Cout opBinary (string op : "<<", T) (T val) {
            write (val); 
            return this;
        }
    }
    Cout cout;
    immutable string endl = "\n";
}

/* Shows the midi ports available. */
void showPorts () {
    // Note: this may raise an exception - we'll get a stack trace on the command line.
    auto midiIn  = new RtMidiIn; 
    auto midiOut = new RtMidiOut;
    
    uint nPorts = midiIn.getPortCount;
    cout << endl << nPorts << " midi input sources available" << endl;
    
    foreach (np; 0..nPorts) {
        cout << "Input port #" << np << " " << midiIn.getPortName (np) << endl;
    }

    nPorts = midiOut.getPortCount;
    cout << endl << nPorts << " midi output sources available" << endl;

    foreach (np; 0..nPorts) {
        cout << "Output port #" << np << " " << midiOut.getPortName (np) << endl;
    }
}

/* Repeats a string `cnt` time: 
    "\n".repeat (10) 
 */
string repeat (string pat, int cnt) {
    string s = ""; 
    foreach (time; 0..cnt) {
        s ~= pat;
    }
    return s;
}


void main () {
    /* Show the available ports. */
    showPorts (); 
    auto midiIn  = new RtMidiIn; 
    auto midiOut = new RtMidiOut;

    /* Here we select the input and output ports #1, 
       one should change the value to one's own environment settings. */
    midiIn .openPort (1); 
    midiOut.openPort (1); 

    cout << "Using midi port #1 \"%s\"".format (midiIn.getPortName (1)) << endl;

    /* Ignore SystemExclusive, Time and ActiveSense messages. */
    midiIn.ignoreTypes (true, true, true);

    /* Represents a note played at a given time. */
    struct Note {
        double dt;    // Timestamp. time, in seconds,  ellapsed since the last played note.
        ubyte [] msg; // midi message.
    }
    Note [] notes; 

    class Listener : Thread {
        bool halt = false; // Will stop the main loop if set to true.

        this () { super (&run); }

        /* The main loop that listen to the midi input. */
        void run () {
            long count = 0; 
            
            while (! halt) {
                // Get the midi message.
                ubyte [] msgs; 
                double dt = midiIn.getMessage (msgs); // May throw an RtError exception. 
                
                while (msgs.length) {
                    /* "Batch" processing. */
                    if (msgs != [250] && msgs != [252]) // Ignore SystemRealtime 'Continue' | 'Stop'.
                        notes ~=  Note (dt, msgs);

                    cout << (count ++) << ": Δt: %f, msgs: %s\n".format (dt, msgs);

                    // Clear the array, otherwise new message will be added to its end.
                    msgs.length = 0;
                    dt = midiIn.getMessage (msgs);
                }

                /* Wait a bit */
                Thread.getThis.sleep (dur!"msecs" (1));
            }
        }

        void stop () {
            halt = true;
        }
    }

    /* Start the midi input listener. */
    auto listener = new Listener ();
    listener.start ();

    /* Wait for the user to press the enter key
       then stop the listener. */
    readln ();
    listener.stop ();
    cout << "\nDone\n" << endl;

    /* Repeat what's been recorded each time one press "Enter" alone. 
       If other keys are pressed before "Enter", it will stop the program. */
    for (;;) {
        foreach (count, note; notes) {
            /* Get the timestamp and try to round it appropriately in nanoseconds for optimal precision. */
            auto dt = ((note.dt * 10.pow (6)).rint * 10.pow (3)).to!long;
            cout << count << ": Δt: %.6f".format (note.dt) << " -> %12d".format (dt) << " nsecs " << note.msg << endl ;
            
            /* First sleep the amount given by dt, then play the note. 
               Otherwise, it won't sound well in time. */
            Thread.getThis.sleep (dur!"nsecs" (dt));
            midiOut.sendMessage (note.msg);
        }

        cout << endl.repeat (2);
        
        /* Stop if the user has type something (space bar) before pressing "Enter". */
        if (readln ().length > 1) break; 
    }
}


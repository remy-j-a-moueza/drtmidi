extern (C):

alias void* RtMidiPtr;
alias void* RtMidiInPtr;
alias void* RtMidiOutPtr;
alias void function (double, const(ubyte)*, void*) RtMidiCCallback;

enum RtMidiApi
{
    RT_MIDI_API_UNSPECIFIED = 0,   /*!< Search for a working compiled API. */
    RT_MIDI_API_MACOSX_CORE = 1,   /*!< Macintosh OS-X Core Midi API. */
    RT_MIDI_API_LINUX_ALSA = 2,    /*!< The Advanced Linux Sound Architecture API. */
    RT_MIDI_API_UNIX_JACK = 3,     /*!< The Jack Low-Latency MIDI Server API. */
    RT_MIDI_API_WINDOWS_MM = 4,    /*!< The Microsoft Multimedia MIDI API. */
    RT_MIDI_API_WINDOWS_KS = 5,    /*!< The Microsoft Kernel Streaming MIDI API. */
    RT_MIDI_API_RTMIDI_DUMMY = 6   /*!< A compilable but non-functional API. */
}

enum RtMidiErrorType
{
    RT_ERROR_WARNING = 0,
    RT_ERROR_DEBUG_WARNING = 1,
    RT_ERROR_UNSPECIFIED = 2,
    RT_ERROR_NO_DEVICES_FOUND = 3,
    RT_ERROR_INVALID_DEVICE = 4,
    RT_ERROR_MEMORY_ERROR = 5,
    RT_ERROR_INVALID_PARAMETER = 6,
    RT_ERROR_INVALID_USE = 7,
    RT_ERROR_DRIVER_ERROR = 8,
    RT_ERROR_SYSTEM_ERROR = 9,
    RT_ERROR_THREAD_ERROR = 10
}

int rtmidi_sizeof_rtmidi_api ();

/* RtMidi API */
int rtmidi_get_compiled_api (RtMidiApi** apis);
void rtmidi_error (RtMidiErrorType type, const(char)* errorString);
void rtmidi_open_port (RtMidiPtr device, uint portNumber, const(char)* portName);
void rtmidi_open_virtual_port (RtMidiPtr device, const(char)* portName);
void rtmidi_close_port (RtMidiPtr device);
uint rtmidi_get_port_count (RtMidiPtr device);
const(char)* rtmidi_get_port_name (RtMidiPtr device, uint portNumber);

/* RtMidiIn API */
RtMidiInPtr rtmidi_in_create_default ();
RtMidiInPtr rtmidi_in_create (RtMidiApi api, const(char)* clientName, uint queueSizeLimit);
void rtmidi_in_free (RtMidiInPtr device);
RtMidiApi rtmidi_in_get_current_api (RtMidiPtr device);
void rtmidi_in_set_callback (RtMidiInPtr device, RtMidiCCallback callback, void* userData);
void rtmidi_in_cancel_callback (RtMidiInPtr device);
void rtmidi_in_ignore_types (RtMidiInPtr device, bool midiSysex, bool midiTime, bool midiSense);
double rtmidi_in_get_message (RtMidiInPtr device, ubyte** message);

/* RtMidiOut API */
RtMidiOutPtr rtmidi_out_create_default ();
RtMidiOutPtr rtmidi_out_create (RtMidiApi api, const(char)* clientName);
void rtmidi_out_free (RtMidiOutPtr device);
RtMidiApi rtmidi_out_get_current_api (RtMidiPtr device);
int rtmidi_out_send_message (RtMidiOutPtr device, const(ubyte)* message, int length);

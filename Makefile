

recorder: recorder.d dRtMidi.d RtMidi.o cRtMidi.o 
	dmd -g recorder.d dRtMidi.d RtMidi.o cRtMidi.o -L-lstdc++ -L-lasound -L-lpthread 

RtMidi.o: RtMidi.cpp
	g++ -c -Wall -D__LINUX_ALSA__ RtMidi.cpp 

cRtMidi.o: cRtMidi.cpp
	g++ -c -D__LINUX_ALSA__ cRtMidi.cpp


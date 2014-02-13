PROGS=typemorse brainwash

all: $(PROGS)

typemorse: typemorse.o morse.o
	gcc -o typemorse typemorse.o morse.o -lm


brainwash: brainwash.o morse.o
	gcc -o brainwash brainwash.o morse.o -lm


clean:
	rm -f *.o $(PROGS)


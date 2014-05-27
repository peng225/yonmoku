#Makefile

CFLAGS = -unittest -gc -m64 -w -wi -O -c
FINAL_CFLAGS = -unittest -gc -m64 -w -wi -O
# CFLAGS = -unittest -main -g -m64 -w -wi -O -c
# FINAL_CFLAGS = -unittest -main -g -m64 -w -wi -O
BINARY = yonmoku
OBJS = field.o ai.o ui.o place.o exception.o
COMPILE = dmd $(CFLAGS)

all: $(BINARY)

$(BINARY): main.d $(OBJS)
	dmd  $(FINAL_CFLAGS) main.d $(OBJS) -of$(BINARY)

field.o: field.d
	$(COMPILE) $<

ai.o: ai.d
	$(COMPILE) $<

ui.o: ui.d
	$(COMPILE) $<

place.o: place.d
	$(COMPILE) $<

exception.o: exception.d
	$(COMPILE) $<

test: $(OBJS)
	dmd  $(FINAL_CFLAGS) test.d $(OBJS) -of$(BINARY)_test

clean:
	rm -rf $(BINARY) *.o *~
PREFIX ?= /usr/local
CC ?= gcc
PKG_CONFIG ?= pkg-config
AR ?= ar
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -Iinclude -I$(PREFIX)/include
LDFLAGS ?= -L$(PREFIX)/lib -Wl,-rpath,$(PREFIX)/lib

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  ifneq ($(wildcard /opt/homebrew/opt/ffmpeg-full/lib/pkgconfig),)
    export PKG_CONFIG_PATH := /opt/homebrew/opt/ffmpeg-full/lib/pkgconfig:/opt/homebrew/opt/srt/lib/pkgconfig:$(PKG_CONFIG_PATH)
    CFLAGS += -I/opt/homebrew/opt/ffmpeg-full/include
    LDFLAGS += -L/opt/homebrew/opt/ffmpeg-full/lib -Wl,-rpath,/opt/homebrew/opt/ffmpeg-full/lib
    LDFLAGS += -L/opt/homebrew/opt/srt/lib -Wl,-rpath,/opt/homebrew/opt/srt/lib
  endif
endif

FFMPEG_CFLAGS := $(shell PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" $(PKG_CONFIG) --cflags libavformat libavcodec libavutil libswscale 2>/dev/null)
FFMPEG_LIBS := $(shell PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" $(PKG_CONFIG) --libs libavformat libavcodec libavutil libswscale 2>/dev/null)
ifeq ($(FFMPEG_LIBS),)
  FFMPEG_LIBS := -lavformat -lavcodec -lavutil -lswscale
endif
EXTRA := $(FFMPEG_LIBS) -lpthread -lm

SRTS := $(shell $(PKG_CONFIG) --libs srt 2>/dev/null)
ifeq ($(SRTS),)
  SRTS := -lsrt
endif
EXTRA += $(SRTS)

.PHONY: all clean install
all: libmedia_core.a libghost_ffmpeg_rx.a libghost_srt.a

libmedia_core.a: src/core/media_core.c include/media_core.h
	$(CC) $(CFLAGS) -c -o media_core.o src/core/media_core.c && $(AR) rcs $@ media_core.o && rm -f media_core.o

libghost_ffmpeg_rx.a: src/modules/ffmpeg_rx/ffmpeg_rx.c include/ffmpeg_rx.h
	$(CC) $(CFLAGS) $(FFMPEG_CFLAGS) -c -o ffmpeg_rx.o src/modules/ffmpeg_rx/ffmpeg_rx.c && $(AR) rcs $@ ffmpeg_rx.o && rm -f ffmpeg_rx.o

libghost_srt.a: src/modules/srt/ghost_srt.c include/ghost_srt.h libghost_ffmpeg_rx.a libmedia_core.a
	$(CC) $(CFLAGS) -c -o ghost_srt.o src/modules/srt/ghost_srt.c && $(AR) rcs $@ ghost_srt.o && rm -f ghost_srt.o

install: all
	install -d $(DESTDIR)$(PREFIX)/include $(DESTDIR)$(PREFIX)/lib
	install -m 644 include/*.h $(DESTDIR)$(PREFIX)/include/
	install -m 644 libmedia_core.a libghost_ffmpeg_rx.a libghost_srt.a $(DESTDIR)$(PREFIX)/lib/

clean:
	rm -f *.a *.o

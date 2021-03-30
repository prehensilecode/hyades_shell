LIBDIR = /l/lib/idl/hyades
HTTPDIR = /l/web_home

all: install dist

install:
	/usr/um/gnu/bin/cp -f *.pro ${LIBDIR}


dist:
	/usr/um/gnu/bin/cp -f *.pro ${HTTPDIR}

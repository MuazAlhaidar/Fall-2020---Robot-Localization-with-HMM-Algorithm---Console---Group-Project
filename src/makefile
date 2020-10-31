SRC=$(wildcard *.cpp)
OBJ = ${SRC:.cpp=.o}

BIN = ./Run
# LIBDIRS = -lSDL2  -lSDL2_image -llua
# INCDIRS = 
CC = g++
DEBUG = -g


all: ${BIN}

run: ${BIN}
	./${BIN}


${BIN}: ${OBJ}
	${CC} -o $@ ${OBJ} ${INCDIRS} ${LIBDIRS} ${LIBS}


%.o : %.cpp
	g++ -c -g $*.cpp -o $*.o  


clean:
	rm -rf ${BIN} ${OBJ}

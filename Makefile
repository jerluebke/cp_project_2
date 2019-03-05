CC 		= g++
FC 		= gfortran
PPFLAGS = -E -P -cpp
# CFLAGS 	= -Wall -Wextra -g
CFLAGS 	= -Wall -Wextra -O3 -fPIC
XFLAGS  = -xc++ -std=c++17 -Iinclude/
NOWARN 	= -Wno-unused-function # -Wno-unused-dummy-argument
PPCMD 	= $(CC) -Iinclude/ $(PPFLAGS)

SRCDIR 	:= src/
TESTDIR := test/
OBJDIR 	:= obj/
BINDIR 	:= bin/

FSRC 	:= $(shell find $(SRCDIR) $(TESTDIR) -name "*.f90")
FSRC_PP := $(OBJDIR)boris_pp.f90 $(OBJDIR)ftest_pp.f90
FOBJ 	:= $(OBJDIR)boris.o $(OBJDIR)ftest.o
FTESTBIN:= $(BINDIR)ftest

CSRC 	:= $(shell find $(SRCDIR) -name "*.cpp")
COBJ 	:= $(patsubst $(SRCDIR)%.cpp, $(OBJDIR)%.o, $(CSRC))
CTESTSRC:= $(TESTDIR)ctest.cpp
CTESTOBJ:= $(OBJDIR)ctest.o
CTESTBIN:= $(BINDIR)ctest

ALLOBJ := $(FOBJ) $(COBJ) $(CTESTOBJ)
ALLBIN := $(FTESTBIN) $(CTESTBIN)


debug:
	echo $(CSRC)
	echo $(COBJ)


ctest: obj/boris.o $(CTESTOBJ) $(COBJ)
	$(FC) $^ -lstdc++ -o $(CTESTBIN)

$(OBJDIR)%.o: $(SRCDIR)%.cpp
	$(CC) $(CFLAGS) $(XFLAGS) -c $< -o $@

$(CTESTOBJ): $(CTESTSRC)
	$(CC) $(CFLAGS) $(XFLAGS) -c $< -o $@


ftest: $(FOBJ)
	$(FC) $^ -o $(FTESTBIN)

obj/boris.o: obj/boris_pp.f90
	$(FC) $(CFLAGS) $(NOWARN) -c $^ -o $@

obj/ftest.o: obj/ftest_pp.f90
	$(FC) $(CFLAGS) -c $^ -o $@

obj/boris_pp.f90: src/boris.f90
	$(PPCMD) $^ -o $@

obj/ftest_pp.f90: test/ftest.f90
	$(PPCMD) $^ -o $@

# $(FOBJ): $(FSRC_PP)
#     $(FC) $(CLFAGS) -c $< -o $@

# $(FSRC_PP): $(FSRC)
#     $(PPCMD) $< -o $@

clean:
	rm -f $(ALLOBJ) $(ALLBIN) $(FSRC_PP)

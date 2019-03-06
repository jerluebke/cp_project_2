CC 		= g++
FC 		= gfortran
PPFLAGS = -E -P -cpp
# CFLAGS 	= -Wall -Wextra -g
CFLAGS 	= -Wall -Wextra -O3 -fPIC
XFLAGS  = -xc++ -std=c++17 -Iinclude/
NOWARN 	= -Wno-unused-function # -Wno-unused-dummy-argument
PPCMD 	= $(CC) -Iinclude/ $(PPFLAGS)
PYCMD	= python3 python/setup.py build_ext

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

PYDIR 	:= python/
PYBUILD := $(PYDIR)build/
CYSRC	:= $(PYDIR)propagator.cpp
PYSO	:= $(PYDIR)propagator.cpython*.so

ALLOBJ := $(FOBJ) $(COBJ) $(CTESTOBJ)
ALLBIN := $(FTESTBIN) $(CTESTBIN)


.PHONY: python ctest ftest clean


python: $(OBJDIR)boris.o $(COBJ)
	$(PYCMD) --build-lib=$(PYDIR) --build-temp=$(PYBUILD)
	rm -rf $(PYBUILD)
	rm -f $(CYSRC)


ctest: $(OBJDIR)boris.o $(CTESTOBJ) $(COBJ)
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
	rm -f $(ALLOBJ) $(ALLBIN) $(PYSO) $(FSRC_PP) boris_module.mod

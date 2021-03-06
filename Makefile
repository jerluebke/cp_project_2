CC 		= g++
FC 		= gfortran
PPFLAGS = -E -P -cpp
# CFLAGS 	= -Wall -Wextra -0g -ggdb3 -fPIC
CFLAGS 	= -Wall -Wextra -O3 -fPIC -DNDEBUG
XFLAGS  = -xc++ -std=c++17 -Iinclude/
NOWARN 	= -Wno-unused-function -Wno-unused-dummy-argument
PPCMD 	= $(CC) $(PPFLAGS)
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

obj/boris_pp.f90: src/boris.f90 obj/config_pp.hpp
	$(PPCMD) -Iobj $< -o $@

obj/ftest_pp.f90: test/ftest.f90 obj/config_pp.hpp
	$(PPCMD) -Iobj $< -o $@

obj/config_pp.hpp: include/config.hpp
	$(PPCMD) -dD $^ -o $@


clean:
	rm -f $(ALLOBJ) $(ALLBIN) $(PYSO) $(FSRC_PP) \
		obj/config_pp.hpp boris_module.mod

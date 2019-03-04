CC = gcc
FC = gfortran
PPFLAGS = -E -P -cpp
CFLAGS = -Wall -Wextra

SRCNAME := ctof_test
CSRC := $(SRCNAME).c
FSRC := $(SRCNAME).f90
FSRC_PP := $(SRCNAME)_pp.f90
COBJ := $(SRCNAME)_c.o
FOBJ := $(SRCNAME)_f.o
EXE := ctof.exe

ctof: $(COBJ) $(FOBJ)
	$(FC) $^ -o $(EXE)

$(COBJ): $(CSRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(FOBJ): $(FSRC_PP)
	$(FC) $(CFLAGS) -c $< -o $@

$(FSRC_PP): $(FSRC)
	$(FC) $(PPFLAGS) $^ -o $@

clean:
	rm -f $(COBJ) $(FOBJ) $(FSRC_PP) ctof.mod

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
from distutils.core import setup, Extension
from Cython.Build import cythonize
from Cython.Distutils import build_ext
import numpy

this_dir = os.path.dirname(os.path.realpath(__file__))
obj_dir = os.path.join(this_dir, "../obj")

ext = Extension(
    "propagator",
    sources = [os.path.join(this_dir, "./propagator.pyx")],
    include_dirs = [os.path.join(this_dir, "../include"),
                    numpy.get_include()],
    language = "c++",
    extra_compile_args = ["-std=c++17", "-O3", "-fPIC"],
    extra_link_args = ["-lgfortran"],
    extra_objects = [os.path.join(obj_dir, f)
                     for f in os.listdir(obj_dir) if f.endswith(".o")]
)

setup(
    name = "propagator",
    cmdclass = {"build_ext" : build_ext},
    ext_modules = cythonize(ext)
)

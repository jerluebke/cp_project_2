# -*- coding: utf-8 -*-

import os
from distutils.core import setup, Extension
from Cython.Build import cythonize
from Cython.Distutils import build_ext
import numpy

ext = Extension(
    "propagator",
    sources = ["./propagator.pyx"],
    include_dirs = ["../include", numpy.get_include()],
    language = "c++",
    extra_compile_args = ["-std=c++17", "-O3", "-fPIC"],
    extra_link_args = ["-lgfortran"],
    extra_objects = [os.path.join("../obj", f) for f in os.listdir("../obj")
                     if f.endswith(".o")]
)

setup(
    name = "propagator",
    cmdclass = {"build_ext" : build_ext},
    ext_modules = cythonize(ext)
)

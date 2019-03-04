# -*- coding: utf-8 -*-

from distutils.core import setup, Extension
from Cython.Build import cythonize
import numpy

ext = Extension(
    "propagator",
    sources = ["./propagator.pyx", "../src/propagator.cpp"],
    include_dirs = ["../include", numpy.get_include()],
    language = "c++",
    extra_compile_args = ["-std=c++17"]
)

setup(ext_modules = cythonize(ext))

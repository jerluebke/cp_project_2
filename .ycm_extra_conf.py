# -*- coding: utf-8 -*-

import os

FLAGS = [
    '-Wall',
    '-Wextra',
    #  '-Werror',
    #  '-DNDEBUG',
    '-std=c++17',
    '-xc++',
    '-I', os.path.join(os.path.dirname(os.path.realpath(__file__)), 'include'),
    '-isystem', 'C:\\MinGW64\\mingw64\\include',
    '-isystem', 'D:\\source\\Libs\\include'
]


def Settings(**kwds):
    return {'flags' : FLAGS}


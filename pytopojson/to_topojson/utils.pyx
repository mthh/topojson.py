# -*- coding: utf-8 -*-
#cython: boundscheck = False
#cython: wraparound = False

E = 1e-6
# Actually I don't know if there is any gain in cythonizing these functions
# ... but let's try it as they are called pretty often.
cpdef inline bint is_point(x):
    return isinstance(x, list) and len(x)==2

cpdef inline bint is_infinit(n):
    return abs(n) == float('inf')

def point_compare(a, b):
    if is_point(a) and is_point(b):
        return a[0] - b[0] or a[1] - b[1]

class Strut(list):
    def __init__(self, ite=[]):
        self.index=0
        list.__init__(self, ite)

def mysterious_line_test(a, b):
    for arg in (a, b):
        if not isinstance(arg, list):
            return True
    return a == b

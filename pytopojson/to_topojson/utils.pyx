# -*- coding: utf-8 -*-
#cython: boundscheck = False
#cython: wraparound = False
#cython: cdivision = True
E = 1e-6
# Actually I don't know if there is any gain in cythonizing these functions
# ... but let's try it as they are called pretty often.
cpdef inline bint is_point(x):
    return isinstance(x, list) and len(x)==2

cpdef inline bint is_infinit(n):
    return abs(n) == float('inf')

cpdef list make_ks(long quantization,
                   double x0, double x1,
                   double y0, double y1):
    cdef double x, y
    x, y = 1, 1
    if quantization:
        if x1 - x0:
            x = (quantization - 1.0) / (x1 - x0)
        if y1 - y0:
            y = (quantization - 1.0) / (y1 - y0)
    return [x, y]

cpdef point_compare(a, b):
    if is_point(a) and is_point(b):
        return a[0] - b[0] or a[1] - b[1]

cpdef bint mysterious_line_test(a, b):
    for arg in (a, b):
        if not isinstance(arg, list):
            return True
    return a == b

cdef class Strut(list):
    cdef public object ite
    cdef public int index
    def __init__(self, ite=[]):
        self.index=0
        list.__init__(self, ite)

# -*- coding: utf-8 -*-
#cython: boundscheck = True
#cython: wraparound = True
#cython: cdivision = True
from libc.math cimport ceil, log

ctypedef int[2] Kp

cdef inline bint equal(Kp keyA, Kp keyB):
    return keyA[0] == keyB[0] and keyA[1] == keyB[1]

cdef class Hashtable:
    cdef int size, mask
    cdef list table
    cdef object h

    def __init__(self, double in_size):
        self.size = 1 << int(ceil(log(in_size)/log(2)))
        self.table = [False]*self.size
        self.mask = self.size - 1
        self.h = self.retfunc

    cpdef int retfunc(self, list point):
        cdef int key
#        if isinstance(point, list) and len(point) == 2:
        key = (int(point[0]) + 31 * int(point[1])) | 0
        return (~key if key < 0 else key) & self.mask

    cpdef peak(self, list key):
        cdef Kp k = <Kp> key
        matches = self.table[self.h(key)]
        if matches:
            for match in matches:
                if equal(<Kp>match['key'], k):
                    return match['values']
        return None

    cpdef get(self, list key):
        cdef Kp k = <Kp> key
        index = self.h(key)
        if not index:
            return []
        matches = self.table[index]
        if matches:
            for match in matches:
                if equal(<Kp>match['key'], k):
                    return match['values']
        else:
            matches = self.table[index] = []
        values = []
        matches.append({'key': key, 'values': values})
        return values
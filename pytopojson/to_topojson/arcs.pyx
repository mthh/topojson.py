# -*- coding: utf-8 -*-
#cython: boundscheck = True
#cython: wraparound = True
#cython: cdivision = True

from hashlib import sha1

from .hashtable import Hashtable
from .utils import point_compare

cdef class Arcs:
    cdef object coincidences, arcsByPoint, pointsByPoint
    cdef dict db
    cdef public dict arcs
    cdef public unsigned int length

    def __init__(self, double Q):
        self.coincidences = Hashtable(Q * 10)
        self.arcsByPoint = Hashtable(Q * 10)
        self.pointsByPoint = Hashtable(Q * 10)
        #self.arc_db_path=mkdtemp()+'/arc_db'
        #self.arcs= shelve.open(self.arc_db_path)
        self.arcs={}
        self.length=0
        #self.storage_path = mkdtemp()+'/db'
        #self.db = shelve.open(self.storage_path)
        self.db={}

    cpdef get_index(self, point):
        return self.pointsByPoint.get(point)
    cpdef get_point_arcs(self, point):
        return self.arcsByPoint.get(point)
    cpdef coincidence_lines(self, point):
        return self.coincidences.get(point)
    cpdef peak(self, point):
        return self.coincidences.peak(point)
    cpdef int push(self, arc):
        self.arcs[str(self.length)]=arc
        self.length+=1
        return self.length
    cpdef list map(self, func):
        cdef unsigned int num
        cdef list out = []
        #self.db.close()
        #remove(self.storage_path)
        for num in range(0, self.length):
            out.append(func(self.arcs[str(num)]))
        #self.arcs.close()
        #remove(self.arc_db_path)
        return out

    cpdef get_hash(self, arc):
        ourhash = sha1()
        ourhash.update(str(arc).encode('utf8'))
        return ourhash.hexdigest()

    cpdef long check(self, object arcs):
        cdef list point, point_arcs, a0, a1
        cdef long index

        a0 = arcs[0]
        a1 = arcs[-1]
        point = a0 if point_compare(a0, a1) < 0 else a1
        point_arcs = self.get_point_arcs(point)
        h = self.get_hash(arcs)
        if h in self.db:
            return int(self.db[h])
        else:
            index = self.length
            point_arcs.append(arcs)
            self.db[h]=index
            self.db[self.get_hash(list(reversed(arcs)))]=~index
            self.push(arcs)
            return index


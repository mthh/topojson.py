# -*- coding: utf-8 -*-
#cython: boundscheck = True
#cython: wraparound = True
#cython: cdivision = True
from .arcs import Arcs
from .utils import point_compare, is_point, Strut, mysterious_line_test

#ctypedef double[2] Point_d

cdef class Line:
    cdef public object arcs
    cdef public object line_arcs

    def __init__(self, Q):
        self.arcs = Arcs(Q)

    cdef void *arc(self, object current_arc, bint last=False):
        cdef Py_ssize_t n = len(current_arc)
        cdef list point, index

        if last and not len(self.line_arcs) and n == 1:
            point = current_arc[0]
            index = self.arcs.get_index(point)
            if len(index):
                self.line_arcs.append(index[0])
            else:
                index.append(self.arcs.length)
                self.line_arcs.append(index[0])
                self.arcs.push(current_arc)
        elif n > 1:
            self.line_arcs.append(self.arcs.check(current_arc))

    cpdef line(self, list points, bint opened):
        cdef Py_ssize_t n = len(points)
        cdef object current_arc = Strut()
        cdef int k = 0, i = 0
        cdef list p=[], t=[]

        self.line_arcs = []
       
        if not opened:
            points.pop()
            n -= 1
        while k < n:
            t = self.arcs.peak(points[k])
            if opened:
                break
            if p and not mysterious_line_test(p, t):
                tInP = all([line in p for line in t])
                pInT = all([line in t for line in p])
                if tInP and not pInT:
                    k-=1
                break
            p = t
            k+=1
        # If no shared starting point is found for closed lines, rotate to minimum.

        if k == n and isinstance(p, list) and len(p) > 1:
            point0 = points[0]
            i = 2
            k=0
            while i<n:
                point = points[i];
                if point_compare(point0, point) > 0:
                    point0 = point
                    k = i
                i+=1
        i = -1
        if opened:
            m = n-1
        else:
            m = n
        while i < m:
            i+=1
            point = points[(i + k) % n]
            p = self.arcs.peak(point)
            if not mysterious_line_test(p, t):
                tInP = all([line in p for line in t])
                pInT = all([line in t for line in p])
                if tInP:
                    current_arc.append(point)
                self.arc(current_arc)
                if not tInP and not pInT and len(current_arc):
                    self.arc(Strut([current_arc[-1], point]))
                if pInT and len(current_arc):
                    current_arc = Strut([current_arc[-1]])
                else:
                    current_arc = Strut();
            if not len(current_arc) or point_compare(current_arc[-1], point):
                current_arc.append(point) # skip duplicate points
            t = p
        self.arc(current_arc, True)
        return self.line_arcs

    cpdef line_closed(self, list points):
        return self.line(points, False)

    cpdef line_open(self, list points):
        return self.line(points, True)

    cpdef list map_func(self, object arc):
        cdef unsigned int i = 1
        cdef Py_ssize_t n
        cdef double x1, y1, x2=0, y2=0
        cdef long dx=0, dy=0
        cdef list points, point

        if len(arc)==2 and isinstance(arc[0], int):
            arc = [arc]

        i = 1
        n = len(arc)

        point = arc[0]
        x1, y1 = point
        points = [[int(x1), int(y1)]]
        while i < n:
            point = arc[i]
            if not is_point(point):
                i+=1
                continue
            x2, y2 = point
            dx = int(x2 - x1)
            dy = int(y2 - y1)
            if dx or dy:
                points.append([dx, dy])
                x1, y1 = x2, y2
            i+=1
        return points

    cpdef get_arcs(self):
        return self.arcs.map(self.map_func)

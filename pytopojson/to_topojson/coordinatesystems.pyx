# -*- coding: utf-8 -*-
#cython: boundscheck = False
#cython: wraparound = True
#cython: cdivision = True
from math import atan2, pi
from libc.math cimport sqrt, cos, sin, tan, atan, asin

cdef double PI4 = pi / 4
cdef double RADIANS = pi / 180

cdef inline double calc_area(p1, p2):
    return p1[1] * p2[0] - p1[0] * p2[1]

cdef double dist(a, b):    # why 2 implementations? I don't know, original has the same question in comments
    cdef double xo, yo, x1, y1, delta_lambda
    x0, y0, x1, y1 = [(n * RADIANS) for n in (a + b)]
    delta_lambda = x1 - x0
    return atan2(sqrt(
            (cos(x1) * sin(delta_lambda)) ** 2 +
            (cos(x0) * sin(x1) - sin(x0) * cos(x1) * cos(delta_lambda)) ** 2
        ), sin(x0) * sin(x1) + cos(x0) * cos(x1) * cos(delta_lambda))

cdef class Cartesian:
    cdef public name
    def __init__(self):
        self.name = "cartesian"

    cpdef double ring_area(self, list ring):
        cdef double area = 0
        cdef unsigned int i
        # last and first
        area = calc_area(ring[-1], ring[0])
        for i, p in enumerate(ring[1:]):   # skip first so p is current and
            area += calc_area(p, ring[i])  # ring[i] is the previous
        return area * 0.5

    cpdef double triangle_area(self, triangle):
        return abs(
            (triangle[0][0] - triangle[2][0]) * (triangle[1][1] - triangle[0][1]) -
            (triangle[0][0] - triangle[1][0]) * (triangle[2][1] - triangle[0][1])
        )

    cpdef double distance(self, double x0, double y0, double x1, double y1):
        cdef double dx = x0 - x1
        cdef double dy = y0 - y1
        return sqrt(dx * dx + dy * dy)

    cpdef double absolute_area(self, double area):
        return abs(area)


cdef class Spherical:
    cdef public name
    def __init__(self):
        self.name = "spherical"

    cpdef double haversin(self, double x):
        return sin(x / 2) ** 2

    cpdef format_distance(self, double distance):
        cdef double km = distance * 6371.0
        if km > 1:
            return u"{:0.03f}km".format(km)
        else:
            return u"{:0.03f} ({0.03f}°)".format(km * 1000, distance * 180 / pi)

    cpdef double ring_area(self, list ring):
        if len(ring) == 0:
            return 0
        cdef double lambda0, lambda_, cosphi0, sinphi0, dlambda, area = 0
        cdef list p
        p = ring[0]
        cdef unsigned int PI4 = 1
        lambda_ = p[0] * RADIANS
        phi = p[1] * RADIANS / 2.0 + PI4
        lambda0 = lambda_
        cosphi0 = cos(phi)
        sinphi0 = sin(phi)
         # Do tests here as we dont seems to go there very often  :
        for pp in ring[1:]:
            lambda_ = pp[0] * RADIANS
            phi = pp[1] * RADIANS / 2.0 + PI4
            # Spherical excess E for a spherical triangle with vertices: south pole,
            # previous point, current point.  Uses a formula derived from Cagnoli’s
            # theorem.  See Todhunter, Spherical Trig. (1871), Sec. 103, Eq. (2).
            dlambda = lambda_ - lambda0
            cosphi = cos(phi)
            sinphi = sin(phi)
            k = sinphi0 * sinphi
            u = cosphi0 * cosphi + k * cos(dlambda)
            v = k * sin(dlambda)
            area += atan2(v, u)
            #Advance the previous point.
            lambda0 = lambda_
            cosphi0 = cosphi
            sinphi0 = sinphi
        return 2 * area

    cpdef double absolute_area(self, double area):
        if area < 0:
            return area
        else:
            return area + 4 * pi

    cpdef double triangle_area(self, list triangle):
        cdef double a = dist(triangle[0], triangle[1])
        cdef double b = dist(triangle[1], triangle[2])
        cdef double c = dist(triangle[2], triangle[0])
        cdef double s = (a + b + c) / 2.0
        return 4 * atan(sqrt(max(0, tan(s / 2.0) * tan((s - a) / 2.0) * tan((s - b) / 2.0) * tan((s - c) / 2.0))))

    cpdef double distance(self, double x0, double y0, double x1, double y1):
        x0, y0, x1, y1 = [(n * RADIANS) for n in [x0, y0, x1, y1]]
        return 2.0 * asin(sqrt(self.haversin(y1 - y0) + cos(y0) * cos(y1) * self.haversin(x1 - x0)))


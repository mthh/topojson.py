from .mytypes import Types

cpdef stitch (objects, options=False):
    verbose = False;
    if type(options)==type({}) and 'verbose' in options:
        verbose = options['verbose']
    Stitch(objects)

class Stitch(Types):
    def polygon(self, list polygon):
        stitch_poly(polygon)

    def point(self, p):
        return p

cdef void *stitch_poly(list polygon):
    cdef bint a, b, c, antimeridian, polar
    cdef Py_ssize_t n
    cdef list line, point
    cdef int i, i0

    for line in polygon:
        n = len(line)
        a, b, c = False, False, False
    
        i0 = -1
        i = 0
        while i<n:
            point=line[i]
            antimeridian = abs(abs(point[0]) - 180) < 1e-2
            polar = abs(abs(point[1]) - 90) < 1e-2
            if antimeridian or polar:
                if not (a or b or c):
                    i0 = i
                if antimeridian:
                    if a:
                        c = True
                    else:
                        a = True
                if polar:
                    b = True
            if not antimeridian and not polar or i == n - 1:
                if a and b and c:
                    del line[i0:i]
                    n -= i - i0
                    i = i0
                a = b = c = False
            i+=1

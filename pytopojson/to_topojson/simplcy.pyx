# -*- coding: utf-8 -*-
#cython: boundscheck = False
#cython: wraparound = False
#cython: cdivision = True

ctypedef struct Point:
    double x
    double y


cdef double getSquareDistance(Point p1, Point p2):
    """
    Square distance between two points
    """
    cdef double dx, dy, res
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    res = dx * dx + dy * dy
    return res


cdef double getSquareSegmentDistance(Point p, Point p1, Point p2):
    """
    Square distance between point and a segment
    """
    cdef double x, y, dx, dy, res
    x = p1.x
    y = p1.y

    dx = p2.x - x
    dy = p2.y - y

    if dx != 0 or dy != 0:
        t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy)

        if t > 1:
            x = p2.x
            y = p2.y
        elif t > 0:
            x += dx * t
            y += dy * t

    dx = p.x - x
    dy = p.y - y
    res = dx * dx + dy * dy
    return res

cdef simplifyRadialDistance(list points, double tolerance):
    cdef unsigned int length, i=0
    cdef list new_points = []
    cdef Point prev_point, point

    length = len(points)
    prev_point = points[0]
    new_points.append((prev_point.x, prev_point.y))

    for i in range(length):
        point = points[i]

        if getSquareDistance(point, prev_point) > tolerance:
            new_points.append((point.x, point.y))
            prev_point = point

    if prev_point.x != point.x and prev_point.y != point.y:
        new_points.append([point.x, point.y])

    return new_points


cdef simplifyDouglasPeucker(list points, double tolerance):
    cdef unsigned int length, first, i=0, index=0
    cdef int last
    cdef list first_stack, last_stack, new_points, markers
    cdef double sqdist, max_sqdist
    cdef Point pt

    length = len(points)
    #markers = <unsigned int*>malloc(length * sizeof(unsigned int))
    markers = [0] * length  # Maybe not the most efficent way?

    first = 0
    last = length - 1

    first_stack = []
    last_stack = []
    new_points = []

    markers[first] = 1
    markers[last] = 1

    while last != -1:
        max_sqdist = 0

        for i in range(first, last):
            sqdist = getSquareSegmentDistance(points[i], points[first], points[last])

            if sqdist > max_sqdist:
                index = i
                max_sqdist = sqdist

        if max_sqdist > tolerance:
            markers[index] = 1

            first_stack.append(first)
            last_stack.append(index)

            first_stack.append(index)
            last_stack.append(last)

        # Can pop an empty array in Javascript, but not Python, so check
        # the length of the list first
        if len(first_stack) == 0:
            first = -1
        else:
            first = first_stack.pop()

        if len(last_stack) == 0:
            last = -1
        else:
            last = last_stack.pop()

    for i in range(length):
        if markers[i]:
            pt = points[i]
            new_points.append([pt.x, pt.y])

    return new_points


cpdef list simplify(list points, double tolerance=0.1, highestQuality=True):
    cdef double sqtolerance = tolerance * tolerance
    cdef list new_points = []
    cdef unsigned int i=0
    for i in range(len(points)):
        points[i] = {'x': points[i][0], 'y': points[i][1]}
    if not highestQuality:
        new_points = simplifyRadialDistance(points, sqtolerance)
    else:
        new_points = simplifyDouglasPeucker(points, sqtolerance)

    return new_points

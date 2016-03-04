# -*- coding: utf-8 -*-
#from https://github.com/omarestrella/simplify.py
from .mytypes import Types
from .simplcy import simplify

def simplify_object(obj, tolerance):
    class Simplify(Types):
        def line(self, points):
            return simplify(points, tolerance)
        def polygon(self, coordinates):
            return [self.line(coord) for coord in coordinates]
        def GeometryCollection(self, collection):
            if 'geometries' in collection:
                collection['geometries'] = [self.geometry(geoms) for geoms in collection['geometries']]
        def LineString(self,lineString):
            lineString['coordinates'] = self.line(lineString['coordinates'])
        def MultiLineString(self,multiLineString):
            multiLineString['coordinates'] = [self.line(li) for li in multiLineString['coordinates']]
        def MultiPolygon(self,multiPolygon):
            multiPolygon['coordinates'] = [self.polygon(p) for p in multiPolygon['coordinates']]
        def Polygon(self,polygon):
            polygon['coordinates'] = self.polygon(polygon['coordinates'])
    Simplify(obj)
    return obj
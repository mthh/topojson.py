# -*- coding: utf-8 -*-
ctypedef public struct Point:
    double x
    double y

ctypedef public struct Trans_param:
    double x
    double y

ctypedef public struct Scale_param:
    double x
    double y

cdef class Transformer:
    cdef Scale_param scale
    cdef Trans_param translate
    cdef list arcs
    def __init__(self, dict transform, arcs):
        self.scale.x, self.scale.y = transform['scale']
        self.translate.x, self.translate.y = transform['translate']
        self.arcs = [self.convert_arc(a) for a in arcs]

    cdef list convert_arc(self, list arc):
        cdef list out_arc = [], previous=[0,0]
        for point in arc:
            previous[0]+=point[0]
            previous[1]+=point[1]
            out_arc.append(self.convert_point(previous))
        return out_arc

    cdef list reversed_arc(self, arc):
        return list(reversed(self.arcs[~arc]))

    cdef list stitch_arcs(self, list arcs):
        cdef list line_string = []
        for arc in arcs:
            if arc < 0:
                line = self.reversed_arc(arc)
            else:
                line = self.arcs[arc]
            if len(line_string)>0:
                if line_string[-1] == line[0]:
                    line_string.extend(line[1:])
                else:
                    line_string.extend(line)
            else:
                line_string.extend(line)
        return line_string

    cdef list stich_multi_arcs(self,arcs):
        return [self.stitch_arcs(a) for a in arcs]

    cdef list conv_point(self, Point point):
        return [point.x*self.scale.x+self.translate.x,point.y*self.scale.y+self.translate.y]

    cpdef convert_point(self, point):
        return self.conv_point({'x': point[0], 'y': point[1]})

    cdef feature(self, dict feature):
        cdef dict out={'type':'Feature'}
        out['geometry']={'type':feature['type']}
        if feature['type'] in ('Point','MultiPoint'):
            out['geometry']['coordinates'] = feature['coordinates']
        elif feature['type'] in ('LineString','MultiLineString','MultiPolygon','Polygon'):
            out['geometry']['arcs'] = feature['arcs']
        elif feature['type'] == 'GeometryCollection':
            out['geometry']['geometries'] = feature['geometries']
        for key in ('properties','bbox','id'):
            if key in feature:
                out[key] = feature[key]
        out['geometry']=self.geometry(out['geometry'])
        return out

    def geometry(self,geometry):
        if geometry['type']=='Point':
            return self.point(geometry)
        elif geometry['type']=='MultiPoint':
            return self.multi_point(geometry)
        elif geometry['type']=='LineString':
            return self.line_string(geometry)
        elif geometry['type']=='MultiLineString':
            return self.multi_line_string_poly(geometry)
        elif geometry['type']=='Polygon':
            return self.multi_line_string_poly(geometry)
        elif geometry['type']=='MultiPolygon':
            return self.multi_poly(geometry)
        elif geometry['type']=='GeometryCollection':
            return self.geometry_collection(geometry)

    def point(self, geometry):
        geometry['coordinates'] = self.convert_point(geometry['coordinates'])
        return geometry
    def multi_point(self, geometry):
        geometry['coordinates']= [self.convert_point(geom) for geom in geometry['coordinates']]
        return  geometry
    def line_string(self,geometry):
        geometry['coordinates']=self.stitch_arcs(geometry['arcs'])
        del geometry['arcs']
        return geometry
    def multi_line_string_poly(self,geometry):
        geometry['coordinates']=self.stich_multi_arcs(geometry['arcs'])
        del geometry['arcs']
        return geometry
    def multi_poly(self,geometry):
        geometry['coordinates'] = [self.stich_multi_arcs(a) for a in geometry['arcs']]
        del geometry['arcs']
        return geometry
    def geometry_collection(self, geometry):
        out = {'type': 'FeatureCollection'}
        out['features'] = [self.feature(geom) for geom in geometry['geometries']]
        return out
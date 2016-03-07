# coding=utf8
from .mytypes import Types
from .stitchpoles import stitch
from .coordinatesystems import Cartesian, Spherical
from .bounds import bound
from .line import Line
from .simplify import simplify_object
from .utils import is_infinit, E, make_ks

def property_transform (outprop, key, inprop):
        outprop[key]=inprop
        return True

def topology (objects, stitchPoles=True, quantization=1e4, id_key='id',
              property_transform = property_transform, system = False, simplify=False):
    ln = Line(quantization)
#    id_func = lambda x: x.get(id_key, None)
    if simplify:
        objects = simplify_object(objects,simplify)
    x0, x1, y0, y1 = bound(objects)
    
    oversize = x0 < -180 - E or x1 > 180 + E or y0 < -90 - E or y1 > 90 + E

    if isinstance(system, str) and system.lower() == 'cartesian':
        system = Cartesian()
    elif isinstance(system, str) and system.lower() == 'spherical':
        if oversize:
            raise Exception(u"spherical coordinates outside of [±180°, ±90°]")
        system = Spherical()
    elif system:
        print("System argument doesn't match {'cartesian', 'spherical'}\n"
              "A default value will be used")
    if not system:
        if oversize:
            system = Cartesian()
        else:
            system = Spherical()

    if system.name == 'spherical':
        if stitchPoles:
            stitch(objects)
            [x0,x1,y0,y1] = bound(objects)
        if x0 < -180 + E:
            x0 = -180
        if x1 > 180 - E:
            x1 = 180
        if y0 < -90 + E:
            y0 = -90
        if y1 > 90 - E:
            y1 = 90

    if is_infinit(x0):
        x0 = 0
    if is_infinit(x1):
        x1 = 0

    if is_infinit(y0):
        y0 = 0
    if is_infinit(y1):
        y1 = 0

    kx, ky = make_ks(quantization, x0, x1, y0, y1)

    if not quantization:
        quantization = x1 + 1
        x0 = y0 = 0
        
    finde = findEmax(objects, system, (kx, ky, x0, y0))
    emax = finde.emax  # Currently this emax isn't used ?

    # Clock(objects,system.ring_area)

#    class find_coincidences(Types):
#        def line(self,line):
#            for point in line:
#                lines = ln.arcs.coincidence_lines(point)
#                if not line in lines:
#                    lines.append(line)
#    
    find_coincidences(objects, ln)
#    fcInst = find_coincidences(objects)  # Currently this statement doesn't seems to be use ?
#    polygon = lambda poly: [ln.line_closed(p) for p in poly]  # Have been put in the make_topo class

    #Convert features to geometries, and stitch together arcs.
    make_topo_inst = make_topo(objects, ln, id_key)

    return {
        'type': "Topology",
        'bbox': [x0, y0, x1, y1],
        'transform': {
            'scale': [1.0 / kx, 1.0 / ky],
            'translate': [x0, y0]
        },
        'objects': make_topo_inst.outObj,
        'arcs': ln.get_arcs()
    }

class find_coincidences(Types):
    def __init__(self, obj, ln):
        self.ln = ln
        self.obj(obj)
    def line(self, line):
        for point in line:
            lines = self.ln.arcs.coincidence_lines(point)
            if not line in lines:
                lines.append(line)


class findEmax(Types):
    def __init__(self, obj, system, args):
        self.emax=0
        self.system = system
        self.kx, self.ky, self.x0, self.y0 = args
        self.obj(obj)
    def point(self,point):
        x1 = point[0]
        y1 = point[1]
        x = ((x1 - self.x0) * self.kx)
        y =((y1 - self.y0) * self.ky)
        ee = self.system.distance(x1, y1, x / self.kx + self.x0, y / self.ky + self.y0)
        if ee > self.emax:
            self.emax = ee
        point[0], point[1] = int(x), int(y)

class make_topo(Types):
    def __init__(self, obj, ln, id_key):
        self.ln = ln
        self.id_key = id_key
        self.obj(obj)
    def polyg(self, poly):
        return [self.ln.line_closed(p) for p in poly]
    def Feature (self,feature):
        geometry = feature["geometry"]
        if feature['geometry'] == None:
            geometry = {}
        if 'id' in feature:
            geometry['id'] = feature['id']
        if 'properties' in feature:
            geometry['properties'] = feature['properties']
        return self.geometry(geometry)
    def FeatureCollection(self,collection):
        collection['type'] = "GeometryCollection"
        collection['geometries'] = list(map(self.Feature,collection['features']))
        del collection['features']
        return collection
    def GeometryCollection(self,collection):
        collection['geometries'] = list(map(self.geometry,collection['geometries']))
    def MultiPolygon(self,multiPolygon):
        multiPolygon['arcs'] = [self.polyg(p) for p in multiPolygon['coordinates']]
    def Polygon(self, polygon):
         polygon['arcs'] = [self.ln.line_closed(p) for p in polygon['coordinates']]
    def MultiLineString(self, multiLineString):
        multiLineString['arcs'] = list(map(self.ln.line_open,multiLineString['coordinates']))
    def LineString(self,lineString):
        lineString['arcs'] = self.ln.line_open(lineString['coordinates'])
    def geometry(self, geometry):
        if geometry == None:
            geometry = {}
        else:
            Types.geometry(self,geometry)
        geometry['id'] = geometry.get(self.id_key, None)
        if geometry['id'] == None:
            del geometry['id']
        properties0 = geometry['properties']
        if properties0:
            properties1 = {}
            del geometry['properties']
            for key0 in properties0:
                if property_transform(properties1, key0, properties0[key0]):
                    geometry['properties'] = properties1
        if 'arcs' in geometry:
            del geometry['coordinates']
        return geometry

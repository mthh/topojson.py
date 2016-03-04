class Clock:
    def __init__(self, area):
        self.area=area

    def clock(self, feature):
        if 'geometries' in feature:
            feature['geometries'] = \
                [self.clock_geometry(f) for f in feature['geometries']]
        elif 'geometry' in feature:
            feature['geometry']=self.clock_geometry(feature['geometry'])
        return feature

    def clock_geometry(self,geo):
        if 'type' in geo:
            if geo['type']=='Polygon' or geo['type']=='MultiLineString':
                geo['coordinates'] = self.clockwise_polygon(geo['coordinates'])
            elif geo['type']=='MultiPolygon':
                geo['coordinates'] = \
                    [self.clockwise_polygon(x) for x in geo['coordinates']]
            elif geo['type']=='LineString':
                geo['coordinates'] = self.clockwise_ring(geo['coordinates'])
        return geo

    def clockwise_polygon(self, rings):
        return [self.clockwise_ring(x) for x in rings]

    def clockwise_ring(self, ring):
        if self.area(ring) > 0:
            return list(reversed(ring))
        else:
            return ring

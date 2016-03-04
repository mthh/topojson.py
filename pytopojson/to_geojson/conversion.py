from ujson import load, loads, dump
from io import TextIOWrapper
from .transform import Transformer

def convert(topojson, input_name=None, geojson=None):
    if isinstance(topojson, dict):
        parsed_geojson = topojson

    elif isinstance(topojson, TextIOWrapper):
        parsed_geojson = load(topojson)

    elif isinstance(topojson, str):
        try:
            with open(topojson) as in_file:
                parsed_geojson = load(in_file)
        except:
            parsed_geojson=loads(topojson)

    if input_name is None:
        input_name = list(parsed_geojson['objects'].keys())[0]

    out = from_topo(parsed_geojson, input_name)

    if isinstance(geojson, str):
        with open(geojson, 'w') as f:
            dump(out, f)

    elif isinstance(geojson, TextIOWrapper):
        dump(out, geojson)
    else:
        return out

def from_topo(topo, obj_name):
    TYPEGEOMETRIES = (
        'LineString',
        'MultiLineString',
        'MultiPoint',
        'MultiPolygon',
        'Point',
        'Polygon',
        'GeometryCollection'
    )

    if obj_name in topo['objects']:
        geojson = topo['objects'][obj_name]
    else:
        raise Exception(u"Something ain't right")
    transformer = Transformer(topo['transform'],topo['arcs'])
    if geojson['type'] in TYPEGEOMETRIES:
        geojson = transformer.geometry(geojson)
    return geojson

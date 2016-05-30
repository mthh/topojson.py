from ujson import load, loads, dump
from io import TextIOWrapper
from .transform import Transformer, Transformer_no_transform

def convert(topojson, input_name=None, geojson=None):
    if isinstance(topojson, dict):
        parsed_json = topojson

    elif isinstance(topojson, TextIOWrapper):
        parsed_json = load(topojson)

    elif isinstance(topojson, str):
        try:
            with open(topojson, "r") as in_file:
                parsed_json = loads(in_file.read())
        except:
            parsed_json = loads(topojson)

    if input_name is None:
        input_name = list(parsed_json['objects'].keys())[0]

    out = from_topo(parsed_json, input_name)

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
    if not "transform" in topo:
        transformer = Transformer_no_transform(topo['arcs'])
    else:
        transformer = Transformer(topo['transform'], topo['arcs'])
    if geojson['type'] in TYPEGEOMETRIES:
        geojson = transformer.geom_dispatch(geojson)
    return geojson

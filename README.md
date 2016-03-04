Just some quick tests around the [topojson.py](https://github.com/calvinmetcalf/topojson.py) python port :
- Some errors encountered in python 3.4 are removed (but isn't probably python 2.x compatible anymore for the moment)
- Some modifications in the naming/structure for my personal convenience
- After looking at profiling results, some little "critical" parts written in cython (and also a little bottleneck avoided in the hashtable creation)
(mainly untested but it seems to be able to allow speed-up in the range of x3-5 on a 10Mb GeoJSON)

Original Readme (except function names):

# TOPOJSON.PY

Port of [topojson](https://github.com/mbostock/topojson) more of a translation then a port at this point, licensed under same BSD license as original, current usage:

input can be a file-like object, a path to a file, or a dict, output can be a path or a file-like object, if omited a dict is returned

current tested options are `quantization` and `simplify`.

```python
from pytopojson import geo_to_topo
#give it a path in and out
result = geo_to_topo(inPath, quantization=1e6, simplify=0.0001)
```

can also go the other way.

```python
from pytopojson import topo_to_geo
result = topo_to_geo(topojson,input_name=None,out_geojson=None)
```
`topojson` may be a dict, a path, or a file like object, `input_name` is a string and if omited
the first object in `topojson.objects` is used, `geojson` may be a file like object or
a path if omitied the dict is returned

known issues:
- coding style only a mother could love
- holds everything in memory, this could be bad
- should be able to incrementally add features to a topojson object

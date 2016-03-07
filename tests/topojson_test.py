import ujson as json
import unittest
import pickle

from pytopojson import geo_to_topo, topo_to_geo

class TestTopojson(unittest.TestCase):
    ## Currently the results are tested againts resultuts obtained with the topojson.py version
    ## from the forked repository (results, as dict, were saved with pickle); but against the
    ## results produced by the original (node.js) topojson version (which may be more useful..)
    def setUp(self):
        with open("tests/data/square.geojson") as f:
            self.square_geojson = json.load(f)

        with open("tests/data/multipolygons_spherical.geojson") as f:
            self.multipolygons = json.load(f)

        with open("tests/data/result_multipoly_simpl0_00001.pickle_obj", 'rb') as f:
            self.multipolygons_result = pickle.load(f)

        with open("tests/data/multilines_cartesian.geojson") as f:
            self.multilines = json.load(f)

        with open("tests/data/result_multilines_simpl0_0001.pickle_obj", 'rb') as f:
            self.multilines_result = pickle.load(f)

        with open("tests/data/multipolygons_cartesian.geojson") as f:
            self.multipolygons_cartesian = json.load(f)
    
        with open("tests/data/result_multipoly_c_simpl0_000001.pickle_obj", 'rb') as f:
            self.multipolygons_c_result = pickle.load(f)
    
    def test_convert_geojson_to_topojson(self):
        tj = geo_to_topo(self.square_geojson)
        self.assertEqual(tj['type'], 'Topology')

    def test_convert_equal_multipoly_spherical(self):
        tj = geo_to_topo(self.multipolygons, simplify=0.00001)
        self.assertEqual(len(tj['arcs']),
                         len(self.multipolygons_result['arcs']))
        self.assertEqual(len(tj['objects']),
                         len(self.multipolygons_result['objects']))
        self.assertEqual(tj['transform'],
                         self.multipolygons_result['transform'])
        self.assertEqual(len(str(tj['arcs'])), len(str(self.multipolygons_result['arcs'])))

    def test_convert_equal_multiline_cartesian(self):
        tj = geo_to_topo(self.multilines, simplify=0.0001)
        name = list(tj['objects'].keys())[0]
        self.assertEqual(len(tj['arcs']),
                         len(self.multilines_result['arcs']))
        self.assertEqual(len(tj['objects']),
                         len(self.multilines_result['objects']))
        self.assertEqual(tj['transform'],
                         self.multilines_result['transform'])
        self.assertEqual(len(str(tj['arcs'])), len(str(self.multilines_result['arcs'])))
        self.assertEqual(len(str(tj['objects'][name])), len(str(self.multilines_result['objects']['multilines_cartesian'])))

    def test_convert_equal_multipolygons_cartesian(self):
        tj = geo_to_topo(self.multipolygons_cartesian, simplify=0.000001)
        name = list(tj['objects'].keys())[0]
        self.assertEqual(len(tj['arcs']),
                         len(self.multipolygons_c_result['arcs']))
        self.assertEqual(len(tj['objects']),
                         len(self.multipolygons_c_result['objects']))
        self.assertEqual(tj['transform'],
                         self.multipolygons_c_result['transform'])
        self.assertEqual(len(str(tj['objects'][name])), len(str(self.multipolygons_c_result['objects']['multipolygons_cartesian'])))


class TestGeojson(unittest.TestCase):
    def setUp(self):
        with open("tests/data/square.geojson") as f:
            self.square_geojson = json.load(f)
        with open("tests/data/square.topojson") as f:
            self.square_topojson = json.load(f)
        with open("tests/data/multipolygons_spherical.geojson") as f:
            self.ref = json.load(f)

    def test_convert_back(self):
        square_back = topo_to_geo(self.square_topojson)
        self.assertAlmostEqual(square_back['features'][0]['geometry']['coordinates'][0][0][0],
                               self.square_geojson['features'][0]['geometry']['coordinates'][0][0][0], 6)
        self.assertAlmostEqual(square_back['features'][0]['geometry']['coordinates'][0][1][1],
                           self.square_geojson['features'][0]['geometry']['coordinates'][0][1][1], 6)
        self.assertAlmostEqual(square_back['features'][0]['geometry']['coordinates'][0][2][0],
                           self.square_geojson['features'][0]['geometry']['coordinates'][0][2][0], 6)
        self.assertEqual(square_back['features'][0]['properties'],
                         self.square_geojson['features'][0]['properties'])

    def test_extensive(self):
        tj = geo_to_topo("tests/data/multipolygons_spherical.geojson",
                         quantization=1e6)
        geo_back = topo_to_geo(tj)
        for i in range(len(self.ref['features'])):
            self.assertEqual(len(geo_back['features'][i]['geometry']['coordinates']),
                             len(self.ref['features'][i]['geometry']['coordinates']))
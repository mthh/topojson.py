from distutils.core import setup
from setuptools import find_packages
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize

exts = [Extension("pytopojson/to_topojson/simplcy",
            ["pytopojson/to_topojson/simplcy.pyx"], ["pytopojson"]),
        Extension("pytopojson/to_topojson/coordinatesystems",
            ["pytopojson/to_topojson/coordinatesystems.pyx"], ["pytopojson"]),
        Extension("pytopojson/to_topojson/hashtable",
            ["pytopojson/to_topojson/hashtable.pyx"], ["pytopojson"]),
        Extension("pytopojson/to_topojson/utils",
            ["pytopojson/to_topojson/utils.pyx"], ["pytopojson"]),
        Extension("pytopojson.to_geojson.transform",
            ["pytopojson/to_geojson/transform.pyx"], ["pytopojson"])]

setup(
    name="pytopojson",
    version="0.1.0",
    license="BSD",
    install_requires = ['ujson', 'cython'],
    ext_modules=cythonize(exts),
    cmdclass = {'build_ext': build_ext},
    packages=find_packages(),
)

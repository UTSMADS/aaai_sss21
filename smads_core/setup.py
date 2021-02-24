#!/usr/bin/env python

from distutils.core import setup
from catkin_pkg.python_setup import generate_distutils_setup

d = generate_distutils_setup(
    packages=['smads_core.client', 'smads_core.interface'],
    package_dir={'': 'src'},
    )

setup(**d)

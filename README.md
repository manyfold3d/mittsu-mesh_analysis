# Mittsu: Mesh Analysis

Mesh analysis methods for [Mittsu](https://github.com/danini-the-panini/mittsu).

Adds three methods:

* `Mittsu::Object3D#manifold?`: Detects if a mesh is a single valid surface; i.e. it has no holes, and faces are consistently oriented.
* `Mittsu::Object3D#solid?`: Detects if the faces of a manifold mesh are correctly oriented, giving the mesh a sensible inside and outside.
* `Mittsu::Face3#flip!`: Flips the vertex order, and thus orientation of a particular face.

## Requirements

Ruby 3.1 or above, otherwise the same as for [Mittsu](https://github.com/danini-the-panini/mittsu) itself.

## Usage

Just install:

`bundle add mittsu-mesh_analysis`

Then require in your code:

`require 'mittsu/mesh_analysis'`

The methods above should then be available for use.

## About

This code was originally written for [Manyfold](https://manyfold.app), supported by funding from [NLNet](https://nlnet.nl) and [NGI Zero](https://ngi.eu/ngi-projects/ngi-zero/).

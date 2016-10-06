import untangle

def get_coords(filename):
	obj = untangle.parse(filename)
	n = obj.espa_metadata.global_metadata.bounding_coordinates.north.cdata
	w = obj.espa_metadata.global_metadata.bounding_coordinates.west.cdata
	s = obj.espa_metadata.global_metadata.bounding_coordinates.south.cdata
	e = obj.espa_metadata.global_metadata.bounding_coordinates.east.cdata

	
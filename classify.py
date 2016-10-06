import matlab.engine
import os
import re

cwd = os.getcwd() + '/'
d = cwd+'data/'
row_paths = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))]

for rp  in row_paths:
    print rp
    d=rp
    scenes = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))] 
    for scene in scenes:

        # get the metadata file
        for file in os.listdir(scene):
            if file.endswith(".xml"):
                meta_file = str(scene+'/'+file)
            if file.endswith(".tif"):
                tif_file = str(scene+'/'+file)

        obj = untangle.parse(meta_file)
        n = obj.espa_metadata.global_metadata.bounding_coordinates.north.cdata
        w = obj.espa_metadata.global_metadata.bounding_coordinates.west.cdata
        s = obj.espa_metadata.global_metadata.bounding_coordinates.south.cdata
        e = obj.espa_metadata.global_metadata.bounding_coordinates.east.cdata

        # write matlab commands out to a separate file to be run later
        for cat in cats:
            write_str = "%s %s %s %s %s %s %s\n" % (
                    tif_file,
                    mask_dir+cat+'.ref',
                    scene+'/'+cat+'.tif',
                    n,s,e,w)
            #print('Creating Matlab command:')
            #print(write_str)
            exec_file.write(write_str)
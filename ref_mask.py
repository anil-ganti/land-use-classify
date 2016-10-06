import os
import shutil
import glob
import untangle
from pykml import parser as kml_parser
import re

cats = ['heavy_urban','light_urban','agriculture', 'woodlot','water']

def read_mask_kml():

    cwd = os.getcwd() + '/'
    mask_dir = cwd+'masks/'

    ref_kml = cwd+'Masks.kml'

    doc = kml_parser.parse(ref_kml).getroot()

    for i in range(len(cats)):
        cat = doc.Document.Folder[0].Folder[i]
        cat_name = str(cat.name)
        if os.path.isfile(mask_dir+cat_name+'.ref'):
            os.remove(mask_dir+cat_name+'.ref')

        f = open(mask_dir+cat_name+'.ref','w')

        cur_mark = cat.Placemark[0]

        while cur_mark is not None:
            # Ugh, we have to format the stupid string
            coord_str = str(cur_mark.Polygon.outerBoundaryIs.LinearRing.coordinates)
            coord_str = re.sub('[\n\t]','',coord_str)
            coord_str = coord_str.replace(',0','')
            coord_str = coord_str[:-1]
            coord_pairs = coord_str.split(" ")

            # Finally, we are getting to x and y coordinate pairs for vertices
            xv = []
            yv = []
            for pair in coord_pairs:
                split = pair.split(",")
                xv.append(split[0])
                yv.append(split[1])

            # Create the output Matlab likes
            poly_out = ' '.join([x for x in xv]) + '; '
            poly_out = poly_out + ' '.join([y for y in yv])
            print('Creating %s mask:' % cat_name)
            print(poly_out)
            f.write(poly_out+'\n')
            cur_mark = cur_mark.getnext()

def create_masks():
    cwd = os.getcwd() + '/'
    data_dir = cwd+'data/'
    #eng = matlab.engine.start_matlab()
    #eng.cd(cwd)

    d=data_dir
    mask_dir = cwd+'masks/'
    row_paths = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))]

    print cwd
    exec_file = open(cwd+'create_masks_commands.txt', 'w')

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

                exec_file.write(write_str)


read_mask_kml()
create_masks()
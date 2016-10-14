import os
import shutil
import glob
import untangle
from pykml import parser as kml_parser
import re

cats = ['heavy_urban','light_urban','agriculture', 'woodlot','water']

def read_i85_kml():
    cwd = os.getcwd() + '/'
    doc = kml_parser.parse(cwd+'i85.kml').getroot()
    coord_str = str(doc.Document.Placemark.LineString.coordinates)
    xv,yv = parse_coord_str(coord_str, altitude_coord=True)
    f = open(cwd+'/masks/i85.ref','w')

    write_coord_pairs(xv,yv,f)

def parse_coord_str(coord_str, altitude_coord=False):
    coord_str = re.sub('[\n\t]','',coord_str)
    if altitude_coord:
        coord_str = coord_str.replace(',0','')

    coord_str = coord_str[:-1]
    coord_pairs = coord_str.split(" ")

    xv = []
    yv = []
    for pair in coord_pairs:
        split = pair.split(",")
        xv.append(split[0])
        yv.append(split[1])

    return xv,yv

def write_coord_pairs(xv,yv,out_file):
    # Create the output Matlab likes
    poly_out = ' '.join([x for x in xv]) + '; '
    poly_out = poly_out + ' '.join([y for y in yv])
    out_file.write(poly_out+'\n')

def read_mask_kml(mask_file):

    cwd = os.getcwd() + '/'
    mask_dir = cwd+'masks/'

    ref_kml = mask_file

    doc = kml_parser.parse(ref_kml).getroot()

    print 'Parsing %s and creating .ref files with coordinate pairs' % mask_file
    for i in range(len(cats)):
        cat = doc.Document.Folder[0].Folder[i]
        cat_name = str(cat.name)
        if os.path.isfile(mask_dir+cat_name+'.ref'):
            os.remove(mask_dir+cat_name+'.ref')

        f = open(mask_dir+cat_name+'.ref','w')

        cur_mark = cat.Placemark[0]

        while cur_mark is not None:
            # Ugh, we have to format the stupid string
            print 'Creating coordinates from polygon called %s' % cur_mark.name
            coord_str = str(cur_mark.Polygon.outerBoundaryIs.LinearRing.coordinates)
            xv,yv = parse_coord_str(coord_str, altitude_coord=True)

            write_coord_pairs(xv,yv,f)
            cur_mark = cur_mark.getnext()

def create_masks():
    cwd = os.getcwd() + '/'
    data_dir = cwd+'data/'

    d=data_dir
    mask_dir = cwd+'masks/'
    row_paths = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))]

    exec_file = open(cwd+'create_masks_commands.txt', 'w')
    study_file = open(cwd+'create_study_masks.txt','w')

    for rp  in row_paths:
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

            # write matlab command to create study mask
            write_str="%s %s %s %s %s %s %s\n" % (
                    tif_file,
                    mask_dir+'i85.ref',
                    scene+'/'+'study'+'.tif',
                    n,s,e,w)
            study_file.write(write_str)

cwd = os.getcwd()+'/'
read_mask_kml('Masks_1.kml')
read_i85_kml()
create_masks()

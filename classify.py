import matlab.engine
import os
import re

def classify_all():
    row_paths = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))]
    for rp_dir  in row_paths:
        print 'Now processing rowpath: %s' % rp_dir
        d=rp_dir
        scenes = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))] 
        for scene_dir in scenes:
            print 'Now processing scene %s' % scene_dir
            fname = [name for name in os.listdir(scene_dir) if 'LC80' in name][0]
            fname = fname.split('_')[0]
            future = eng.land_class(cwd, scene_dir)

def classify_scene(eng,data_dir,rowpath,scene,outfile):
    scene_dir = "%s/%s/%s/" % (data_dir,rowpath,scene)
    fname = [name for name in os.listdir(scene_dir) if 'LC80' in name and '.tif' in name][0]
    fname = fname.split('_')[0]
    future = eng.land_class(cwd,scene_dir,fname,outfile)

eng = matlab.engine.start_matlab()

cwd = os.getcwd() + '/'
d = cwd+'data/'

classify_scene(eng, d, '016035','2014361','classify_2')
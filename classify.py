import matlab.engine
import os
import re

def classify_scenedir(eng, scene_dir, sat_code, outfile, classify=True):
    # find the filename base for each band file, ie. what comes before _band*.tif
    fname = [name for name in os.listdir(scene_dir) if sat_code in name and '.tif' in name][0]
    fname = fname.split('_')[0]
    if sat_code == 'LC8':
        landsat = 8
    else:
        landsat = 7
    future = eng.land_class(cwd,scene_dir,fname,outfile,landsat,classify)

def classify_scene(eng,data_dir,sat_code,rowpath,scene,outfile,classify=True):
    scene_dir = "%s/%s/%s/" % (data_dir,rowpath,scene)
    classify_scenedir(eng, scene_dir, sat_code, outfile,classify=classify)

def classify_all(run_name,row_path=None):
    cwd = os.getcwd() + '/'
    data_dir = cwd+'data/'

    d=data_dir
    row_paths = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))]
    for rp_dir  in row_paths:
        if row_path is None or row_path==rp_dir[-6:]:
            print 'Now processing rowpath: %s' % rp_dir
            d=rp_dir
            scenes = [os.path.join(d,o) for o in os.listdir(d) if os.path.isdir(os.path.join(d,o))] 
            for scene_dir in scenes:
                print 'Now processing scene %s' % scene_dir
                scene_id = scene_dir.split('/')[-1]
                rowpath_id = scene_dir.split('/')[-2]
                classify_scenedir(eng, scene_dir,'LC8', run_name)

eng = matlab.engine.start_matlab()

cwd = os.getcwd() + '/'
d = cwd+'data/'

classify_scene(eng, d, 'LC8', '016035','2016207','classify_cloud',classify=False)
#classify_all('Run2', row_path='016035')
eng.quit()
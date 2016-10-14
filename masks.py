import matlab.engine
import os
import re
import sys

args = sys.argv

if len(args) >= 2:
    row_path = args[1]
if len(args) >= 3:
    scene_id = args[2]

cwd = os.getcwd() + '/'
command_file = open(cwd+'create_masks_commands.txt')
study_file = open(cwd+'create_study_masks.txt')
eng = matlab.engine.start_matlab()

for line in command_file.readlines():
    args = line.split(" ")
    run_command = not(row_path)
    if row_path and row_path in line:
        run_command = True
    if len(args) == 7 and run_command:
        print 'Running command: %s' % line
        future = eng.gen_sig_mask(
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5],
            args[6],
            async=True)
        ret = future.result()
        print(ret);

'''
for line in study_file.readlines():
    print line
    args = line.split(" ")
    if len(args) == 7:
        future = eng.gen_study_mask(
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5],
            args[6],
            async=True)
        ret = future.result()
        print(ret)
'''
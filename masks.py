import matlab.engine
import os
import re

cwd = os.getcwd() + '/'
command_file = open(cwd+'create_masks_commands.txt')
eng = matlab.engine.start_matlab()

for line in command_file.readlines():
    print line
    args = line.split(" ")
    if len(args) == 7:
        future = eng.generate_reference_mask(
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
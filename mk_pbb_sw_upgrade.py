#!/usr/bin/python

import sys
import os
import json
import cPickle
import shutil

version = sys.argv[1]
image_file = open(sys.argv[2], 'rb')


tmpdir = 'tmp'
os.mkdir(tmpdir)
os.chdir(tmpdir)

with open("manifest.json", "w") as f:
    f.write(json.dumps({'format': 'Process Program Definition v01',
                         'description': "Update PBB Software to version %s" % version,
                         'userInputs' : []}))

with open("sequence.mlpps", "w") as f:
    f.write("""
InputID (SSName, moduleNameVersionRevision, slotNumber, softwareModule)
OutputID ()

sequential
   SUSD.upgradeSoftwareModule(SSName, moduleNameVersionRevision, slotNumber, softwareModule)()
endseq
""")

os.mkdir('inputs')
with open('inputs/SSName', 'wb') as f:
    f.write(cPickle.dumps("PBB", protocol = 2))
with open('inputs/moduleNameVersionRevision', 'wb') as f:
    f.write(cPickle.dumps("PBB Software %s" % version, protocol = 2))
with open('inputs/slotNumber', 'wb') as f:
    f.write(cPickle.dumps(1, protocol = 2))
with open('inputs/softwareModule', 'wb') as f:
    f.write(image_file.read())

os.system('zip -q -P "Modifying this file is subject to MAPPER terms and conditions" -r -D ../PBB.upgradeSoftwareModule-%s.mlpp .' % version )

os.chdir('..')

shutil.rmtree(tmpdir)

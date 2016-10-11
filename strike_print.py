from sys import argv
from os import system
with open('strikes.txt') as f:
    sdict = eval(f.read())
try:
    strs = sdict[argv[1]]
    osislist = list(argv[1])
    osisspaced = ' '.join(osislist)
    strn = ' has ' + str(strs) + ' strikes.'
    print argv[1] + strn
    system('spd-say "' + osisspaced + strn + '"')
except KeyError:
    pass


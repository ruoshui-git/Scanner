import sys, os

os.chdir('logs')
for osis in sys.argv[1:]:
    print 'Dates %s Attended Dojo' % (osis)
    with os.popen('grep -l "%s" *.csv' % (osis)) as source:
        dates = sorted(source.read().split("\n")[:-1])
    for date in dates:
        os.system("date -d %s +'%%A %%B %%d %%Y'" % (date[:-4].replace('_','')))
    print
os.chdir('..')

import sys, os

if len(sys.argv) < 2:
    print "Usage: python lookup.py <osis> <osis> <osis> ..."

for osis in sys.argv[1:]:
    print 'Dates %s Attended Dojo' % (osis)
    with os.popen('grep "%s" logs/*.csv' % (osis)) as source:
        dates = sorted(source.read().split("\n")[:-1])
    for date in dates:
        if ',' in date:
            os.system("date -d '%s' +'%%A %%B %%d %%Y %%T'" % (date[5:date.find('.')].replace('_','') + ' ' + date[date.find(',') + 2:]))
        else:
            os.system("date -d '%s' +'%%A %%B %%d %%Y'" % (date[5:date.find('.')].replace('_','')))
    print "%s has attended Dojo for %d day(s)\n" % (osis, len(dates))

'''Simple test of graphing OSIS data. Just plots attendance over time without labels. Can do more.'''

from datetime import datetime, timedelta
from os.path import exists
import matplotlib.pyplot as plt 
from sys import argv


def get_oses(start=datetime(2014,1,1), end=datetime(2018,1,1)):
	'''Uses the log data from logs/ to compile two things: an ordered list of oses by day, and a dictionary with datetimes as keys and their oses as values.'''
	day = timedelta(1)
	diff = (end - start).days
	dt_osis_dict = {}
	ordered_oses = []
	for _ in range(diff):
		start += day
		stpath = 'logs/'+start.strftime('%Y_%m_%d') + '.csv'
		if exists(stpath):
			with open(stpath) as f:
                                osises = []
                                for i in f.readlines():
                                        try:
                                                osises.append(int(i.strip()))
                                        except:
                                                pass
			dt_osis_dict[start] = osises
			ordered_oses.append(osises)
	return dt_osis_dict, ordered_oses


def get_dates(osis, dt_osis_dict):
        dates = []
        for dt, oses in dt_osis_dict.items():
                if osis in oses:
                        dates.append(dt)
        return dates
                        
                        
if __name__ == '__main__':
	dc, _ = get_oses(datetime(2014,1,1), datetime(2017,1,1))
        oses = argv[1:]
        for i in oses:
                try:
                        print i, get_dates(int(i), dc)
                        print
                except:
                        pass

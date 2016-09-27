'''Simple test of graphing OSIS data. Just plots attendance over time without labels. Can do more.'''

from datetime import datetime, timedelta
from os.path import exists
import matplotlib.pyplot as plt 


def get_oses(start, end):
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
				osises = [int(i.strip()) for i in f.readlines()]
			dt_osis_dict[start] = osises
			ordered_oses.append(osises)
	return dt_osis_dict, ordered_oses


if __name__ == '__main__':
	_, oo = get_oses(datetime(2014, 3, 7), datetime(2015, 6, 10))
	lengths = [len(i) for i in oo]
	x = range(len(oo))
	plt.plot(x, lengths)
	plt.title('Attendance vs. Time')
	plt.show()

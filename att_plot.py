from datetime import datetime, timedelta
from os.path import exists
start = datetime(2014, 9, 10)
end = datetime(2015, 6, 1)
day = timedelta(1)
diff = (end - start).days
dt_osis_dict = {}
for _ in range(diff):
	start += day
	stpath = start.strftime('%Y_%m_%d') + '.csv'
	if exists(stpath):
		with open('logs/' + stpath) as f:
			osises = [int(i.strip()) for i in f.readlines()]
		dt_osis_dict[start] = osises
		ordered_oses.append(osises)
lengths = [len(i) for i in ordered_oses]
x = range(len(ordered_oses))
plt.plot(x, lengths)
plt.title('Attendance vs. Time')
plt.show()

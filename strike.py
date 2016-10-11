from sys import argv

#add strikes mode = 1
#subtract strikes mode = -1
mode = argv[1]
oses = argv[2:]

for osis in oses:
        with open('strikes.txt', 'r') as f:
                strike_dict = eval(f.read())
                if osis not in strike_dict:
                        strike_dict[osis] = 0
                strike_dict[osis] += int(mode)
                if strike_dict[osis] <= 0:
                        del strike_dict[osis]
        with open('strikes.txt', 'w') as f:
                f.write(repr(strike_dict))

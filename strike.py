osis = 163727272
with open('strikes.txt', 'r') as f:
	strike_dict = eval(f.read())
	if osis not in strike_dict:
		strike_dict[osis] = 0
	strike_dict[osis] += 1
with open('strikes.txt', 'w') as f:
	f.write(repr(strike_dict))

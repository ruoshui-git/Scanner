from osis import get_oses


def dictapp(dictt, key, el):
  if key in dictt:
    dictt[key].append(el)
  else:
    dictt[key] = [el]
    

def byosis_dict(dt_dict):
  newdict = {}
  for dt, oses in dt_dict.items():
    for osis in oses:
      dictapp(newdict, osis, dt)
  return newdict


def show_attendance(osis, osis_dict):
  dts = osis_dict[osis]
  print str(osis) + ':'
  for dt in sorted(dts):
    print '\t' + dt.strftime('%m/%d/%y')
    

if __name__ == '__main__':
  dtd, _ = get_oses()
  byod = byosis_dict(dtd)
  os = 0
  maxc = 0
  for osis in byod:
    if len(byod[osis]) > maxc:
      maxc = len(byod[osis])
      os = [osis]
    elif len(byod[osis]) == maxc:
      os.append(osis)
  for osis in os:
    show_attendance(osis, byod)

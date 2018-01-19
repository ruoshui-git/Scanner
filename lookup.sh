#! /bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: ./lookup.sh <osis> <osis> <osis> ..."
fi
for osis in "$@"; do
    echo "Dates $osis Attended Dojo"
    days=0
    IFS=$'\n'
    for line in $(grep "$osis" logs/*.csv | sort); do
        let "days++"
        time=${line#*,}
        date=${line:5:10}
        date=${date//_/}
        if [[ $time = $line ]]; then
            date -d "$date" +'%A %B %d %Y'
        else
            date -d "$date$time" +'%A %B %d %Y %T'
        fi
    done
    echo -e "$osis has attended Dojo for $days day(s)\n"
done

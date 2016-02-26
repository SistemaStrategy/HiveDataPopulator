#!/bin/bash
if [[ -z $1 ]]; then
	echo 'You must provide as first and only arg the number of lines generated'
else
	hexdump -v -e '5/1 "%02x""\n"' /dev/urandom | 
	awk -v OFS=';' '
	NR == 1 { print "col1", "col2", "col3" }
	{ print substr($0, 1, 8), substr($0, 9, 2), int(NR * 32768 * rand()) }' |
	head -n "$1" > random_values.csv
  fi
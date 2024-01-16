#!/bin/bash
cat ip | while read ip
do
	python3 qqwry.py $ip |grep -v without
done

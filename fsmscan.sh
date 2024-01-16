#!/bin/bash
#rm -rf ./tmp/*
#rm -rf ./results/ip/*
#rm -rf ./results/whatweb/*
#rm -rf ./results/finger/*
#rm -rf ./results/*.txt

#输入二级域名清单所在文件路径，或者提前预设
#echo "pls input main_domains path"
#read main_domains
main_domains="./main_domains"
#输入子域名搜集要跑的线程，最高可以二级域名数*子域名工具数，输入或者提前预设
#echo "pls input thread num"
#read thread
thread=2
#输入公司名拼音，或提前预设
#echo "pls input company name"
#read company
company=example

./get_subs.sh $main_domains $company $thread
echo "all domain's sub_domians collected."
echo "output to ./results/subs_$company.txt"
./host_and_cloud_dislodge.sh $company
./main.sh $company


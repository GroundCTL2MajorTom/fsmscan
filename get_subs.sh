#!/bin/bash
main_domains=$1
company=$2
thread=$3
#生成数个子域名扫描工具的sh脚本
while IFS= read -r domain; do
echo python3 subDomainsBrute/subDomainsBrute.py $domain -o ./tmp/sBB_$domain.txt >> ./tmp/subsh_SubDomainBrute_$domain.sh
echo python3 oneforall/oneforall.py --target $domain --path=./tmp/Oneforall_$domain.csv run >> ./tmp/subsh_oneforall_$domain.sh
done < "$main_domains"
#多线程执行子域名搜集
ls ./tmp/subsh* | xargs -n1 -P $thread sh
#将所有得到的结果中的子域名汇总到一个清单./results/subs_$company.txt
while IFS= read -r domain; do
cat ./tmp/sBB_$domain.txt | awk '{print($1)}' >> ./tmp/subs_$domain.txt
tail -n +2 ./tmp/Oneforall_$domain.csv | awk -F "," '{print($6)}' >> ./tmp/subs_$domain.txt
cat ./tmp/subs_$domain.txt |sort|uniq >> ./results/subs_$company.txt
done < "$main_domains"

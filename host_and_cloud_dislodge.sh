#!/bin/bash
company=$1
#将子域名清单一个一个host解析出所有ip地址
cat ./results/subs_$company.txt|while read line
do
	host $line >> ./tmp/host_ips_$company.txt
done
cat ./tmp/host_ips_$company.txt|grep address|grep -v :|awk '{print($4)}'|sort|uniq > ./results/ip/all_ips_$company.txt
echo "all sub_domains's ip address collected."
echo "output to ./results/ip/all_ips_$company.txt"
#筛选出非云的ip地址
cat ./results/ip/all_ips_$company.txt > ./geoip/ip
cd ./geoip
sh ip.sh |xargs -n3 > ../tmp/ipsh_$company.txt
cd ../
cat ./tmp/ipsh_$company.txt|grep -vE "局域网|美国|阿里云|华为云|腾讯云|百度云|网宿|金山云|Amazon|韩国|亚太|CZ88|香港|本地"|awk '{print($1)}' >> ./tmp/ipsh_tmp_$company.txt
./AlliN -f ./tmp/ipsh_tmp_$company.txt -o ./tmp/allin_first_$company.txt
cat ./tmp/allin_first_$company.txt|grep -vE "CDN|防火墙|WAF"|awk '{print($2)}'|awk -F "//" '{print($2)}'|sort|uniq >./tmp/ips_not_cloud_tmp_$company.txt
echo ""
echo "not_cloud_ips:"
echo ""
cat ./tmp/ips_not_cloud_tmp_$company.txt
echo "output to ./tmp/ips_not_cloud_tmp_$company.txt"

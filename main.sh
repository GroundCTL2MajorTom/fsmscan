#!/bin/bash
company=$1
#看网段
# 定义一个变量，表示是否已经输入
#is_input=false
# 循环等待用户输入
#while [ "$is_input" = false ]; do
  # 接收用户输入
#  read -p "pls input netmask" netmask
  # 判断输入是否为空
#  if [ -z "$netmask" ]; then
#    echo "invalid input!"
#  else
#    is_input=true
#  fi
#done
# 输出输入的值，并继续执行其他命令
#echo "you input is: $netmask"
netmask=28
echo "start ipcalc..."
cat ./tmp/ips_not_cloud_tmp_$company.txt|sed "s/$/\/$netmask/g"|xargs -n1 ipcalc|grep Network|awk '{print($2)}'|sort|uniq > ./results/netmask_$company.txt
cat ./results/netmask_$company.txt
echo "output path ./results/netmask_$company.txt"
echo "ipcalc done,start fping"
cat ./results/netmask_$company.txt|while read line
do
	fping -g $line >> ./tmp/fping_raw_$company.txt
done
cat ./tmp/fping_raw_$company.txt|grep alive|awk '{print($1)}'>>./tmp/fping_processed_$company.txt
echo "fping done,masscan start"
#扫描疑似非云ip的端口
masscan -p1-65535 -iL ./tmp/fping_processed_$company.txt --rate=2000 > ./tmp/masscan_raw_$company.txt
cat ./tmp/masscan_raw_$company.txt |awk '{print($6":"$4)}'|sed 's#/tcp##g'|sort|uniq >> ./tmp/masscan_ip_port_$company.txt
#扫描后的结果如果同ip出现50次以上的筛除
cat ./tmp/masscan_ip_port_$company.txt| awk -F: '{print $1}' | sort | uniq -c | awk '$1 <= 50 {print $2}' | while read ip; do grep -w "$ip:[0-9]*" ./tmp/masscan_ip_port_$company.txt; done >> ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt
echo "possible real ip:port"
cat ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt
echo "output to ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt"
#筛选出可用端口
cat ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt|awk -F ":" '{print($2)}'|sort|uniq >> ./tmp/available_ports_$company.txt
#url:port拼接和whatweb探测4线程执行
while read item; do paste <(yes "$item" | head -n $(wc -l < ./tmp/available_ports_$company.txt)) ./tmp/available_ports_$company.txt --delimiters ':'; done < ./results/subs_$company.txt > ./tmp/url_plus_port_$company.txt
#四线程
echo "whatweb -i ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt --colour=never --url-prefix="http://" --no-errors >>./tmp/whatweb_raw_$company.txt" > ./tmp/whatwebsh_tmp1_$company.sh
echo "whatweb -i ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt --colour=never --url-prefix="https://" --no-errors >>./tmp/whatweb_raw_$company.txt" > ./tmp/whatwebsh_tmp2_$company.sh
echo "whatweb -i ./tmp/url_plus_port_$company.txt --colour=never --url-prefix="http://" --no-errors >> ./tmp/whatweb_raw_$company.txt" > ./tmp/whatwebsh_tmp3_$company.sh
echo "whatweb -i ./tmp/url_plus_port_$company.txt --colour=never --url-prefix="https://" --no-errors >> ./tmp/whatweb_raw_$company.txt" > ./tmp/whatwebsh_tmp4_$company.sh
echo "start whatweb..."
ls ./tmp/whatwebsh* | xargs -n1 -P 4 sh
echo "whatweb done"
#输出到result里方便查看
cat ./tmp/whatweb_raw_$company.txt |grep -E "200 OK|302 Found"|awk '{print($1)}' > ./results/whatweb/200_302_weblist_$company.txt
cat ./tmp/whatweb_raw_$company.txt |grep "403 Forbidden" |awk '{print($1)}' > ./results/whatweb/403_weblist_$company.txt
cat ./tmp/whatweb_raw_$company.txt |grep "400 Bad Request"|grep -vE "plain|443"|awk '{print($1)}' > ./tmp/valuable_400_weblist_$company.txt
cat ./tmp/whatweb_raw_$company.txt |grep -vE "400 Bad Request"|awk '{print($1)}' > ./results/whatweb/whatweball_except400_$company.txt
cat ./tmp/valuable_400_weblist_$company.txt >> ./results/whatweb/whatweball_except400_$company.txt
cat ./results/whatweb/whatweball_except400_$company.txt
echo "weblist output to ./results/whatweb/whatweball_except400_$company.txt"
echo ""
echo ""
cat ./results/whatweb/whatweball_except400_$company.txt|awk -F "//" '{print($2)}' >> ./tmp/whatweball_except400_tmp_$company.txt
cat  ./results/ip/masscan_processed_not_cloud_ip_port_$company.txt|grep -vwf ./tmp/whatweball_except400_tmp_$company.txt >> ./results/ip/services_not_web_$company.txt
echo "real_ip's services without web collected"
cat ./results/ip/services_not_web_$company.txt
echo "output to ./results/ip/services_not_web_$company.txt"
#指纹识别输出无后续
echo "allin start ..."
./AlliN -f ./results/whatweb/whatweball_except400_$company.txt -o ./tmp/allin_all_$company.txt
cat ./tmp/allin_all_$company.txt|grep "\!\!" >> ./results/finger/allin_important_$company.txt
cat ./results/finger/allin_important_$company.txt
echo "allin critical output to ./results/finger/allin_important_$company.txt"
echo ""
echo "EHole start..."
./EHole/ehole finger -l ./results/whatweb/whatweball_except400_$company.txt >> ./results/finger/ehole_$company.txt
echo "EHole done.output to ./results/finger/ehole_$company.txt"
#nuclei扫描
#echo "start nuclei scan"
#./nuclei -list ./results/whatweb/whatweball_except400_$company.txt -t /opt/NucleiTP -s high,critical -o ./results/nuclei_$company.txt
#echo "nuclei done.results output to ./results/nuclei_$company.txt"

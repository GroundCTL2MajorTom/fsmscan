# fsmscan

支持同一公司的多个主域同时扫描

1.在子目录中main_domains文件中写入要扫描的多个主域

2.子目录中主脚本为fsmscan.sh，直接运行该脚本后输入子域名搜集阶段要跑的线程（最高可以设置主域数*2）、该公司名(区分扫描不同公司的输出结果)，也可以提前在脚本中预设。

### 过程及输出结果说明

#### 1.子域名搜集

得到要扫描的主域名后主脚本fsmscan.sh调用get_subs.sh进行多线程子域名搜集，本脚本只调用了oneforall和subdomainsbrute两个工具，可以往上加Sublist3r、Amass等工具，反正最后结果会汇总到一张清单上并去重，该清单位置为./results/subs_$company.txt。

**输出物./results/subs_$company.txt**,即所有子域名。

#### 2.ip资产筛选

执行host_and_cloud_dislodge.sh(子脚本)，将./results/subs_$company.txt(子域名清单)的结果一个一个用host工具解析出ip地址并将该结果进一步筛选，排除云资产的ip地址。然后需要扫描每一个非云ip资产所在的网段，需要人工输入一个网段值，可以在脚本运行时输入或修改main.sh中的netmask变量。通过fping工具筛选出每个网段中的存活ip并交给masscan工具扫描每个存活ip的存活端口，将扫描结果中同一ip同时开放50个端口以上的ip筛除(因为他很可能是之前筛除云资产ip时漏掉的)，输出**./results/ip/masscan_processed_not_cloud_ip_port__$company.txt**，即该公司潜在的真实ip:port。

#### 3.web资产梳理

将所有潜在真实ip:port表中的端口单独提出来去重，和之前搜集的子域名作拼接，然后用whatweb工具去撞，把whatweb输出中的非400状态码结果输出，在把该输出结果放入nuclei中进行初步扫描。**输出结果./results/nuclei_$company.txt**。

放入Allin和Ehole中进行指纹扫描，然后将扫描出的重要资产结果放入**./results/finger/allin_important_$company.txt**

和 **./results/finger/ehole_$company.txt**

#### 4.网络资产梳理

将前面masscan扫描输出的./results/ip/masscan_processed_not_cloud_ip_port__$company.txt（即该公司潜在的真实ip:port）与 whatweb扫描出的web资产表作去重处理，梳理出不包含web资产的网络资产。输出物为./results/ip/services_not_web_$company.txt，后续可以放到goby、nessus等网络扫描器中扫描。

#### 注意

请根据运行环境预装python3、host、ipcalc、fping、whatweb工具，将要扫描的域名放入main_domains文件中，多次扫描时注释掉fsmscan.sh文件开头的rm -rf 命令。

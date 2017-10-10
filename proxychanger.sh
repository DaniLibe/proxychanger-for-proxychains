#!/bin/bash

function restore_original()
{
cp -f /etc/proxychains.conf.bak /etc/proxychains.conf
echo
exit
}

function switch()
{
trap restore_original SIGINT

list_len=$(wc -l proxy_list.txt | tr ' ' '\t' | cut -f 1)
echo '#PROXY HERE' >> /etc/proxychains.conf

while true; do
	for i in $(seq 1 $list_len); do
		http_proxy=$(sed "$i!d" proxy_list.txt)
		curr_proxy=$(echo $http_proxy | tr ' ' ':')
		sed -i "s/#PROXY HERE/$2\t$http_proxy/" /etc/proxychains.conf
		echo "Current $2 proxy: $curr_proxy"
		sleep $1
		sed -i "s/$2\t$http_proxy/#PROXY HERE/" /etc/proxychains.conf
	done
done
}

if [[ $1 && $2 ]]; then
	if [ -f /etc/proxychains.conf ]; then
		if [ ! -f /etc/proxychains.conf.bak ]; then
			cp -f /etc/proxychains.conf /etc/proxychains.conf.bak
		fi

		#switch

		trap restore_original SIGINT

		list_len=$(wc -l proxy_list.txt | tr ' ' '\t' | cut -f 1)
		echo '#PROXY HERE' >> /etc/proxychains.conf

		while true; do
			for i in $(seq 1 $list_len); do
				http_proxy=$(sed "$i!d" proxy_list.txt)
				curr_proxy=$(echo $http_proxy | tr ' ' ':')
				sed -i "s/#PROXY HERE/$2\t$http_proxy/" /etc/proxychains.conf
				echo "Current $2 proxy: $curr_proxy"
				sleep $1
				sed -i "s/$2\t$http_proxy/#PROXY HERE/" /etc/proxychains.conf
			done
		done
	else
		echo -e "\n[ERROR] Proxychains is not installed or /etc/proxychains.conf is missing!\n"
	fi
else
	echo -e "\n[ERROR] Specify a duration and a proxy type!\nbash proxychanger.sh <proxy duration> <proxy type>\n"
fi

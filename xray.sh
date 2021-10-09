#!/bin/bash
#==========================#
###### Author: CuteBi ######
#==========================#

#Stop xray & delete xray files.
Delete() {
	systemctl disable xray.service
	rm -rf /etc/init.d/xray /lib/systemd/system/xray.service
	if [ -f "${xray_install_directory:=/usr/local/xray}/xray.init" ]; then
		"$xray_install_directory"/xray.init stop
		rm -rf "$xray_install_directory"
	fi
}

#Print error message and exit.
Error() {
	echo $echo_e_arg "\033[41;37m$1\033[0m"
	echo -n "remove xray?[y]: "
	read remove
	echo "$remove"|grep -qi 'n' || Delete
	exit 1
}

makeHttpInbound() {
local port="$1"
local tlsConfig="$2"
local protocol="$3"
echo '{
			"port": "'$port'",
			"protocol": "'$protocol'",
			"settings": {
				"udp": true,
				"clients": [{
					"id": "'$uuid'",
					"level": 0,
					"alterId": 4
				}]
			},
			"streamSettings": {
				"sockopt": {
					"tcpFastOpen": '$tcpFastOpen'
				},
				"network": "tcp",
				"tcpSettings": {
					"header": {
						"type": "http"
					}
				}'$tlsConfig'
			}
		}'
}

makeWSInbound() {
local port="$1"
local tlsConfig="$2"
local url="$3"
local protocol="$4"
echo '{
			"port": "'$port'",
			"protocol": "'$protocol'",
			"settings": {
				"udp": true,
				"clients": [{
					"id": "'$uuid'",
					"flow": "xtls-rprx-direct",
					"level": 0,
					"alterId": 4
				}],
				"decryption": "none"
			},
			"streamSettings": {
				"sockopt": {
					"tcpFastOpen": '$tcpFastOpen'
				},
				"network": "ws",
				"wsSettings": {
					"path": "'$url'"
				}'$tlsConfig'
			}
		}'
}

makeTcpInbound() {
local port="$1"
local tlsConfig="$2"
local protocol="$3"
echo '{
			"port": "'$port'",
			"protocol": "'$protocol'",
			"settings": {
				"udp": true,
				"clients": [{
					"id": "'$uuid'",
					"flow": "xtls-rprx-direct",
					"level": 0,
					"alterId": 4
				}],
				"decryption": "none"
			},
			"streamSettings": {
				"sockopt": {
					"tcpFastOpen": '$tcpFastOpen'
				},
				"network": "tcp"'$tlsConfig'
			}
		}'
}

makeKcpInbound() {
local port="$1"
local tlsConfig="$2"
local headerType="$3"
local protocol="$4"
echo '{
			"port": "'$port'",
			"protocol": "'$protocol'",
			"settings": {
				"udp": true,
				"clients": [{
					"id": "'$uuid'",
					"flow": "xtls-rprx-direct",
					"level": 0,
					"alterId": 4
				}],
				"decryption": "none"
			},
			"streamSettings": {
				"network": "kcp",
				"kcpSettings": {
					"header": {
						"type": "'$headerType'"
					}
				}'$tlsConfig'
			}
		}'
}

#Input xray.json
Config() {
	clear
	uuid=`cat /proc/sys/kernel/random/uuid`
	tcpFastOpen=`[ -f /proc/sys/net/ipv4/tcp_fastopen ] && echo -n 'true' || echo -n 'false'`
	if [ -z "$xray_install_directory" ]; then
		echo -n "Please input xray install directory(default is /usr/local/xray): "
		read xray_install_directory
		echo -n "Install UPX compress version?[n]: "
		read xray_UPX
		echo "$xray_UPX"|grep -qi '^y' && xray_UPX="upx" || xray_UPX=""
		echo $echo_e_arg "options(TLS default self signed certificate, if necessary, please change it yourself.):
		\r\t1. tcp_http(vmess)
		\r\t2. WebSocket(vmess)
		\r\t3. WebSocket+tls(vless)
		\r\t4. mkcp(vmess)
		\r\t5. mkcp+xtls(vless)
		\r\t6. tcp+xtls(vless)
		\rPlease input your options(Separate multiple options with spaces):"
		read xray_inbounds_options
		for opt in $xray_inbounds_options; do
			case $opt in
				1)
					echo -n "Please input xray http server port: "
					read xray_http_port
				;;
				2)
					echo -n "Please input xray webSocket server port: "
					read xray_ws_port
					echo -n "Please input xray webSocket Path(default is '/'): "
					read xray_ws_path
					xray_ws_path=${xray_ws_path:-/}
				;;
				3)
					echo -n "Please input xray webSocket tls server port: "
					read xray_ws_tls_port
					echo -n "Please input xray webSocket tls Path(default is '/'): "
					read xray_ws_tls_path
					xray_ws_tls_path=${xray_ws_tls_path:-/}
				;;
				4)
					echo -n "Please input xray mKCP server port: "
					read xray_mkcp_port
				;;
				5)
					echo -n "Please input xray mKCP xtls server port: "
					read xray_mkcp_xtls_port
				;;
				6)
					echo -n "Please input xray tcp xtls server port: "
					read xray_tcp_xtls_port
				;;
			esac
		done
	fi
}

GetAbi() {
	machine=`uname -m`
	if echo "$machine"|grep -q 'mips64'; then
		shContent=`cat "$SHELL"`
		[ "${shContent:5:1}" = `echo $echo_e_arg "\x01"` ] && machine='mips64le' || machine='mips64'
	elif echo "$machine"|grep -q 'mips'; then
		shContent=`cat "$SHELL"`
		[ "${shContent:5:1}" = `echo $echo_e_arg "\x01"` ] && machine='mipsle' || machine='mips'
	elif echo "$machine"|grep -Eq 'i686|i386'; then
		machine='386'
	elif echo "$machine"|grep -Eq 'armv7|armv6'; then
		machine='arm'
	elif echo "$machine"|grep -Eq 'armv8|aarch64'; then
		machine='arm64'
	else
		machine='amd64'
	fi
}

#install xray xray.init xray.service
InstallFiles() {
	GetAbi
	if echo "$machine" | grep -q '^mips'; then
		cat /proc/cpuinfo | grep -qiE 'fpu|neon|vfp|softfp|asimd' || softfloat='_softfloat'
	fi
	mkdir -p "${xray_install_directory:=/usr/local/xray}" || Error "Create xray install directory failed."
	cd "$xray_install_directory" || Error "Create cns install directory failed."
	#install xray
	$download_tool_cmd xray http://pros.cutebi.flashproxy.cn:666/xray/${xray_UPX}/linux_${machine}${softfloat} || Error "xray download failed."
	$download_tool_cmd xray.init http://pros.cutebi.flashproxy.cn:666/xray/xray.init || Error "xray.init download failed."
	sed -i "s~\[xray_install_directory\]~$xray_install_directory~g" xray.init
	sed -i "s~\[xray_tcp_port_list\]~$xray_http_port $xray_http_tls_port $xray_ws_port $xray_ws_tls_port~g" xray.init
	sed -i "s~\[xray_udp_port_list\]~$xray_mkcp_port $xray_mkcp_xtls_port~g" xray.init
	ln -s "$xray_install_directory/xray.init" /etc/init.d/xray
	chmod -R +rwx "$xray_install_directory" /etc/init.d/xray
	if which systemctl && [ -z "$(systemctl --failed|grep -q 'Host is down')" ]; then
		$download_tool_cmd /lib/systemd/system/xray.service http://pros.cutebi.flashproxy.cn:666/xray/xray.service || Error "xray.service download failed."
		chmod +rwx /lib/systemd/system/xray.service
		sed -i "s~\[xray_install_directory\]~$xray_install_directory~g" /lib/systemd/system/xray.service
		systemctl daemon-reload
	fi
	#make json config
	local tlsConfig=',
			"security": "tls",
			"tlsSettings": {
				"certificates": ['"`./xray tls cert`"']
			}'
	for opt in $xray_inbounds_options; do
		[ -n "$in_networks" ] && in_networks="$in_networks, "
		case $opt in
			1) in_networks="$in_networks"`makeHttpInbound "$xray_http_port" "" vmess`;;
			2) in_networks="$in_networks"`makeWSInbound "$xray_ws_port" "" "$xray_ws_path" vmess`;;
			3) in_networks="$in_networks"`makeWSInbound "$xray_ws_tls_port" "$tlsConfig" "$xray_ws_tls_path" vless`;;
			4) in_networks="$in_networks"`makeKcpInbound "$xray_mkcp_port" "" utp vmess`;;
			5) in_networks="$in_networks"`makeKcpInbound "$xray_mkcp_xtls_port" "${tlsConfig//tls/xtls}" none vless`;;
			6) in_networks="$in_networks"`makeTcpInbound "$xray_tcp_xtls_port" "${tlsConfig//tls/xtls}" vless`;;
		esac
	done
	echo $echo_E_arg '
	{
		"log" : {
			"loglevel": "none"
		},
		"inbounds": ['"$in_networks"'],
		"outbounds": [{
			"protocol": "freedom"
		}]
	}
	' >xray.json
}

#install initialization
InstallInit() {
	echo -n "make a update?[n]: "
	read update
	PM=`which apt-get || which yum`
	echo "$update"|grep -qi 'y' && $PM -y update
	$PM -y install curl wget #unzip
	type curl && download_tool_cmd='curl -L --connect-timeout 7 -ko' || download_tool_cmd='wget -T 60 --no-check-certificate -O'
	getip_urls="http://myip.dnsomatic.com/ http://ip.sb/"
	for url in $getip_urls; do
		ip=`$download_tool_cmd - "$url"`
	done
}

outputVmessLink() {
	[ -z "$ip" ] && return
	for opt in $xray_inbounds_options; do
		case $opt in
			1)
				link=`echo -n $echo_E_arg '{"add": "'$ip'", "port": '$xray_http_port', "aid": "4", "host": ".cutebi.flashproxy.cn", "id": "'$uuid'", "net": "tcp", "path": "/", "ps": "http_'$ip:$xray_http_port'", "tls": "", "type": "http", "v": "2"}'|base64 -w 0`
				echo $echo_e_arg "\033[45;37m\rhttp:\033[0m\n\t\033[4;35mvmess://$link\033[0m"
			;;
			2)
				link=`echo -n $echo_E_arg '{"add": "'$ip'", "port": "'$xray_ws_port'", "aid": "4", "host": ".cutebi.flashproxy.cn", "id": "'$uuid'", "net": "ws", "path": "'$xray_ws_path'", "ps": "ws_'$ip:$xray_ws_port'", "tls": "", "type": "none", "v": "2"}'|base64 -w 0`
				echo $echo_e_arg "\033[45;37m\rws:\033[0m\n\t\033[4;35mvmess://$link\033[0m"
			;;
			3)
				#link=`echo -n $echo_E_arg '{"add": "'$ip'", "port": "'$xray_ws_tls_port'", "aid": "4", "host": ".cutebi.flashproxy.cn", "id": "'$uuid'", "net": "ws", "path": "'$xray_ws_tls_path'", "ps": "ws+tls_'$ip:$xray_ws_tls_port'", "tls": ".cutebi.flashproxy.cn", "type": "none", "v": "2"}'|base64 -w 0`
				#echo $echo_e_arg "\033[45;37m\rws+tls:\033[0m\n\t\033[4;35mvmess://$link\033[0m"
				echo $echo_e_arg "\033[45;37m\rws+tls:\033[0m\n\t\033[4;35mvless://${uuid}@${ip}:${xray_ws_tls_port}?path=${xray_ws_tls_path}&security=tls&encryption=none&host=.cutebi.flashproxy.cn&type=ws#ws+tls_${ip}:${xray_ws_tls_port}\033[0m"
				
			;;
			4)
				link=`echo -n $echo_E_arg '{"add": "'$ip'", "port": "'$xray_mkcp_port'", "aid": "4", "host": "", "id": "'$uuid'", "net": "kcp", "path": "", "ps": "mkcp_'$ip:$xray_mkcp_port'", "tls": "", "type": "utp", "v": "2"}'|base64 -w 0`
				echo $echo_e_arg "\033[45;37m\rmkcp:\033[0m\n\t\033[4;35mvmess://$link\033[0m"
			;;
			5)
				#link=`echo -n $echo_E_arg '{"add": "'$ip'", "port": "'$xray_mkcp_xtls_port'", "aid": "4", "host": "", "id": "'$uuid'", "net": "kcp", "path": "", "ps": "mkcp_'$ip:$xray_mkcp_xtls_port'", "tls": "tls", "host": ".cutebi.flashproxy.cn", "type": "utp", "v": "2"}'|base64 -w 0`
				#echo $echo_e_arg "\033[45;37m\rmkcp+tls:\033[0m\n\t\033[4;35mvmess://$link\033[0m"
				echo $echo_e_arg "\033[45;37m\rmkcp+xtls:\033[0m\n\t\033[4;35mvless://${uuid}@${ip}:${xray_mkcp_xtls_port}?security=xtls&encryption=none&headerType=none&type=kcp&flow=xtls-rprx-direct#mkcp+xtls_${ip}:${xray_mkcp_xtls_port}\033[0m"
			;;
			6)
				echo $echo_e_arg "\033[45;37m\rtcp+tls:\033[0m\n\t\033[4;35mvless://${uuid}@${ip}:${xray_tcp_xtls_port}?security=xtls&encryption=none&host=.cutebi.flashproxy.cn&headerType=none&type=tcp&flow=xtls-rprx-direct#tcp+xtls_${ip}:${xray_tcp_xtls_port}\033[0m"
			;;
		esac
	done
}

Install() {
	Config
	Delete >/dev/null 2>&1
	InstallInit
	InstallFiles
	"$xray_install_directory/xray.init" start|grep -q FAILED && Error "xray install failed."
	which systemctl && [ -z "$(systemctl --failed|grep -q 'Host is down')" ] && systemctl restart xray &>/dev/null
	echo $echo_e_arg \
		"\033[44;37mxray install success.\033[0;34m
		`
			for opt in $xray_inbounds_options; do
				case $opt in
					1) echo $echo_e_arg "\r	http server(vmess):\033[34G port=${xray_http_port}";;
					2) echo $echo_e_arg "\r	webSocket server(vmess):\033[34G port=${xray_ws_port} path=${xray_ws_path}";;
					3) echo $echo_e_arg "\r	webSocket tls server(vless):\033[34G port=${xray_ws_tls_port} path=${xray_ws_tls_path}";;
					4) echo $echo_e_arg "\r	mKCP server(vmess):\033[34G port=${xray_mkcp_port} type=utp";;
					5) echo $echo_e_arg "\r	mKCP xtls server(vless):\033[34G port=${xray_mkcp_xtls_port} type=none";;
					6) echo $echo_e_arg "\r	tcp xtls server(vless):\033[34G port=${xray_tcp_xtls_port} flow: xtls-rprx-direct";;
				esac
			done
		`
		\r	uuid:\033[35G$uuid
		\r	alterId:\033[35G4
		\r`[ -f /etc/init.d/xray ] && /etc/init.d/xray usage || \"$xray_install_directory/xray.init\" usage`
		`outputVmessLink`\033[0m"
}

Uninstall() {
	if [ -z "$xray_install_directory" ]; then
		echo -n "Please input xray install directory(default is /usr/local/xray): "
		read xray_install_directory
	fi
	Delete &>/dev/null && \
		echo $echo_e_arg "\n\033[44;37mxray uninstall success.\033[0m" || \
		echo $echo_e_arg "\n\033[41;37mxray uninstall failed.\033[0m"
}

#script initialization
ScriptInit() {
	emulate bash 2>/dev/null #zsh emulation mode
	if echo -e ''|grep -q 'e'; then
		echo_e_arg=''
		echo_E_arg=''
	else
		echo_e_arg='-e'
		echo_E_arg='-E'
	fi
}

ScriptInit
echo $*|grep -qi uninstall && Uninstall || Install

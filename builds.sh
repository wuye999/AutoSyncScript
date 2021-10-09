#!/bin/sh
#==========================#
###### Author: CuteBi ######
#==========================#

option() {
	echo -n $echo_opt_e "1. 安装项目\n2. 卸载项目\n请输入选项(默认为1): "
	read install_opt
	echo "$install_opt"|grep -q '2' && task_type='uninstall' || task_type='install'
	echo -n $echo_opt_e "可选项目:
	\r1. tinyproxy
	\r2. cns
	\r3. xray
	\r请选择项目(多个用空格隔开): "
	read build_projects
	echo -n '后台运行吗?(输出保存在builds.out文件)[n]: '
	read daemon_run
}

tinyproxy_set() {
	echo -n '请输入tinyproxy端口: '
	read tinyproxy_port
	echo -n "请输入tinyproxy代理头域(默认为 'Meng'): "
	read tinyproxy_proxy_key
	echo -n '请输入tinyproxy安装目录(默认/usr/local/tinyproxy): '
	read tinyproxy_install_dir
	echo -n "安装UPX压缩版本?[n]: "
	read tinyproxy_UPX
	echo "tinyproxy_UPX"|grep -qi '^y' && tinyproxy_UPX="upx" || tinyproxy_UPX=""
	[ -z "$tinyproxy_install_dir" ] && tinyproxy_install_dir='/usr/local/tinyproxy'
	export tinyproxy_port tinyproxy_proxy_key tinyproxy_install_dir tinyproxy_UPX
}

cns_set() {
	echo -n '请输入cns服务端口(如果不用请留空): '
	read cns_port
	echo -n '请输入cns加密密码(默认不加密): '
	read cns_encrypt_password
	echo -n "请输入cns的udp标识(默认: 'httpUDP'): "
	read cns_udp_flag
	echo -n "请输入cns代理头域(默认: 'Meng'): "
	read cns_proxy_key
	echo -n '请输入tls服务端口(如果不用请留空): '
	read cns_tls_port
	echo -n '请输入cns安装目录(默认/usr/local/cns): '
	read cns_install_dir
	echo -n "安装UPX压缩版本?[n]: "
	read cns_UPX
	echo "$cns_UPX"|grep -qi '^y' && cns_UPX="upx" || cns_UPX=""
	[ -z "$cns_install_dir" ] && cns_install_dir='/usr/local/cns'
	export cns_port cns_encrypt_password cns_udp_flag cns_proxy_key cns_tls_port cns_install_dir cns_UPX
}

xray_set() {
	echo -n "请输入xray安装目录(默认/usr/local/xray): "
	read xray_install_directory
	echo -n "安装UPX压缩版本?[n]: "
	read xray_UPX
	echo "$xray_UPX"|grep -qi '^y' && xray_UPX="upx" || xray_UPX=""
	echo $echo_opt_e "options(tls默认为自签名证书, 如有需要请自行更改):
	\r\t1. tcp_http(vmess)
	\r\t2. WebSocket(vmess)
	\r\t3. WebSocket+tls(vless)
	\r\t4. mkcp(vmess)
	\r\t5. mkcp+tls(vless)
	\r\t6. tcp+xtls(vless)
	\r请输入你的选项(用空格分隔多个选项):"
	read xray_inbounds_options
	for opt in $xray_inbounds_options; do
		case $opt in
			1)
				echo -n "请输入xray http端口: "
				read xray_http_port
			;;
			2)
				echo -n "请输入xray webSocket端口: "
				read xray_ws_port
				echo -n "请输入xray WebSocket请求头的Path(默认为/): "
				read xray_ws_path
				xray_ws_path=${xray_ws_path:-/}
			;;
			3)
				echo -n "请输入xray webSocket tls端口: "
				read xray_ws_tls_port
				echo -n "请输入xray WebSocket请求头的Path(默认为/): "
				read xray_ws_tls_path
				xray_ws_tls_path=${xray_ws_tls_path:-/}
			;;
			4)
				echo -n "请输入xray mKCP端口: "
				read xray_mkcp_port
			;;
			5)
				echo -n "请输入xray mKCP xtls端口: "
				read xray_mkcp_xtls_port
			;;
			6)
				echo -n "请输入xray tcp xtls端口: "
				read xray_tcp_xtls_port
			;;
		esac
	done
	[ -z "$xray_install_directory" ] && xray_install_directory='/usr/local/xray'
	export xray_install_directory xray_UPX xray_inbounds_options xray_http_port xray_ws_port xray_ws_path xray_ws_tls_port xray_ws_tls_path xray_mkcp_port xray_mkcp_xtls_port xray_tcp_xtls_port
}

tinyproxy_task() {
	if $download_tool_cmd tinyproxy.sh https://ghproxy.com/https://raw.githubusercontent.com/wuye999/AutoSyncScript/cns/tinyproxy.sh; then
		chmod 777 tinyproxy.sh
		sed -i "s~#!/bin/bash~#!$SHELL~" tinyproxy.sh
		./tinyproxy.sh $task_type && \
				echo 'tinyproxy任务成功' >>builds.log || \
				echo 'tinyproxy启动失败' >>builds.log
	else
		echo 'tinyproxy脚本下载失败' >>builds.log
	fi
	rm -f tinyproxy.sh
}

cns_task() {
	if $download_tool_cmd cns.sh https://ghproxy.com/https://raw.githubusercontent.com/wuye999/AutoSyncScript/cns/cns.sh; then
		chmod 777 cns.sh
		sed -i "s~#!/bin/bash~#!$SHELL~" cns.sh
		echo $echo_opt_e "n\ny\ny\ny\ny\n"|./cns.sh $task_type && \
				echo 'cns任务成功' >>builds.log || \
				echo 'cns启动失败' >>builds.log
	else
		echo 'cns脚本下载失败' >>builds.log
	fi
	rm -f cns.sh
}

xray_task() {
	if $download_tool_cmd xray.sh https://ghproxy.com/https://raw.githubusercontent.com/wuye999/AutoSyncScript/cns/xray.sh; then
		chmod 777 xray.sh
		sed -i "s~#!/bin/bash~#!$SHELL~" xray.sh
		echo $echo_opt_e "n\ny\ny\ny\ny\n"|./xray.sh $task_type && \
			echo 'xray任务成功' >>builds.log || \
			echo 'xray任务失败' >>builds.log
	else
		echo 'xray脚本下载失败' >>builds.log
	fi
	rm -f xray.sh
}


tinyproxy_uninstall_set() {
	echo -n '请输入tinyproxy安装目录(默认/usr/local/tinyproxy): '
	read tinyproxy_install_dir
	[ -z "$tinyproxy_install_dir" ] && tinyproxy_install_dir='/usr/local/tinyproxy'
	export tinyproxy_install_dir
}

cns_uninstall_set() {
	echo -n '请输入cns安装目录(默认/usr/local/cns): '
	read cns_install_dir
	[ -z "$cns_install_dir" ] && cns_install_dir='/usr/local/cns'
	export cns_install_dir
}

xray_uninstall_set() {
	echo -n "请输入xray安装目录(默认/usr/local/xray): "
	read xray_install_directory
	[ -z "$xray_install_directory" ] && xray_install_directory='/usr/local/xray'
	export xray_install_directory
}

server_install_set() {
	for opt in $*; do
		case $opt in
			1) tinyproxy_set;;
			2) cns_set;;
			3) xray_set;;
			*) exec echo "选项($opt)不正确，请输入正确的选项！";;
		esac
	done
}

server_uninstall_set() {
	for opt in $*; do
		case $opt in
			1) tinyproxy_uninstall_set;;
			2) cns_uninstall_set;;
			3) xray_uninstall_set;;
			*) exec echo "选项($opt)不正确，请输入正确的选项！";;
		esac
	done
}

start_task() {
	for opt in $*; do
		case $opt in
			1) tinyproxy_task;;
			2) cns_task;;
			3) xray_task;;
		esac
		sleep 1
	done
	echo '所有任务完成' >>builds.log
	echo $echo_opt_e "\033[32m`cat builds.log 2>&-`\033[0m"
}

run_tasks() {
	[ "$task_type" != 'uninstall' ] && server_install_set $build_projects || server_uninstall_set $build_projects
	if echo "$daemon_run"|grep -qi 'y'; then
		(`start_task $build_projects &>builds.out` &)
		echo "正在后台运行中......"
	else
		start_task $build_projects
		rm -f builds.log
	fi
}

script_init() {
	emulate bash 2>/dev/null #zsh仿真模式
	echo -e '' | grep -q 'e' && echo_opt_e='' || echo_opt_e='-e' #dash的echo没有-e选项
	PM=`which apt-get || which yum`
	type curl || type wget || $PM -y install curl wget
	type curl && download_tool_cmd='curl -sko' || download_tool_cmd='wget --no-check-certificate -qO'
	rm -f builds.log builds.out
	clear
}

main() {
	script_init
	option
	run_tasks
}

main

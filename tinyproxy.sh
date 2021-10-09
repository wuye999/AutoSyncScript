#!/bin/bash
#==========================#
###### Author: CuteBi ######
#==========================#

#Stop tinyproxy & delete tinyproxy files.
Delete() {
	systemctl disable tinyproxy.service
	rm -f /etc/init.d/tinyproxy /lib/systemd/system/tinyproxy.service
	if [ -f "${tinyproxy_install_dir:=/usr/local/tinyproxy}/tinyproxy.init" ]; then
		"$tinyproxy_install_dir"/tinyproxy.init stop
		rm -rf "$tinyproxy_install_dir"
	fi
}

#Print error message and exit.
Error() {
	echo $echo_e_arg "\033[41;37m$1\033[0m"
	echo -n "remove tinyproxy?[y]: "
	read remove
	echo "$remove"|grep -qi 'n' || Delete
	exit 1
}

#Make tinyproxy start cmd
Config() {
	[ -n "$tinyproxy_install_dir" ] && return  #Variables come from the environment
	echo -n "Please input tinyproxy server port: "
	read tinyproxy_port
	echo -n "Please input tinyproxy proxy key(Default is 'Meng'): "
	read tinyproxy_proxy_key
	echo -n "Please input tinyproxy install directory(difault is /usr/local/tinyproxy): "
	read tinyproxy_install_dir
	echo "${tinyproxy_install_dir:=/usr/local/tinyproxy}"|grep -q '^/' || tinyproxy_install_dir="$PWD/$tinyproxy_install_dir"
	echo -n "Install UPX compress version?[n]: "
	read tinyproxy_UPX
	echo "$tinyproxy_UPX"|grep -qi '^y' && tinyproxy_UPX="upx" || tinyproxy_UPX=""
}

GetAbi() {
	machine=`uname -m`
	#mips[...] use 'le' version
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

#install tinyproxy files
InstallFiles() {
	GetAbi
	mkdir -p "$tinyproxy_install_dir" || Error "Create tinyproxy install directory failed."
	cd "$tinyproxy_install_dir" || exit 1
	$download_tool_cmd tinyproxy http://pros.cutebi.flashproxy.cn:666/tinyproxy/${tinyproxy_UPX}/linux_${machine} || Error "tinyproxy download failed."
	$download_tool_cmd tinyproxy.init http://pros.cutebi.flashproxy.cn:666/tinyproxy/tinyproxy.init || Error "tinyproxy.init download failed."
	sed -i "s~\[tinyproxy_start_cmd\]~$tinyproxy_start_cmd~g" tinyproxy.init
	sed -i "s~\[tinyproxy_install_dir\]~$tinyproxy_install_dir~g" tinyproxy.init
	sed -i "s~\[tinyproxy_tcp_port_list\]~$tinyproxy_port $tinyproxy_tls_port~g" tinyproxy.init
	ln -s "$tinyproxy_install_dir/tinyproxy.init" /etc/init.d/tinyproxy
	cat >tinyproxy.conf <<-EOF
	Port $tinyproxy_port
	Proxy_header "${tinyproxy_proxy_key:-Meng}"
	Timeout 120
	MaxClients 512
	StartServers 3
	Syslog Off
	PidFile "${tinyproxy_install_dir}/run.pid"
	EOF
	chmod -R 777 "$tinyproxy_install_dir" /etc/init.d/tinyproxy
	if which systemctl && [ -z "$(systemctl --failed|grep -q 'Host is down')" ]; then
		$download_tool_cmd /lib/systemd/system/tinyproxy.service http://pros.cutebi.flashproxy.cn:666/tinyproxy/tinyproxy.service || Error "tinyproxy.service download failed."
		chmod 777 /lib/systemd/system/tinyproxy.service
		sed -i "s~\[tinyproxy_install_dir\]~$tinyproxy_install_dir~g"  /lib/systemd/system/tinyproxy.service
		systemctl daemon-reload
	fi
}

#install initialization
InstallInit() {
	echo -n "make a update?[n]: "
	read update
	PM=`which apt-get || which yum`
	echo "$update"|grep -qi 'y' && $PM -y update
	$PM -y install curl wget unzip
	type curl && download_tool_cmd='curl -L -ko' || download_tool_cmd='wget --no-check-certificate -O'
}

Install() {
	Config
	Delete >/dev/null 2>&1
	InstallInit
	InstallFiles
	"${tinyproxy_install_dir}/tinyproxy.init" start|grep -q FAILED && Error "tinyproxy install failed."
	which systemctl && [ -z "$(systemctl --failed|grep -q 'Host is down')" ] && systemctl restart tinyproxy &>/dev/null
	echo $echo_e_arg \
		"\033[44;37mtinyproxy install success.\033[0;34m
		\r	tinyproxy server port:\033[35G${tinyproxy_port}
		\r	tinyproxy proxy key:\033[35G${tinyproxy_proxy_key:-Meng}
		\r`[ -f /etc/init.d/tinyproxy ] && /etc/init.d/tinyproxy usage || \"$tinyproxy_install_dir/tinyproxy.init\" usage`"
}

Uninstall() {
	if [ -z "$tinyproxy_install_dir" ]; then
		echo -n "Please input tinyproxy install directory(default is /usr/local/tinyproxy): "
		read tinyproxy_install_dir
	fi
	Delete >/dev/null 2>&1 && \
		echo $echo_e_arg "\n\033[44;37mtinyproxy uninstall success.\033[0m" || \
		echo $echo_e_arg "\n\033[41;37mtinyproxy uninstall failed.\033[0m"
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

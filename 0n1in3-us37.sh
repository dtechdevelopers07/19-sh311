#!/bin/bash

phpCode=$(cat << 'eof'
	$data="";
	while(false!==($line=fgets(STDIN))){$data.=$line;}
	echo json_encode(array_filter(array_map(function($value){
		if($value!=""){
			$d = explode("\t",$value);
			return [
				"username" => $d[1],
				'connected_at' => $d[7],
				'connected_timestamp' => $d[8],
				'real_ip' => explode(":",$d[2])[0],
				'sent' => $d[5],
				'received' => $d[6]
			];
		}
	},explode("\r\n",$data)));
eof
)

bash << EOF | php -r "$phpCode"
expect <<-eof | grep -e ^CLIENT_LIST
	spawn telnet localhost 7505
	set timeout 10
	expect "OpenVPN Management Interface"
	send "status 3\r"
	expect "END"
	send "exit\r"
eof
EOF

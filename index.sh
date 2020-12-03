#!/bin/bash
# client="$(curl ifconfig.me)"
client="client";
new_client () {
	# Generates the custom client.ovpn
	{
	cat /etc/openvpn/server/client-common.txt
	echo "<ca>"
	cat /etc/openvpn/server/easy-rsa/pki/ca.crt
	echo "</ca>"
	echo "<cert>"
	sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$1".crt
	echo "</cert>"
	echo "<key>"
	cat /etc/openvpn/server/easy-rsa/pki/private/"$1".key
	echo "</key>"
#	echo "<tls-crypt>"
#	sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
#	echo "</tls-crypt>"
	} > /etc/openvpn/client/"$1".ovpn
}
cd /etc/openvpn/server/easy-rsa/

 #Revoke a client
./easyrsa --batch revoke $client
./easyrsa gen-crl >> /dev/null
rm -rf pki/reqs/$client.req
rm -rf pki/private/$client.key
rm -rf pki/issued/$client.crt
rm -rf /etc/openvpn/server/crl.pem
cp /etc/openvpn/server/easy-rsa/pki/crl.pem /etc/openvpn/server/crl.pem

#Add a client
./easyrsa build-client-full $client nopass
# Generates the custom client.ovpn
newclient "$client"

# echo "Content-type: text/file"
# echo "Content-Disposition: attachment; filename=\"$client.ovpn\""
# echo ""
while read c; do
	echo $c
done </etc/openvpn/client/$client.ovpn
exit 0

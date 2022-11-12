function addr --description 'ip address'
	ifconfig | \
	awk '$1 == "inet" && $2 != "127.0.0.1" {print $2}' | \
	cowsay -dn
end

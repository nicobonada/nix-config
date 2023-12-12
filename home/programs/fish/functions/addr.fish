function addr --description 'ip address'
	ip --brief -4 address | \
	awk -v OFS="\t" '$1 != "lo" {print $1,$3}' | \
	cowsay -dn
end

function addr --description 'ip address'
    ip --brief -4 address \
        | awk '$1 != "lo" {print $1,$3}' \
        | column -t -s ' /' \
        | cowsay -dn
end

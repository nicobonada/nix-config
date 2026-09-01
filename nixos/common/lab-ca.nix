{ pkgs, ... }:
{
  # Caddy local CA for *.lab.bonada.ca (public cert only). If lab PKI is
  # recreated, replace ./caddy-lab-root.crt from:
  #   ssh homelab -- docker exec caddy cat /data/caddy/pki/authorities/local/root.crt
  security.pki.certificateFiles = [ ./caddy-lab-root.crt ];

  # Chrome Root Store ignores the system bundle; Brave reads managed policy.
  environment.etc."brave/policies/managed/caddy-lab-ca.json".source =
    pkgs.runCommand "caddy-lab-ca.json"
      {
        nativeBuildInputs = [ pkgs.openssl ];
        cert = ./caddy-lab-root.crt;
      }
      ''
        b64=$(openssl x509 -in "$cert" -outform der | base64 -w0)
        printf '{"CACertificates":["%s"]}\n' "$b64" > "$out"
      '';
}

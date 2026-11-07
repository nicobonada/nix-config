{ pkgs, ... }:
let
  caddyLabCaJson =
    pkgs.runCommand "caddy-lab-ca.json"
      {
        nativeBuildInputs = [ pkgs.openssl ];
        cert = ./caddy-lab-root.crt;
      }
      ''
        b64=$(openssl x509 -in "$cert" -outform der | base64 -w0)
        printf '{"CACertificates":["%s"]}\n' "$b64" > "$out"
      '';
in
{
  # Caddy local CA for *.lab.bonada.ca (public cert only). If lab PKI is
  # recreated, replace ./caddy-lab-root.crt from:
  #   ssh homelab -- docker exec caddy cat /data/caddy/pki/authorities/local/root.crt
  security.pki.certificateFiles = [ ./caddy-lab-root.crt ];

  # Chrome Root Store ignores the system bundle. Helium reads managed
  # policy from /etc/helium and /etc/chromium (same pair as the oxcl
  # flake module).
  environment.etc = {
    "helium/policies/managed/caddy-lab-ca.json".source = caddyLabCaJson;
    "chromium/policies/managed/caddy-lab-ca.json".source = caddyLabCaJson;
  };
}

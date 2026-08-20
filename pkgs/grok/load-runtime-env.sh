# Grok-runtime Environment → this process (MCP env expansion at start).
# Lookup Environments stay out; already-set process env wins.
# Default: GROK_ENV_FILE, else ~/.config/grok/environments/Grok-runtime.env.
# Trilium: TRILIUM_ETAPI_TOKEN_<HOST> → TRILIUM_ETAPI_TOKEN.
_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/grok/environments"
if [ -n "${GROK_ENV_FILE:-}" ]; then
  grok_env_mount="$GROK_ENV_FILE"
else
  grok_env_mount="$_cfg/Grok-runtime.env"
fi
unset _cfg
if [ -e "$grok_env_mount" ]; then
  # One read of the FIFO (1Password materializes once per open).
  while IFS= read -r _line || [ -n "${_line:-}" ]; do
    case "$_line" in
      "" | \#*) continue ;;
    esac
    case "$_line" in
      *=*)
        _key="${_line%%=*}"
        _val="${_line#*=}"
        case "$_key" in
          "" | *[!A-Za-z0-9_]* | [0-9]*) continue ;;
        esac
        if ! printenv "$_key" >/dev/null 2>&1; then
          export "${_key}=${_val}"
        fi
        ;;
    esac
  done <"$grok_env_mount"
  unset _line _key _val
fi
if [ -z "${TRILIUM_ETAPI_TOKEN:-}" ]; then
  _host="$(hostname -s 2>/dev/null || uname -n)"
  _host="${_host%%.*}"
  _want="TRILIUM_ETAPI_TOKEN_$(printf '%s' "$_host" | tr '[:lower:]' '[:upper:]')"
  if [ -n "${!_want:-}" ]; then
    export TRILIUM_ETAPI_TOKEN="${!_want}"
  fi
  unset _host _want
fi

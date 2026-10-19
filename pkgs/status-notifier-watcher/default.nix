{
  writers,
  python3Packages,
}:
# bin/status-notifier-watcher is the path home-manager's
# services.status-notifier-watcher module executes.
writers.writePython3Bin "status-notifier-watcher" { libraries = [ python3Packages.dbus-next ]; } (
  builtins.readFile ./watcher.py
)

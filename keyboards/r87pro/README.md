# Royal Kludge R87 Pro (VIA / QMK)

USB id `342d:e48e`. Host udev bits live in `nixos/common/royal-kludge.nix`.

## Files

| File | What it is |
|------|------------|
| `via-definition.json` | VIA **layout definition** (matrix geometry). Load in VIA if the board is unrecognized: *File → Load Draft Definition*. Does **not** store keycodes. |
| `keymap.json` | Live **dynamic keymap** dump after removing the Mac-mode switch. Restore with `scripts/via-r87 apply`. |
| `keymap-before-no-mac.json` | Snapshot before that change (stock Fn+S → Mac). |

## Win vs Mac on this firmware

Not `AG_SWAP`. Two base layers with different bottom-row mods:

| Layer | Role |
|------:|------|
| 0 | Windows base (`LCTL`, `LGUI`, `LALT`) |
| 1 | Windows Fn (`TG(1)` from the Fn key) |
| 2 | Mac base (`LCTL`, `LALT`, `LGUI` — Alt/Win swapped) |
| 3 | Mac Fn |
| 4 | Extra |

Stock accidental switch: **Fn+S** = `TO(2)` at matrix **L1 (3,2)**.  
Recovery from Mac: **Fn+A** on the Mac Fn layer = `TO(0)` at **L3 (3,1)** (still present).

`keymap.json` sets L1 (3,2) to `KC_TRNS` so Fn+S no longer enters Mac mode.

## CLI

```fish
cd ~/src/nix-config
./scripts/via-r87 find-mac
./scripts/via-r87 get 1 3 2
./scripts/via-r87 set 1 3 2 0x0001    # KC_TRNS
./scripts/via-r87 dump -o /tmp/r87.json
./scripts/via-r87 apply keyboards/r87pro/keymap.json
```

Requires the board on USB and hidraw access (`hardware.keyboard.qmk.enable`).

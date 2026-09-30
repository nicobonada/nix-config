# Royal Kludge R87 Pro (VIA / QMK)

USB id `342d:e48e`. Host udev bits live in `nixos/common/royal-kludge.nix`.

## Files

| File | What it is |
|------|------------|
| `via-definition.json` | VIA **layout definition** (matrix geometry). Load in VIA if the board is unrecognized: *File → Load Draft Definition*. Does **not** store keycodes. |
| `keymap.json` | Live **dynamic keymap**. Fn layer keeps only the light toggle. Restore with `scripts/via-r87 apply`. |
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

The Fn key toggles layer 1 and leaves it on until Fn is pressed again. On that layer, Backspace is the light toggle (`RGB_TOG`). Every other key is `KC_TRNS`, so it types the normal key while the layer is latched.

That removes, from the Fn layer: EEPROM clear (Space), the bootloader layer (O, L, Right Shift), lighting tweaks (Scroll Lock and the arrow keys), NKRO toggle, the media keys, and the old Mac-mode switch. Mac base is still stored on layer 2. Nothing on layer 0 or 1 selects it. Recovery if you are already there: hold Fn and press A (`TO(0)` at L3 (3,1)).

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

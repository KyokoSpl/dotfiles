# Migration Notes: Niri config.kdl → Hyprland main configs

## Keybinds
- Most keybinds were migrated to `keybindings.conf` in the main directory.
- Some Niri-specific actions (e.g., `show-hotkey-overlay`, `overview`, `tabbed`, `switchpresetcolumnwidth`, etc.) do not have direct Hyprland equivalents and may require custom scripts or plugins.
- DMS IPC calls and some exec commands may need adaptation for Hyprland or external tools.
- Mouse/touchpad scroll binds, cooldowns, and some workspace/column/window movement semantics differ between Niri and Hyprland. These were adapted to closest Hyprland actions or omitted if not possible.
- Some binds referencing Niri-specific features (e.g., `niri-cheatsheet`, `niri msg action quit`) may not work in Hyprland and are left as comments or execs for manual review.

## Theming
- Focus ring, border, and gradient settings were migrated to `colors.conf`.
- Hyprland may not support all gradient or border options natively; manual review and adaptation may be needed.
- General theming settings (e.g., `prefer-no-csd`, `screenshot-path`) were added to `general.conf`.

## Window Rules
- All window rules were copied to `rules.conf`.
- Niri's window rule syntax and matching (e.g., `default-column-width`, `open-maximized`, `draw-border-with-background`) may differ from Hyprland's. Manual adaptation may be required for full compatibility.
- Some rules with complex matching (regex, multiple properties) may need to be split or rewritten for Hyprland.

## Not Implemented or Changed
- Mouse/touchpad scroll binds, cooldowns, and touchpad-specific actions were omitted due to lack of direct Hyprland support.
- Some layout, animation, and gesture settings were not migrated (Hyprland uses different config structure).
- Any Niri-specific commands, actions, or features that do not exist in Hyprland were left as comments or require manual scripting.

---

**Review all migrated configs for compatibility and adjust as needed for Hyprland.**

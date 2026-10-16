---
name: lazarus-lcl-ui
description: Design, edit, and debug Lazarus LCL user interfaces, forms, .lfm resources, native controls, event handlers, layout anchoring, scaling, dialogs, menus, actions, timers, localization, and responsive desktop UX. Use whenever a task touches Lazarus forms, visual components, UI behavior, or LCL event-driven code.
---

# Lazarus LCL UI

## Encoding And Resources

For Lazarus forms and dynamically created LCL controls, treat source encoding as part of the resource contract. Before changing captions, hints, dialog text, or `.lfm` resources with Russian text, check whether the file is UTF-8 or Windows-1251 and whether `{$codepage ...}` matches. Do not save through default encodings. A successful compile can still corrupt runtime captions into `????` if the file bytes and directive disagree.

## RecorderLnx Original UI Reference

For RecorderLnx UI, mnemonic, dialog, oscillogram, and trend behavior that should match the original Recorder, do not ask for the original source location. Inspect `D:\works\windev-v3.9\..`, prioritizing `rc_*` and `mr` directories.
## UI Editing Rule

Treat `.lfm` and the matching `.pas` unit as one artifact. Before changing a form, read both files and preserve designer-managed names, component hierarchy, events, and resource syntax.

Prefer editing the `.pas` logic unless the requested change is structural UI layout or component properties.

## Form Design

Build native utility screens, not web pages:
- Keep forms dense, predictable, and keyboard-friendly.
- Use menus/toolbars/actions for repeated commands.
- Use `TActionList` when multiple controls trigger the same command.
- Use modal dialogs for short blocking choices and non-modal forms for workflows.
- Use status bars or log panes for operational feedback.

## Layout

Use LCL layout primitives instead of fixed pixel assumptions when possible:
- Set `Anchors` for controls that resize with the form.
- Use panels/group boxes/splitters for stable regions.
- Keep tab order coherent.
- Avoid text clipping by checking captions, constraints, and autosize behavior.
- Keep minimum form sizes realistic when adding controls.

## Event Handlers

Keep handlers short:
- Validate input.
- Call a service/model method.
- Update UI state.

Avoid putting database, network, parsing, or heavy calculation logic directly in button click handlers. If a handler grows, extract a method with a precise name.

## UI State

Centralize state transitions:
- Enable/disable buttons based on valid state, not scattered guesses.
- Use `try/finally` to restore cursor, enabled controls, and progress state.
- Wrap long operations with `Screen.Cursor := crHourGlass` only when the UI remains responsive; otherwise move work off the main thread.

## Localization

For Russian or multilingual UI, keep source files UTF-8 and avoid hard-coded strings when the project already uses resources, dxgettext, or translation units. Preserve existing localization conventions.

## Debugging LCL Problems

For crashes or freezes:
- Log form lifecycle events: create, show, close, destroy.
- Log selected event entry/exit markers.
- Check re-entrant events caused by programmatic value changes.
- Check timer handlers and background thread callbacks first when symptoms are intermittent.
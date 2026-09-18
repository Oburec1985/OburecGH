# Settings window lags behind pointer while dragging

## Symptom

Moving the RecorderLnx settings window visibly lags behind the mouse pointer.

## Confirmed code path

The selected-channels grid draws an icon in each virtual or inactive tag row.
Before this change, each cell paint created a bitmap, copied from ImageList,
stretched it to the cell, then freed it. Moving the window repeatedly
invalidates and repaints these cells, multiplying the allocations and bitmap
copies by the visible row count.

## Fix and verification

Cache the two icon bitmaps when setting up the ImageList and reuse them in
`fSelectedChannelsGridDrawCell`. Forced build of RecorderLnx in `_buildverify`
succeeded. The runtime drag latency has not yet been measured in a live GUI;
the repaint path is a confirmed cost, while its share of the observed lag
remains to be verified.

## Follow-up: both windows lag with smooth inertia

The user reports the same smooth pointer lag for the main window and settings.
The application has no explicit `WM_MOVE`/`WM_MOVING` handler. Main-form data,
UI and coordinator timers run on the GUI thread; when a modal form is open,
the live page repaint is skipped but queue drain and time display continue.
Lua scripts are invoked synchronously by the GUI data timer, so a costly script
could add latency, but the simple example is not evidence of that.

The local host RecorderLnx process has no top-level window, so its low CPU use
is not a measurement of the lagging GUI. The active VMware VM is Windows 10
(4 vCPU, 4 GB RAM, VMware Tools working, 3D enabled). Its log shows a Vulkan
3D renderer and a separate GDI presentation backend; neither proves the cause.
The Debian/Astra VM is paused. `measure-window-message-latency.ps1` measures
the response to `WM_NULL` for a visible Windows process and is ready for a
reproduction in the same desktop/session as the lagging window. Compare
RecorderLnx with a normal window in the same VM before changing runtime or
VM graphics settings.

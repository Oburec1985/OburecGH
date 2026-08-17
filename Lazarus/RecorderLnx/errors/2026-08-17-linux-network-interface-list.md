# 2026-08-17 - Linux network interface combo shows only automatic mode

## 2026-08-17 Linux broadcast/autosearch follow-up

Symptom: in Linux UI the adapter combo shows only `ens33 [192.168.112.128]`,
while the user expected Wi-Fi too. TCP ping from RecorderLnx to MIC-140
`192.168.14.42:4000` succeeds, but autosearch by broadcast finds no devices.

Confirmed facts:

- SSH to the Linux machine shows only `lo` and `ens33`; no Wi-Fi interface is
  visible inside this OS instance.
- `ens33` has `192.168.112.128/24`, default route via `192.168.112.2`.
- `ip route get 192.168.14.42` routes through `ens33` and gateway
  `192.168.112.2`; MIC-140 is reachable by unicast ping/TCP but is not on the
  guest's local L2 segment.
- Linux `RecorderDiscoverMeraBroadcast` was still a stub that always returned
  an empty list. This made the UI depend on slow fallback probes.
- After implementing Linux UDP discovery, sending to `255.255.255.255`,
  `192.168.112.255`, and hint-derived `192.168.14.255` produced no replies in
  the VM test.
- A directed legacy UDP probe to `192.168.14.42:4001` also timed out, so the
  working path across this VM route is TCP/ICMP unicast, not UDP discovery.

Checked hypotheses:

- **Adapter enumeration misses Wi-Fi because of a code parsing bug:** rejected
  for the current Linux VM. The OS itself exposes only `ens33`; RecorderLnx
  cannot list a host Wi-Fi adapter that is not present in the guest.
- **Wrong selected bind address blocks the socket:** fixed a byte-order bug in
  Linux `IsLocalIPv4`; selected `192.168.112.128` is now accepted as effective.
- **Broadcast code path not implemented on Linux:** confirmed and fixed.
- **MIC-140 does not answer discovery at all:** not proven. Original Recorder
  on the host network answers/found devices; in the Linux VM, UDP discovery
  packets or replies appear blocked by routing/NAT/bridge topology.

Actions:

- Implemented Linux `RecorderDiscoverMeraBroadcast` with modern MebDAQ and
  legacy `MERA:Eth81Srch` UDP request parsing.
- Added discovery hints so the address typed in the TCP-ping field can add a
  directed `/24` broadcast target such as `192.168.14.255`.
- Implemented Linux `RecorderProbeMeraLegacyHost` for exact-host legacy UDP
  probing; it currently times out in the VM test.
- Added UI fallback after empty broadcast: try exact host from the TCP-ping
  field by legacy probe and then by existing TCP protocol probe. This is not a
  network scan and does not require the `Ping` checkbox.

Verification:

- Linux `lazbuild -B RecorderLnx.lpi` completed with `LINUX_BUILD_EXIT=0`.
- Windows build reached link stage, but `RecorderLnx.exe` was already running
  and locked the output file (`error code: 5`); no Pascal compile error was
  reached before linking.

Current conclusion: the code now lists every IPv4 interface visible to Linux
and has a real Linux broadcast implementation. For true fast broadcast of all
MIC devices, the Linux environment must have a network mode where UDP broadcast
to the MIC subnet is delivered, for example a bridged adapter on that LAN. With
the current VM route, use the exact MIC IP in the host field; the UI now falls
back to TCP protocol probing when broadcast is empty.

## 2026-08-17 Manual host must work with Ping disabled

Symptom: with Linux broadcast still not returning devices, entering an explicit
MIC IP in the host field should make autosearch find that exact device even
when the `Ping` checkbox is off, but the UI still reported no useful discovery.

Confirmed cause: the exact-host TCP fallback was guarded by
`lDialog.DeviceCount = 0`. The dialog can already contain live/configured
MIC-185 rows before the manual host fallback runs, so the manually typed MIC-140
address was skipped even though it was the only address the user wanted to
probe.

Action: replaced the `DeviceCount = 0` guard with `not SeenHost(host)`. The
exact host from `edNetworkTestHost` is now probed by legacy UDP and then by TCP
protocol identification whenever that host is not already in the found list.
The broad ARP/TCP scan remains controlled only by the `Ping` checkbox.

Verification: Linux `lazbuild -B RecorderLnx.lpi` completed with
`LINUX_BUILD_EXIT=0`. Windows compile reached link stage but could not overwrite
the running `RecorderLnx.exe` (`error code: 5`).

## Symptom

In the Linux settings dialog the network interface combo box contains only
`Автоматически (метрика ОС)`, so the user cannot choose the adapter used for
hardware discovery/connect.

## Confirmed Facts

- `TRecorderSettingsDialog.LoadFromSettings` fills the combo through
  `RecorderEnumerateLocalIPv4`.
- The Windows path uses `GetAdaptersAddresses` and displays
  `<adapter name> [<IPv4>]`.
- The non-Windows path only tried to resolve `HOSTNAME`; on Linux this often
  returns no useful interface IPv4, so the combo remains with the automatic
  item only.
- Existing `2026-08-11-linux-network-bind.md` fixed invalid saved bind
  addresses, but did not add Linux interface enumeration.

## Checked Hypotheses

- **UI combo disabled:** not supported by the screenshot; the combo is active
  but has no selectable adapter rows.
- **Saved Windows bind hides Linux interfaces:** not the direct cause here.
  Invalid saved bind is already cleared by `SetRecorderNetworkBindAddress`;
  the list itself was empty because enumeration lacked a Linux implementation.

## Fix

Added Linux `SIOCGIFCONF` enumeration in `uRecorderNetworkBinding.pas`.
`RecorderEnumerateLocalIPv4` now adds entries like `eth0 [192.168.x.y]` on
Unix before falling back to hostname lookup. Loopback and link-local addresses
are skipped.

## Verification

- Windows `RecorderLnx.lpi` full rebuild completed with exit code 0.
- A local `-Tlinux` compile was attempted but this Windows FPC installation has
  no Linux RTL (`Can't find unit system`), so the Linux branch still needs an
  Astra/Linux build or UI check.

## 2026-08-17 Linux build error

User reported a Linux build stop at `NetAddrToHost(lSockAddr^.sin_addr)`.
The helper is not available/compatible in that Linux Lazarus environment.

Action: replaced it with `inet_ntoa(lSockAddr^.sin_addr)`, which is already used
elsewhere in `uRecorderNetworkBinding.pas` for socket IPv4 display.

Verification: Windows `RecorderLnx.lpi` rebuild completed with exit code 0.
Linux rebuild should be repeated on the target machine.

## 2026-08-17 Linux build error follow-up

User reported the next Linux build stop at
`inet_ntoa(lSockAddr^.sin_addr)`: that symbol is available in the Windows
WinSock path, but not as a plain Unix symbol in this Lazarus/FPC build.

Rejected hypothesis: plain `inet_ntoa` is portable here because similar calls
exist elsewhere in the unit. Those other active calls are inside Windows-only
branches or use `WinSock2.inet_ntoa`.

Action: changed the Linux `SIOCGIFCONF` enumerator to use the FPC `Sockets`
API directly: `HostAddrToStr(lSockAddr^.sin_addr)`. This removes both the
invalid `NetAddrToHost` conversion and the unavailable plain `inet_ntoa`.

Later hardware/VM verification showed this still had wrong byte order for
kernel `sin_addr`; see the final fix below.

Verification: `rg` confirms the Linux enumerator now has
`lIp := HostAddrToStr(lSockAddr^.sin_addr);`. Windows `RecorderLnx.lpi` full
rebuild completed with exit code 0. Linux rebuild still needs to be repeated
on the target machine because this Windows FPC has no Linux RTL.

## 2026-08-17 SSH access note

User provided the current Linux SSH credentials:

- host alias: `linux`
- user: `user`
- password: `11111111`

Action: added `ssh user@linux` to `Docs/vm_atra_lazarus.md` beside the older
`ssh user@192.168.112.128` VM instruction.

Check from the current Windows execution environment: `ssh user@linux` failed
before authentication because hostname `linux` could not be resolved. Next
attempt should first resolve the host (`ping linux`, `nslookup linux`, hosts
file, or explicit IP from the user/VM) and then run:

```bash
hostname
ip -brief address
ip route
ls -l /sys/class/net
```

## 2026-08-17 Linux adapter inspection and final fix

Connected by SSH to the documented VM address `user@192.168.112.128` with the
provided password. The hostname is `SkripnikPC-Astra-vmWare`.

Observed Linux network state:

- `lo`: `127.0.0.1/8`
- `ens33`: `UP`, `192.168.112.128/24`, MAC `00:0c:29:2b:32:29`
- routes: default gateway `192.168.112.2` via `ens33`; local route
  `192.168.112.0/24` via `ens33`

Confirmed root cause: `SIOCGIFCONF` returned `len=80`, i.e. two Linux `ifreq`
records of 40 bytes. The first implementation used a 32-byte record
(`16-byte name + 16-byte sockaddr`), so it read `lo` correctly, skipped it, and
then read the second entry from the wrong offset instead of `ens33`.

Also confirmed byte order: `HostAddrToStr(sin_addr)` displayed
`128.112.168.192`; for a `sockaddr_in.sin_addr` value from the kernel the
correct helper is `NetAddrToStr`.

Final fix:

- `TRecorderLinuxIfReq` now has an 8-byte padding tail so `SizeOf(...) = 40`
  on x86_64 Linux.
- Linux enumeration now formats the kernel network-order address with
  `NetAddrToStr(lSockAddr^.sin_addr)`.

Verification:

- Windows `RecorderLnx.lpi` full rebuild completed with exit code 0.
- Linux `lazbuild --pcp=/home/user/.lazarus_work -B RecorderLnx.lpi` completed
  with `LINUX_BUILD_EXIT=0`.
- A temporary Linux test program using real
  `uRecorderNetworkBinding.RecorderEnumerateLocalIPv4` returned:
  `Автоматически (метрика ОС)` and `ens33 [192.168.112.128]`.

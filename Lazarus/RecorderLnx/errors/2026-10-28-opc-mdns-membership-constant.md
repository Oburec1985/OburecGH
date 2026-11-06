# OPC UA mDNS subscription error on Windows — 2026-10-28

## Symptom

Clicking the OPC UA server-search button reports that subscribing to mDNS
multicast failed.

## Confirmed cause

`RecorderOpcUaDiscoverMdns` called `setsockopt(IPPROTO_IP,
IP_ADD_MEMBERSHIP, ...)` with the shared numeric value `3` on all targets.
That is not `IP_ADD_MEMBERSHIP` on Windows or Linux.

An FPC 3.2.2 Win64 probe used the same Winsock socket creation, reuse option,
bind to UDP 5353, multicast group and 8-byte membership structure as the
application:

- option 3 returned `WSAEINVAL (10022)`;
- option 5 (legacy value declared by FPC's `WinSock2`) returned
  `WSAENOPROTOOPT (10042)`;
- option 12 succeeded and joined the group.

The Windows 10 SDK `shared/ws2ipdef.h` defines modern Winsock2
`IP_ADD_MEMBERSHIP` as 12. FPC's Linux socket header defines it as 35. The
project's previous shared value 3 was wrong on both supported targets.

## Fix

- Define the named `CRecorderOpcUaIpAddMembership` per platform: 12 for modern
  Winsock2 and 35 for Linux; other Unix targets use 12.
- Include `WSAGetLastError` in the Windows diagnostic if joining the group
  fails.
- Update the mirrored OPC UA source files and add a platform-specific socket
  option verification rule to `device-lifecycle-programming`.

## Verification

- Exact standalone FPC/Winsock probe before fix: reproduced option 3 failure.
- Variant probe: option 5 failed, option 12 succeeded.
- Post-fix FPC probe imported `CRecorderOpcUaIpAddMembership` from
  `uRecorderOpcUaTypes`; the configured value 12 joined successfully.
- The actual `RecorderOpcUaDiscoverMdns` function no longer reported a
  multicast subscription error. It returned “OPC UA servers not found” because
  no `_opcua-tcp._tcp.local` announcement was observed during the 1 s search.
- Official/primary definitions checked in Windows SDK `ws2ipdef.h` and FPC
  Linux `unxsockh.inc`.
- Forced Win64 application build: passed, 236,596 lines compiled, exit 0.
- mDNS response from a real OPC UA advertiser: not observed in this probe.
- Linux build/runtime probe: not run; this Windows FPC installation has no Linux
  RTL/FCL target units.

## Sources

- [Microsoft Winsock IPPROTO_IP socket options](https://learn.microsoft.com/en-us/windows/win32/winsock/ipproto-ip-socket-options)
- [Linux IP socket options](https://man7.org/linux/man-pages/man7/ip.7.html)

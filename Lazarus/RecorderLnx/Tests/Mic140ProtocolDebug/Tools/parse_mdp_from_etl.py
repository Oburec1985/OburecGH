#!/usr/bin/env python3
"""Extract MDP frames (sync 0x12B8) from netsh ETL or raw TCP dump bytes."""

import struct
import sys
from pathlib import Path

SYNC = 0x12B8
BIOS_HDR = 10
NUM_BUFF_IDX = 8


def parse_frames(data: bytes, max_frames: int = 200):
    frames = []
    i = 0
    n = len(data)
    while i + 8 <= n and len(frames) < max_frames:
        if struct.unpack_from("<H", data, i)[0] != SYNC:
            i += 1
            continue
        if i + 8 > n:
            break
        port, size, hcs = struct.unpack_from("<HHH", data, i + 2)
        calc_hcs = (SYNC + port + size) & 0xFFFF
        need = 8 + size * 2 + 2
        if need > 65536 or i + need > n:
            i += 1
            continue
        payload = data[i + 8 : i + 8 + size * 2]
        dcs = struct.unpack_from("<H", data, i + 8 + size * 2)[0]
        calc_dcs = sum(struct.unpack(f"<{size}H", payload)) & 0xFFFF if size else 0
        if hcs != calc_hcs:
            i += 1
            continue
        if dcs != calc_dcs:
            i += 1
            continue
        frames.append(
            {
                "offset": i,
                "port": port,
                "size_words": size,
                "payload": payload,
                "hcs_ok": True,
                "dcs_ok": True,
            }
        )
        i += need
    return frames


def signed_words(payload: bytes, start_word: int, count: int):
    out = []
    for w in range(start_word, start_word + count):
        off = w * 2
        if off + 2 > len(payload):
            break
        out.append(struct.unpack_from("<h", payload, off)[0])
    return out


def describe_stream_frame(payload: bytes):
    if len(payload) < BIOS_HDR * 2:
        return None
    hdr = struct.unpack_from("<10H", payload, 0)
    data_words = (len(payload) // 2) - BIOS_HDR
    nb = hdr[NUM_BUFF_IDX]
    info = {
        "bios_type": hdr[0],
        "msg_size": hdr[1],
        "scan_id": hdr[2],
        "slot": hdr[3],
        "chan": hdr[4],
        "num_buff": nb,
        "state": hdr[9],
        "data_words": data_words,
    }
    for stride in (48, 51, 60, 106, 112):
        if data_words > 0 and data_words % stride == 0:
            info["stride_candidate"] = stride
            info["samples"] = data_words // stride
            break
    else:
        info["stride_candidate"] = None
        info["samples"] = 0
    stride = info.get("stride_candidate") or 48
    if stride and info["samples"]:
        info["ain48"] = signed_words(payload, BIOS_HDR, min(48, stride))
        if stride >= 51:
            info["tin3"] = signed_words(payload, BIOS_HDR + 48, 3)
    return info


def export_reference(frames, out_path: Path, last_n: int = 10):
    port0 = [f for f in frames if f["port"] == 0]
    if not port0:
        return
    sample = port0[-last_n:]
    sums = [0] * 48
    tin_sums = [0] * 3
    tin_n = 0
    n = 0
    for f in sample:
        info = describe_stream_frame(f["payload"])
        if not info or not info.get("ain48"):
            continue
        row = info["ain48"]
        for i in range(min(48, len(row))):
            sums[i] += row[i]
        if info.get("tin3"):
            for i in range(3):
                tin_sums[i] += info["tin3"][i]
            tin_n += 1
        n += 1
    if n == 0:
        return
    lines = [
        "# MIC-140 ADC reference — exported from Recorder MDP capture",
        f"# frames averaged: last {n} PORT=0 stream packets",
        "# tolerance stand: ±50 codes",
        "#",
        "# KIND  N  CODE",
        "",
    ]
    for i in range(48):
        lines.append(f"AIN {i + 1} {round(sums[i] / n)}")
    if tin_n:
        for i in range(3):
            lines.append(f"TIN {i + 1} {round(tin_sums[i] / tin_n)}")
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {out_path} from {n} frames")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--export-reference":
        etl = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(
            r"D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug\Data\captures"
            r"\netsh_192.168.14.155_20260701_123631.etl"
        )
        ref_out = Path(sys.argv[3]) if len(sys.argv) > 3 else Path(
            r"D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug\Data"
        ) / "mic140_adc_reference.txt"
        export_reference(parse_frames(etl.read_bytes()), ref_out)
        return

    etl = Path(
        r"D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug\Data\captures"
        r"\netsh_192.168.14.155_20260701_123631.etl"
    )
    out = etl.parent / "recorder_mdp_reference.txt"
    if len(sys.argv) > 1:
        etl = Path(sys.argv[1])
    data = etl.read_bytes()
    frames = parse_frames(data)
    port0 = [f for f in frames if f["port"] == 0]
    port1 = [f for f in frames if f["port"] == 1]

    lines = [
        f"# MDP frames extracted from {etl.name}",
        f"# total_valid_mdp={len(frames)} port0={len(port0)} port1={len(port1)}",
        "",
    ]

  # size histogram port0
    sizes = {}
    for f in port0:
        sizes[f["size_words"]] = sizes.get(f["size_words"], 0) + 1
    lines.append("# PORT=0 message size (words) histogram:")
    for k in sorted(sizes):
        lines.append(f"#   size={k} count={sizes[k]}")
    lines.append("")

    shown = 0
    for f in port0:
        info = describe_stream_frame(f["payload"])
        if not info or info["data_words"] < 48:
            continue
        stride = info.get("stride_candidate") or "?"
        lines.append(
            f"FRAME nb={info['num_buff']} msgWords={info['msg_size']} "
            f"dataWords={info['data_words']} stride={stride} samples={info['samples']} "
            f"state={info['state']}"
        )
        if info.get("ain48"):
            lines.append("  AIn01-12: " + ",".join(str(x) for x in info["ain48"][:12]))
            lines.append("  AIn25-27: " + ",".join(str(x) for x in info["ain48"][24:27]))
        if info.get("tin3"):
            lines.append("  TIn1-3: " + ",".join(str(x) for x in info["tin3"]))
        lines.append("")
        shown += 1
        if shown >= 15:
            break

    # command port samples
    lines.append("# PORT=1 command frames (first 10):")
    for f in port1[:10]:
        words = struct.unpack(f"<{f['size_words']}H", f["payload"]) if f["size_words"] else ()
        lines.append(f"  CMD size={f['size_words']} words={[hex(w) for w in words[:8]]}")

    ctrl = etl.parent / "recorder_mdp_control_examples.txt"
    # append compact cross-check block
    if port0:
        f0 = port0[0]
        info0 = describe_stream_frame(f0["payload"])
        lines.append("")
        lines.append("# CONTROL BLOCK for mic140_adc_reference.txt (tol ±50):")
        if info0 and info0.get("ain48"):
            ref_path = etl.parent.parent / "mic140_adc_reference.txt"
            ref = {}
            if ref_path.is_file():
                for ln in ref_path.read_text(encoding="utf-8").splitlines():
                    parts = ln.split()
                    if len(parts) >= 3 and parts[0] in ("AIN", "TIN"):
                        ref[f"{parts[0]}{parts[1]}"] = int(parts[2])
            for label, idx, rk in [
                ("AIN01", 0, "AIN1"),
                ("AIN25", 24, "AIN25"),
                ("TIN01", None, "TIN1"),
            ]:
                if label.startswith("TIN"):
                    val = info0["tin3"][0] if info0.get("tin3") else None
                else:
                    val = info0["ain48"][idx]
                if val is not None and rk in ref:
                    rv = ref[rk]
                    lines.append(f"#   {rk}: rec={val} ref={rv} delta={val - rv}")

    out.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {out} ({shown} stream frames detailed)")
    print(f"See also {ctrl}")


if __name__ == "__main__":
    main()

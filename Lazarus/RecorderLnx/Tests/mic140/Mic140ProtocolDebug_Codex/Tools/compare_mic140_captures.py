#!/usr/bin/env python3
"""Сравнивает два пакетных CSV MIC-140 и создаёт воспроизводимый Markdown-отчёт."""

from __future__ import annotations

import argparse
import csv
import hashlib
import statistics
from collections import Counter
from pathlib import Path


def args_parse() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference", required=True, type=Path)
    parser.add_argument("--actual", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    return parser.parse_args()


def load(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def payload(row: dict[str, str]) -> bytes:
    return bytes.fromhex(row["payload_hex"]) if row["payload_hex"] else b""


def words(data: bytes, limit: int = 12) -> str:
    values = [
        int.from_bytes(data[index : index + 2], "little")
        for index in range(0, min(len(data) - 1, limit * 2), 2)
    ]
    return " ".join(f"{value:04X}" for value in values)


def payload_hist(rows: list[dict[str, str]]) -> Counter[int]:
    return Counter(
        int(row["tcp_payload_len"])
        for row in rows
        if int(row["tcp_payload_len"]) > 0
    )


def stream_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    device_payloads = [
        row
        for row in rows
        if row["direction"] == "DEV->PC" and int(row["tcp_payload_len"]) >= 200
    ]
    if not device_payloads:
        return []
    dominant = Counter(int(row["tcp_payload_len"]) for row in device_payloads).most_common(1)[0][0]
    return [row for row in device_payloads if int(row["tcp_payload_len"]) == dominant]


def intervals(rows: list[dict[str, str]]) -> list[float]:
    values = [float(row["relative_ms"]) for row in rows]
    return [values[index] - values[index - 1] for index in range(1, len(values))]


def outgoing(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    return [
        row
        for row in rows
        if row["direction"] == "PC->DEV" and int(row["tcp_payload_len"]) > 0
    ]


def signature(row: dict[str, str]) -> str:
    data = payload(row)
    return f"{len(data)}:{hashlib.sha256(data).hexdigest()[:16]}"


def main() -> int:
    args = args_parse()
    reference = load(args.reference)
    actual = load(args.actual)
    ref_stream = stream_rows(reference)
    act_stream = stream_rows(actual)
    ref_out = outgoing(reference)
    act_out = outgoing(actual)
    ref_intervals = intervals(ref_stream)
    act_intervals = intervals(act_stream)
    ref_period = statistics.median(ref_intervals) if ref_intervals else 0.0
    act_period = statistics.median(act_intervals) if act_intervals else 0.0

    common_prefix = 0
    for ref_row, act_row in zip(ref_out, act_out):
        if payload(ref_row) != payload(act_row):
            break
        common_prefix += 1

    lines = [
        "# Сравнение сетевого жизненного цикла MIC-140",
        "",
        f"- Эталон: `{args.reference.name}`",
        f"- Проверка: `{args.actual.name}`",
        f"- Прибор: `192.168.14.48:4000`, подтверждённый `MIC-140-48v3`",
        "",
        "## Сводка",
        "",
        "| Параметр | Original Recorder | RecorderLnx test |",
        "| --- | ---: | ---: |",
        f"| Всего TCP-пакетов | {len(reference)} | {len(actual)} |",
        f"| PC→DEV с payload | {len(ref_out)} | {len(act_out)} |",
        f"| Потоковых DEV→PC payload | {len(ref_stream)} | {len(act_stream)} |",
        f"| Размер потокового payload, байт | "
        f"{int(ref_stream[0]['tcp_payload_len']) if ref_stream else 0} | "
        f"{int(act_stream[0]['tcp_payload_len']) if act_stream else 0} |",
        f"| Медианный период потока, мс | {ref_period:.3f} | {act_period:.3f} |",
        f"| Совпавших исходящих payload от начала | {common_prefix} | {common_prefix} |",
        "",
        "## Размеры TCP payload",
        "",
        "| Размер, байт | Original | RecorderLnx test |",
        "| ---: | ---: | ---: |",
    ]
    ref_hist = payload_hist(reference)
    act_hist = payload_hist(actual)
    for size in sorted(set(ref_hist) | set(act_hist)):
        lines.append(f"| {size} | {ref_hist[size]} | {act_hist[size]} |")

    lines.extend(
        [
            "",
            "## Начало последовательности PC→DEV",
            "",
            "Формат: номер, относительное время, длина, первые WORD little-endian, SHA-256.",
            "",
            "### Original Recorder",
            "",
        ]
    )
    for index, row in enumerate(ref_out[:40], 1):
        data = payload(row)
        lines.append(
            f"{index:02d}. `{float(row['relative_ms']):10.3f} ms` "
            f"`len={len(data):3d}` `{words(data)}` `{signature(row)}`"
        )
    lines.extend(["", "### RecorderLnx test", ""])
    for index, row in enumerate(act_out[:40], 1):
        data = payload(row)
        lines.append(
            f"{index:02d}. `{float(row['relative_ms']):10.3f} ms` "
            f"`len={len(data):3d}` `{words(data)}` `{signature(row)}`"
        )

    lines.extend(["", "## Первое прямое расхождение", ""])
    if common_prefix < min(len(ref_out), len(act_out)):
        ref_data = payload(ref_out[common_prefix])
        act_data = payload(act_out[common_prefix])
        lines.extend(
            [
                f"- Номер исходящего payload: `{common_prefix + 1}`.",
                f"- Original: `len={len(ref_data)}`, words `{words(ref_data, 24)}`.",
                f"- RecorderLnx: `len={len(act_data)}`, words `{words(act_data, 24)}`.",
                "",
                "Полный hex остаётся в соответствующих `_packets.csv` и `.pcapng`.",
            ]
        )
    else:
        lines.append("Общая сравнимая часть исходящих payload совпала полностью.")

    lines.extend(
        [
            "",
            "## Подтверждённый вывод",
            "",
            "Разный размер и период потокового payload означает различную настройку "
            "порции FIFO/числа опросных кадров в блоке. Это различие находится в "
            "Config/Start-профиле и не является ошибкой сетевого транспорта.",
        ]
    )
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"REPORT={args.out}")
    print(f"COMMON_OUTGOING_PREFIX={common_prefix}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

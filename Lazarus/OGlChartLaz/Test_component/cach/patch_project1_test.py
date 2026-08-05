# -*- coding: utf-8 -*-
import io

file_path = "project1.lpr"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

content = content.replace("\r\n", "\n").replace("\r", "\n")

target_uses = """  uOglChartVertexEditListener, Unit1;"""
replacement_uses = """  uOglChartVertexEditListener, Unit1, uOglChartCursorTest;"""

if target_uses in content:
    content = content.replace(target_uses, replacement_uses)
    print("project1.lpr uses clause updated.")
else:
    print("Error: project1.lpr target_uses not found")

target_call = """  try
    RequireDerivedFormResource:=True;"""

replacement_call = """  try
    RunCursorTests;
    RequireDerivedFormResource:=True;"""

if target_call in content:
    content = content.replace(target_call, replacement_call)
    print("project1.lpr test call added.")
else:
    print("Error: project1.lpr target_call not found")

content = content.replace("\n", "\r\n")

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Done.")

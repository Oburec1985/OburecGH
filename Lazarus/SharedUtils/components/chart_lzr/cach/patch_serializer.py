# -*- coding: utf-8 -*-
import io

file_path = "uOglChartSerializer.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Normalize
content = content.replace("\r\n", "\n").replace("\r", "\n")

target_uses = "uOglChartLog, uOglChartPage, uOglChartAxis, uOglChartTrend, uOglChartTextLabel;"
replacement_uses = "uOglChartLog, uOglChartPage, uOglChartAxis, uOglChartTrend, uOglChartTextLabel, uOglChartCursor;"

target_branch = """        else if SameText(lTypeStr, 'TChartTextLabel') then
          lChild := TChartTextLabel.Create
        else if SameText(lTypeStr, 'TChartFlagLabel') then
          lChild := TChartFlagLabel.Create;"""

replacement_branch = """        else if SameText(lTypeStr, 'TChartTextLabel') then
          lChild := TChartTextLabel.Create
        else if SameText(lTypeStr, 'TChartFlagLabel') then
          lChild := TChartFlagLabel.Create
        else if SameText(lTypeStr, 'TChartCursor') then
          lChild := TChartCursor.Create;"""

if target_uses in content and target_branch in content:
    content = content.replace(target_uses, replacement_uses)
    content = content.replace(target_branch, replacement_branch)
    print("Serializer patch matches found and applied!")
else:
    print("Error: Serializer targets not found!")
    if target_uses not in content:
        print("  - target_uses not found")
    if target_branch not in content:
        print("  - target_branch not found")

content = content.replace("\n", "\r\n")

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Done.")

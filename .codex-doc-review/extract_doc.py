from pathlib import Path
from zipfile import ZipFile

from lxml import etree


DOCX = Path(r"D:\works\clients\воздуходувка\Приложение_1.docx")
NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "m": "http://schemas.openxmlformats.org/officeDocument/2006/math",
}


def local_name(element):
    return etree.QName(element).localname


def text_content(element):
    values = []
    for child in element.iter():
        if local_name(child) == "t" and child.text:
            values.append(child.text)
    return "".join(values).strip()


with ZipFile(DOCX) as archive:
    root = etree.fromstring(archive.read("word/document.xml"))

for index, paragraph in enumerate(root.xpath(".//w:body/w:p", namespaces=NS)):
    content = text_content(paragraph)
    equations = [text_content(eq) for eq in paragraph.xpath(".//m:oMath", namespaces=NS)]
    drawings = len(paragraph.xpath(".//w:drawing", namespaces=NS))
    if content or drawings:
        print(f"P{index:03d}: {content}")
        if equations:
            for equation_index, equation in enumerate(equations, start=1):
                print(f"  EQ{equation_index}: {equation}")
        if drawings:
            print(f"  DRAWINGS: {drawings}")

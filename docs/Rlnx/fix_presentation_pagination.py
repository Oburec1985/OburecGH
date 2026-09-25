from pathlib import Path

from docx import Document


DOCX_PATH = Path(r"D:\works\OburecGH\docs\Rlnx\Презентация Rlnx\Сценарий презентации Rlnx.docx")
TEMP_PATH = DOCX_PATH.with_name(DOCX_PATH.stem + ".pagination.docx")


def delete_paragraph(paragraph) -> None:
    element = paragraph._element
    element.getparent().remove(element)
    paragraph._p = paragraph._element = None


document = Document(DOCX_PATH)

for paragraph in list(document.paragraphs):
    if paragraph.text.startswith("7."):
        paragraph.text = "7. Платформа растёт вместе с методикой"
        paragraph.style = "Heading 1"
    elif paragraph.text.startswith("•  LuaCalcPlugin"):
        paragraph.text = (
            "•  LuaCalcPlugin для пользовательских формул и сценариев, "
            "включая чтение и изменение уставок тегов;"
        )
        paragraph.style = "Feature bullet"
    elif paragraph.text.startswith("•  Lua API для чтения и изменения уставок"):
        delete_paragraph(paragraph)

document.save(TEMP_PATH)
TEMP_PATH.replace(DOCX_PATH)


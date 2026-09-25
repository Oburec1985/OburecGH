from __future__ import annotations

import copy
import shutil
import tempfile
import zipfile
from pathlib import Path

from lxml import etree


ROOT = Path(r"D:\works\OburecGH\docs\Rlnx\РП на ПО")
SOURCE = ROOT / "БЛИЖ.409801.100.236-01 34_v01.docx"
OUTPUT = ROOT / "БЛИЖ.409801.100.236-01 34_v02.docx"

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
NS = {"w": W}
qn = lambda name: f"{{{W}}}{name}"


def text_of(element):
    return "".join(element.xpath(".//w:t/text()", namespaces=NS)).strip()


def replace_paragraph_text(paragraph, text, field=None, suffix=None):
    ppr = paragraph.find(qn("pPr"))
    sample_rpr = paragraph.find(".//" + qn("rPr"))
    for child in list(paragraph):
        if child is not ppr:
            paragraph.remove(child)
    if field:
        r1 = etree.SubElement(paragraph, qn("r"))
        etree.SubElement(r1, qn("fldChar")).set(qn("fldCharType"), "begin")
        r2 = etree.SubElement(paragraph, qn("r"))
        instr = etree.SubElement(r2, qn("instrText"))
        instr.set("{http://www.w3.org/XML/1998/namespace}space", "preserve")
        instr.text = field
        r3 = etree.SubElement(paragraph, qn("r"))
        etree.SubElement(r3, qn("fldChar")).set(qn("fldCharType"), "separate")
        r4 = etree.SubElement(paragraph, qn("r"))
        t = etree.SubElement(r4, qn("t"))
        t.text = text
        r5 = etree.SubElement(paragraph, qn("r"))
        etree.SubElement(r5, qn("fldChar")).set(qn("fldCharType"), "end")
        if suffix:
            r6 = etree.SubElement(paragraph, qn("r"))
            t6 = etree.SubElement(r6, qn("t"))
            t6.set("{http://www.w3.org/XML/1998/namespace}space", "preserve")
            t6.text = suffix
        return
    run = etree.SubElement(paragraph, qn("r"))
    if sample_rpr is not None:
        run.append(copy.deepcopy(sample_rpr))
    t = etree.SubElement(run, qn("t"))
    if text.startswith(" ") or text.endswith(" "):
        t.set("{http://www.w3.org/XML/1998/namespace}space", "preserve")
    t.text = text


def clone_paragraph(sample, text, outline_level=None):
    p = copy.deepcopy(sample)
    replace_paragraph_text(p, text)
    if outline_level is not None:
        ppr = p.find(qn("pPr"))
        if ppr is None:
            ppr = etree.Element(qn("pPr"))
            p.insert(0, ppr)
        old = ppr.find(qn("outlineLvl"))
        if old is not None:
            ppr.remove(old)
        etree.SubElement(ppr, qn("outlineLvl")).set(qn("val"), str(outline_level))
    return p


def rebuild_cell(cell, text, paragraph_sample):
    tcpr = cell.find(qn("tcPr"))
    for child in list(cell):
        if child is not tcpr:
            cell.remove(child)
    cell.append(clone_paragraph(paragraph_sample, text))


def make_table(sample_table, rows, paragraph_sample):
    tbl = copy.deepcopy(sample_table)
    old_rows = tbl.findall(qn("tr"))
    header_template = copy.deepcopy(old_rows[0])
    body_template = copy.deepcopy(old_rows[1] if len(old_rows) > 1 else old_rows[0])
    for row in old_rows:
        tbl.remove(row)
    for index, values in enumerate(rows):
        tr = copy.deepcopy(header_template if index == 0 else body_template)
        cells = tr.findall(qn("tc"))
        if len(cells) != len(values):
            raise ValueError(f"Table expects {len(cells)} columns, got {len(values)}")
        for cell, value in zip(cells, values):
            rebuild_cell(cell, value, paragraph_sample)
        tbl.append(tr)
    return tbl


def main():
    with tempfile.TemporaryDirectory(prefix="rp_v02_") as tmp_name:
        tmp = Path(tmp_name)
        with zipfile.ZipFile(SOURCE, "r") as zin:
            zin.extractall(tmp)

        doc_path = tmp / "word" / "document.xml"
        tree = etree.parse(str(doc_path))
        body = tree.getroot().find("w:body", NS)
        children = list(body)
        paragraphs = [x for x in children if x.tag == qn("p")]
        tables = [x for x in children if x.tag == qn("tbl")]

        # Title page: keep all geometry and direct formatting, replace text only.
        replace_paragraph_text(paragraphs[12], "ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ")
        replace_paragraph_text(paragraphs[13], "«RLNX, RCPANEL И HOSTAGENT ДЛЯ СИСТЕМ СТТ И ВКУ»")
        replace_paragraph_text(paragraphs[15], "Руководство оператора")
        replace_paragraph_text(paragraphs[17], "1", field=" NUMPAGES \\* MERGEFORMAT ", suffix=" листов")

        sample_h1 = paragraphs[20]
        sample_h2 = paragraphs[34]
        sample_normal = paragraphs[21]
        sample_body = paragraphs[35]
        sample_bullet = paragraphs[56]
        sample_caption = paragraphs[94]

        terms = [
            ("Аппаратный канал", "Канал источника данных, связанный с физическим входом измерительного прибора."),
            ("Градуировочная характеристика", "Зависимость, преобразующая код или сигнал канала в значение физической величины."),
            ("Измерительный проект", "Сохраняемый набор приборов, каналов, тегов, градуировок, форм отображения и параметров записи."),
            ("Тег", "Именованный канал данных Rlnx, который может иметь единицу измерения, диапазон, уставки, оценки и правила записи."),
            ("Сеанс записи", "Интервал от перехода Rlnx в Record до перехода в Stop, в течение которого формируются файлы и события записи."),
        ]
        abbreviations = [
            ("АРМ", "автоматизированное рабочее место"),
            ("БД", "база данных"),
            ("ВКУ", "система вибрационного контроля установки"),
            ("ГХ", "градуировочная характеристика"),
            ("КИП", "компьютер измерительного поста"),
            ("НДС", "напряжённо-деформированное состояние"),
            ("ПО", "программное обеспечение"),
            ("СПО", "специальное программное обеспечение"),
            ("СТТ", "система тензо-термометрирования"),
            ("Rlnx", "модуль RecorderLnx"),
            ("RCPanel", "модуль RecorderCoordinator"),
            ("HostAgent", "модуль RecorderHostAgent"),
        ]

        items = []
        def h1(t): items.append(("h1", t))
        def h2(t): items.append(("h2", t))
        def p(t): items.append(("p", t))
        def b(t): items.append(("b", t))
        def cap(t): items.append(("cap", t))
        def table2(rows): items.append(("table2", rows))
        def table3(rows): items.append(("table3", rows))

        h1("Введение")
        p("Настоящее руководство оператора распространяется на специальное программное обеспечение в составе модулей Rlnx, RCPanel и HostAgent. Комплект ПО предназначен для обеспечения работы двух прикладных систем: СТТ и ВКУ.")
        p("В системе СТТ ПО применяется для сбора, регистрации и отображения деформаций и температур, расчёта производных величин и оценки НДС. В системе ВКУ ПО применяется для цифровой записи сигналов виброускорения, фильтрации, интегрирования, спектрального анализа и построения трендов.")
        p("В руководстве приведены условия выполнения, состав и назначение модулей, порядок подготовки, пуска, записи, останова и завершения работы, а также связь функций ПО с требованиями ТЗ на системы СТТ и ВКУ.")

        h1("Термины и определения")
        table2([("Термин", "Определение"), *terms])
        h1("Обозначения и сокращения")
        table2([("Сокращение", "Расшифровка"), *abbreviations])

        h1("1 Назначение СПО СТТ и ВКУ")
        p("СПО представляет собой набор стандартизированных программных модулей для сбора, обработки, отображения, регистрации, хранения и выдачи измерительной информации, а также для централизованного контроля измерительных постов.")
        p("Один комплект ПО применяется в обеих системах. Различие задач СТТ и ВКУ учитывается составом приборов, типами каналов, частотами опроса, градуировками, набором расчётов, формами отображения и правилами архивирования в измерительном проекте.")

        h1("2 Условия выполнения СПО СТТ и ВКУ")
        h2("2.1 Требования к техническим и системным средствам")
        p("СПО предназначено для работы в среде Astra Linux Special Edition. Конкретная редакция операционной системы и состав пакетов задаются эксплуатационной конфигурацией объекта. Пользовательский интерфейс модулей русскоязычный.")
        b("На КИП должны быть доступны: сетевой интерфейс для связи с приборами и модулями, рабочий каталог проекта, каталог записи с достаточным свободным местом, клавиатура, мышь и дисплей, позволяющий одновременно контролировать необходимые формы и графики.")
        p("Для сетевой работы по умолчанию используются TCP 8765 для RCPanel, TCP 8766 для HostAgent, UDP 38765 и 38766 для автообнаружения, а также UDP 9 для Wake-on-LAN. Используемые порты должны быть разрешены межсетевым экраном и сетевой инфраструктурой.")
        h2("2.2 Установка СПО")
        p("Установка выполняется из штатного дистрибутива. На каждом КИП устанавливаются Rlnx и HostAgent. RCPanel устанавливается на АРМ централизованного управления. Допускается совмещение модулей на одном компьютере, если это предусмотрено схемой системы.")
        b("После установки необходимо проверить запуск Rlnx, автозапуск HostAgent, доступность RCPanel, права на каталоги проекта и записи, а также доступность измерительных приборов.")
        p("Параметры сетевого доступа, пути к файлам, токены и разрешение выключения компьютера задаются в конфигурационных файлах. Секреты не должны включаться в проекты измерений и передаваться через UDP-обнаружение.")
        h2("2.3 Состав СПО")
        table3([
            ("Модуль", "Размещение", "Основная роль"),
            ("Rlnx (RecorderLnx)", "КИП или локальное АРМ", "Сбор, обработка, отображение и регистрация измерительных данных."),
            ("RCPanel (RecorderCoordinator)", "АРМ оператора", "Централизованное наблюдение и координация нескольких экземпляров Rlnx."),
            ("HostAgent (RecorderHostAgent)", "Каждый управляемый КИП", "Проверка доступности, запуск Rlnx и разрешённое выключение ОС."),
        ])
        h2("2.4 Назначение модулей СПО")
        h2("2.4.1 Модуль Rlnx")
        p("Rlnx является основным исполнительным модулем. Он настраивает приборы и каналы, формирует теги, применяет ГХ и расчёты, отображает текущие значения, осциллограммы, тренды и спектры, регистрирует данны в файлы и при настроенной подсистеме передаёт оценки в SQL БД.")
        h2("2.4.2 Модуль RCPanel")
        p("RCPanel показывает доступность и режимы Rlnx, передаёт команды Preview, Record и Stop, получает результаты команд и сведения о текущей записи. Модуль также обеспечивает работу с событиями записи, хранилищами и базой SDB в пределах настроенной конфигурации.")
        h2("2.4.3 Модуль HostAgent")
        p("HostAgent работает в фоновом режиме на компьютере Rlnx и предоставляет только три операции: выдачу статуса, запуск Rlnx и разрешённое выключение ОС. HostAgent не получает измерительные данные, не заменяет Rlnx и не выполняет Preview, Record и Stop.")

        h1("3 Порядок работы с СПО СТТ и ВКУ")
        p("1) Проверить питание и сетевую доступность компьютеров, измерительных приборов, каталогов проекта и записи.")
        p("2) Убедиться, что HostAgent запущен на тех КИП, где нужны дистанционный запуск Rlnx или выключение ОС.")
        p("3) Запустить RCPanel, включить его HTTP-сервис и проверить перечень управляемых компьютеров.")
        p("4) Запустить Rlnx локально либо командой RCPanel через HostAgent; дождаться регистрации и первого heartbeat.")
        p("5) В Rlnx выбрать проект СТТ или ВКУ, проверить состав приборов, каналов, тегов, ГХ, частоту опроса, периоды записи и формы отображения.")
        p("6) Перевести Rlnx в Preview. Проверить связь с приборами, текущие значения, единицы, диапазоны, уставки, тренды и диагностику.")
        p("7) Перевести нужные экземпляры Rlnx в Record локально или групповой командой RCPanel; убедиться в создании сеансов записи.")
        p("8) По завершении измерения подать Stop, дождаться закрытия файлов и получения RCPanel событий завершения.")
        p("9) Проверить файлы, записи БД и наличие данных для экспорта и постобработки.")
        p("Команда Stop останавливает измерительный цикл и закрывает текущую запись, но не завершает процесс Rlnx, не завершает HostAgent и не выключает компьютер. Закрытие Rlnx и выключение ОС являются отдельными действиями и допускаются только после Stop.")

        h1("4 Описание, запуск и настройка модулей СПО")
        h2("4.1 Модуль Rlnx")
        p("Перед запуском измерений оператор выбирает измерительный проект и проверяет цепочку обработки: источник данных — аппаратный канал — аппаратная ГХ — тег — пользовательская ГХ и расчётные оценки — отображение и запись.")
        p("Режим Stop используется для изменения аппаратной конфигурации. В Preview выполняются подключение к источникам, проверка связи и оперативное отображение без основной файловой записи. В Record открывается новый сеанс, данные записываются в каталог, а выбранные оценки могут дополнительно передаваться в SQL БД.")
        h2("4.1.1 Работа в конфигурации СТТ")
        b("Задать типы первичных преобразователей, диапазоны, единицы, ГХ, частоты опроса от 1 до 200 Гц в пределах возможностей прибора и периоды записи по группам точек.")
        b("Настроить мнемосхемы, оперативные и исторические тренды, индивидуальные и групповые уставки, а также индикацию отказов каналов и линий связи.")
        b("Для оценки НДС включить в проект расчётные каналы пересчёта деформаций в напряжения для принятой схемы тензорозетки. Формулы, поправки и критерии достоверности задаются в утверждённой конфигурации системы.")
        h2("4.1.2 Работа в конфигурации ВКУ")
        b("Задать каналы виброускорения, частоту дискретизации, диапазоны и формат записи сырого сигнала.")
        b("Настроить ФНЧ, ФВЧ и полосовую фильтрацию, однократное или двукратное интегрирование, размер БПФ и частотное разрешение.")
        b("Включить требуемые оценки: СКЗ, размах, пик-фактор, коэффициент эксцесса, автоспектры, полосовые спектры, гармоники и субгармоники с амплитудами ускорения, скорости или перемещения.")
        b("Настроить тренды виброускорения, виброскорости и виброперемещения для сравнения режимов и наработки.")
        h2("4.1.3 Архив, БД и выгрузка")
        p("Файловая запись Rlnx является основным архивом сырых измерительных данных. SQL БД хранит выбранные оценки и метаданные и не заменяет файловую запись. Однократно заданные в проекте имена, ГХ, расчёты, уставки и формы используются при последующих запусках и постобработке.")
        p("Выгрузка для внешней обработки выполняется средствами проекта или сопутствующими утилитами в текстовый или табличный формат. Для требуемого ТЗ представления формируются колонка дискретного времени и колонка физической величины. Тип файла — TXT или XLSX — выбирается в соответствии с задачей и конфигурацией системы.")
        h2("4.2 Модуль RCPanel")
        p("RCPanel может запускаться как графическое приложение, как консольная утилита или как постоянный HTTP-сервис. Для приёма подключений с других КИП задаётся адрес прослушивания и TCP-порт, по умолчанию 8765.")
        p("В одном broadcast-домене Rlnx и RCPanel могут обнаружить друг друга автоматически. UDP используется только для обнаружения адреса. Команды, токены и пути к файлам через UDP не передаются. Между подсетями, VLAN и VPN автообнаружение может не работать; в этом случае задаётся ручной HTTP endpoint.")
        p("Команды Preview, Record и Stop RCPanel помещает в очередь. Работающий Rlnx периодически получает команды и возвращает результат. Для групповой записи RCPanel может назначить общий идентификатор корреляции и объединить события нескольких Rlnx.")
        p("Для хранилищ на Windows допускаются UNC-пути SMB; на Linux используется заранее смонтированный CIFS-каталог. Пароли хранилищ в INI-файле RCPanel не сохраняются. Тип SFTP в текущей реализации не имеет подключённого транспортного адаптера и не используется как рабочий способ передачи.")
        h2("4.3 Модуль HostAgent")
        p("HostAgent запускается в пользовательской графической сессии. Конфигурация хранится в RecorderHostAgent.ini и содержит адрес прослушивания, порт, путь к Rlnx, разрешение выключения ОС и API-токен. Если путь не задан, агент ищет Rlnx рядом со своим исполняемым файлом.")
        table3([
            ("Метод", "Адрес", "Назначение"),
            ("GET", "/api/v1/status", "Получение минимальной диагностической информации."),
            ("POST", "/api/v1/recorder/start", "Проверка и запуск исполняемого файла Rlnx."),
            ("POST", "/api/v1/system/shutdown", "Выключение ОС только при allow_shutdown=1."),
        ])
        p("Если задан api_token, все запросы должны содержать заголовок Authorization: Bearer <token>. Для эксплуатации в рабочей сети токен должен быть задан и храниться в защищённом конфигурационном файле.")
        p("На Linux HostAgent не работает от root. Для выключения используется отдельный root-owned helper без параметров; разрешение allow_shutdown включается только после проверки этого механизма. Для запуска графического Rlnx необходима активная пользовательская графическая сессия.")
        p("HostAgent не имеет endpoint для закрытия процесса Rlnx. Поэтому штатное завершение включает Stop, проверку закрытия файлов, закрытие Rlnx оператором и лишь затем — при необходимости — выключение ОС.")

        h2("4.4 Соответствие функций СПО требованиям ТЗ")
        p("Исходные выжимки ТЗ не содержат сквозных идентификаторов требований. В таблице приведена функциональная трассировка по тематическим блокам ТЗ.")
        matrix = [
            ("Требование ТЗ", "Реализующий модуль", "Отражение в СПО"),
            ("Сбор, отображение, запись и архив", "Rlnx", "Источники, теги, Preview/Record/Stop, файловые сеансы и SQL БД."),
            ("Централизованное управление", "RCPanel, Rlnx", "Статусы, heartbeat, групповые Preview/Record/Stop, события записи."),
            ("Автозапуск и восстановление работы", "HostAgent, Rlnx, RCPanel", "Автозапуск агента, удалённый запуск Rlnx, контроль статуса. Норма 5 мин подтверждается приёмочным испытанием конкретной конфигурации."),
            ("Русскоязычный интерфейс и Astra Linux", "Все модули", "Русские интерфейсы; штатные Linux-дистрибутивы и user-systemd для HostAgent."),
            ("Целостность и однократный ввод", "Rlnx", "Проект хранит состав каналов, ГХ, расчёты, уставки и формы для повторного использования."),
            ("СТТ: деформации, температуры, НДС, мнемосхемы", "Rlnx", "Каналы и ГХ, расчётные теги, мнемосхемы, тренды, уставки и диагностика."),
            ("ВКУ: фильтры, интегрирование, спектры и гармоники", "Rlnx", "Цифровая запись, ФНЧ/ФВЧ/ПФ, одно-/двукратное интегрирование, БПФ, спектральные оценки и тренды."),
            ("Экспорт и внешние носители", "Rlnx", "Выборка данных и выгрузка в TXT/XLSX в виде «время — физическая величина»; копирование штатными средствами ОС."),
            ("Санкционированный доступ", "HostAgent, ОС, Rlnx", "Bearer-токен HostAgent, права ОС и разделение ролей настраиваются для конкретного объекта."),
        ]
        table3(matrix)

        new_nodes = []
        for kind, value in items:
            if kind == "h1":
                new_nodes.append(clone_paragraph(sample_h1, value, 0))
            elif kind == "h2":
                new_nodes.append(clone_paragraph(sample_h2, value, 1))
            elif kind == "p":
                new_nodes.append(clone_paragraph(sample_normal, value))
            elif kind == "b":
                new_nodes.append(clone_paragraph(sample_bullet, value))
            elif kind == "cap":
                new_nodes.append(clone_paragraph(sample_caption, value))
            elif kind == "table2":
                new_nodes.append(make_table(tables[3], value, sample_normal))
            elif kind == "table3":
                new_nodes.append(make_table(tables[8], value, sample_normal))

        # Remove the old body content, retaining title/TOC and change register.
        start = children.index(paragraphs[20])
        end = children.index(paragraphs[356])
        for node in list(body)[start:end]:
            body.remove(node)
        anchor = paragraphs[356]
        anchor_ppr = anchor.find(qn("pPr"))
        if anchor_ppr is None:
            anchor_ppr = etree.Element(qn("pPr"))
            anchor.insert(0, anchor_ppr)
        if anchor_ppr.find(qn("keepNext")) is None:
            etree.SubElement(anchor_ppr, qn("keepNext"))
        anchor_index = list(body).index(anchor)
        for offset, node in enumerate(new_nodes):
            body.insert(anchor_index + offset, node)

        # Ask Word to refresh TOC and fields on open.
        settings_path = tmp / "word" / "settings.xml"
        settings_tree = etree.parse(str(settings_path))
        settings_root = settings_tree.getroot()
        update = settings_root.find("w:updateFields", NS)
        if update is None:
            update = etree.SubElement(settings_root, qn("updateFields"))
        update.set(qn("val"), "true")

        tree.write(str(doc_path), xml_declaration=True, encoding="UTF-8", standalone="yes")
        settings_tree.write(str(settings_path), xml_declaration=True, encoding="UTF-8", standalone="yes")

        if OUTPUT.exists():
            OUTPUT.unlink()
        with zipfile.ZipFile(OUTPUT, "w", zipfile.ZIP_DEFLATED) as zout:
            for file in tmp.rglob("*"):
                if file.is_file():
                    zout.write(file, file.relative_to(tmp).as_posix())
    print(OUTPUT)


if __name__ == "__main__":
    main()

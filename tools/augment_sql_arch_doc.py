from pathlib import Path
from docx import Document
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

P = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Docs\sql\Архитектура SQL-хранилища RecorderLnx.docx")

def heading(d, s, n=1):
    p=d.add_paragraph(s, style=f"Heading {n}"); p.paragraph_format.keep_with_next=True; return p
def body(d, s):
    p=d.add_paragraph(s); p.paragraph_format.space_after=Pt(5); p.paragraph_format.line_spacing=1.08
def steps(d, items, style="List Number"):
    for s in items:
        p=d.add_paragraph(s, style=style); p.paragraph_format.space_after=Pt(3); p.paragraph_format.line_spacing=1.05
def shade(c, color):
    pr=c._tc.get_or_add_tcPr(); x=pr.find(qn("w:shd"))
    if x is None: x=OxmlElement("w:shd"); pr.append(x)
    x.set(qn("w:fill"), color)
def margins(c):
    pr=c._tc.get_or_add_tcPr(); m=pr.first_child_found_in("w:tcMar")
    if m is None: m=OxmlElement("w:tcMar"); pr.append(m)
    for n in ("top","start","bottom","end"):
        x=m.find(qn(f"w:{n}"))
        if x is None: x=OxmlElement(f"w:{n}"); m.append(x)
        x.set(qn("w:w"),"100"); x.set(qn("w:type"),"dxa")
def style_table(t):
    t.style="Table Grid"; t.autofit=False
    widths=(Cm(4.4),Cm(5.2),Cm(6.6))
    for ri,r in enumerate(t.rows):
        for ci,c in enumerate(r.cells):
            c.width=widths[ci]; c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER; margins(c)
            if ri==0:
                shade(c,"1F4E78")
                for p in c.paragraphs:
                    for x in p.runs: x.font.bold=True; x.font.color.rgb=RGBColor(255,255,255)
            elif ri%2==0: shade(c,"EAF2F8")
            for p in c.paragraphs:
                p.paragraph_format.space_after=Pt(0); p.paragraph_format.line_spacing=1
                for x in p.runs: x.font.size=Pt(9)
    pr=t.rows[0]._tr.get_or_add_trPr(); x=OxmlElement("w:tblHeader"); x.set(qn("w:val"),"true"); pr.append(x)

def main():
    d=Document(P)
    start=next(i for i,p in enumerate(d.paragraphs) if p.text.strip()=="12. Источники")
    for p in list(d.paragraphs[start:]): p._element.getparent().remove(p._element)

    heading(d,"12. Подробные алгоритмы")
    body(d,"Алгоритмы фиксируют последовательность вызовов и границы владения данными. Поток приборов не ждёт сеть и БД, SQL writer единолично владеет соединением и транзакцией, а UI получает только завершённые снимки. Это исключает взаимные блокировки между сбором данных, отображением и Firebird.")
    heading(d,"12.1. Формирование кадра записи",2)
    steps(d,[
        "Runtime по таймеру берёт неизменяемый снимок разрешённых тегов. Список меняется через настройки или централизованную синхронизацию, но не во время обхода.",
        "Заранее исключаются отключённые каналы, теги без актуального значения и теги SQL data source. Последнее правило разрывает цикл Firebird → SQL data source → Firebird.",
        "В кадр копируются имя, источник, адрес, единица, UTC-время, значение, качество и sequence number. В нём нет указателей на живые объекты тегов.",
        "Готовый кадр атомарно помещается в bounded queue. Переполнение учитывается счётчиком пропусков и не приводит к бесконтрольному росту памяти.",
        "Поток приборов продолжает работу; подключение к Firebird и COMMIT выполняются только writer-потоком."])
    heading(d,"12.2. Пакетная запись кадра",2)
    steps(d,[
        "Writer извлекает один кадр и проверяет соединение. При разрыве выполняется ограниченное повторное подключение с backoff; параллельных writers нет.",
        "Repository открывает короткую транзакцию и пакетно разрешает signal_id. Физический канал идентифицируется объектом, источником и адресом, а не только отображаемым именем.",
        "Точки группируются по размеру multi-row INSERT. Для каждого размера используется подготовленный запрос, что уменьшает разбор SQL и число сетевых round-trip.",
        "После Execute всех групп repository освобождает подготовленные запросы при активной транзакции и выполняет полный COMMIT. Читатель видит весь кадр целиком.",
        "После COMMIT создаётся новая транзакция; statements предыдущей транзакции повторно не используются.",
        "При ошибке откатывается только текущий кадр, очищается транзакционный кэш, записываются причина, размер и длительность. UI и устройства продолжают работать."])
    heading(d,"12.3. Жизненный цикл prepared statements",2)
    body(d,"Кэш вставки хранит плоские пары [число строк, объект TSQLQuery]. Число строк кодируется как Pointer для поиска и не является объектом. Очистка освобождает только TSQLQuery на нечётных позициях, затем очищает список. Вызов Free для row count вызывает Access violation, отключает SQL runtime и останавливает свежие точки; этот инвариант должен проверяться тестом Flush.")
    steps(d,["запрос создаётся только при активной транзакции;","повторное использование разрешено только в той же транзакции и для того же размера batch;","очистка выполняется до COMMIT или ROLLBACK;","освобождаются только объекты запросов, но не закодированные счётчики;","после очистки Count равен нулю."],"List Bullet")
    heading(d,"12.4. Пакетное чтение текущих значений",2)
    steps(d,[
        "SQL data source хранит выбранный список signal_id и период чтения; запрос на каждый тег не выполняется.",
        "Один параметризованный запрос получает последнюю точку каждого signal_id. Большой список делится на chunks, но цикл собирается в единый временный массив.",
        "До успеха всего цикла опубликованный снимок не очищается, поэтому краткая ошибка не заставляет линии исчезать и появляться.",
        "Готовый массив атомарно заменяет предыдущий снимок; UI читает его без обращений к Firebird.",
        "С value сохраняются quality и timestamp. Возраст новейшей точки сравнивается с stale threshold, чтобы старое значение не выдавалось за текущее.",
        "Зеркальные теги имеют source kind SQL database и принудительно запрещённую SQL recording, независимо от проектной галочки."])
    heading(d,"12.5. Чтение исторического тренда",2)
    steps(d,[
        "Trend формирует единый UTC-интервал и набор signal_id активного отображения.",
        "Repository читает диапазон по индексу (signal_id, timestamp_utc) с ORDER BY signal_id, timestamp_utc, не сканируя всю историю.",
        "Ограничение точек выполняется серверной агрегацией по корзинам или равномерной клиентской децимацией с сохранением первой и последней точки.",
        "Линии строятся во временной модели и подменяются одним действием. MouseMove меняет курсор и подсказку, но не компилирует линии заново.",
        "Автообновление не сбрасывает пользовательский zoom. Автомасштаб применяется при смене отображения, явной команде или отсутствии пользовательского диапазона."])
    heading(d,"12.6. События и уставки",2)
    steps(d,[
        "Первое значение после запуска задаёт исходное состояние без события, даже если оно уже вне диапазона.",
        "Событие создаётся только при переходе нормальное → аварийное или аварийное → нормальное; при необходимости применяется гистерезис.",
        "Запись содержит signal_id, UTC-время, тип, уровень, значение, уставку и текст. Пользовательская информационная строка заменяет стандартное сообщение.",
        "События не заставляют SQL data source перечитывать текстовые строки в каждом цикле текущих значений."])
    heading(d,"12.7. Переподключение и устаревшие данные",2)
    body(d,"Сетевая ошибка не выбрасывается в UI. Repository возвращает классифицированную причину, runtime закрывает повреждённую пару connection/transaction и переходит в backoff. Повтор создаёт новые объекты и новую транзакцию. Интерфейс различает состояния «SQL недоступен», «данные устарели» и «данных ещё нет», чтобы не путать отсутствие связи с корректной постоянной линией.")

    heading(d,"13. Оптимизации и предотвращаемые ошибки")
    t=d.add_table(rows=1,cols=3)
    for i,s in enumerate(("Решение","Зачем","Какой отказ предотвращает")): t.rows[0].cells[i].text=s
    rows=[
        ("Один writer и одна очередь","Сохраняет порядок и владение соединением","гонки транзакций, блокировки, перестановка точек"),
        ("Кадр одним COMMIT","Публикует согласованный срез","частичный кадр и разное время видимости каналов"),
        ("Multi-row INSERT","Сокращает SQL parsing и round-trip","задержка от сотен одиночных INSERT"),
        ("Prepared query на batch","Повторно использует план внутри транзакции","лишняя компиляция SQL"),
        ("Очистка query cache до COMMIT","Не оставляет запросы завершённой транзакции","висячие statements и ошибка следующего кадра"),
        ("Free только query в паре","Учитывает [row count, query]","Access violation и отключение SQL runtime"),
        ("Bounded queue","Ограничивает память при недоступной БД","рост RAM и зависание RecorderLnx"),
        ("Один запрос current values","Читает массив с одной точкой синхронизации","N запросов и отставание АРМ"),
        ("Atomic swap результата","Сохраняет старый снимок до готовности нового","периодическое исчезновение линий"),
        ("Timestamp и stale threshold","Отделяет значение от актуальности","показ старой точки как текущей"),
        ("Запрет записи mirrored tags","Разрывает обратную связь","дублирование и цикл чтение–запись"),
        ("Короткая транзакция чтения","Продвигает snapshot","невидимость свежих COMMIT"),
        ("Индекс signal_id + timestamp","Ограничивает диапазонный поиск","full scan и деградация истории"),
        ("Переход состояния уставки","Отбрасывает стартовое состояние","ложная авария при запуске"),
        ("Backoff и новый connection","Ограничивает повторы","шторм подключений и повреждённая транзакция")]
    for vals in rows:
        cells=t.add_row().cells
        for i,s in enumerate(vals): cells[i].text=s
    style_table(t)

    heading(d,"14. Наблюдаемость и диагностический алгоритм")
    body(d,"Диагностика начинается с факта в БД. Для контрольного канала сравниваются MAX(timestamp_utc), UTC-время сервера, период записи и значение на KIP. Это разделяет случаи: writer не пишет; Firebird принял COMMIT, но reader держит старый snapshot; UI не опубликовал прочитанный массив.")
    steps(d,[
        "Проверить возраст последней точки. Если он больше двух периодов, искать проблему writer или соединения, а не графика.",
        "Проверить SQL runtime и последнюю ошибку. Access violation, rollback и reconnect имеют отдельные коды и счётчики.",
        "Проверить глубину очереди, максимум, dropped frames и p95 времени Flush.",
        "Если Firebird свежий, проверить возраст снимка SQL data source, длительность batch SELECT и поколение опубликованного массива.",
        "Если снимок свежий, проверить поколение модели тренда и время перерисовки. MouseMove не меняет поколение данных.",
        "После исправления выдержать тест дольше прежнего интервала отказа и повторно сравнить канал на KIP, в Firebird и на АРМ."])

    heading(d,"15. Retention и обслуживание истории")
    body(d,"Retention выполняется отдельной сервисной операцией, а не каждым RecorderLnx. Удаление идёт ограниченными диапазонами с COMMIT между пакетами, затем обслуживаются индексы и статистика. Очистка не запускается на всех KIP и не смешивается с синхронизацией разрешённых каналов. До неё проверяется backup, после — диапазон времени, число сигналов и восстановление тестовой копии.")
    steps(d,["хранить raw-данные согласно политике проекта;","удалять только историю старше подтверждённой границы retention;","не удалять metadata signals вместе с точками без отдельного решения;","для больших объёмов планировать секционирование PostgreSQL;","контролировать активные версии транзакций и время запросов после очистки."],"List Bullet")

    heading(d,"16. Выбор СУБД и готовность к миграции")
    body(d,"Firebird соответствует текущей нагрузке при native ext4, коротких транзакциях и пакетном I/O. Смена СУБД не исправит ошибки владения транзакцией, неатомарную публикацию массивов или цикл зеркальных тегов; сначала эти инварианты закрепляются тестами и метриками.")
    body(d,"PostgreSQL — предпочтительный следующий серверный вариант: свободная лицензия, COPY, партиционирование, репликация и зрелая наблюдаемость. TimescaleDB допустим как необязательное расширение без зависимости от закрытых функций. ClickHouse оправдан как аналитическая копия при существенно большем потоке, но не как единственная БД метаданных и событий.")
    heading(d,"16.1. Контракт миграционной готовности",2)
    steps(d,["предметный слой работает через repository и не строит SQL в UI;","DDL и миграции версионируются и повторно проверяются;","UTC-время, signal identity, quality и sequence number одинаковы во всех backend;","batch write и latest-values read имеют контрактные тесты Firebird и PostgreSQL;","двойная запись при миграции ограничена и сверяется по числу, времени и контрольным суммам;","readers переключаются раньше writers, а Firebird сохраняется до завершения сверки."],"List Bullet")

    heading(d,"17. Источники")
    steps(d,[
        "Firebird 5 Quick Start Guide: https://firebirdsql.org/file/documentation/pdf/en/firebirddocs/qsg5/firebird-5-quickstartguide.pdf",
        "Firebird Configuration Reference: https://www.firebirdsql.org/docs/html/en/refdocs/fbconf/firebird-configuration-reference.html",
        "PostgreSQL License: https://www.postgresql.org/about/licence/",
        "PostgreSQL bulk loading: https://www.postgresql.org/docs/17/populate.html",
        "TimescaleDB license split: https://github.com/timescale/timescaledb/blob/main/LICENSE",
        "ClickHouse license: https://github.com/ClickHouse/ClickHouse/blob/master/LICENSE"],"List Bullet")
    for p in d.paragraphs:
        if p.style.name.startswith("Heading"):
            p.paragraph_format.keep_with_next=True; p.paragraph_format.space_before=Pt(10); p.paragraph_format.space_after=Pt(4)
    d.save(P); print(P)

if __name__=="__main__": main()

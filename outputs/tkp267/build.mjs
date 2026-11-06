import fs from 'node:fs/promises';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';
const wb=Workbook.create(), s=wb.worksheets.add('Перечень');
const rows=[
['1','Акселерометр',24,'АР2038-100','Трёхосевой кандидат; 24 шт. = 72 сигнала','70872-18; 88508-23','Проверить исполнение, диапазон, выход и температуру; 72 канала только при одновременной записи','https://globaltest.ru/dokumenty/'],
['2','Тензометрический датчик',24,'Подбор после уточнения','Мост / полумост / тензорезистор','Не определён','Уточнить измеряемую величину, диапазон, базу и схему; датчик и тензорезистор не тождественны',''],
['3','Датчик частоты вращения',1,'Подбор после уточнения','Импульсный выход','Не определён','Уточнить обороты, способ установки и уровни импульсов',''],
['4','Датчик местоположения',1,'Подбор после уточнения','Приёмник позиционирования','Не определён','Уточнить точность, условия приёма и интерфейс',''],
['5','Датчик перемещения',6,'LPS','Линейное перемещение; исполнение выбрать','82818-21','Уточнить ход, выход, температуру и поставку','https://teh-m.ru/grsi/82818-21'],
['6','Датчик температуры',24,'ОВЕН ДТС-И','Термосопротивление с выходом 4–20 мА','28354-10','Выбрать исполнение; отдельно проверить температуру головки и среды','https://docs.owen.ru/product/dtshh5_termosoprotivleniya_s_vihodnim_signalom_420_ma/doc/rukovodstvo-po-ekspluatacii-dts-i-dtp-i/ispolzovanie-po-naznaceniu/podklucenie'],
['7','Датчик влажности',2,'ИВТМ-7 Н','4–20 мА / RS-485 в зависимости от исполнения','71394-18','Проверить конфигурацию, температурный диапазон и выход','https://www.eksis.ru/catalog/termogigrometry-ivtm-7-n/product5578.php'],
['8','Датчик давления',4,'ОВЕН ПД100, исполнение уточнить','Пример: 0–0,1 МПа; предел и присоединение выбрать','Проверить','Давление, среда, точность и номер типа конкретного исполнения не подтверждены','https://docs.owen.ru/product/preobrazovateli_dlya_slozhnih_uslovij_v_polevom_korpuse/595'],
['9','Датчик скорости воздуха',6,'CTV110 / CTV210','Преобразователь скорости воздуха, аналоговый выход','60867-15','Импортный вариант; проверить поставку, выход, диапазон и статус типа','https://oei-analitika.ru/kurilka/si_type_info.php?si_type_id=374191'],
['10','Датчик CO₂',2,'ПКУ-4/2 + ИПДУ-02','Вариант: 1 блок и 2 выносных преобразователя','62127-15','Количество блоков 1, преобразователей 2; диапазон, выход и температуру согласовать','https://www.eksis.ru/catalog/gazoanalizatory-uglekislogo-gaza-pku-4/product1473.php'],
['11','Измерительный микрофон со стойкой',3,'Подбор после уточнения','Микрофон, предусилитель и стойка','Не определён','Уточнить диапазон звукового давления, полосу и интерфейс',''],
['12','Датчик тока',12,'Подбор после уточнения','Преобразователь / клещи','Не определён','Уточнить AC/DC, ток, полосу, размер шины и изоляцию',''],
['13','Датчик напряжения',14,'Подбор после уточнения','Изолированный преобразователь','Не определён','Уточнить диапазон AC/DC, полосу и изоляцию',''],
['14','Кабели датчиков',null,'Подбор после выбора датчиков','Не менее 30 м; возможность до 200 м','Не применимо','Количество, разъёмы, экранирование и пригодность к длине рассчитать',''],
['15','Стойка микрофона',3,'В составе позиции 11','Стойка под измерительный микрофон','Не применимо','Учтена в комплекте микрофона; не суммировать повторно',''],
['16','Источники питания / ИБП',null,'Подбор после расчёта','AC 160–260 В; DC 35–72 / 77–137,5 В','Проверить','Автономность до 30 мин; устойчивость к провалам и импульсам по ТЗ',''],
['17','Согласующие модули / шунты',null,'Подбор после выбора входов','4–20 мА, питание и гальваническая развязка','Проверить','Состав и точность измерительной цепи определить проектом','']
];
s.getRange('A1:H1').merge(); s.getRange('A1').values=[['ТКП-267 · Предварительный перечень покупного оборудования']];
s.getRange('A2:H2').merge(); s.getRange('A2').values=[['ТЗ п. 2.17: 123 датчика и прибора; данные для запроса КП, не окончательная спецификация. Дата: 03.11.2026']];
s.getRange('A4:H4').values=[['№','Наименование','Кол-во','Кандидат / модель','Основные характеристики','Госреестр №','Что подтвердить до заказа','Источник']];
s.getRangeByIndexes(4,0,rows.length,8).values=rows;
s.getRange('A1:H1').format={fill:'#006e73',font:{name:'Arial',size:16,bold:true,color:'#FFFFFF'},rowHeight:30};
s.getRange('A2:H2').format={font:{name:'Arial',size:10,color:'#52667b'},rowHeight:29,wrapText:true};
s.getRange('A4:H4').format={fill:'#17364d',font:{name:'Arial',bold:true,color:'#FFFFFF',size:10},wrapText:true,rowHeight:35};
s.getRange('A5:H21').format.font={name:'Arial',size:10}; s.getRange('A5:H21').format.wrapText=true; s.getRange('A5:H21').format.rowHeight=55;
s.getRange('A:A').format.columnWidth=5; s.getRange('B:B').format.columnWidth=27; s.getRange('C:C').format.columnWidth=10; s.getRange('D:D').format.columnWidth=28; s.getRange('E:E').format.columnWidth=39; s.getRange('F:F').format.columnWidth=20; s.getRange('G:G').format.columnWidth=53; s.getRange('H:H').format.columnWidth=60;
s.getRange('A4:H21').format.borders={preset:'all',style:'thin',color:'#D4E0E5'}; s.freezePanes.freezeRows(4); s.showGridLines=false;
s.getRange('A23:H23').merge(); s.getRange('A23').values=[['Госреестр: указан номер типа по найденному источнику, действительность утверждения типа, поверку конкретного экземпляра и доступность поставки проверить до закупки.']]; s.getRange('A23:H23').format={wrapText:true,rowHeight:35,font:{name:'Arial',size:10,color:'#A33C29'}};
wb.recalculate(); const out=await SpreadsheetFile.exportXlsx(wb); await out.save('D:/works/AGrav/20_Проекты/ТКП/267/ТКП-267_покупное_оборудование.xlsx');
const preview=await wb.render({sheetName:'Перечень',range:'A1:G8',scale:1,format:'png'}); await fs.writeFile('D:/works/OburecGH/outputs/tkp267/preview.png',new Uint8Array(await preview.arrayBuffer()));
console.log((await wb.inspect({kind:'region',sheetId:'Перечень',range:'A4:G8',maxChars:2500})).ndjson);

object Form1: TForm1
  Left = 108
  Top = 79
  Width = 664
  Height = 353
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TabbedNotebook1: TTabbedNotebook
    Left = 0
    Top = 0
    Width = 656
    Height = 326
    Align = alClient
    PageIndex = 3
    TabFont.Charset = DEFAULT_CHARSET
    TabFont.Color = clBtnText
    TabFont.Height = -11
    TabFont.Name = 'MS Sans Serif'
    TabFont.Style = []
    TabOrder = 0
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Загрузка Excel'
      object Button1: TButton
        Left = 24
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Button1'
        TabOrder = 0
        OnClick = Button1Click
      end
      object ListBox1: TListBox
        Left = 120
        Top = 16
        Width = 121
        Height = 97
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Формат ячейки'
      object Button2: TButton
        Left = 16
        Top = 8
        Width = 125
        Height = 25
        Caption = 'Открываем книгу'
        TabOrder = 0
        OnClick = Button2Click
      end
      object Button3: TButton
        Left = 16
        Top = 40
        Width = 125
        Height = 25
        Caption = 'Заполняем ячейки'
        Enabled = False
        TabOrder = 1
        OnClick = Button3Click
      end
      object Button10: TButton
        Left = 472
        Top = 256
        Width = 113
        Height = 25
        Caption = 'Закрываем книгу'
        Enabled = False
        TabOrder = 2
        OnClick = Button10Click
      end
      object Button4: TButton
        Left = 16
        Top = 72
        Width = 125
        Height = 25
        Caption = 'Читаем ячейки'
        Enabled = False
        TabOrder = 3
        OnClick = Button4Click
      end
      object Memo1: TMemo
        Left = 160
        Top = 8
        Width = 305
        Height = 281
        Lines.Strings = (
          'Memo1')
        TabOrder = 4
      end
      object Button5: TButton
        Left = 16
        Top = 104
        Width = 125
        Height = 25
        Caption = 'Ширина/высота'
        Enabled = False
        TabOrder = 5
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 16
        Top = 136
        Width = 125
        Height = 25
        Caption = 'Формат данных'
        Enabled = False
        TabOrder = 6
        OnClick = Button6Click
      end
      object Button7: TButton
        Left = 16
        Top = 168
        Width = 125
        Height = 25
        Caption = 'Выравнивание'
        Enabled = False
        TabOrder = 7
        OnClick = Button7Click
      end
      object Button8: TButton
        Left = 16
        Top = 200
        Width = 125
        Height = 25
        Caption = 'Поворот'
        Enabled = False
        TabOrder = 8
        OnClick = Button8Click
      end
      object CheckBox1: TCheckBox
        Left = 16
        Top = 228
        Width = 121
        Height = 17
        Caption = 'Перенос по словам'
        Enabled = False
        TabOrder = 9
        OnClick = CheckBox1Click
      end
      object CheckBox2: TCheckBox
        Left = 16
        Top = 246
        Width = 121
        Height = 17
        Caption = 'Объединение ячеек'
        Enabled = False
        TabOrder = 10
        OnClick = CheckBox2Click
      end
      object CheckBox3: TCheckBox
        Left = 16
        Top = 264
        Width = 121
        Height = 17
        Caption = 'Автоподбор ширины'
        Enabled = False
        TabOrder = 11
        OnClick = CheckBox3Click
      end
      object Button9: TButton
        Left = 472
        Top = 8
        Width = 113
        Height = 25
        Caption = 'Шрифт'
        TabOrder = 12
        OnClick = Button9Click
      end
      object Button11: TButton
        Left = 472
        Top = 40
        Width = 113
        Height = 25
        Caption = 'Шрифт +'
        TabOrder = 13
        OnClick = Button11Click
      end
      object Button12: TButton
        Left = 472
        Top = 72
        Width = 113
        Height = 25
        Caption = 'Граница'
        TabOrder = 14
        OnClick = Button12Click
      end
      object Button13: TButton
        Left = 472
        Top = 104
        Width = 113
        Height = 25
        Caption = 'Заливка ячейки'
        TabOrder = 15
        OnClick = Button13Click
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Параметры листа'
      object Button14: TButton
        Left = 16
        Top = 8
        Width = 125
        Height = 25
        Caption = 'Открываем книгу'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = Button14Click
      end
      object Button15: TButton
        Left = 16
        Top = 40
        Width = 125
        Height = 25
        Caption = 'Заполняем ячейки'
        Enabled = False
        TabOrder = 1
        OnClick = Button15Click
      end
      object Button16: TButton
        Left = 464
        Top = 256
        Width = 113
        Height = 25
        Caption = 'Закрываем книгу'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = Button16Click
      end
      object Button17: TButton
        Left = 16
        Top = 184
        Width = 98
        Height = 25
        Caption = 'Просмотр печати'
        TabOrder = 3
        OnClick = Button17Click
      end
      object Button18: TButton
        Left = 16
        Top = 216
        Width = 125
        Height = 25
        Caption = 'Диалог печати'
        TabOrder = 4
        OnClick = Button18Click
      end
      object Button19: TButton
        Left = 116
        Top = 184
        Width = 25
        Height = 25
        Caption = 'Ex'
        TabOrder = 5
        OnClick = Button19Click
      end
      object Button20: TButton
        Left = 16
        Top = 248
        Width = 125
        Height = 25
        Caption = 'Рисунок фона листа'
        TabOrder = 6
        OnClick = Button20Click
      end
      object CheckBox4: TCheckBox
        Left = 16
        Top = 72
        Width = 121
        Height = 17
        Caption = 'Линии сетки ячеек'
        Checked = True
        State = cbChecked
        TabOrder = 7
        OnClick = CheckBox4Click
      end
      object CheckBox5: TCheckBox
        Left = 16
        Top = 96
        Width = 129
        Height = 17
        Caption = 'Печать линий сетки'
        TabOrder = 8
        OnClick = CheckBox5Click
      end
      object ComboBox1: TComboBox
        Left = 16
        Top = 120
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 9
        OnChange = ComboBox1Change
        Items.Strings = (
          'Книжная ориентация'
          'Альбомная ориентация')
      end
      object ComboBox2: TComboBox
        Left = 16
        Top = 144
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 10
        OnChange = ComboBox2Change
        Items.Strings = (
          'Обычный вид документа'
          'Разметка страницы')
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Диаграммы'
      object Button21: TButton
        Left = 152
        Top = 8
        Width = 125
        Height = 25
        Caption = 'Новая диаграмма'
        TabOrder = 0
        OnClick = Button21Click
      end
      object Button22: TButton
        Left = 16
        Top = 8
        Width = 125
        Height = 25
        Caption = 'Открываем книгу'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = Button22Click
      end
      object Button23: TButton
        Left = 464
        Top = 256
        Width = 113
        Height = 25
        Caption = 'Закрываем книгу'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = Button23Click
      end
      object Button25: TButton
        Left = 288
        Top = 8
        Width = 125
        Height = 25
        Caption = 'Заполняем данными'
        TabOrder = 3
        OnClick = Button25Click
      end
      object Button32: TButton
        Left = 424
        Top = 8
        Width = 125
        Height = 25
        Caption = 'Заголовок'
        TabOrder = 4
        OnClick = Button32Click
      end
      object TabbedNotebook2: TTabbedNotebook
        Left = 8
        Top = 40
        Width = 633
        Height = 209
        PageIndex = 5
        TabFont.Charset = DEFAULT_CHARSET
        TabFont.Color = clBtnText
        TabFont.Height = -11
        TabFont.Name = 'MS Sans Serif'
        TabFont.Style = []
        TabOrder = 5
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Область диаграммы'
          object Button29: TButton
            Left = 8
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль рамки'
            TabOrder = 0
            OnClick = Button29Click
          end
          object Button30: TButton
            Left = 8
            Top = 86
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль области'
            TabOrder = 1
            OnClick = Button30Click
          end
          object Button31: TButton
            Left = 8
            Top = 118
            Width = 125
            Height = 25
            Caption = 'Рисунок области'
            TabOrder = 2
            OnClick = Button31Click
          end
        end
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Область построения диаграммы'
          object Button24: TButton
            Left = 8
            Top = 22
            Width = 125
            Height = 25
            Caption = 'Координаты области'
            TabOrder = 0
            OnClick = Button24Click
          end
          object Button26: TButton
            Left = 8
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль рамки'
            TabOrder = 1
            OnClick = Button26Click
          end
          object Button27: TButton
            Left = 8
            Top = 86
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль области'
            TabOrder = 2
            OnClick = Button27Click
          end
          object Button28: TButton
            Left = 8
            Top = 118
            Width = 125
            Height = 25
            Caption = 'Рисунок области'
            TabOrder = 3
            OnClick = Button28Click
          end
        end
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Тип и размещение диаграммы'
          object Label1: TLabel
            Left = 55
            Top = 91
            Width = 38
            Height = 13
            Caption = 'Наклон'
          end
          object Label2: TLabel
            Left = 50
            Top = 123
            Width = 43
            Height = 13
            Caption = 'Поворот'
          end
          object ComboBox3: TComboBox
            Left = 8
            Top = 16
            Width = 313
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnClick = ComboBox3Click
            Items.Strings = (
              'xlColumnClustered=51; '
              'xlColumnStacked=52; '
              'xlColumnStacked100=53;'
              'xl3DColumnClustered=54;'
              'xl3DColumnStacked=55;'
              'xl3DColumnStacked100=56;'
              'xlBarClustered=57;'
              'xlBarStacked=58;'
              'xlBarStacked100=59;'
              'xl3DBarClustered=60;'
              'xl3DBarStacked=61;'
              'xl3DBarStacked100=62;'
              'xlLineStacked=63;'
              'xlLineStacked100=64;'
              'xlLineMarkers=65;'
              'xlLineMarkersStacked=66;'
              'xlLIneMarkersStacked100=67;'
              'xlPieOfPie=68;'
              'xlPieExploded=69;'
              'xl3DPieExploded=70;'
              'xlBarOfPie=71; '
              'xlXYScatterSmooth=72;'
              'xlXYScatterSmoothNoMarkers=73;'
              'xlXYScatterLines=74;'
              'xlXYScatterLinesNoMarkers=75;'
              'xlAreaStacked=76;'
              'xlAreaStacked100=77;'
              'xl3DAreaStacked=78; '
              'xl3DAreaStacked100=79;'
              'xlDoughnutExploded=80;'
              'xlRadarMarkers=81;'
              'xlRadarFilled=82;'
              'xlSurface=83;'
              'xlSurfaceWireframe=84;'
              'xlSurfaceTopView=85;'
              'xlSurfaceTopViewWireframe=86;'
              'xlBubble3DEffect=87;'
              'xlStockHLC=88;'
              'xlStockOHLC=89;'
              'xlStockVHLC=90;'
              'xlStockVOHLC=91;'
              'xlCylinderColClustered=92;'
              'xlCylinderColStacked=93;'
              'xlCylinderColStacked100=94;'
              'xlCylinderBarClustered=95;'
              'xlCylinderBarStacked=96;'
              'xlCylinderBarStacked100=97;'
              'xlCylinderCol=98;'
              'xlConeColClustered=99;'
              'xlConeColStacked=100;'
              'xlConeColStacked100=101;'
              'xlConeBarClustered=102;'
              'xlConeBarStacked=103;'
              'xlConeBarStacked100=104;'
              'xlConeCol=105;'
              'xlPyramidColClustered=106;'
              'xlPyramidColStacked=107;'
              'xlPyramidColStacked100=108;'
              'xlPyramidBarClustered=109;'
              'xlPyramidBarStacked=110;'
              'xlPyramidBarStacked100=111;'
              'xlPyramidCol=112;')
          end
          object CheckBox6: TCheckBox
            Left = 8
            Top = 48
            Width = 188
            Height = 17
            Caption = 'Разместить на листе с данными'
            TabOrder = 1
            OnClick = CheckBox6Click
          end
          object Edit1: TEdit
            Left = 200
            Top = 45
            Width = 121
            Height = 21
            TabOrder = 2
            Text = 'Лист1'
          end
          object SpinEdit1: TSpinEdit
            Left = 96
            Top = 88
            Width = 121
            Height = 22
            MaxValue = 90
            MinValue = -90
            TabOrder = 3
            Value = 0
            OnChange = SpinEdit1Change
          end
          object SpinEdit2: TSpinEdit
            Left = 96
            Top = 120
            Width = 121
            Height = 22
            MaxValue = 360
            MinValue = 0
            TabOrder = 4
            Value = 0
            OnChange = SpinEdit2Change
          end
        end
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Легенда,оси'
          object Button33: TButton
            Left = 8
            Top = 22
            Width = 125
            Height = 25
            Caption = 'Координаты области'
            TabOrder = 0
            OnClick = Button33Click
          end
          object Button34: TButton
            Left = 8
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль рамки'
            TabOrder = 1
            OnClick = Button34Click
          end
          object Button35: TButton
            Left = 8
            Top = 86
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль области'
            TabOrder = 2
            OnClick = Button35Click
          end
          object Button36: TButton
            Left = 8
            Top = 118
            Width = 125
            Height = 25
            Caption = 'Рисунок области'
            TabOrder = 3
            OnClick = Button36Click
          end
          object Button37: TButton
            Left = 145
            Top = 22
            Width = 125
            Height = 25
            Caption = 'Шрифт элемента '
            TabOrder = 4
            OnClick = Button37Click
          end
          object Button38: TButton
            Left = 144
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Подписи осей'
            TabOrder = 5
            OnClick = Button38Click
          end
        end
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Стены,основание'
          object Label3: TLabel
            Left = 16
            Top = 32
            Width = 32
            Height = 13
            Caption = 'Стены'
          end
          object Label4: TLabel
            Left = 160
            Top = 32
            Width = 56
            Height = 13
            Caption = 'Основание'
          end
          object Button39: TButton
            Left = 8
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль рамки'
            TabOrder = 0
            OnClick = Button39Click
          end
          object Button40: TButton
            Left = 8
            Top = 86
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль области'
            TabOrder = 1
            OnClick = Button40Click
          end
          object Button41: TButton
            Left = 8
            Top = 118
            Width = 125
            Height = 25
            Caption = 'Рисунок области'
            TabOrder = 2
            OnClick = Button41Click
          end
          object Button42: TButton
            Left = 152
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль рамки'
            TabOrder = 3
            OnClick = Button42Click
          end
          object Button43: TButton
            Left = 152
            Top = 86
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль области'
            TabOrder = 4
            OnClick = Button43Click
          end
          object Button44: TButton
            Left = 152
            Top = 118
            Width = 125
            Height = 25
            Caption = 'Рисунок области'
            TabOrder = 5
            OnClick = Button44Click
          end
        end
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Коллекции'
          object Button45: TButton
            Left = 8
            Top = 54
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль рамки'
            TabOrder = 0
            OnClick = Button45Click
          end
          object Button46: TButton
            Left = 8
            Top = 86
            Width = 125
            Height = 25
            Caption = 'Цвет, стиль'
            TabOrder = 1
            OnClick = Button46Click
          end
          object Button47: TButton
            Left = 8
            Top = 118
            Width = 125
            Height = 25
            Caption = 'Вид серий'
            TabOrder = 2
            OnClick = Button47Click
          end
        end
      end
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 524
    Top = 32
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 
      'All (*.jpg;*.jpeg;*.bmp;*.ico;*.emf;*.wmf)|*.jpg;*.jpeg;*.bmp;*.' +
      'ico;*.emf;*.wmf|JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*' +
      '.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bmp|Enhanced Metafiles (*.emf)|*' +
      '.emf|Metafiles (*.wmf)|*.wmf'
    Options = [ofHideReadOnly]
    Left = 316
    Top = 32
  end
end

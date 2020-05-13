object Form1: TForm1
  Left = 229
  Top = 160
  BorderStyle = bsDialog
  Caption = #1054#1073#1088#1072#1073#1090#1082#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' '#1080#1089#1087#1099#1090#1072#1085#1080#1081' '#1082#1086#1088#1087#1091#1089#1086#1074' '#1064'-80-1 (v.1.4.3)'
  ClientHeight = 622
  ClientWidth = 935
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LabelFile: TLabel
    Left = 8
    Top = 10
    Width = 123
    Height = 13
    Caption = #1060#1072#1081#1083' '#1080#1089#1093#1086#1076#1085#1099#1093' '#1076#1072#1085#1085#1099#1093':'
  end
  object LabelCfg: TLabel
    Left = 232
    Top = 10
    Width = 107
    Height = 13
    Caption = #1060#1072#1081#1083' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1080':'
  end
  object GroupBox1: TGroupBox
    Left = 520
    Top = 384
    Width = 409
    Height = 201
    Caption = ' '#1054#1090#1095#1077#1090' '
    TabOrder = 11
    object Label7: TLabel
      Left = 13
      Top = 172
      Width = 85
      Height = 13
      Caption = #1042#1080#1076' '#1085#1072#1075#1088#1091#1078#1077#1085#1080#1103':'
    end
    object Label6: TLabel
      Left = 13
      Top = 148
      Width = 87
      Height = 13
      Caption = #1044#1072#1090#1072' '#1080#1089#1087#1099#1090#1072#1085#1080#1103':'
    end
    object Label4: TLabel
      Left = 13
      Top = 124
      Width = 82
      Height = 13
      Caption = #1053#1086#1084#1077#1088' '#1080#1079#1076#1077#1083#1080#1103':'
    end
    object Label5: TLabel
      Left = 13
      Top = 20
      Width = 68
      Height = 13
      Caption = #1060#1072#1081#1083' '#1086#1090#1095#1077#1090#1072':'
    end
    object Label8: TLabel
      Left = 13
      Top = 44
      Width = 57
      Height = 13
      Caption = #1058#1080#1087' '#1092#1072#1081#1083#1072':'
    end
    object Label17: TLabel
      Left = 277
      Top = 124
      Width = 108
      Height = 13
      Caption = #1062#1080#1092#1088' '#1087#1086#1089#1083#1077' '#1079#1072#1087#1103#1090#1086#1081':'
    end
    object rbReport_doc: TRadioButton
      Left = 104
      Top = 48
      Width = 132
      Height = 17
      Caption = '*.doc (Microsoft Word)'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbReport_docClick
    end
    object CheckBoxShowWordInRuntime: TCheckBox
      Left = 13
      Top = 96
      Width = 268
      Height = 17
      Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1088#1086#1094#1077#1089#1089' '#1079#1072#1087#1086#1083#1085#1077#1085#1080#1103' '#1087#1088#1086#1090#1086#1082#1086#1083#1072
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object rbReport_csv: TRadioButton
      Left = 104
      Top = 72
      Width = 52
      Height = 17
      Caption = '*.csv'
      TabOrder = 2
      OnClick = rbReport_csvClick
    end
    object LabelReportName: TEdit
      Left = 104
      Top = 16
      Width = 201
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = cl3DLight
      ReadOnly = True
      TabOrder = 3
    end
    object EditNagr: TEdit
      Left = 104
      Top = 172
      Width = 145
      Height = 21
      TabOrder = 4
    end
    object EditDate: TEdit
      Left = 104
      Top = 148
      Width = 145
      Height = 21
      TabOrder = 5
    end
    object EditNumIzd: TEdit
      Left = 104
      Top = 124
      Width = 145
      Height = 21
      TabOrder = 6
    end
    object ButtonSaveReportAs: TButton
      Left = 312
      Top = 16
      Width = 33
      Height = 25
      Caption = '...'
      TabOrder = 7
      OnClick = ButtonSaveReportAsClick
    end
    object edDigits: TSpinEdit
      Left = 277
      Top = 148
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 8
      Value = 3
    end
  end
  object ListViewSignals: TListView
    Left = 8
    Top = 72
    Width = 177
    Height = 537
    Columns = <
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 100
      end
      item
        AutoSize = True
        Caption = #1045#1076'.'#1080#1079#1084
      end>
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = DblClickSignals
    OnKeyPress = OnPressSpace
    OnSelectItem = ListViewSignalsSelectItem
  end
  object PageControlParams: TPageControl
    Left = 232
    Top = 96
    Width = 281
    Height = 489
    ActivePage = TabPressure
    TabOrder = 1
    object TabPressure: TTabSheet
      Caption = #1044#1072#1074#1083#1077#1085#1080#1077
      object Label1: TLabel
        Left = 8
        Top = 168
        Width = 184
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1085#1072#1095#1072#1083#1072' '#1101#1082#1089#1087#1077#1088#1080#1084#1077#1085#1090#1072' [To], '#1089':'
      end
      object Label2: TLabel
        Left = 8
        Top = 200
        Width = 179
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1082#1086#1085#1094#1072' '#1101#1082#1089#1087#1077#1088#1080#1084#1077#1085#1090#1072' [Tk], '#1089':'
      end
      object Label3: TLabel
        Left = 8
        Top = 240
        Width = 119
        Height = 13
        Caption = #1064#1072#1075' '#1087#1086' '#1076#1072#1074#1083#1077#1085#1080#1102' , '#1072#1090#1084':'
      end
      object Label9: TLabel
        Left = 8
        Top = 72
        Width = 179
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1085#1072#1095#1072#1083#1072' '#1088#1072#1089#1095#1077#1090#1072' '#1052#1054' [Tmo], '#1089':'
      end
      object Label10: TLabel
        Left = 8
        Top = 104
        Width = 174
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1082#1086#1085#1094#1072' '#1088#1072#1089#1095#1077#1090#1072' '#1052#1054' [Tmk], '#1089':'
      end
      object Label11: TLabel
        Left = 8
        Top = 304
        Width = 143
        Height = 13
        Caption = #1055#1077#1088#1080#1086#1076' '#1087#1086#1080#1089#1082#1072' '#1087#1077#1088#1077#1087#1072#1076#1072', '#1089':'
      end
      object Label12: TLabel
        Left = 8
        Top = 336
        Width = 187
        Height = 13
        Caption = #1055#1077#1088#1080#1086#1076' '#1101#1092#1092#1077#1082#1090#1080#1074#1085#1086#1089#1090#1080' '#1087#1077#1088#1077#1087#1072#1076#1072', '#1089':'
      end
      object Label13: TLabel
        Left = 8
        Top = 368
        Width = 148
        Height = 13
        Caption = #1052#1080#1085'. '#1082#1088#1091#1090#1080#1079#1085#1072' '#1087#1077#1088#1077#1087#1072#1076#1072', '#1077#1076'.:'
      end
      object Label14: TLabel
        Left = 8
        Top = 48
        Width = 163
        Height = 13
        Caption = #1052#1072#1090#1077#1084#1072#1090#1080#1095#1077#1089#1082#1086#1077' '#1086#1078#1080#1076#1072#1085#1080#1077
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label15: TLabel
        Left = 8
        Top = 144
        Width = 80
        Height = 13
        Caption = #1069#1082#1089#1087#1077#1088#1080#1084#1077#1085#1090
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label16: TLabel
        Left = 8
        Top = 280
        Width = 61
        Height = 13
        Caption = #1055#1077#1088#1077#1087#1072#1076#1099
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object EditPressureName: TEdit
        Left = 8
        Top = 16
        Width = 257
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = #1087#1072#1088#1072#1084#1077#1090#1088' '#1085#1077' '#1074#1099#1073#1088#1072#1085
        OnClick = EditPressureNameClick
      end
      object EditT0: TEdit
        Left = 200
        Top = 164
        Width = 65
        Height = 21
        TabOrder = 1
        Text = '0'
        OnChange = EditT0Change
        OnClick = EditT0Click
      end
      object EditTk: TEdit
        Left = 200
        Top = 196
        Width = 65
        Height = 21
        TabOrder = 2
        Text = '0'
        OnChange = EditTkChange
        OnClick = EditTkClick
      end
      object EditStep: TEdit
        Left = 200
        Top = 236
        Width = 65
        Height = 21
        TabOrder = 3
        Text = '5'
      end
      object EditTm0: TEdit
        Left = 200
        Top = 68
        Width = 65
        Height = 21
        TabOrder = 4
        Text = '0'
        OnChange = EditTm0Change
        OnClick = EditTm0Click
      end
      object EditTmk: TEdit
        Left = 200
        Top = 100
        Width = 65
        Height = 21
        TabOrder = 5
        Text = '0'
        OnChange = EditTmkChange
        OnClick = EditTmkClick
      end
      object edPikDeltaT: TEdit
        Left = 200
        Top = 300
        Width = 65
        Height = 21
        TabOrder = 6
        Text = '50'
      end
      object edPikDeltaEff: TEdit
        Left = 200
        Top = 332
        Width = 65
        Height = 21
        TabOrder = 7
        Text = '50'
      end
      object edPikKEff: TEdit
        Left = 200
        Top = 364
        Width = 65
        Height = 21
        TabOrder = 8
        Text = '0,8'
      end
    end
    object TabShifts: TTabSheet
      Caption = #1055#1077#1088#1077#1084#1077#1097#1077#1085#1080#1103
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ListViewShifts: TListView
        Left = 8
        Top = 8
        Width = 257
        Height = 441
        Columns = <
          item
            Caption = #1053#1072#1079#1074#1072#1085#1080#1077
            Width = 180
          end
          item
            AutoSize = True
            Caption = #1045#1076'.'#1080#1079#1084
          end>
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = DblClickSignals
        OnKeyPress = OnPressSpace
        OnSelectItem = ListViewSignalsSelectItem
      end
    end
    object TabDeformations: TTabSheet
      Caption = #1044#1077#1092#1086#1088#1084#1072#1094#1080#1080
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ListViewDeformations: TListView
        Left = 8
        Top = 8
        Width = 257
        Height = 441
        Columns = <
          item
            Caption = #1053#1072#1079#1074#1072#1085#1080#1077
            Width = 180
          end
          item
            AutoSize = True
            Caption = #1045#1076'.'#1080#1079#1084
          end>
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = DblClickSignals
        OnKeyPress = OnPressSpace
        OnSelectItem = ListViewSignalsSelectItem
      end
    end
  end
  object ButtonLoadFile: TButton
    Left = 152
    Top = 32
    Width = 33
    Height = 25
    Caption = '...'
    TabOrder = 2
    OnClick = ButtonLoadFileClick
  end
  object ButtonLoadCfg: TButton
    Left = 376
    Top = 56
    Width = 65
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 3
    OnClick = ButtonLoadCfgClick
  end
  object ButtonSaveCfg: TButton
    Left = 448
    Top = 56
    Width = 65
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 4
    OnClick = ButtonSaveCfgClick
  end
  object ButtonAdd: TButton
    Left = 192
    Top = 208
    Width = 33
    Height = 105
    Caption = '-->'
    TabOrder = 5
    OnClick = ButtonAddClick
  end
  object ButtonRemove: TButton
    Left = 192
    Top = 328
    Width = 33
    Height = 105
    Caption = '<--'
    TabOrder = 6
    OnClick = ButtonRemoveClick
  end
  object ChartPreview: TChart
    Left = 520
    Top = 8
    Width = 409
    Height = 329
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Gradient.Direction = gdFromCenter
    Gradient.EndColor = clWhite
    Gradient.StartColor = 14155775
    Legend.Visible = False
    Title.Text.Strings = (
      #1055#1088#1077#1076#1074#1072#1088#1080#1090#1077#1083#1100#1085#1099#1081' '#1087#1088#1086#1089#1084#1086#1090#1088)
    Pages.ScaleLastPage = False
    View3D = False
    View3DOptions.Elevation = 336
    View3DOptions.Perspective = 67
    View3DOptions.Zoom = 102
    View3DWalls = False
    BevelOuter = bvNone
    BevelWidth = 0
    Color = clWhite
    TabOrder = 7
    object Series1: TFastLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Style = smsValue
      Marks.Visible = False
      SeriesColor = clBlue
      LinePen.Color = clBlue
      LinePen.Width = 2
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series2: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.BackColor = 15395583
      Marks.Color = 15395583
      Marks.Style = smsValue
      Marks.Visible = True
      Pointer.HorizSize = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.VertSize = 2
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series3: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.BackColor = 14873060
      Marks.Color = 14873060
      Marks.Visible = True
      Pointer.HorizSize = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.VertSize = 2
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object CheckBoxPreview: TCheckBox
    Left = 520
    Top = 344
    Width = 337
    Height = 17
    Caption = #1055#1088#1077#1076#1074#1072#1088#1080#1090#1077#1083#1100#1085#1099#1081' '#1087#1088#1086#1089#1084#1086#1090#1088
    Checked = True
    State = cbChecked
    TabOrder = 8
    OnClick = CheckBoxPreviewClick
  end
  object CheckBoxInterval: TCheckBox
    Left = 520
    Top = 360
    Width = 337
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1091#1095#1072#1089#1090#1086#1082' '#1101#1082#1089#1087#1077#1088#1080#1084#1077#1085#1090#1072' [To - Tk]'
    Checked = True
    State = cbChecked
    TabOrder = 9
    OnClick = CheckBoxIntervalClick
  end
  object ButtonExecute: TButton
    Left = 808
    Top = 592
    Width = 121
    Height = 25
    Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1088#1072#1089#1095#1077#1090
    TabOrder = 10
    OnClick = ButtonExecuteClick
  end
  object ButtonClear: TButton
    Left = 232
    Top = 592
    Width = 89
    Height = 25
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100
    TabOrder = 12
    OnClick = ButtonClearClick
  end
  object ProgressBar1: TProgressBar
    Left = 520
    Top = 600
    Width = 281
    Height = 16
    TabOrder = 13
  end
  object LabelFileName: TEdit
    Left = 8
    Top = 32
    Width = 137
    Height = 21
    Color = cl3DLight
    ReadOnly = True
    TabOrder = 14
  end
  object LabelCfgName: TEdit
    Left = 232
    Top = 32
    Width = 281
    Height = 21
    Color = cl3DLight
    ReadOnly = True
    TabOrder = 15
  end
  object OpenCfgDialog: TOpenDialog
    DefaultExt = '*.cfg'
    FileName = 'default.cfg'
    Filter = #1060#1072#1081#1083#1099' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1080' (*.cfg)|*.cfg'
    Left = 72
    Top = 592
  end
  object SaveCfgDialog: TSaveDialog
    DefaultExt = '*.cfg'
    FileName = 'default.cfg'
    Filter = #1060#1072#1081#1083#1099' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1080' (*.cfg)|*.cfg'
    Left = 112
    Top = 592
  end
  object SaveReportDialog: TSaveDialog
    DefaultExt = '*.doc'
    FileName = 'report.doc'
    Filter = #1060#1072#1081#1083#1099' '#1086#1090#1095#1077#1090#1086#1074' (*.doc)|*.doc'
    Left = 152
    Top = 592
  end
end

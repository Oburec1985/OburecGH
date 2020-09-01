object FFTFltFrm: TFFTFltFrm
  Left = 0
  Top = 0
  Caption = 'FFT '#1092#1080#1083#1100#1090#1088
  ClientHeight = 734
  ClientWidth = 1261
  Color = clBtnFace
  Constraints.MinHeight = 237
  Constraints.MinWidth = 593
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Splitter1: TSplitter
    Left = 819
    Top = 0
    Width = 5
    Height = 640
    Align = alRight
    Color = clHighlight
    ParentColor = False
    ExplicitLeft = 818
  end
  object ActionPanel: TPanel
    Left = 0
    Top = 640
    Width = 1261
    Height = 94
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      1261
      94)
    object ApplyBtn: TButton
      Left = 19
      Top = 16
      Width = 104
      Height = 59
      Anchors = [akLeft, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 14
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
    end
  end
  object RightPanel: TPanel
    Left = 824
    Top = 0
    Width = 437
    Height = 640
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 153
      Top = 1
      Width = 5
      Height = 638
      Color = clHighlight
      ParentColor = False
      ExplicitLeft = 87
      ExplicitTop = 27
    end
    object ScalesLV: TBtnListView
      Left = 1
      Top = 1
      Width = 152
      Height = 638
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      Columns = <
        item
          Caption = #1048#1085#1076'.'
          Width = 38
        end
        item
          Caption = 'F'
        end
        item
          Caption = 'Scale'
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      MultiSelect = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnKeyDown = ScalesLVKeyDown
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
    object SignalsLV: TBtnListView
      Left = 158
      Top = 1
      Width = 278
      Height = 638
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #1048#1085#1076'.'
          Width = 38
        end
        item
          Caption = #1057#1080#1075#1085#1072#1083#1099
        end
        item
          Caption = 'Fs'
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      MultiSelect = True
      RowSelect = True
      ParentFont = False
      TabOrder = 1
      ViewStyle = vsReport
      OnKeyDown = ScalesLVKeyDown
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
  object EditCurvePanel: TPanel
    Left = 0
    Top = 0
    Width = 313
    Height = 640
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    Color = clActiveCaption
    ParentBackground = False
    TabOrder = 2
    DesignSize = (
      313
      640)
    object F1Label: TLabel
      Left = 2
      Top = 8
      Width = 87
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1053#1072#1095#1072#1083#1086' '#1087#1086#1083#1086#1089#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object F2Label: TLabel
      Left = 104
      Top = 8
      Width = 81
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1086#1085#1077#1094' '#1087#1086#1083#1086#1089#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object F1indLabel: TLabel
      Left = 2
      Top = 58
      Width = 52
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1085#1076#1077#1082#1089' 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object F2indLabel: TLabel
      Left = 104
      Top = 58
      Width = 52
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1085#1076#1077#1082#1089' 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 2
      Top = 100
      Width = 48
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1052#1072#1089#1096#1090#1072#1073
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object FFTCountLabel: TLabel
      Left = 6
      Top = 188
      Width = 59
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1058#1086#1095#1077#1082' FFT'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object OffsetLabel: TLabel
      Left = 5
      Top = 243
      Width = 105
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1087#1086#1088#1094#1080#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object dFLabel: TLabel
      Left = 120
      Top = 211
      Width = 22
      Height = 14
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'dF='
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Indexse_01: TSpinEdit
      Left = 2
      Top = 74
      Width = 98
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object Indexse_02: TSpinEdit
      Left = 104
      Top = 74
      Width = 73
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object SetScaleBtn: TButton
      Left = 104
      Top = 117
      Width = 97
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = SetScaleBtnClick
    end
    object OffsetSE: TSpinEdit
      Left = 5
      Top = 263
      Width = 74
      Height = 23
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 3
      Value = 2048
    end
    object pCountIE: TIntEdit
      Left = 6
      Top = 210
      Width = 73
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = '512'
    end
    object pCountBtn: TSpinButton
      Left = 85
      Top = 208
      Width = 20
      Height = 25
      DownGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000008080000080800000808000000000000080800000808000008080000080
        8000008080000080800000808000000000000000000000000000008080000080
        8000008080000080800000808000000000000000000000000000000000000000
        0000008080000080800000808000000000000000000000000000000000000000
        0000000000000000000000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      TabOrder = 5
      UpGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000000000000000000000000000000000000000000000000000000000000080
        8000008080000080800000000000000000000000000000000000000000000080
        8000008080000080800000808000008080000000000000000000000000000080
        8000008080000080800000808000008080000080800000808000000000000080
        8000008080000080800000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      OnDownClick = pCountBtnDownClick
      OnUpClick = pCountBtnUpClick
    end
    object EditScaleBtn: TButton
      Left = 104
      Top = 150
      Width = 97
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = EditScaleBtnClick
    end
    object F1SE: TFloatSpinEdit
      Left = 2
      Top = 27
      Width = 97
      Height = 21
      Increment = 0.100000000000000000
      TabOrder = 7
    end
    object f2se: TFloatSpinEdit
      Left = 105
      Top = 27
      Width = 97
      Height = 21
      Increment = 0.100000000000000000
      TabOrder = 8
    end
    object ScaleSE: TFloatSpinEdit
      Left = 2
      Top = 119
      Width = 97
      Height = 21
      Increment = 0.100000000000000000
      TabOrder = 9
    end
    object SaveCfgCB: TComboBox
      Left = 2
      Top = 370
      Width = 226
      Height = 20
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      Text = 'C:\Winpos\FFTFltCfg\test.txt'
    end
    object SaveBtn: TButton
      Left = 234
      Top = 368
      Width = 74
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 11
      OnClick = SaveBtnClick
    end
    object LoadCfgCB: TComboBox
      Left = 2
      Top = 342
      Width = 225
      Height = 20
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
      Anchors = [akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      Text = 'C:\Winpos\FFTFltCfg\test.txt'
      OnChange = LoadCfgCBChange
    end
    object LoadBtn: TButton
      Left = 233
      Top = 338
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 13
      OnClick = LoadBtnClick
    end
  end
  object ScaleCurveChart: cChart
    Left = 313
    Top = 0
    Width = 506
    Height = 640
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Caption = 'ScaleCurveChart'
    TabOrder = 3
    allowEditPages = False
    showTV = False
    showLegend = True
    selectSize = 5
  end
  object OpenDialog1: TOpenDialog
    Left = 261
    Top = 283
  end
end

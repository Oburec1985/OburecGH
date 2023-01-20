object FFTFltFrm: TFFTFltFrm
  Left = 0
  Top = 0
  Caption = 'FFT '#1092#1080#1083#1100#1090#1088
  ClientHeight = 694
  ClientWidth = 1314
  Color = clBtnFace
  Constraints.MinHeight = 316
  Constraints.MinWidth = 791
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 489
    Top = 0
    Width = 243
    Height = 568
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Color = clHighlight
    ParentColor = False
    ExplicitLeft = 856
    ExplicitHeight = 853
  end
  object ActionPanel: TPanel
    Left = 0
    Top = 568
    Width = 1314
    Height = 126
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 853
    ExplicitWidth = 1681
    DesignSize = (
      1314
      126)
    object ApplyBtn: TButton
      Left = 25
      Top = 21
      Width = 139
      Height = 79
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 18
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
    end
  end
  object RightPanel: TPanel
    Left = 732
    Top = 0
    Width = 582
    Height = 568
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 1099
    ExplicitHeight = 853
    object Splitter2: TSplitter
      Left = 204
      Top = 1
      Width = 7
      Height = 566
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Color = clHighlight
      ParentColor = False
      ExplicitHeight = 851
    end
    object ScalesLV: TBtnListView
      Left = 1
      Top = 1
      Width = 203
      Height = 566
      Align = alLeft
      Columns = <
        item
          Caption = #1048#1085#1076'.'
          Width = 51
        end
        item
          Caption = 'F'
          Width = 67
        end
        item
          Caption = 'Scale'
          Width = 67
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      MultiSelect = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = ScalesLVClick
      OnKeyDown = ScalesLVKeyDown
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
      ExplicitHeight = 851
    end
    object SignalsLV: TBtnListView
      Left = 211
      Top = 1
      Width = 370
      Height = 566
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #1048#1085#1076'.'
          Width = 51
        end
        item
          Caption = #1057#1080#1075#1085#1072#1083#1099
          Width = 67
        end
        item
          Caption = 'Fs'
          Width = 67
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
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
      ExplicitHeight = 851
    end
  end
  object EditCurvePanel: TPanel
    Left = 0
    Top = 0
    Width = 417
    Height = 568
    Align = alLeft
    Color = clActiveCaption
    ParentBackground = False
    TabOrder = 2
    ExplicitHeight = 853
    DesignSize = (
      417
      568)
    object F1Label: TLabel
      Left = 3
      Top = 11
      Width = 104
      Height = 18
      Caption = #1053#1072#1095#1072#1083#1086' '#1087#1086#1083#1086#1089#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object F2Label: TLabel
      Left = 139
      Top = 11
      Width = 96
      Height = 18
      Caption = #1050#1086#1085#1077#1094' '#1087#1086#1083#1086#1089#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object F1indLabel: TLabel
      Left = 3
      Top = 77
      Width = 61
      Height = 18
      Caption = #1048#1085#1076#1077#1082#1089' 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object F2indLabel: TLabel
      Left = 139
      Top = 77
      Width = 61
      Height = 18
      Caption = #1048#1085#1076#1077#1082#1089' 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 3
      Top = 133
      Width = 63
      Height = 18
      Caption = #1052#1072#1089#1096#1090#1072#1073
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object FFTCountLabel: TLabel
      Left = 8
      Top = 251
      Width = 72
      Height = 18
      Caption = #1058#1086#1095#1077#1082' FFT'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object OffsetLabel: TLabel
      Left = 7
      Top = 324
      Width = 126
      Height = 18
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1087#1086#1088#1094#1080#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object dFLabel: TLabel
      Left = 160
      Top = 281
      Width = 27
      Height = 18
      Caption = 'dF='
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Indexse_01: TSpinEdit
      Left = 3
      Top = 99
      Width = 130
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object Indexse_02: TSpinEdit
      Left = 139
      Top = 99
      Width = 97
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object SetScaleBtn: TButton
      Left = 139
      Top = 156
      Width = 129
      Height = 37
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = SetScaleBtnClick
    end
    object OffsetSE: TSpinEdit
      Left = 7
      Top = 351
      Width = 98
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 3
      Value = 2048
    end
    object pCountIE: TIntEdit
      Left = 8
      Top = 280
      Width = 97
      Height = 26
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = '512'
    end
    object pCountBtn: TSpinButton
      Left = 113
      Top = 277
      Width = 27
      Height = 34
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
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
      Left = 139
      Top = 200
      Width = 129
      Height = 37
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = EditScaleBtnClick
    end
    object F1SE: TFloatSpinEdit
      Left = 3
      Top = 36
      Width = 129
      Height = 26
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 7
    end
    object f2se: TFloatSpinEdit
      Left = 140
      Top = 36
      Width = 129
      Height = 26
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 8
    end
    object ScaleSE: TFloatSpinEdit
      Left = 3
      Top = 159
      Width = 129
      Height = 26
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 9
    end
    object SaveCfgCB: TComboBox
      Left = 3
      Top = 493
      Width = 301
      Height = 24
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      Text = 'C:\Winpos\FFTFltCfg\test.txt'
    end
    object SaveBtn: TButton
      Left = 312
      Top = 491
      Width = 99
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 11
      OnClick = SaveBtnClick
    end
    object LoadCfgCB: TComboBox
      Left = 3
      Top = 456
      Width = 300
      Height = 24
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      Text = 'C:\Winpos\FFTFltCfg\test.txt'
      OnChange = LoadCfgCBChange
    end
    object LoadBtn: TButton
      Left = 311
      Top = 451
      Width = 100
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 13
      OnClick = LoadBtnClick
    end
  end
  object ScaleCurveChart: cChart
    Left = 417
    Top = 0
    Width = 72
    Height = 568
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

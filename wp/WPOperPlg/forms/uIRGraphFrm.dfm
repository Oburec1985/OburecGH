object IRGraphFrm: TIRGraphFrm
  Left = 0
  Top = 0
  Caption = 'IRGraphFrm'
  ClientHeight = 670
  ClientWidth = 1044
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    1044
    670)
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 520
    Top = 0
    Width = 4
    Height = 670
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Color = clBackground
    ParentColor = False
    ExplicitLeft = 438
  end
  object FFTCountLabel: TLabel
    Left = 29
    Top = 89
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
    Left = 27
    Top = 255
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
    Left = 178
    Top = 109
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
  object TahoLabel: TLabel
    Left = 29
    Top = 434
    Width = 34
    Height = 18
    Caption = #1058#1072#1093#1086
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object BlockSizeLabel: TLabel
    Left = 178
    Top = 131
    Width = 136
    Height = 18
    Caption = #1056#1072#1079#1084#1077#1088' '#1073#1083#1086#1082#1072', '#1089#1077#1082'='
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 402
    Top = 64
    Width = 60
    Height = 18
    Caption = #1064#1072#1075', '#1089#1077#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Label3: TLabel
    Left = 29
    Top = 174
    Width = 93
    Height = 18
    Caption = #1063#1080#1089#1083#1086' '#1073#1083#1086#1082#1086#1074
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 30
    Top = 16
    Width = 73
    Height = 18
    Caption = #1057#1090#1072#1088#1090', '#1089#1077#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 155
    Top = 16
    Width = 65
    Height = 18
    Caption = #1057#1090#1086#1087', '#1089#1077#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 29
    Top = 340
    Width = 34
    Height = 18
    Caption = #1054#1082#1085#1086
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object pCountBtn: TSpinButton
    Left = 132
    Top = 115
    Width = 26
    Height = 33
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
    TabOrder = 0
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
    OnDownClick = FFTdecrease
    OnUpClick = FFTincrease
  end
  object FFTpoints: TIntEdit
    Left = 29
    Top = 118
    Width = 95
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
    ReadOnly = True
    TabOrder = 1
    Text = '512'
  end
  object OffsetSE: TSpinEdit
    Left = 27
    Top = 281
    Width = 97
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxValue = 0
    MinValue = 0
    ParentFont = False
    TabOrder = 2
    Value = 2048
    OnChange = OffsetSEChange
  end
  object LoadCfgCB: TComboBox
    Left = 29
    Top = 460
    Width = 176
    Height = 25
    Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    Text = #1089#1080#1075#1085#1072#1083' '#1090#1072#1093#1086
    OnDragDrop = LoadCfgCBDragDrop
    OnDragOver = LoadCfgCBDragOver
  end
  object RightPanel: TPanel
    Left = 524
    Top = 0
    Width = 520
    Height = 670
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    TabOrder = 4
    object SearchPanel: TPanel
      Left = 1
      Top = 1
      Width = 518
      Height = 74
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      DesignSize = (
        518
        74)
      object SearchLabel: TLabel
        Left = 8
        Top = 14
        Width = 28
        Height = 18
        Caption = #1048#1084#1103
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object SearchE: TEdit
        Left = 7
        Top = 38
        Width = 485
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        ShowHint = False
        TabOrder = 0
        TextHint = #1087#1086#1080#1089#1082
        OnChange = SearchTextChanged
      end
    end
    object SignalsLV: TBtnListView
      Left = 1
      Top = 75
      Width = 518
      Height = 594
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #8470
          Width = 65
        end
        item
          Caption = #1048#1084#1103
          Width = 65
        end
        item
          Caption = 'Fs'
          Width = 65
        end>
      DragMode = dmAutomatic
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnSelectItem = GetFS
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
  object blocksAmount: TSpinEdit
    Left = 29
    Top = 200
    Width = 97
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxValue = 0
    MinValue = 0
    ParentFont = False
    TabOrder = 5
    Value = 1
    OnChange = OnBlocksChange
  end
  object CheckBox1: TCheckBox
    Left = 178
    Top = 284
    Width = 223
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1089#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1089#1084#1077#1097#1077#1085#1080#1077
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = CheckBox1Click
  end
  object Button1: TButton
    Left = 29
    Top = 554
    Width = 98
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1056#1072#1089#1095#1105#1090
    TabOrder = 7
    OnClick = Button1Click
  end
  object t1FE: TFloatEdit
    Left = 30
    Top = 39
    Width = 95
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ReadOnly = True
    TabOrder = 8
    Text = '1'
    OnChange = OnStepChange
  end
  object t2FE: TFloatEdit
    Left = 155
    Top = 39
    Width = 96
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ReadOnly = True
    TabOrder = 9
    Text = '1'
    OnChange = OnStepChange
  end
  object CheckBox2: TCheckBox
    Left = 259
    Top = 40
    Width = 253
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Caption = #1089#1090#1072#1088#1090'-'#1089#1090#1086#1087
    State = cbGrayed
    TabOrder = 10
    OnClick = CheckBox2Click
  end
  object WndCB: TComboBox
    Left = 30
    Top = 374
    Width = 175
    Height = 25
    Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 4
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    Text = 'FLAT-TOP'
    Items.Strings = (
      #1055#1088#1103#1084#1086#1091#1075#1086#1083#1100#1085#1086#1077
      #1058#1088#1077#1091#1075#1086#1083#1100#1085#1086#1077
      #1061#1072#1085#1085#1080#1085#1075
      #1041#1083#1101#1082#1084#1072#1085
      'FLAT-TOP')
  end
  object StepBox: TFloatEdit
    Left = 402
    Top = 87
    Width = 96
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ReadOnly = True
    TabOrder = 12
    Text = '1'
    Visible = False
    OnChange = OnStepChange
  end
end

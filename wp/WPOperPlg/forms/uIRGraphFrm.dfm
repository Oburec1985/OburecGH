object IRGraphFrm: TIRGraphFrm
  Left = 0
  Top = 0
  Caption = 'IRGraphFrm'
  ClientHeight = 512
  ClientWidth = 736
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    736
    512)
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 335
    Top = 0
    Height = 512
    Align = alRight
    Color = clBackground
    ParentColor = False
    ExplicitLeft = 673
    ExplicitTop = 8
    ExplicitHeight = 469
  end
  object FFTCountLabel: TLabel
    Left = 22
    Top = 68
    Width = 51
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1058#1086#1095#1077#1082' FFT'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OffsetLabel: TLabel
    Left = 21
    Top = 195
    Width = 91
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1087#1086#1088#1094#1080#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object dFLabel: TLabel
    Left = 136
    Top = 83
    Width = 20
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'dF='
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object TahoLabel: TLabel
    Left = 22
    Top = 332
    Width = 24
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1058#1072#1093#1086
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object BlockSizeLabel: TLabel
    Left = 136
    Top = 100
    Width = 100
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1056#1072#1079#1084#1077#1088' '#1073#1083#1086#1082#1072', '#1089#1077#1082'='
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 21
    Top = 12
    Width = 45
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1064#1072#1075', '#1089#1077#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 22
    Top = 133
    Width = 69
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1063#1080#1089#1083#1086' '#1073#1083#1086#1082#1086#1074
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 136
    Top = 12
    Width = 55
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1090#1072#1088#1090', '#1089#1077#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 232
    Top = 12
    Width = 49
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1090#1086#1087', '#1089#1077#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 22
    Top = 260
    Width = 24
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1058#1072#1093#1086
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object pCountBtn: TSpinButton
    Left = 101
    Top = 88
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
    Left = 22
    Top = 90
    Width = 73
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    Text = '512'
  end
  object OffsetSE: TSpinEdit
    Left = 21
    Top = 215
    Width = 74
    Height = 22
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
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
    Left = 22
    Top = 352
    Width = 241
    Height = 21
    Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    Text = #1089#1080#1075#1085#1072#1083' '#1090#1072#1093#1086
    OnDragDrop = LoadCfgCBDragDrop
    OnDragOver = LoadCfgCBDragOver
  end
  object RightPanel: TPanel
    Left = 338
    Top = 0
    Width = 398
    Height = 512
    Align = alRight
    TabOrder = 4
    object SearchPanel: TPanel
      Left = 1
      Top = 1
      Width = 396
      Height = 56
      Align = alTop
      TabOrder = 0
      DesignSize = (
        396
        56)
      object SearchLabel: TLabel
        Left = 6
        Top = 11
        Width = 19
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1048#1084#1103
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object SearchE: TEdit
        Left = 5
        Top = 29
        Width = 371
        Height = 21
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
      Top = 57
      Width = 396
      Height = 454
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = #1048#1084#1103
        end
        item
          Caption = 'Fs'
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
      ExplicitLeft = 6
      ExplicitTop = 63
    end
  end
  object StepBox: TFloatEdit
    Left = 21
    Top = 30
    Width = 73
    Height = 21
    ReadOnly = True
    TabOrder = 5
    Text = '1'
    OnChange = OnStepChange
  end
  object blocksAmount: TSpinEdit
    Left = 22
    Top = 153
    Width = 74
    Height = 22
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxValue = 0
    MinValue = 0
    ParentFont = False
    TabOrder = 6
    Value = 1
    OnChange = OnBlocksChange
  end
  object CheckBox1: TCheckBox
    Left = 136
    Top = 217
    Width = 171
    Height = 17
    Caption = #1089#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1089#1084#1077#1097#1077#1085#1080#1077
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = CheckBox1Click
  end
  object Button1: TButton
    Left = 22
    Top = 424
    Width = 75
    Height = 25
    Caption = #1056#1072#1089#1095#1105#1090
    TabOrder = 8
    OnClick = Button1Click
  end
  object t1FE: TFloatEdit
    Left = 136
    Top = 30
    Width = 73
    Height = 21
    ReadOnly = True
    TabOrder = 9
    Text = '1'
    OnChange = OnStepChange
  end
  object t2FE: TFloatEdit
    Left = 232
    Top = 30
    Width = 73
    Height = 21
    ReadOnly = True
    TabOrder = 10
    Text = '1'
    OnChange = OnStepChange
  end
  object CheckBox2: TCheckBox
    Left = 136
    Top = 67
    Width = 185
    Height = 17
    Caption = #1089#1090#1072#1088#1090'-'#1089#1090#1086#1087
    State = cbGrayed
    TabOrder = 11
    OnClick = CheckBox2Click
  end
  object WndCB: TComboBox
    Left = 23
    Top = 286
    Width = 240
    Height = 21
    Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1076#1089#1082#1072#1079#1082#1080
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 4
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
    Text = 'FLAT-TOP'
    Items.Strings = (
      #1055#1088#1103#1084#1086#1091#1075#1086#1083#1100#1085#1086#1077
      #1058#1088#1077#1091#1075#1086#1083#1100#1085#1086#1077
      #1061#1072#1085#1085#1080#1085#1075
      #1041#1083#1101#1082#1084#1072#1085
      'FLAT-TOP')
  end
end

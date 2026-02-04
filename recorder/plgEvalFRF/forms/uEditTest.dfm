object EditTestFrm: TEditTestFrm
  Left = 0
  Top = 0
  Caption = 'EditTestFrm'
  ClientHeight = 626
  ClientWidth = 1097
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 120
  TextHeight = 24
  object TestGB: TGroupBox
    Left = 0
    Top = 0
    Width = 1097
    Height = 311
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TurbLabel: TLabel
      Left = 8
      Top = 40
      Width = 136
      Height = 27
      Caption = #1058#1080#1087' '#1090#1091#1088#1073#1080#1085#1099':'
    end
    object StageLabel: TLabel
      Left = 8
      Top = 93
      Width = 89
      Height = 27
      Caption = #1057#1090#1091#1087#1077#1085#1100':'
    end
    object SketchLabel: TLabel
      Left = 8
      Top = 149
      Width = 172
      Height = 27
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object Splitter2: TSplitter
      Left = 628
      Top = 29
      Width = 4
      Height = 280
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Color = clBackground
      ParentColor = False
      OnMoved = Splitter2Moved
      ExplicitLeft = 754
      ExplicitHeight = 264
    end
    object blNumSE: TLabel
      Left = 6
      Top = 202
      Width = 161
      Height = 27
      Caption = #1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object BlCountLabel: TLabel
      Left = 452
      Top = 147
      Width = 165
      Height = 27
      Caption = #1050#1086#1083'-'#1074#1086' '#1083#1086#1087#1072#1090#1086#1082':'
    end
    object TNameLabel: TLabel
      Left = 374
      Top = 40
      Width = 49
      Height = 27
      Caption = #1048#1084#1103':'
    end
    object StageCountLabel: TLabel
      Left = 374
      Top = 93
      Width = 77
      Height = 27
      Caption = #1050#1086#1083'-'#1074#1086':'
    end
    object TurbCB: TComboBox
      Left = 180
      Top = 37
      Width = 190
      Height = 35
      TabOrder = 0
      Text = 'TurbCB'
      OnChange = TurbCBChange
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object StageCB: TComboBox
      Left = 180
      Top = 90
      Width = 190
      Height = 35
      TabOrder = 1
      Text = '1'
      OnChange = StageCBChange
      Items.Strings = (
        '1')
    end
    object BladeCB: TComboBox
      Left = 180
      Top = 149
      Width = 190
      Height = 35
      TabOrder = 2
      Text = '1'
      OnChange = BladeCBChange
      Items.Strings = (
        '1')
    end
    object BladeSe: TSpinEdit
      Left = 180
      Top = 198
      Width = 190
      Height = 38
      MaxValue = 1000
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = BladeSeChange
    end
    object TurbNameCb: TComboBox
      Left = 452
      Top = 37
      Width = 171
      Height = 35
      TabOrder = 4
      Text = 'TurbCB'
      OnChange = TurbNameCbChange
      OnKeyDown = TurbNameCbKeyDown
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object BlCountIE: TSpinEdit
      Left = 452
      Top = 178
      Width = 171
      Height = 38
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 0
      OnChange = BlCountIEChange
    end
    object StageCountSE: TSpinEdit
      Left = 452
      Top = 90
      Width = 171
      Height = 38
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 0
    end
    object SideCB: TCheckBox
      Left = 8
      Top = 254
      Width = 187
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1051#1077#1074#1072#1103' '#1083#1086#1087#1072#1090#1082#1072
      TabOrder = 7
      OnClick = SideCBClick
    end
    object BladesGB: TGroupBox
      Left = 632
      Top = 29
      Width = 463
      Height = 280
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Caption = #1051#1086#1087#1072#1090#1082#1080
      TabOrder = 8
      object BladesLV: TBtnListView
        Left = 2
        Top = 81
        Width = 459
        Height = 197
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        Columns = <
          item
            Caption = #8470
            Width = 63
          end
          item
            Caption = 'sn'
            Width = 63
          end
          item
            Caption = #1058#1080#1087
            Width = 63
          end>
        MultiSelect = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = BladesLVChange
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ChangeTextColor = False
        Editable = False
      end
      object BladesControlPan: TPanel
        Left = 2
        Top = 29
        Width = 459
        Height = 52
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alTop
        TabOrder = 1
        object SelectAllCb: TCheckBox
          Left = 5
          Top = 10
          Width = 187
          Height = 22
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1042#1099#1073#1088#1072#1090#1100' '#1074#1089#1077
          TabOrder = 0
          OnClick = SelectAllCbClick
        end
      end
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 311
    Width = 1097
    Height = 211
    Align = alBottom
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object ThresholdLabel: TLabel
      Left = 14
      Top = 69
      Width = 114
      Height = 27
      Caption = #1044#1086#1087#1091#1089#1082', %:'
    end
    object Label1: TLabel
      Left = 16
      Top = 117
      Width = 130
      Height = 27
      Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
    end
    object DateLabel: TLabel
      Left = 16
      Top = 165
      Width = 49
      Height = 27
      Caption = #1044#1072#1090#1072
    end
    object Splitter1: TSplitter
      Left = 628
      Top = 29
      Width = 4
      Height = 180
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 801
      ExplicitHeight = 179
    end
    object Label2: TLabel
      Left = 305
      Top = 36
      Width = 142
      Height = 27
      Caption = #1050#1086#1083'-'#1074#1086' '#1087#1086#1083#1086#1089':'
    end
    object ThresholdSE: TFloatSpinEdit
      Left = 150
      Top = 66
      Width = 144
      Height = 38
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 5.000000000000000000
    end
    object PersonE: TEdit
      Left = 150
      Top = 110
      Width = 144
      Height = 35
      TabOrder = 1
      Text = 'PersonE'
    end
    object ProfileSG: TStringGridExt
      Left = 632
      Top = 29
      Width = 463
      Height = 180
      Hint = 
        #1078#1077#1083#1090#1099#1081' - '#1091' '#1086#1073#1098#1077#1082#1090#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1082#1086#1090#1086#1088#1086#1077' '#1077#1089#1090#1100' '#1091' '#1090#1080#1087#1072'. '#1047#1077#1083#1077 +
        #1085#1099#1081' - '#1091' '#1090#1080#1087#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1087#1088#1080#1089#1091#1090#1089#1090#1074#1091#1102#1097#1077#1077' '#1091' '#1086#1073#1098#1077#1082#1090#1072
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -22
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 2
      OnKeyDown = ProfileSGKeyDown
      RowHeights = (
        24
        24
        24
        24
        23)
    end
    object BandCountIE: TSpinEdit
      Left = 305
      Top = 66
      Width = 135
      Height = 38
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = BandCountIEChange
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 522
    Width = 1097
    Height = 104
    Align = alBottom
    Caption = #1055#1072#1088#1072#1077#1084#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object OkBtn: TButton
      Left = 13
      Top = 40
      Width = 131
      Height = 48
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = OkBtnClick
    end
  end
end

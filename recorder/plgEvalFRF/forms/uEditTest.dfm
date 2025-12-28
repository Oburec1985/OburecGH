object EditTestFrm: TEditTestFrm
  Left = 0
  Top = 0
  Caption = 'EditTestFrm'
  ClientHeight = 484
  ClientWidth = 969
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 19
  object TestGB: TGroupBox
    Left = 0
    Top = 0
    Width = 969
    Height = 234
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TurbLabel: TLabel
      Left = 13
      Top = 32
      Width = 107
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1058#1080#1087' '#1090#1091#1088#1073#1080#1085#1099':'
    end
    object StageLabel: TLabel
      Left = 13
      Top = 74
      Width = 70
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1090#1091#1087#1077#1085#1100':'
    end
    object SketchLabel: TLabel
      Left = 13
      Top = 124
      Width = 132
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object Splitter2: TSplitter
      Left = 695
      Top = 23
      Height = 209
      Align = alRight
      Color = clBackground
      ParentColor = False
      OnMoved = Splitter2Moved
      ExplicitLeft = 509
      ExplicitHeight = 210
    end
    object blNumSE: TLabel
      Left = 11
      Top = 160
      Width = 123
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object BlCountLabel: TLabel
      Left = 296
      Top = 160
      Width = 58
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1086#1083'-'#1074#1086':'
    end
    object TNameLabel: TLabel
      Left = 296
      Top = 32
      Width = 37
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1084#1103':'
    end
    object StageCountLabel: TLabel
      Left = 296
      Top = 74
      Width = 58
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1086#1083'-'#1074#1086':'
    end
    object TurbCB: TComboBox
      Left = 149
      Top = 29
      Width = 135
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
      Text = 'TurbCB'
      OnChange = TurbCBChange
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object StageCB: TComboBox
      Left = 149
      Top = 71
      Width = 135
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = '1'
      OnChange = StageCBChange
      Items.Strings = (
        '1')
    end
    object BladeCB: TComboBox
      Left = 149
      Top = 124
      Width = 135
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 2
      Text = '1'
      Items.Strings = (
        '1')
    end
    object ObjPropSG: TStringGridExt
      Left = 698
      Top = 23
      Width = 269
      Height = 209
      Hint = 
        #1078#1077#1083#1090#1099#1081' - '#1091' '#1086#1073#1098#1077#1082#1090#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1082#1086#1090#1086#1088#1086#1077' '#1077#1089#1090#1100' '#1091' '#1090#1080#1087#1072'. '#1047#1077#1083#1077 +
        #1085#1099#1081' - '#1091' '#1090#1080#1087#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1087#1088#1080#1089#1091#1090#1089#1090#1074#1091#1102#1097#1077#1077' '#1091' '#1086#1073#1098#1077#1082#1090#1072
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 3
      RowHeights = (
        24
        24
        24
        24
        24)
    end
    object BladeSe: TSpinEdit
      Left = 149
      Top = 157
      Width = 135
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 1000
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = BladeSeChange
    end
    object TurbNameCb: TComboBox
      Left = 358
      Top = 29
      Width = 135
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 5
      Text = 'TurbCB'
      OnChange = TurbNameCbChange
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object BlCountIE: TSpinEdit
      Left = 358
      Top = 157
      Width = 135
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 0
      OnChange = BlCountIEChange
    end
    object StageCountSE: TSpinEdit
      Left = 358
      Top = 71
      Width = 135
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 7
      Value = 0
    end
    object SideCB: TCheckBox
      Left = 13
      Top = 201
      Width = 148
      Height = 17
      Caption = #1051#1077#1074#1072#1103' '#1083#1086#1087#1072#1090#1082#1072
      TabOrder = 8
      OnClick = SideCBClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 234
    Width = 969
    Height = 167
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object ThresholdLabel: TLabel
      Left = 11
      Top = 55
      Width = 88
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1086#1087#1091#1089#1082', %:'
    end
    object Label1: TLabel
      Left = 13
      Top = 93
      Width = 102
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
    end
    object DateLabel: TLabel
      Left = 13
      Top = 131
      Width = 38
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1072#1090#1072
    end
    object Splitter1: TSplitter
      Left = 634
      Top = 23
      Height = 142
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 448
    end
    object Label2: TLabel
      Left = 379
      Top = 26
      Width = 108
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1086#1083'-'#1074#1086' '#1087#1086#1083#1086#1089':'
    end
    object ThresholdSE: TFloatSpinEdit
      Left = 119
      Top = 52
      Width = 114
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 5.000000000000000000
    end
    object PersonE: TEdit
      Left = 119
      Top = 87
      Width = 114
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = 'PersonE'
    end
    object ProfileSG: TStringGridExt
      Left = 637
      Top = 23
      Width = 330
      Height = 142
      Hint = 
        #1078#1077#1083#1090#1099#1081' - '#1091' '#1086#1073#1098#1077#1082#1090#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1082#1086#1090#1086#1088#1086#1077' '#1077#1089#1090#1100' '#1091' '#1090#1080#1087#1072'. '#1047#1077#1083#1077 +
        #1085#1099#1081' - '#1091' '#1090#1080#1087#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1087#1088#1080#1089#1091#1090#1089#1090#1074#1091#1102#1097#1077#1077' '#1091' '#1086#1073#1098#1077#1082#1090#1072
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
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
      Left = 494
      Top = 24
      Width = 135
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = BandCountIEChange
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 401
    Width = 969
    Height = 83
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    Caption = #1055#1072#1088#1072#1077#1084#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object OkBtn: TButton
      Left = 0
      Top = 32
      Width = 104
      Height = 38
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = OkBtnClick
    end
  end
end

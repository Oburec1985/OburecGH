object EditTestFrm: TEditTestFrm
  Left = 0
  Top = 0
  Caption = 'EditTestFrm'
  ClientHeight = 593
  ClientWidth = 894
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 24
  object TestGB: TGroupBox
    Left = 0
    Top = 0
    Width = 894
    Height = 273
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 923
    object TurbLabel: TLabel
      Left = 16
      Top = 40
      Width = 124
      Height = 24
      Caption = #1058#1080#1087' '#1090#1091#1088#1073#1080#1085#1099':'
    end
    object StageLabel: TLabel
      Left = 16
      Top = 83
      Width = 81
      Height = 24
      Caption = #1057#1090#1091#1087#1077#1085#1100':'
    end
    object SketchLabel: TLabel
      Left = 16
      Top = 126
      Width = 157
      Height = 24
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object Splitter2: TSplitter
      Left = 467
      Top = 26
      Width = 4
      Height = 245
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 2
      ExplicitHeight = 577
    end
    object blNumSE: TLabel
      Left = 16
      Top = 174
      Width = 157
      Height = 24
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object TurbCB: TComboBox
      Left = 186
      Top = 37
      Width = 170
      Height = 32
      TabOrder = 0
      Text = 'TurbCB'
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object StageCB: TComboBox
      Left = 186
      Top = 80
      Width = 170
      Height = 32
      TabOrder = 1
      Text = '1'
      Items.Strings = (
        '1')
    end
    object BladeCB: TComboBox
      Left = 186
      Top = 123
      Width = 170
      Height = 32
      TabOrder = 2
      Text = '1'
      Items.Strings = (
        '1')
    end
    object ObjPropSG: TStringGridExt
      Left = 471
      Top = 26
      Width = 421
      Height = 245
      Hint = 
        #1078#1077#1083#1090#1099#1081' - '#1091' '#1086#1073#1098#1077#1082#1090#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1082#1086#1090#1086#1088#1086#1077' '#1077#1089#1090#1100' '#1091' '#1090#1080#1087#1072'. '#1047#1077#1083#1077 +
        #1085#1099#1081' - '#1091' '#1090#1080#1087#1072' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1086' '#1089#1074#1086#1081#1089#1090#1074#1086' '#1087#1088#1080#1089#1091#1090#1089#1090#1074#1091#1102#1097#1077#1077' '#1091' '#1086#1073#1098#1077#1082#1090#1072
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -22
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
        23)
    end
    object BladeSe: TSpinEdit
      Left = 186
      Top = 168
      Width = 170
      Height = 35
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 273
    Width = 894
    Height = 215
    Align = alClient
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitTop = 279
    ExplicitWidth = 961
    ExplicitHeight = 239
    object ThresholdLabel: TLabel
      Left = 14
      Top = 49
      Width = 104
      Height = 24
      Caption = #1044#1086#1087#1091#1089#1082', %:'
    end
    object Label1: TLabel
      Left = 16
      Top = 97
      Width = 118
      Height = 24
      Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
    end
    object DateLabel: TLabel
      Left = 16
      Top = 145
      Width = 45
      Height = 24
      Caption = #1044#1072#1090#1072
    end
    object Splitter1: TSplitter
      Left = 471
      Top = 26
      Width = 4
      Height = 187
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 463
      ExplicitTop = 21
    end
    object ThresholdSE: TFloatSpinEdit
      Left = 140
      Top = 46
      Width = 121
      Height = 35
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 5.000000000000000000
    end
    object PersonE: TEdit
      Left = 140
      Top = 97
      Width = 121
      Height = 32
      TabOrder = 1
      Text = 'PersonE'
    end
    object ProfileSG: TStringGridExt
      Left = 475
      Top = 26
      Width = 417
      Height = 187
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
      TabOrder = 2
      ExplicitLeft = 483
      ExplicitTop = 21
      ExplicitHeight = 259
      ColWidths = (
        64
        65
        64
        64
        64)
      RowHeights = (
        24
        24
        24
        24
        24)
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 488
    Width = 894
    Height = 105
    Align = alBottom
    Caption = #1055#1072#1088#1072#1077#1084#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitTop = 512
    ExplicitWidth = 961
    object OkBtn: TButton
      Left = 14
      Top = 40
      Width = 131
      Height = 49
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = OkBtnClick
    end
  end
end

object EditTestFrm: TEditTestFrm
  Left = 0
  Top = 0
  Caption = 'EditTestFrm'
  ClientHeight = 592
  ClientWidth = 989
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
    Width = 989
    Height = 273
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 894
    object TurbLabel: TLabel
      Left = 16
      Top = 40
      Width = 136
      Height = 27
      Caption = #1058#1080#1087' '#1090#1091#1088#1073#1080#1085#1099':'
    end
    object StageLabel: TLabel
      Left = 16
      Top = 83
      Width = 89
      Height = 27
      Caption = #1057#1090#1091#1087#1077#1085#1100':'
    end
    object SketchLabel: TLabel
      Left = 16
      Top = 126
      Width = 172
      Height = 27
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object Splitter2: TSplitter
      Left = 562
      Top = 29
      Width = 4
      Height = 242
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 467
      ExplicitTop = 27
      ExplicitHeight = 243
    end
    object blNumSE: TLabel
      Left = 16
      Top = 174
      Width = 172
      Height = 27
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object TurbCB: TComboBox
      Left = 186
      Top = 37
      Width = 170
      Height = 35
      TabOrder = 0
      Text = 'TurbCB'
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object StageCB: TComboBox
      Left = 186
      Top = 80
      Width = 170
      Height = 35
      TabOrder = 1
      Text = '1'
      Items.Strings = (
        '1')
    end
    object BladeCB: TComboBox
      Left = 186
      Top = 123
      Width = 170
      Height = 35
      TabOrder = 2
      Text = '1'
      Items.Strings = (
        '1')
    end
    object ObjPropSG: TStringGridExt
      Left = 566
      Top = 29
      Width = 421
      Height = 242
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
      ExplicitLeft = 471
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
      Height = 38
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
    object TurbNameCb: TComboBox
      Left = 377
      Top = 37
      Width = 170
      Height = 35
      TabOrder = 5
      Text = 'TurbCB'
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 273
    Width = 989
    Height = 215
    Align = alClient
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitWidth = 894
    object ThresholdLabel: TLabel
      Left = 14
      Top = 49
      Width = 114
      Height = 27
      Caption = #1044#1086#1087#1091#1089#1082', %:'
    end
    object Label1: TLabel
      Left = 16
      Top = 97
      Width = 130
      Height = 27
      Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
    end
    object DateLabel: TLabel
      Left = 16
      Top = 145
      Width = 49
      Height = 27
      Caption = #1044#1072#1090#1072
    end
    object Splitter1: TSplitter
      Left = 566
      Top = 29
      Width = 4
      Height = 184
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 471
      ExplicitTop = 27
      ExplicitHeight = 185
    end
    object ThresholdSE: TFloatSpinEdit
      Left = 140
      Top = 45
      Width = 121
      Height = 38
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 5.000000000000000000
    end
    object PersonE: TEdit
      Left = 140
      Top = 97
      Width = 121
      Height = 35
      TabOrder = 1
      Text = 'PersonE'
    end
    object ProfileSG: TStringGridExt
      Left = 570
      Top = 29
      Width = 417
      Height = 184
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
      ExplicitLeft = 475
      RowHeights = (
        24
        24
        24
        24
        23)
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 488
    Width = 989
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
    ExplicitWidth = 894
    object OkBtn: TButton
      Left = 14
      Top = 40
      Width = 131
      Height = 48
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = OkBtnClick
    end
  end
end

object EditTestFrm: TEditTestFrm
  Left = 0
  Top = 0
  Caption = 'EditTestFrm'
  ClientHeight = 469
  ClientWidth = 708
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
    Width = 708
    Height = 216
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TurbLabel: TLabel
      Left = 13
      Top = 32
      Width = 102
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1058#1080#1087' '#1090#1091#1088#1073#1080#1085#1099':'
    end
    object StageLabel: TLabel
      Left = 13
      Top = 66
      Width = 66
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1090#1091#1087#1077#1085#1100':'
    end
    object SketchLabel: TLabel
      Left = 13
      Top = 100
      Width = 126
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object Splitter2: TSplitter
      Left = 370
      Top = 21
      Height = 193
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitHeight = 194
    end
    object blNumSE: TLabel
      Left = 13
      Top = 138
      Width = 126
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1077#1088#1090#1077#1078' '#1083#1086#1087#1072#1090#1082#1080':'
    end
    object TurbCB: TComboBox
      Left = 147
      Top = 29
      Width = 135
      Height = 27
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
      Text = 'TurbCB'
      Items.Strings = (
        #1043#1058#1069'-170.1')
    end
    object StageCB: TComboBox
      Left = 147
      Top = 63
      Width = 135
      Height = 27
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = '1'
      Items.Strings = (
        '1')
    end
    object BladeCB: TComboBox
      Left = 147
      Top = 97
      Width = 135
      Height = 27
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
      Left = 373
      Top = 21
      Width = 333
      Height = 193
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
        23)
    end
    object BladeSe: TSpinEdit
      Left = 147
      Top = 133
      Width = 135
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 216
    Width = 708
    Height = 170
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitTop = 218
    object ThresholdLabel: TLabel
      Left = 11
      Top = 39
      Width = 84
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1086#1087#1091#1089#1082', %:'
    end
    object Label1: TLabel
      Left = 13
      Top = 77
      Width = 96
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
    end
    object DateLabel: TLabel
      Left = 13
      Top = 115
      Width = 35
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1072#1090#1072
    end
    object Splitter1: TSplitter
      Left = 373
      Top = 21
      Height = 147
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 702
      ExplicitTop = 20
    end
    object ThresholdSE: TFloatSpinEdit
      Left = 111
      Top = 36
      Width = 96
      Height = 29
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 5.000000000000000000
    end
    object PersonE: TEdit
      Left = 111
      Top = 77
      Width = 96
      Height = 27
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = 'PersonE'
    end
    object ProfileSG: TStringGridExt
      Left = 376
      Top = 21
      Width = 330
      Height = 147
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
      ExplicitLeft = 373
      ExplicitTop = 64
      ExplicitHeight = 104
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
    Top = 386
    Width = 708
    Height = 83
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    Caption = #1055#1072#1088#1072#1077#1084#1090#1088#1099' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object OkBtn: TButton
      Left = 11
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

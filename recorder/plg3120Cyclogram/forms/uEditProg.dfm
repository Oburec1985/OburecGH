object EditProgFrm: TEditProgFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
  ClientHeight = 458
  ClientWidth = 732
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    732
    458)
  PixelsPerInch = 120
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 185
    Top = 0
    Height = 280
    ExplicitLeft = 178
    ExplicitTop = 18
    ExplicitHeight = 319
  end
  object ThresholdLabel: TLabel
    Left = 416
    Top = 96
    Width = 41
    Height = 16
    Caption = #1044#1086#1087#1091#1089#1082
  end
  object ModeLabel: TLabel
    Left = 416
    Top = 4
    Width = 92
    Height = 16
    Caption = #1042#1099#1073#1088#1072#1085' '#1088#1077#1078#1080#1084':'
  end
  object ProgramGB: TGroupBox
    Left = 0
    Top = 0
    Width = 185
    Height = 280
    Align = alLeft
    Caption = #1057#1087#1080#1089#1086#1082' '#1087#1088#1086#1075#1088#1072#1084#1084
    TabOrder = 0
    object ProgLB: TListBox
      Left = 2
      Top = 18
      Width = 241
      Height = 260
      Align = alLeft
      TabOrder = 0
      OnClick = ProgLBClick
      OnKeyDown = ProgLBKeyDown
    end
  end
  object ModeGB: TGroupBox
    Left = 188
    Top = 0
    Width = 216
    Height = 280
    Align = alLeft
    Caption = #1057#1087#1080#1089#1086#1082' '#1088#1077#1078#1080#1084#1086#1074
    TabOrder = 1
    object ModesLB: TListBox
      Left = 2
      Top = 18
      Width = 241
      Height = 260
      Align = alLeft
      TabOrder = 0
      OnClick = ModesLBClick
    end
  end
  object EnableThresholdCb: TCheckBox
    Left = 416
    Top = 66
    Width = 329
    Height = 17
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072'. '#1057#1083#1077#1076'. '#1088#1077#1078#1080#1084' '#1087#1086#1089#1083#1077' '#1087#1088#1086#1074#1077#1088#1082#1080' '#1076#1086#1087#1091#1089#1082#1086#1074
    TabOrder = 2
  end
  object ThresholdSE: TFloatSpinEdit
    Left = 416
    Top = 126
    Width = 121
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 3
  end
  object ThresholdType: TRadioGroup
    Left = 547
    Top = 89
    Width = 169
    Height = 81
    Anchors = [akTop, akRight]
    Caption = #1058#1080#1087' '#1076#1086#1087#1091#1089#1082#1072' ('#1086#1090#1082#1083#1086#1085#1077#1085#1080#1077')'
    ItemIndex = 0
    Items.Strings = (
      #1055#1088#1086#1094#1077#1085#1090#1099', %'
      #1040#1073#1089'. '#1079#1085#1072#1095#1077#1085#1080#1103', '#1092'.'#1074'.')
    TabOrder = 4
  end
  object BottomPanel: TPanel
    Left = 0
    Top = 280
    Width = 732
    Height = 124
    Align = alBottom
    TabOrder = 5
    object TmpltLabel: TLabel
      Left = 5
      Top = 7
      Width = 93
      Height = 16
      Caption = #1042#1099#1073#1086#1088' '#1096#1072#1073#1083#1086#1085#1072
    end
    object CpLabel: TLabel
      Left = 5
      Top = 58
      Width = 117
      Height = 16
      Caption = #1042#1088#1077#1084#1103' '#1076#1086' '#1089#1085#1103#1090#1080#1103' '#1050#1058
    end
    object AvrTimeLabel: TLabel
      Left = 149
      Top = 58
      Width = 117
      Height = 16
      Caption = #1042#1088#1077#1084#1103' '#1076#1086' '#1089#1085#1103#1090#1080#1103' '#1050#1058
    end
    object ComboBox1: TComboBox
      Left = 5
      Top = 29
      Width = 399
      Height = 24
      TabOrder = 0
      Text = 'XlsTmpltCB'
    end
    object CpTimeSe: TFloatSpinEdit
      Left = 5
      Top = 80
      Width = 121
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 1
      Value = 1.000000000000000000
    end
    object AvrTimeSe: TFloatSpinEdit
      Left = 149
      Top = 78
      Width = 121
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 2
      Value = 1.000000000000000000
    end
  end
  object ModeNameEdit: TEdit
    Left = 416
    Top = 26
    Width = 121
    Height = 24
    TabOrder = 6
  end
  object Panel1: TPanel
    Left = 0
    Top = 404
    Width = 732
    Height = 54
    Align = alBottom
    TabOrder = 7
    DesignSize = (
      732
      54)
    object Button1: TButton
      Left = 611
      Top = 5
      Width = 113
      Height = 41
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = ApplyBtnClick
    end
    object Button2: TButton
      Left = 5
      Top = 4
      Width = 166
      Height = 41
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1086#1075#1088#1072#1084#1084#1091
      TabOrder = 1
      OnClick = CopyProgBtnClick
    end
  end
  object AutoCpCb: TCheckBox
    Left = 416
    Top = 176
    Width = 329
    Height = 17
    Caption = #1040#1074#1090#1086' ('#1082#1086#1085#1090#1088#1086#1083#1100#1085#1072#1103' '#1090#1086#1095#1082#1072')'
    TabOrder = 8
  end
end

object EditProgFrm: TEditProgFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
  ClientHeight = 344
  ClientWidth = 549
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    549
    344)
  PixelsPerInch = 96
  TextHeight = 12
  object Splitter1: TSplitter
    Left = 139
    Top = 0
    Width = 2
    Height = 210
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object ThresholdLabel: TLabel
    Left = 312
    Top = 72
    Width = 36
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1044#1086#1087#1091#1089#1082
  end
  object ModeLabel: TLabel
    Left = 312
    Top = 3
    Width = 74
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1042#1099#1073#1088#1072#1085' '#1088#1077#1078#1080#1084':'
  end
  object ProgramGB: TGroupBox
    Left = 0
    Top = 0
    Width = 139
    Height = 210
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    Caption = #1057#1087#1080#1089#1086#1082' '#1087#1088#1086#1075#1088#1072#1084#1084
    TabOrder = 0
    object ProgLB: TListBox
      Left = 2
      Top = 14
      Width = 180
      Height = 194
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      ItemHeight = 12
      TabOrder = 0
      OnClick = ProgLBClick
      OnKeyDown = ProgLBKeyDown
    end
  end
  object ModeGB: TGroupBox
    Left = 141
    Top = 0
    Width = 162
    Height = 210
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    Caption = #1057#1087#1080#1089#1086#1082' '#1088#1077#1078#1080#1084#1086#1074
    TabOrder = 1
    object ModesLB: TListBox
      Left = 2
      Top = 14
      Width = 180
      Height = 194
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      ItemHeight = 12
      TabOrder = 0
      OnClick = ModesLBClick
    end
  end
  object EnableThresholdCb: TCheckBox
    Left = 312
    Top = 50
    Width = 247
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072'. '#1057#1083#1077#1076'. '#1088#1077#1078#1080#1084' '#1087#1086#1089#1083#1077' '#1087#1088#1086#1074#1077#1088#1082#1080' '#1076#1086#1087#1091#1089#1082#1086#1074
    TabOrder = 2
  end
  object ThresholdSE: TFloatSpinEdit
    Left = 312
    Top = 95
    Width = 91
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Increment = 0.100000000000000000
    TabOrder = 3
  end
  object ThresholdType: TRadioGroup
    Left = 410
    Top = 67
    Width = 127
    Height = 61
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
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
    Top = 210
    Width = 549
    Height = 93
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 5
    object TmpltLabel: TLabel
      Left = 4
      Top = 5
      Width = 76
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1099#1073#1086#1088' '#1096#1072#1073#1083#1086#1085#1072
    end
    object CpLabel: TLabel
      Left = 4
      Top = 44
      Width = 94
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1088#1077#1084#1103' '#1076#1086' '#1089#1085#1103#1090#1080#1103' '#1050#1058
    end
    object AvrTimeLabel: TLabel
      Left = 112
      Top = 44
      Width = 102
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1088#1077#1084#1103' '#1091#1089#1088#1077#1076#1085#1077#1085#1080#1103' '#1050#1058
    end
    object RepTamplatesCb: TComboBox
      Left = 4
      Top = 21
      Width = 299
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
      Text = 'XlsTmpltCB'
    end
    object CpTimeSe: TFloatSpinEdit
      Left = 4
      Top = 60
      Width = 91
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      TabOrder = 1
      Value = 1.000000000000000000
    end
    object AvrTimeSe: TFloatSpinEdit
      Left = 112
      Top = 60
      Width = 91
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      TabOrder = 2
      Value = 1.000000000000000000
    end
  end
  object ModeNameEdit: TEdit
    Left = 312
    Top = 20
    Width = 91
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 6
  end
  object Panel1: TPanel
    Left = 0
    Top = 303
    Width = 549
    Height = 41
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 7
    DesignSize = (
      549
      41)
    object Button1: TButton
      Left = 464
      Top = 4
      Width = 85
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = ApplyBtnClick
    end
    object Button2: TButton
      Left = 4
      Top = 3
      Width = 124
      Height = 31
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1086#1075#1088#1072#1084#1084#1091
      TabOrder = 1
      OnClick = CopyProgBtnClick
    end
  end
  object AutoCpCb: TCheckBox
    Left = 307
    Top = 132
    Width = 247
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1040#1074#1090#1086' ('#1082#1086#1085#1090#1088#1086#1083#1100#1085#1072#1103' '#1090#1086#1095#1082#1072')'
    TabOrder = 8
  end
  object AutoCpEndModeCb: TCheckBox
    Left = 307
    Top = 156
    Width = 247
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1040#1074#1090#1086' ('#1082#1086#1085#1090#1088#1086#1083#1100#1085#1072#1103' '#1090#1086#1095#1082#1072')'
    TabOrder = 9
  end
end

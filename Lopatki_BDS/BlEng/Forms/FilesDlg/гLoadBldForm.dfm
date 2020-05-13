object LoadBldDlg: TLoadBldDlg
  Left = 0
  Top = 0
  Caption = 'LoadBldDlg'
  ClientHeight = 216
  ClientWidth = 507
  Color = clBtnFace
  Constraints.MinHeight = 250
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object CommonGB: TGroupBox
    Left = 0
    Top = 0
    Width = 507
    Height = 216
    Align = alClient
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1092#1072#1081#1083#1072
    Constraints.MinHeight = 135
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitWidth = 410
    ExplicitHeight = 201
    object RadioGroup1: TRadioGroup
      Left = 2
      Top = 15
      Width = 503
      Height = 65
      Align = alTop
      Caption = 'RadioGroup1'
      Items.Strings = (
        #1057#1074#1103#1079#1072#1090#1100' '#1089' '#1090#1077#1082#1091#1097#1077#1081' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1077#1081
        #1053#1086#1074#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103)
      TabOrder = 0
      ExplicitLeft = 3
      ExplicitTop = 24
      ExplicitWidth = 225
    end
    object SelectActionGB: TGroupBox
      Left = 2
      Top = 165
      Width = 503
      Height = 49
      Align = alBottom
      Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
      TabOrder = 1
      ExplicitLeft = 0
      ExplicitTop = 251
      ExplicitWidth = 430
      DesignSize = (
        503
        49)
      object CancelBtn: TButton
        Left = 8
        Top = 19
        Width = 75
        Height = 25
        Caption = #1054#1090#1084#1077#1085#1072
        TabOrder = 0
      end
      object ApplyBtn: TButton
        Left = 425
        Top = 21
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
        TabOrder = 1
      end
    end
    object SensorsGB: TGroupBox
      Left = 2
      Top = 80
      Width = 503
      Height = 85
      Align = alClient
      Caption = #1044#1072#1090#1095#1080#1082#1080
      TabOrder = 2
      ExplicitLeft = 48
      ExplicitTop = 86
      ExplicitWidth = 185
      ExplicitHeight = 105
      object BtnListView1: TBtnListView
        Left = 2
        Top = 15
        Width = 499
        Height = 68
        Align = alClient
        Columns = <>
        TabOrder = 0
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        ExplicitLeft = 5
        ExplicitTop = 86
        ExplicitWidth = 250
        ExplicitHeight = 150
      end
    end
  end
end

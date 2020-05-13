object TrigFrm: TTrigFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1090#1088#1080#1075#1075#1077#1088#1086#1074
  ClientHeight = 642
  ClientWidth = 372
  Color = clBtnFace
  Constraints.MinHeight = 570
  Constraints.MinWidth = 380
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    372
    642)
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 3
    Width = 91
    Height = 13
    Caption = #1057#1087#1080#1089#1086#1082' '#1090#1088#1080#1075#1075#1077#1088#1086#1074
  end
  object TrigLabel: TLabel
    Left = 10
    Top = 240
    Width = 31
    Height = 13
    Caption = #1050#1072#1085#1072#1083
  end
  object TrigShiftLabel: TLabel
    Left = 10
    Top = 499
    Width = 102
    Height = 13
    Caption = #1054#1090#1089#1090#1091#1087' '#1085#1072' '#1089#1090#1072#1088#1090#1077', '#1089
  end
  object TrigTheresholdLabel: TLabel
    Left = 10
    Top = 293
    Width = 79
    Height = 13
    Caption = #1055#1086#1088#1086#1075' '#1090#1088#1080#1075#1075#1077#1088#1072
  end
  object TrigNumberLabel: TLabel
    Left = 10
    Top = 545
    Width = 107
    Height = 13
    Caption = #1053#1086#1084#1077#1088' '#1089#1088#1072#1073#1072#1090#1099#1074#1072#1085#1080#1103
  end
  object Label5: TLabel
    Left = 146
    Top = 545
    Width = 67
    Height = 13
    Caption = 'ID '#1080#1089#1090#1086#1095#1085#1080#1082#1072
  end
  object UnitsLabel: TLabel
    Left = 146
    Top = 499
    Width = 45
    Height = 13
    Caption = #1045#1076#1080#1085#1080#1094#1099
  end
  object TrigLV: TBtnListView
    Left = 8
    Top = 22
    Width = 356
    Height = 211
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103
      end
      item
        Caption = 'ID'
      end
      item
        Caption = #1057#1084#1077#1097#1077#1085#1080#1077
      end
      item
        Caption = #1055#1086#1088#1086#1075
      end
      item
        Caption = #1053#1086#1084#1077#1088' '#1089#1088#1072#1073#1072#1090#1099#1074#1072#1085#1080#1103
      end
      item
        Caption = #1060#1088#1086#1085#1090
      end
      item
        Caption = #1045#1076'.'
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = TrigLVChange
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    Editable = False
    ExplicitWidth = 637
  end
  object TrigCB: TComboBox
    Left = 10
    Top = 261
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object TrigShiftE: TFloatEdit
    Left = 10
    Top = 519
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '0.0'
  end
  object TrigTheresholdE: TFloatEdit
    Left = 10
    Top = 313
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '0.5'
  end
  object TrigNumberIE: TIntEdit
    Left = 10
    Top = 564
    Width = 121
    Height = 21
    TabOrder = 4
    Text = '000'
  end
  object AddTrigBtn: TButton
    Left = 275
    Top = 597
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 5
    OnClick = AddTrigBtnClick
    ExplicitLeft = 556
  end
  object TrigApplyBtn: TButton
    Left = 8
    Top = 599
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 6
    OnClick = TrigApplyBtnClick
  end
  object IntEdit1: TIntEdit
    Left = 146
    Top = 564
    Width = 121
    Height = 21
    TabOrder = 7
    Text = '000'
  end
  object UnitsRG: TRadioGroup
    Left = 8
    Top = 340
    Width = 356
    Height = 60
    Anchors = [akLeft, akTop, akRight]
    Caption = #1058#1080#1087' '#1090#1088#1080#1075#1075#1077#1088#1072
    ItemIndex = 0
    Items.Strings = (
      #1060#1088#1086#1085#1090
      #1057#1087#1072#1076)
    TabOrder = 8
    ExplicitWidth = 535
  end
  object UnitsCB: TComboBox
    Left = 146
    Top = 518
    Width = 121
    Height = 21
    ItemIndex = 0
    TabOrder = 9
    Text = #1040#1073#1089'. '#1079#1085#1072#1095'.'
    Items.Strings = (
      #1040#1073#1089'. '#1079#1085#1072#1095'.'
      '%'
      #1044#1073' (20Lg) ('#1064#1057#1042')'
      #1044#1073' (10Lg) (Sin)')
  end
  object TrigTypeRG: TRadioGroup
    Left = 8
    Top = 402
    Width = 356
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = #1058#1080#1087' '#1090#1088#1080#1075#1075#1077#1088#1072
    ItemIndex = 0
    Items.Strings = (
      #1055#1086#1080#1089#1082' '#1080#1085#1090#1077#1088#1074#1072#1083#1072
      #1057#1090#1072#1088#1090
      #1057#1090#1086#1087)
    TabOrder = 10
    ExplicitWidth = 535
  end
end

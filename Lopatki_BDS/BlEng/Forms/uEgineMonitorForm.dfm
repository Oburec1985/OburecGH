object EngineMonitorForm: TEngineMonitorForm
  Left = 0
  Top = 0
  Caption = #1052#1086#1085#1080#1090#1086#1088#1080#1085#1075
  ClientHeight = 500
  ClientWidth = 348
  Color = clBtnFace
  Constraints.MinWidth = 356
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    348
    500)
  PixelsPerInch = 96
  TextHeight = 13
  object CfgLabel: TLabel
    Left = 4
    Top = 8
    Width = 121
    Height = 13
    Caption = #1058#1077#1082#1091#1097#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103
  end
  object DataLabel: TLabel
    Left = 4
    Top = 52
    Width = 132
    Height = 13
    Caption = #1054#1073#1088#1072#1073#1072#1090#1099#1074#1072#1077#1084#1099#1077' '#1076#1072#1085#1085#1099#1077
  end
  object DataFileListLabel: TLabel
    Left = 4
    Top = 97
    Width = 132
    Height = 13
    Caption = #1054#1073#1088#1072#1073#1072#1090#1099#1074#1072#1077#1084#1099#1077' '#1076#1072#1085#1085#1099#1077
  end
  object Label1: TLabel
    Left = 5
    Top = 297
    Width = 69
    Height = 13
    Caption = #1057#1087#1080#1089#1086#1082' '#1079#1072#1076#1072#1095
  end
  object CfgEdit: TEdit
    Left = 4
    Top = 26
    Width = 337
    Height = 21
    TabOrder = 0
  end
  object DataEdit: TEdit
    Left = 4
    Top = 70
    Width = 337
    Height = 21
    TabOrder = 1
  end
  object DataFileListLV: TBtnListView
    Left = 4
    Top = 116
    Width = 336
    Height = 173
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072
      end
      item
        Caption = #1042#1088#1077#1084#1103' '#1086#1073#1088#1072#1073#1086#1090#1082#1080
      end>
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
  object TaskLV: TBtnListView
    Left = 5
    Top = 316
    Width = 336
    Height = 173
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103' '#1079#1072#1076#1072#1095#1080
      end
      item
        Caption = #1057#1086#1089#1090#1086#1103#1085#1080#1077
      end>
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
end

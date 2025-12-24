object EngineMonitorForm: TEngineMonitorForm
  Left = 0
  Top = 0
  Caption = #1052#1086#1085#1080#1090#1086#1088#1080#1085#1075
  ClientHeight = 654
  ClientWidth = 455
  Color = clBtnFace
  Constraints.MinWidth = 466
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    455
    654)
  PixelsPerInch = 120
  TextHeight = 17
  object CfgLabel: TLabel
    Left = 5
    Top = 10
    Width = 152
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1058#1077#1082#1091#1097#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103
  end
  object DataLabel: TLabel
    Left = 5
    Top = 68
    Width = 165
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1054#1073#1088#1072#1073#1072#1090#1099#1074#1072#1077#1084#1099#1077' '#1076#1072#1085#1085#1099#1077
  end
  object DataFileListLabel: TLabel
    Left = 5
    Top = 127
    Width = 165
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1054#1073#1088#1072#1073#1072#1090#1099#1074#1072#1077#1084#1099#1077' '#1076#1072#1085#1085#1099#1077
  end
  object Label1: TLabel
    Left = 7
    Top = 388
    Width = 87
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1057#1087#1080#1089#1086#1082' '#1079#1072#1076#1072#1095
  end
  object CfgEdit: TEdit
    Left = 5
    Top = 34
    Width = 441
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 0
  end
  object DataEdit: TEdit
    Left = 5
    Top = 92
    Width = 441
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 1
  end
  object DataFileListLV: TBtnListView
    Left = 5
    Top = 152
    Width = 440
    Height = 226
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = #8470
        Width = 65
      end
      item
        Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072
        Width = 65
      end
      item
        Caption = #1042#1088#1077#1084#1103' '#1086#1073#1088#1072#1073#1086#1090#1082#1080
        Width = 65
      end>
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
  object TaskLV: TBtnListView
    Left = 7
    Top = 413
    Width = 439
    Height = 226
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = #8470
        Width = 65
      end
      item
        Caption = #1048#1084#1103' '#1079#1072#1076#1072#1095#1080
        Width = 65
      end
      item
        Caption = #1057#1086#1089#1090#1086#1103#1085#1080#1077
        Width = 65
      end>
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
end

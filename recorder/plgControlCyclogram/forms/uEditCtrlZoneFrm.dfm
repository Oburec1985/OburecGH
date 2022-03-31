object EditCtrlZoneFrm: TEditCtrlZoneFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1079#1086#1085#1099' '#1076#1086#1087#1091#1089#1082#1072' '#1088#1077#1075#1091#1083#1103#1090#1086#1088#1072
  ClientHeight = 586
  ClientWidth = 1032
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 24
  object TolLabel: TLabel
    Left = 10
    Top = 57
    Width = 65
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1044#1086#1087#1091#1089#1082
  end
  object ZoneDscLabel: TLabel
    Left = 10
    Top = 172
    Width = 102
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077': '
  end
  object ZoneTypeCB: TCheckBox
    Left = 10
    Top = 20
    Width = 335
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1058#1080#1087'  '#1079#1086#1085#1099': '#1087#1088#1077#1074#1099#1096#1077#1085#1080#1077' '#1091#1089#1090#1072#1074#1082#1080
    TabOrder = 0
  end
  object TolEdit: TFloatEdit
    Left = 10
    Top = 88
    Width = 153
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 1
    Text = '0.0'
  end
  object ChannelsLV: TBtnListView
    Left = 361
    Top = 0
    Width = 286
    Height = 586
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Columns = <
      item
        Caption = #1050#1072#1085#1072#1083
        Width = 63
      end
      item
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
        Width = 63
      end>
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnDragDrop = ChannelsLVDragDrop
    OnDragOver = ChannelsLVDragOver
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
  object FormChannelsGB: TGroupBox
    Left = 647
    Top = 0
    Width = 385
    Height = 586
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Caption = #1057#1087#1080#1089#1086#1082' '#1082#1072#1085#1072#1083#1086#1074
    TabOrder = 3
    object ChanNamesPanel: TPanel
      Left = 2
      Top = 26
      Width = 381
      Height = 116
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      DesignSize = (
        381
        116)
      object FrmTagPropLabel: TLabel
        Left = 5
        Top = 49
        Width = 83
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1057#1074#1086#1081#1089#1090#1074#1086
      end
      object FrmTagPropValue: TLabel
        Left = 140
        Top = 52
        Width = 88
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
      end
      object FilterEdit: TEdit
        Left = 5
        Top = 8
        Width = 372
        Height = 32
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object FrmTagPropValueEdit: TEdit
        Left = 140
        Top = 73
        Width = 221
        Height = 32
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object FrmTagPropNameCB: TComboBox
        Left = 5
        Top = 73
        Width = 128
        Height = 32
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 2
      end
    end
    object TagsLV: TBtnListView
      Left = 2
      Top = 142
      Width = 381
      Height = 442
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Columns = <
        item
          Caption = #1048#1084#1103
          Width = 63
        end
        item
          Caption = #1058#1080#1087
          Width = 63
        end>
      DragMode = dmAutomatic
      MultiSelect = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
end

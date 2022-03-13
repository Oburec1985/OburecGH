object EditCtrlZoneFrm: TEditCtrlZoneFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1079#1086#1085#1099' '#1076#1086#1087#1091#1089#1082#1072' '#1088#1077#1075#1091#1083#1103#1090#1086#1088#1072
  ClientHeight = 464
  ClientWidth = 817
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 19
  object TolLabel: TLabel
    Left = 8
    Top = 45
    Width = 52
    Height = 19
    Caption = #1044#1086#1087#1091#1089#1082
  end
  object ZoneDscLabel: TLabel
    Left = 8
    Top = 136
    Width = 82
    Height = 19
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077': '
  end
  object ZoneTypeCB: TCheckBox
    Left = 8
    Top = 16
    Width = 265
    Height = 17
    Caption = #1058#1080#1087'  '#1079#1086#1085#1099': '#1087#1088#1077#1074#1099#1096#1077#1085#1080#1077' '#1091#1089#1090#1072#1074#1082#1080
    TabOrder = 0
  end
  object TolEdit: TFloatEdit
    Left = 8
    Top = 70
    Width = 121
    Height = 27
    TabOrder = 1
    Text = '0.0'
  end
  object ChannelsLV: TBtnListView
    Left = 286
    Top = 0
    Width = 226
    Height = 464
    Align = alRight
    Columns = <
      item
        Caption = #1050#1072#1085#1072#1083
      end
      item
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
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
    ExplicitLeft = 279
    ExplicitHeight = 231
  end
  object FormChannelsGB: TGroupBox
    Left = 512
    Top = 0
    Width = 305
    Height = 464
    Align = alRight
    Caption = #1057#1087#1080#1089#1086#1082' '#1082#1072#1085#1072#1083#1086#1074
    TabOrder = 3
    ExplicitLeft = 308
    ExplicitTop = -376
    ExplicitHeight = 607
    object ChanNamesPanel: TPanel
      Left = 2
      Top = 21
      Width = 301
      Height = 92
      Align = alTop
      TabOrder = 0
      DesignSize = (
        301
        92)
      object FrmTagPropLabel: TLabel
        Left = 4
        Top = 39
        Width = 68
        Height = 19
        Caption = #1057#1074#1086#1081#1089#1090#1074#1086
      end
      object FrmTagPropValue: TLabel
        Left = 111
        Top = 41
        Width = 69
        Height = 19
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
      end
      object FilterEdit: TEdit
        Left = 4
        Top = 6
        Width = 294
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object FrmTagPropValueEdit: TEdit
        Left = 111
        Top = 58
        Width = 174
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object FrmTagPropNameCB: TComboBox
        Left = 4
        Top = 58
        Width = 101
        Height = 27
        TabOrder = 2
      end
    end
    object TagsLV: TBtnListView
      Left = 2
      Top = 113
      Width = 301
      Height = 349
      Align = alClient
      Columns = <
        item
          Caption = #1048#1084#1103
        end
        item
          Caption = #1058#1080#1087
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
      ExplicitLeft = 1
      ExplicitTop = 87
      ExplicitHeight = 360
    end
  end
end

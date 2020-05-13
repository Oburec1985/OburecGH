object ObjExplorerDlg: TObjExplorerDlg
  Left = 0
  Top = 0
  Caption = 'ObjExplorerDlg'
  ClientHeight = 409
  ClientWidth = 356
  Color = clBtnFace
  Constraints.MinWidth = 279
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lv: TBtnListView
    Left = 0
    Top = 29
    Width = 356
    Height = 307
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #1048#1085#1076#1077#1082#1089
      end
      item
        Caption = #1048#1084#1103
        Width = 114
      end
      item
        Caption = #1058#1080#1087
        Width = 104
      end>
    Constraints.MinWidth = 271
    GridLines = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClickProcess = lvDblClickProcess
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 356
    Height = 29
    ButtonHeight = 29
    ButtonWidth = 82
    Caption = 'ToolBar1'
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'CreateObject'
      ImageIndex = 0
      OnClick = AddObjBtnClick
    end
    object ToolButton2: TToolButton
      Left = 82
      Top = 0
      Caption = 'ToolButton2'
      ImageIndex = 1
    end
  end
  object BottomGB: TGroupBox
    Left = 0
    Top = 336
    Width = 356
    Height = 73
    Align = alBottom
    Caption = #1059#1087#1088#1088#1072#1074#1083#1077#1085#1080#1077' '#1074#1080#1076#1086#1084
    TabOrder = 2
  end
end

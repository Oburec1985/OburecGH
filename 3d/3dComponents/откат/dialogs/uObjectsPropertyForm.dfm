object ObjExplorerDlg: TObjExplorerDlg
  Left = 0
  Top = 0
  Caption = 'ObjExplorerDlg'
  ClientHeight = 409
  ClientWidth = 272
  Color = clBtnFace
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
    Top = 0
    Width = 272
    Height = 409
    Align = alClient
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
    GridLines = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClickProcess = lvDblClickProcess
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
  end
end

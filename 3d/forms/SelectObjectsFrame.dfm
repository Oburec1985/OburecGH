object SelectObjectFrame: TSelectObjectFrame
  Left = 0
  Top = 0
  Width = 301
  Height = 304
  Align = alRight
  Color = clMoneyGreen
  ParentColor = False
  TabOrder = 0
  TabStop = True
  Visible = False
  DesignSize = (
    301
    304)
  object Label1: TLabel
    Left = 92
    Top = 3
    Width = 81
    Height = 13
    Caption = #1054#1073#1098#1077#1082#1090#1099' '#1089#1094#1077#1085#1099
  end
  object ObjectsLV: TBtnListView
    Left = 6
    Top = 22
    Width = 289
    Height = 474
    Anchors = [akTop, akRight, akBottom]
    Color = clScrollBar
    Columns = <
      item
        Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
        Width = 109
      end
      item
        Caption = #1058#1080#1087
        Width = 39
      end
      item
        Caption = #1053#1086#1088#1084#1072#1083#1080
        Width = 73
      end
      item
        Caption = 'BasePivot'
        Width = 64
      end>
    GridLines = True
    Items.ItemData = {
      03420000000200000000000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000
      0001310001320000000000FFFFFFFFFFFFFFFF01000000FFFFFFFF0000000001
      3200013300FFFFFFFF}
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClickProcess = ObjectsLVDblClickProcess
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ExplicitHeight = 447
  end
end

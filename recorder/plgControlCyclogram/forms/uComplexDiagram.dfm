object ComplexDiagramFrm: TComplexDiagramFrm
  Left = 0
  Top = 0
  Caption = 'ComplexDiagramFrm'
  ClientHeight = 572
  ClientWidth = 1036
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SignalsLV: TBtnListView
    Left = 680
    Top = 0
    Width = 356
    Height = 572
    Align = alRight
    Columns = <
      item
        Caption = #1048#1084#1103
      end
      item
        Caption = 'F, Hz'
      end
      item
        Caption = 'Re'
      end
      item
        Caption = 'Im'
      end
      item
        Caption = 'Mag'
      end
      item
        Caption = 'Phase'
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
end

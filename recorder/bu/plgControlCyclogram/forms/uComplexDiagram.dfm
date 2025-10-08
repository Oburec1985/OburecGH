object ComplexDiagramFrm: TComplexDiagramFrm
  Left = 0
  Top = 0
  Caption = 'ComplexDiagramFrm'
  ClientHeight = 748
  ClientWidth = 1355
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object SignalsLV: TBtnListView
    Left = 889
    Top = 0
    Width = 466
    Height = 748
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Columns = <
      item
        Caption = #1048#1084#1103
        Width = 65
      end
      item
        Caption = 'F, Hz'
        Width = 65
      end
      item
        Caption = 'Re'
        Width = 65
      end
      item
        Caption = 'Im'
        Width = 65
      end
      item
        Caption = 'Mag'
        Width = 65
      end
      item
        Caption = 'Phase'
        Width = 65
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

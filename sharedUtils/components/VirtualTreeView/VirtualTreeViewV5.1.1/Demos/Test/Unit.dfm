object Form9: TForm9
  Left = 0
  Top = 0
  Caption = 'Form9'
  ClientHeight = 784
  ClientWidth = 1158
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object vt: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 484
    Height = 784
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseExplorerTheme]
    OnAfterItemErase = vtAfterItemErase
    OnGetText = vtGetText
    OnPaintBackground = vtPaintBackground
    Columns = <>
  end
  object vt2: TVirtualStringTree
    Left = 484
    Top = 0
    Width = 674
    Height = 784
    Align = alRight
    BottomSpace = 2
    ClipboardFormats.Strings = (
      'Virtual Tree Data')
    Color = clSilver
    Header.AutoSizeIndex = -1
    Header.DefaultHeight = 18
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Arial'
    Header.Font.Style = []
    Header.Height = 20
    Header.MainColumn = 1
    Header.MaxHeight = 40
    Header.MinHeight = 18
    SelectionBlendFactor = 64
    TabOrder = 1
    Columns = <
      item
        Position = 0
        Width = 200
      end>
  end
end

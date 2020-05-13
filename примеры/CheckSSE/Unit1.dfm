object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'CheckSSE'
  ClientHeight = 444
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 198
    Width = 328
    Height = 496
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button2: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1080
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 8
    Top = 39
    Width = 328
    Height = 122
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Memo3: TMemo
    Left = 342
    Top = 198
    Width = 328
    Height = 496
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object TestSummSkripnik: TButton
    Left = 342
    Top = 119
    Width = 171
    Height = 25
    Caption = #1058#1077#1089#1090' (Summ a[]) Skripnik'
    TabOrder = 4
    OnClick = TestSummSkripnikClick
  end
end

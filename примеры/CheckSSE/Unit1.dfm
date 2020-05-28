object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'CheckSSE'
  ClientHeight = 581
  ClientWidth = 889
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 17
  object Memo1: TMemo
    Left = 9
    Top = 259
    Width = 240
    Height = 294
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button2: TButton
    Left = 10
    Top = 10
    Width = 99
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1080
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 9
    Top = 51
    Width = 240
    Height = 160
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Memo3: TMemo
    Left = 257
    Top = 259
    Width = 429
    Height = 294
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object TestSummSkripnik: TButton
    Left = 9
    Top = 219
    Width = 224
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1058#1077#1089#1090' (Summ a[]) Skripnik'
    TabOrder = 4
    OnClick = TestSummSkripnikClick
  end
  object Memo4: TMemo
    Left = 257
    Top = 51
    Width = 429
    Height = 200
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object PickBackBtn: TButton
    Left = 694
    Top = 275
    Width = 163
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1080#1081
    TabOrder = 6
  end
  object PickFrontBtn: TButton
    Left = 694
    Top = 51
    Width = 163
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1055#1077#1088#1074#1099#1081
    TabOrder = 7
    OnClick = PickFrontBtnClick
  end
  object PushFrontBtn: TButton
    Left = 694
    Top = 235
    Width = 163
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1077#1088#1074#1099#1081
    TabOrder = 8
  end
  object PushBackBtn: TButton
    Left = 694
    Top = 91
    Width = 163
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074' '#1082#1086#1085#1077#1094
    TabOrder = 9
    OnClick = PushBackBtnClick
  end
end

object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'CheckSSE'
  ClientHeight = 685
  ClientWidth = 946
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  DesignSize = (
    946
    685)
  PixelsPerInch = 120
  TextHeight = 17
  object Memo1: TMemo
    Left = -1
    Top = 408
    Width = 276
    Height = 267
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 562
  end
  object Button2: TButton
    Left = 0
    Top = 7
    Width = 98
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1080
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = -1
    Top = 47
    Width = 239
    Height = 314
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akBottom]
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Memo3: TMemo
    Left = 247
    Top = 408
    Width = 518
    Height = 267
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 3
    ExplicitWidth = 804
  end
  object TestSummSkripnik: TButton
    Left = -1
    Top = 367
    Width = 223
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = #1058#1077#1089#1090' (Summ a[]) Skripnik'
    TabOrder = 4
    OnClick = TestSummSkripnikClick
  end
  object Memo4: TMemo
    Left = 247
    Top = 47
    Width = 518
    Height = 313
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 5
    ExplicitWidth = 804
  end
  object PickBackBtn: TButton
    Left = 776
    Top = 254
    Width = 162
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1080#1081
    TabOrder = 6
    OnClick = PickBackBtnClick
    ExplicitLeft = 1062
  end
  object PickFrontBtn: TButton
    Left = 776
    Top = 47
    Width = 162
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1055#1077#1088#1074#1099#1081
    TabOrder = 7
    OnClick = PickFrontBtnClick
    ExplicitLeft = 1062
  end
  object PushFrontBtn: TButton
    Left = 776
    Top = 294
    Width = 162
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1077#1088#1074#1099#1081
    TabOrder = 8
    OnClick = PushFrontBtnClick
    ExplicitLeft = 1062
  end
  object PushBackBtn: TButton
    Left = 776
    Top = 88
    Width = 162
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074' '#1082#1086#1085#1077#1094
    TabOrder = 9
    OnClick = PushBackBtnClick
    ExplicitLeft = 1062
  end
  object DropBtn: TButton
    Left = 776
    Top = 127
    Width = 162
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = #1054#1090#1073#1088#1086#1089#1080#1090#1100' (2 '#1101#1083'-'#1072')'
    TabOrder = 10
    OnClick = DropBtnClick
    ExplicitLeft = 1062
  end
end

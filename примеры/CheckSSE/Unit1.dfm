object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'CheckSSE'
  ClientHeight = 524
  ClientWidth = 696
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  DesignSize = (
    696
    524)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = -1
    Top = 312
    Width = 184
    Height = 204
    Anchors = [akLeft, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitTop = 195
    ExplicitWidth = 183
  end
  object Button2: TButton
    Left = 0
    Top = 5
    Width = 75
    Height = 25
    Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1080
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = -1
    Top = 36
    Width = 183
    Height = 240
    Anchors = [akLeft, akTop, akBottom]
    ScrollBars = ssVertical
    TabOrder = 2
    ExplicitHeight = 122
  end
  object Memo3: TMemo
    Left = 189
    Top = 312
    Width = 369
    Height = 204
    Anchors = [akLeft, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 3
    ExplicitTop = 195
    ExplicitWidth = 328
  end
  object TestSummSkripnik: TButton
    Left = -1
    Top = 281
    Width = 171
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1058#1077#1089#1090' (Summ a[]) Skripnik'
    TabOrder = 4
    OnClick = TestSummSkripnikClick
    ExplicitTop = 164
  end
  object Memo4: TMemo
    Left = 189
    Top = 36
    Width = 369
    Height = 239
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 5
    ExplicitWidth = 328
    ExplicitHeight = 153
  end
  object PickBackBtn: TButton
    Left = 566
    Top = 194
    Width = 124
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1080#1081
    TabOrder = 6
    OnClick = PickBackBtnClick
    ExplicitLeft = 523
  end
  object PickFrontBtn: TButton
    Left = 566
    Top = 36
    Width = 124
    Height = 24
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1055#1077#1088#1074#1099#1081
    TabOrder = 7
    OnClick = PickFrontBtnClick
    ExplicitLeft = 523
  end
  object PushFrontBtn: TButton
    Left = 566
    Top = 225
    Width = 124
    Height = 24
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1077#1088#1074#1099#1081
    TabOrder = 8
    OnClick = PushFrontBtnClick
    ExplicitLeft = 523
  end
  object PushBackBtn: TButton
    Left = 566
    Top = 67
    Width = 124
    Height = 24
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074' '#1082#1086#1085#1077#1094
    TabOrder = 9
    OnClick = PushBackBtnClick
    ExplicitLeft = 523
  end
end

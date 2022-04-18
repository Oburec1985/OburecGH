object ConfirmFmr: TConfirmFmr
  Left = 0
  Top = 0
  Caption = #1055#1086#1076#1090#1074#1077#1088#1076#1080#1090#1100' '#1076#1077#1081#1089#1090#1074#1080#1077
  ClientHeight = 214
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  DesignSize = (
    455
    214)
  PixelsPerInch = 120
  TextHeight = 16
  object ConfirmTextLabel: TLabel
    Left = 24
    Top = 40
    Width = 257
    Height = 28
    Caption = #1055#1086#1076#1090#1074#1077#1088#1076#1080#1090#1100' '#1076#1077#1081#1089#1090#1074#1080#1077': '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object TxtLabel: TLabel
    Left = 24
    Top = 88
    Width = 414
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 427
  end
  object CancelBtn: TButton
    Left = 8
    Top = 156
    Width = 113
    Height = 52
    Anchors = [akLeft, akTop, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = CancelBtnClick
  end
  object ApplyBtn: TButton
    Left = 316
    Top = 156
    Width = 131
    Height = 52
    Anchors = [akTop, akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = ApplyBtnClick
  end
end

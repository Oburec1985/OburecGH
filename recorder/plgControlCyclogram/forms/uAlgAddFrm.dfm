object AddAlgFrm: TAddAlgFrm
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1072#1089#1095#1077#1090
  ClientHeight = 284
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 239
    Width = 291
    Height = 45
    Align = alBottom
    TabOrder = 0
  end
  object AlgsList: TListBox
    Left = 0
    Top = 0
    Width = 291
    Height = 239
    Align = alClient
    Items.Strings = (
      #1057#1095#1077#1090#1095#1080#1082
      #1058#1072#1093#1086
      #1057#1050#1047' '#1074' '#1087#1086#1083#1086#1089#1077
      #1057#1050#1047' '#1074' '#1087#1086#1083#1086#1089#1077' (1.0)'
      #1060#1072#1079#1072
      #1057#1087#1077#1082#1090#1088
      #1057#1082#1074#1072#1078#1085#1086#1089#1090#1100)
    TabOrder = 1
    OnDblClick = AlgsListDblClick
  end
end

object AddAlgFrm: TAddAlgFrm
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1072#1089#1095#1077#1090
  ClientHeight = 213
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 179
    Width = 218
    Height = 34
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 0
  end
  object AlgsList: TListBox
    Left = 0
    Top = 0
    Width = 218
    Height = 179
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    ItemHeight = 12
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

object EditSignalsListFrm: TEditSignalsListFrm
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100'/ '#1059#1076#1072#1083#1080#1090#1100' '#1089#1080#1075#1085#1072#1083#1099
  ClientHeight = 413
  ClientWidth = 769
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 344
    Height = 306
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1089#1080#1075#1085#1072#1083#1099
    TabOrder = 0
    object SRCsignalsLB: TListBox
      Left = 3
      Top = 20
      Width = 338
      Height = 283
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 306
    Width = 769
    Height = 107
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    Caption = #1042#1099#1073#1086#1088' '#1076#1077#1081#1089#1090#1074#1080#1103
    TabOrder = 1
    DesignSize = (
      769
      107)
    object DelBtn: TButton
      Left = 14
      Top = 38
      Width = 144
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1089#1080#1075#1085#1072#1083#1099
      TabOrder = 0
    end
    object AddBtn: TButton
      Left = 588
      Top = 38
      Width = 147
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1080#1075#1085#1072#1083#1099
      TabOrder = 1
      OnClick = AddBtnClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 344
    Top = 0
    Width = 425
    Height = 306
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1084#1099#1077' '#1089#1080#1075#1085#1072#1083#1099
    TabOrder = 2
    object DSTsignalsLB: TListBox
      Left = 3
      Top = 20
      Width = 419
      Height = 283
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
    end
  end
end

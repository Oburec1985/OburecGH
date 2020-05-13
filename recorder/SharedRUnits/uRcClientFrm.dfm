object RcClientFrm: TRcClientFrm
  Left = 0
  Top = 0
  Caption = 'RcClientFrm'
  ClientHeight = 302
  ClientWidth = 246
  Color = clBtnFace
  Constraints.MinHeight = 299
  Constraints.MinWidth = 260
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    246
    302)
  PixelsPerInch = 96
  TextHeight = 12
  object HostLabel: TLabel
    Left = 18
    Top = 8
    Width = 27
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1061#1086#1089#1090':'
  end
  object NameLabel: TLabel
    Left = 18
    Top = 134
    Width = 72
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
  end
  object FolderLabel: TLabel
    Left = 18
    Top = 176
    Width = 42
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1050#1072#1090#1072#1083#1086#1075':'
  end
  object HostEdit: TEdit
    Left = 18
    Top = 24
    Width = 212
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = HostEditChange
  end
  object NameEdit: TEdit
    Left = 18
    Top = 150
    Width = 212
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object FolderEdit: TEdit
    Left = 18
    Top = 192
    Width = 212
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object portRG: TRadioGroup
    Left = 18
    Top = 50
    Width = 212
    Height = 79
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1055#1086#1088#1090' (MR300=4500;Recorder=4510):'
    ItemIndex = 0
    Items.Strings = (
      'Recorder=4510'
      'MR300=4500'
      'Video=4520')
    TabOrder = 3
    OnClick = portRGClick
  end
  object ApplyBtn: TButton
    Left = 156
    Top = 224
    Width = 74
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akRight, akBottom]
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 4
    OnClick = ApplyBtnClick
  end
  object EditBtn: TButton
    Left = 156
    Top = 248
    Width = 74
    Height = 18
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akRight, akBottom]
    Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 5
    OnClick = EditBtnClick
  end
  object DelBtn: TButton
    Left = 156
    Top = 271
    Width = 74
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akRight, akBottom]
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 6
    OnClick = DelBtnClick
  end
end

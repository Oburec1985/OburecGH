object SignalPathFrm: TSignalPathFrm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1087#1091#1090#1080
  ClientHeight = 235
  ClientWidth = 453
  Color = clBtnFace
  Constraints.MinHeight = 218
  Constraints.MinWidth = 256
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    453
    235)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 52
    Height = 13
    Caption = #1048#1089#1090#1086#1095#1085#1080#1082':'
  end
  object Label2: TLabel
    Left = 8
    Top = 72
    Width = 64
    Height = 13
    Caption = #1053#1072#1079#1085#1072#1095#1077#1085#1080#1077':'
  end
  object DstPath: TEdit
    Left = 8
    Top = 91
    Width = 437
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 8
    Top = 202
    Width = 137
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object AddBtn: TButton
    Left = 327
    Top = 202
    Width = 118
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 2
  end
  object SrcPath: TComboBox
    Left = 8
    Top = 35
    Width = 437
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    Text = 'SrcPath'
  end
  object Button1: TButton
    Left = 8
    Top = 142
    Width = 137
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1080#1075#1085#1072#1083#1099
    ModalResult = 1
    TabOrder = 4
  end
end

object LoadSignalForm: TLoadSignalForm
  Left = 0
  Top = 0
  Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1092#1072#1081#1083
  ClientHeight = 262
  ClientWidth = 283
  Color = clBtnFace
  Constraints.MinHeight = 291
  Constraints.MinWidth = 291
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    283
    262)
  PixelsPerInch = 96
  TextHeight = 13
  object PathBtn: TButton
    Left = 179
    Top = 6
    Width = 80
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1050#1072#1090#1072#1083#1086#1075
    TabOrder = 0
    OnClick = PathBtnClick
  end
  object PathEdit: TEdit
    Left = 21
    Top = 8
    Width = 140
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object CancelBtn: TButton
    Left = 21
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object ApplyBtn: TButton
    Left = 184
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    ModalResult = 1
    TabOrder = 3
  end
  object OpenDialog1: TOpenDialog
    Left = 177
    Top = 39
  end
end

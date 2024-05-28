object ObjFrm3dEdit: TObjFrm3dEdit
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' 3d '#1084#1085#1077#1084#1086#1089#1093#1077#1084#1099
  ClientHeight = 324
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    442
    324)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 37
    Width = 66
    Height = 13
    Caption = #1055#1091#1090#1100' '#1082' '#1089#1094#1077#1085#1077
  end
  object Label2: TLabel
    Left = 8
    Top = 85
    Width = 53
    Height = 13
    Caption = #1048#1084#1103' '#1089#1094#1077#1085#1099
  end
  object ShowTrfrmToolsCB: TCheckBox
    Left = 8
    Top = 8
    Width = 241
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 8
    Top = 291
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object OkBtn: TButton
    Left = 359
    Top = 291
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 2
  end
  object SceneFolderEdit: TEdit
    Left = 8
    Top = 56
    Width = 297
    Height = 21
    TabOrder = 3
  end
  object SceneNameEdit: TEdit
    Left = 8
    Top = 104
    Width = 297
    Height = 21
    TabOrder = 4
  end
  object PathBtn: TButton
    Left = 328
    Top = 102
    Width = 75
    Height = 25
    Caption = #1042#1099#1073#1088#1072#1090#1100
    TabOrder = 5
    OnClick = PathBtnClick
  end
  object OpenDialog1: TOpenDialog
    Left = 352
    Top = 48
  end
end

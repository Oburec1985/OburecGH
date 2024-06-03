object ObjFrm3dEdit: TObjFrm3dEdit
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' 3d '#1084#1085#1077#1084#1086#1089#1093#1077#1084#1099
  ClientHeight = 364
  ClientWidth = 578
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    578
    364)
  PixelsPerInch = 120
  TextHeight = 17
  object Label1: TLabel
    Left = 10
    Top = 48
    Width = 84
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1055#1091#1090#1100' '#1082' '#1089#1094#1077#1085#1077
  end
  object Label2: TLabel
    Left = 10
    Top = 111
    Width = 69
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1048#1084#1103' '#1089#1094#1077#1085#1099
  end
  object ShowTrfrmToolsCB: TCheckBox
    Left = 10
    Top = 10
    Width = 316
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 10
    Top = 321
    Width = 99
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
    ExplicitTop = 381
  end
  object OkBtn: TButton
    Left = 469
    Top = 321
    Width = 99
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 2
    ExplicitTop = 381
  end
  object SceneFolderEdit: TEdit
    Left = 10
    Top = 73
    Width = 389
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 3
  end
  object SceneNameEdit: TEdit
    Left = 10
    Top = 136
    Width = 389
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 4
  end
  object PathBtn: TButton
    Left = 429
    Top = 133
    Width = 98
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1042#1099#1073#1088#1072#1090#1100
    TabOrder = 5
    OnClick = PathBtnClick
  end
  object OpenDialog1vista: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoForceFileSystem]
    Left = 288
    Top = 216
  end
end

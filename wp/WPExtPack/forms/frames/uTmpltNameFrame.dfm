object TmpltNameFrame: TTmpltNameFrame
  Left = 0
  Top = 0
  Width = 800
  Height = 215
  TabOrder = 0
  DesignSize = (
    800
    215)
  object tmpltLabel: TLabel
    Left = 188
    Top = 3
    Width = 83
    Height = 16
    Caption = #1055#1091#1090#1100' '#1096#1072#1073#1083#1086#1085#1072
  end
  object FolderLabel: TLabel
    Left = 188
    Top = 62
    Width = 185
    Height = 16
    Caption = #1050#1072#1090#1072#1083#1086#1075' '#1079#1072#1084#1077#1088#1072' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102':'
  end
  object NameLabel: TLabel
    Left = 188
    Top = 110
    Width = 162
    Height = 16
    Caption = #1048#1084#1103' '#1079#1072#1084#1077#1088#1072' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102':'
  end
  object Label2: TLabel
    Left = 188
    Top = 167
    Width = 80
    Height = 16
    Caption = #1055#1091#1090#1100' '#1082' '#1086#1090#1095#1077#1090#1091
  end
  object TmpltEdit: TEdit
    Left = 188
    Top = 22
    Width = 425
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    Text = #1054#1090#1095#1077#1090' '#1094#1080#1082#1083#1086#1075#1088#1072#1084#1084#1072'.xls'
    OnChange = TmpltEditChange
  end
  object FolderEdit: TEdit
    Left = 188
    Top = 81
    Width = 425
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnChange = FolderEditChange
  end
  object FolderBtn: TButton
    Left = 628
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 2
    OnClick = FolderBtnClick
  end
  object TmpltBtn: TButton
    Left = 628
    Top = 20
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = TmpltBtnClick
  end
  object DateCB: TCheckBox
    Left = 330
    Top = 108
    Width = 166
    Height = 17
    Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1076#1072#1090#1091
    TabOrder = 4
    OnClick = DateCBClick
  end
  object MakeDefaultNameBtn: TButton
    Left = 628
    Top = 127
    Width = 137
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1057#1076#1077#1083#1072#1090#1100' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
    TabOrder = 5
    OnClick = MakeDefaultNameBtnClick
  end
  object NameEdit: TEdit
    Left = 188
    Top = 129
    Width = 425
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
    OnChange = NameEditChange
  end
  object AutoPathCB: TCheckBox
    Left = 4
    Top = 166
    Width = 166
    Height = 17
    Caption = #1043#1077#1085#1077#1088#1080#1090#1100' '#1087#1091#1090#1100' '#1072#1074#1090#1086#1084#1072#1090#1086#1084
    TabOrder = 7
    OnClick = AutoPathCBClick
  end
  object SavePathEdit: TEdit
    Left = 3
    Top = 186
    Width = 610
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
  end
  object NameRG: TRadioGroup
    Left = 0
    Top = 59
    Width = 185
    Height = 73
    Caption = #1060#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077' '#1080#1084#1077#1085#1080
    ItemIndex = 0
    Items.Strings = (
      #1048#1084#1103' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
      #1048#1084#1103' '#1079#1072#1084#1077#1088#1072
      #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1086#1077)
    TabOrder = 9
    OnClick = NameRGClick
  end
  object FolderRG: TRadioGroup
    Left = 0
    Top = 2
    Width = 185
    Height = 55
    Caption = #1060#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077' '#1082#1072#1090#1072#1083#1086#1075#1072
    ItemIndex = 0
    Items.Strings = (
      #1050#1072#1090#1072#1083#1086#1075' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
      #1050#1072#1090#1072#1083#1086#1075' '#1079#1072#1084#1077#1088#1072)
    TabOrder = 10
    OnClick = FolderRGClick
  end
  object PathBtn: TButton
    Left = 628
    Top = 184
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 11
    OnClick = PathBtnClick
  end
  object OpenDialog1: TOpenDialog
    Left = 437
    Top = 43
  end
  object OpenDialog2: TOpenDialog
    Left = 549
    Top = 44
  end
  object SaveDialog1: TSaveDialog
    Left = 496
    Top = 44
  end
  object SaveDialog2: TSaveDialog
    Left = 376
    Top = 43
  end
  object OpenDialog1vista: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoForceFileSystem]
    Left = 376
    Top = 65528
  end
end

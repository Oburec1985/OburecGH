object ObjFrm3dEdit: TObjFrm3dEdit
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' 3d '#1084#1085#1077#1084#1086#1089#1093#1077#1084#1099
  ClientHeight = 612
  ClientWidth = 1051
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object LowPanel: TPanel
    Left = 0
    Top = 571
    Width = 1051
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 245
    ExplicitWidth = 917
    DesignSize = (
      1051
      41)
    object CancelBtn: TButton
      Left = 10
      Top = 5
      Width = 99
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 942
      Top = 5
      Width = 99
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      OnClick = OkBtnClick
      ExplicitLeft = 808
    end
  end
  object AlClientPanel: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 571
    Align = alClient
    TabOrder = 1
    ExplicitLeft = -6
    ExplicitTop = -2
    ExplicitWidth = 808
    ExplicitHeight = 542
    object TopPanel: TPanel
      Left = 1
      Top = 1
      Width = 798
      Height = 152
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 915
      object Label1: TLabel
        Left = 6
        Top = 29
        Width = 84
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1055#1091#1090#1100' '#1082' '#1089#1094#1077#1085#1077
      end
      object Label2: TLabel
        Left = 6
        Top = 81
        Width = 69
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1048#1084#1103' '#1089#1094#1077#1085#1099
      end
      object ShowTrfrmToolsCB: TCheckBox
        Left = 6
        Top = 6
        Width = 316
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
        TabOrder = 0
      end
      object SceneFolderEdit: TEdit
        Left = 6
        Top = 54
        Width = 389
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 1
      end
      object SceneNameEdit: TEdit
        Left = 6
        Top = 104
        Width = 389
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 2
      end
      object PathBtn: TButton
        Left = 400
        Top = 96
        Width = 76
        Height = 33
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1042#1099#1073#1088#1072#1090#1100
        TabOrder = 3
        OnClick = PathBtnClick
      end
    end
  end
  object RightPanel: TPanel
    Left = 800
    Top = 0
    Width = 251
    Height = 571
    Align = alRight
    TabOrder = 2
    ExplicitHeight = 542
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 249
      Height = 569
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 113
      ExplicitTop = 208
      inherited FormChannelsGB: TGroupBox
        Width = 249
        Height = 569
        ExplicitLeft = -48
        ExplicitTop = -4
        inherited ChanNamesPanel: TPanel
          Top = 19
          Width = 245
          ExplicitTop = 19
          inherited FrmTagPropLabel: TLabel
            Width = 62
            Height = 17
            ExplicitWidth = 62
            ExplicitHeight = 17
          end
          inherited FrmTagPropValue: TLabel
            Width = 60
            Height = 17
            ExplicitWidth = 60
            ExplicitHeight = 17
          end
          inherited FilterEdit: TEdit
            Width = 234
            Height = 25
            ExplicitHeight = 25
          end
          inherited FrmTagPropValueEdit: TEdit
            Width = 118
            Height = 25
            ExplicitHeight = 25
          end
          inherited FrmTagPropNameCB: TComboBox
            Height = 25
            ExplicitHeight = 25
          end
        end
        inherited TagsLV: TBtnListView
          Top = 130
          Width = 245
          Height = 437
          ExplicitTop = 130
          ExplicitHeight = 171
        end
      end
    end
  end
  object OpenDialog1vista: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoForceFileSystem]
    Left = 440
    Top = 40
  end
end

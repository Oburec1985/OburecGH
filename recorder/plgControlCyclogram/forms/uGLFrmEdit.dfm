object ObjFrm3dEdit: TObjFrm3dEdit
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' 3d '#1084#1085#1077#1084#1086#1089#1093#1077#1084#1099
  ClientHeight = 702
  ClientWidth = 1051
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object LowPanel: TPanel
    Left = 0
    Top = 660
    Width = 1051
    Height = 42
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      1051
      42)
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
      Left = 944
      Top = 7
      Width = 100
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      OnClick = OkBtnClick
    end
  end
  object AlClientPanel: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 660
    Align = alClient
    TabOrder = 1
    object TopPanel: TPanel
      Left = 1
      Top = 1
      Width = 798
      Height = 216
      Align = alTop
      TabOrder = 0
      object Label1: TLabel
        Left = 7
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
        Left = 7
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
        Left = 7
        Top = 7
        Width = 315
        Height = 22
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
        TabOrder = 0
      end
      object SceneFolderEdit: TEdit
        Left = 7
        Top = 54
        Width = 338
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 1
      end
      object SceneNameEdit: TEdit
        Left = 7
        Top = 105
        Width = 338
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 2
      end
      object PathBtn: TButton
        Left = 353
        Top = 101
        Width = 76
        Height = 34
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1042#1099#1073#1088#1072#1090#1100
        TabOrder = 3
        OnClick = PathBtnClick
      end
      object ObjPanel: TPanel
        Left = 493
        Top = 1
        Width = 304
        Height = 214
        Align = alRight
        TabOrder = 4
        inline ObjEditFrame1: TObjEditFrame
          Left = 1
          Top = 1
          Width = 302
          Height = 212
          Align = alClient
          Constraints.MinWidth = 302
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 302
          ExplicitHeight = 212
          inherited PosGB: TGroupBox
            Width = 302
            ExplicitWidth = 302
            inherited XposLab: TLabel
              Height = 17
              ExplicitHeight = 17
            end
            inherited YposLab: TLabel
              Width = 13
              Height = 17
              ExplicitWidth = 13
              ExplicitHeight = 17
            end
            inherited ZposLab: TLabel
              Width = 13
              Height = 17
              ExplicitWidth = 13
              ExplicitHeight = 17
            end
            inherited XposSE: TFloatSpinEdit
              Top = 37
              Width = 86
              Height = 27
              ExplicitTop = 37
              ExplicitWidth = 86
              ExplicitHeight = 27
            end
            inherited YposSE: TFloatSpinEdit
              Top = 37
              Height = 27
              ExplicitTop = 37
              ExplicitHeight = 27
            end
            inherited ZposSE: TFloatSpinEdit
              Top = 37
              Height = 27
              ExplicitTop = 37
              ExplicitHeight = 27
            end
            inherited XTagCB: TRcComboBox
              Width = 86
              Height = 25
              ExplicitWidth = 86
              ExplicitHeight = 25
            end
            inherited YTagCB: TRcComboBox
              Height = 25
              ExplicitHeight = 25
            end
            inherited ZTagCB: TRcComboBox
              Height = 25
              ExplicitHeight = 25
            end
          end
          inherited OrientationGB: TGroupBox
            Width = 302
            Height = 106
            ExplicitWidth = 302
            ExplicitHeight = 106
            inherited XrotLab: TLabel
              Height = 17
              ExplicitHeight = 17
            end
            inherited YrotLab: TLabel
              Width = 13
              Height = 17
              ExplicitWidth = 13
              ExplicitHeight = 17
            end
            inherited ZrotLab: TLabel
              Width = 13
              Height = 17
              ExplicitWidth = 13
              ExplicitHeight = 17
            end
            inherited XrotSE: TFloatSpinEdit
              Top = 37
              Width = 86
              Height = 27
              ExplicitTop = 37
              ExplicitWidth = 86
              ExplicitHeight = 27
            end
            inherited YrotSE: TFloatSpinEdit
              Top = 37
              Height = 27
              ExplicitTop = 37
              ExplicitHeight = 27
            end
            inherited ZrotSE: TFloatSpinEdit
              Top = 37
              Height = 27
              ExplicitTop = 37
              ExplicitHeight = 27
            end
            inherited XrotTagCB: TRcComboBox
              Width = 86
              Height = 25
              ExplicitWidth = 86
              ExplicitHeight = 25
            end
            inherited YrotTagCB: TRcComboBox
              Height = 25
              ExplicitHeight = 25
            end
            inherited ZrotTagCB: TRcComboBox
              Height = 25
              ExplicitHeight = 25
            end
          end
        end
      end
    end
  end
  object RightPanel: TPanel
    Left = 800
    Top = 0
    Width = 251
    Height = 660
    Align = alRight
    TabOrder = 2
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 249
      Height = 658
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 249
      ExplicitHeight = 658
      inherited FormChannelsGB: TGroupBox
        Width = 249
        Height = 658
        ExplicitWidth = 249
        ExplicitHeight = 658
        inherited ChanNamesPanel: TPanel
          Top = 19
          Width = 245
          Height = 108
          ExplicitTop = 19
          ExplicitWidth = 245
          ExplicitHeight = 108
          inherited FrmTagPropLabel: TLabel
            Width = 62
            Height = 17
            ExplicitWidth = 62
            ExplicitHeight = 17
          end
          inherited FrmTagPropValue: TLabel
            Left = 122
            Width = 60
            Height = 17
            ExplicitLeft = 122
            ExplicitWidth = 60
            ExplicitHeight = 17
          end
          inherited FilterEdit: TEdit
            Width = 234
            Height = 25
            ExplicitWidth = 234
            ExplicitHeight = 25
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 122
            Width = 117
            Height = 25
            ExplicitLeft = 122
            ExplicitWidth = 117
            ExplicitHeight = 25
          end
          inherited FrmTagPropNameCB: TComboBox
            Width = 107
            Height = 25
            ExplicitWidth = 107
            ExplicitHeight = 25
          end
        end
        inherited TagsLV: TBtnListView
          Top = 127
          Width = 245
          Height = 529
          ExplicitLeft = 3
          ExplicitTop = 128
          ExplicitWidth = 243
          ExplicitHeight = 527
        end
      end
    end
  end
  object Button1: TButton
    Left = 449
    Top = 180
    Width = 39
    Height = 25
    Hint = #1058#1077#1089#1090#1086#1074#1099#1077' '#1076#1072#1085#1085#1099#1077' '#1080#1079' ESP '#1075#1080#1088#1086#1089#1082#1086#1087#1072
    Caption = 'Add'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = Button1Click
  end
  object OpenDialog1vista: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoForceFileSystem]
    Left = 328
    Top = 152
  end
end

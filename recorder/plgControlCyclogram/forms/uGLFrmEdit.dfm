object ObjFrm3dEdit: TObjFrm3dEdit
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' 3d '#1084#1085#1077#1084#1086#1089#1093#1077#1084#1099
  ClientHeight = 537
  ClientWidth = 804
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LowPanel: TPanel
    Left = 0
    Top = 505
    Width = 804
    Height = 32
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      804
      32)
    object CancelBtn: TButton
      Left = 8
      Top = 4
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 722
      Top = 5
      Width = 76
      Height = 24
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
    Width = 612
    Height = 505
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 1
    object TopPanel: TPanel
      Left = 1
      Top = 1
      Width = 610
      Height = 165
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alTop
      TabOrder = 0
      object Label1: TLabel
        Left = 5
        Top = 22
        Width = 66
        Height = 13
        Caption = #1055#1091#1090#1100' '#1082' '#1089#1094#1077#1085#1077
      end
      object Label2: TLabel
        Left = 5
        Top = 62
        Width = 53
        Height = 13
        Caption = #1048#1084#1103' '#1089#1094#1077#1085#1099
      end
      object ShowTrfrmToolsCB: TCheckBox
        Left = 5
        Top = 5
        Width = 241
        Height = 17
        Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
        TabOrder = 0
      end
      object SceneFolderEdit: TEdit
        Left = 5
        Top = 41
        Width = 259
        Height = 25
        TabOrder = 1
      end
      object SceneNameEdit: TEdit
        Left = 5
        Top = 80
        Width = 259
        Height = 25
        TabOrder = 2
      end
      object PathBtn: TButton
        Left = 270
        Top = 77
        Width = 58
        Height = 26
        Caption = #1042#1099#1073#1088#1072#1090#1100
        TabOrder = 3
        OnClick = PathBtnClick
      end
      object ObjPanel: TPanel
        Left = 376
        Top = 1
        Width = 233
        Height = 163
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alRight
        TabOrder = 4
        ExplicitLeft = 377
        inline ObjEditFrame1: TObjEditFrame
          Left = 1
          Top = 1
          Width = 231
          Height = 161
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Constraints.MinWidth = 231
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 231
          ExplicitHeight = 162
          inherited PosGB: TGroupBox
            Width = 231
            Height = 80
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            ExplicitWidth = 231
            ExplicitHeight = 80
            inherited XposLab: TLabel
              Left = 7
              Top = 14
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 7
              ExplicitTop = 14
            end
            inherited YposLab: TLabel
              Left = 82
              Top = 14
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 82
              ExplicitTop = 14
            end
            inherited ZposLab: TLabel
              Left = 158
              Top = 14
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 158
              ExplicitTop = 14
            end
            inherited XposSE: TFloatSpinEdit
              Left = 7
              Top = 28
              Width = 66
              Height = 27
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 7
              ExplicitTop = 28
              ExplicitWidth = 66
              ExplicitHeight = 27
            end
            inherited YposSE: TFloatSpinEdit
              Left = 82
              Top = 28
              Width = 66
              Height = 27
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 82
              ExplicitTop = 28
              ExplicitWidth = 66
              ExplicitHeight = 27
            end
            inherited ZposSE: TFloatSpinEdit
              Left = 158
              Top = 28
              Width = 67
              Height = 27
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 158
              ExplicitTop = 28
              ExplicitWidth = 67
              ExplicitHeight = 27
            end
            inherited XTagCB: TRcComboBox
              Left = 7
              Top = 55
              Width = 66
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 7
              ExplicitTop = 55
              ExplicitWidth = 66
            end
            inherited YTagCB: TRcComboBox
              Left = 82
              Top = 55
              Width = 66
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 82
              ExplicitTop = 55
              ExplicitWidth = 66
            end
            inherited ZTagCB: TRcComboBox
              Left = 158
              Top = 55
              Width = 67
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 158
              ExplicitTop = 55
              ExplicitWidth = 67
            end
          end
          inherited OrientationGB: TGroupBox
            Top = 80
            Width = 231
            Height = 81
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            ExplicitTop = 80
            ExplicitWidth = 231
            ExplicitHeight = 81
            inherited XrotLab: TLabel
              Left = 7
              Top = 14
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 7
              ExplicitTop = 14
            end
            inherited YrotLab: TLabel
              Left = 82
              Top = 14
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 82
              ExplicitTop = 14
            end
            inherited ZrotLab: TLabel
              Left = 158
              Top = 14
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 158
              ExplicitTop = 14
            end
            inherited XrotSE: TFloatSpinEdit
              Left = 7
              Top = 28
              Width = 66
              Height = 27
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 7
              ExplicitTop = 28
              ExplicitWidth = 66
              ExplicitHeight = 27
            end
            inherited YrotSE: TFloatSpinEdit
              Left = 82
              Top = 28
              Width = 66
              Height = 27
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 82
              ExplicitTop = 28
              ExplicitWidth = 66
              ExplicitHeight = 27
            end
            inherited ZrotSE: TFloatSpinEdit
              Left = 158
              Top = 28
              Width = 67
              Height = 27
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 158
              ExplicitTop = 28
              ExplicitWidth = 67
              ExplicitHeight = 27
            end
            inherited XrotTagCB: TRcComboBox
              Left = 7
              Top = 55
              Width = 66
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 7
              ExplicitTop = 55
              ExplicitWidth = 66
            end
            inherited YrotTagCB: TRcComboBox
              Left = 82
              Top = 55
              Width = 66
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 82
              ExplicitTop = 55
              ExplicitWidth = 66
            end
            inherited ZrotTagCB: TRcComboBox
              Left = 158
              Top = 55
              Width = 67
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              ExplicitLeft = 158
              ExplicitTop = 55
              ExplicitWidth = 67
            end
          end
        end
      end
    end
  end
  object RightPanel: TPanel
    Left = 612
    Top = 0
    Width = 192
    Height = 505
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    TabOrder = 2
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 190
      Height = 503
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 190
      ExplicitHeight = 504
      inherited FormChannelsGB: TGroupBox
        Width = 190
        Height = 503
        Margins.Left = 3
        Margins.Top = 3
        Margins.Right = 3
        Margins.Bottom = 3
        ExplicitWidth = 190
        ExplicitHeight = 503
        inherited ChanNamesPanel: TPanel
          Width = 186
          Height = 83
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitWidth = 186
          ExplicitHeight = 83
          inherited FrmTagPropLabel: TLabel
            Left = 4
            Top = 44
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 44
          end
          inherited FrmTagPropValue: TLabel
            Left = 93
            Top = 46
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 93
            ExplicitTop = 46
          end
          inherited FilterEdit: TEdit
            Left = 4
            Top = 6
            Width = 179
            Height = 25
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 6
            ExplicitWidth = 179
            ExplicitHeight = 25
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 93
            Top = 63
            Width = 90
            Height = 25
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 93
            ExplicitTop = 63
            ExplicitWidth = 90
            ExplicitHeight = 25
          end
          inherited FrmTagPropNameCB: TComboBox
            Left = 4
            Top = 63
            Width = 82
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 63
            ExplicitWidth = 82
          end
        end
        inherited TagsLV: TBtnListView
          Top = 98
          Width = 186
          Height = 403
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          Columns = <
            item
              Caption = #1048#1084#1103
            end
            item
              Caption = #1058#1080#1087
            end
            item
              Caption = 'Fs'
              Width = 38
            end>
          ExplicitTop = 98
          ExplicitWidth = 187
          ExplicitHeight = 404
        end
      end
    end
  end
  object Button1: TButton
    Left = 343
    Top = 138
    Width = 30
    Height = 19
    Hint = #1058#1077#1089#1090#1086#1074#1099#1077' '#1076#1072#1085#1085#1099#1077' '#1080#1079' ESP '#1075#1080#1088#1086#1089#1082#1086#1087#1072
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
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

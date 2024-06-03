object EditGLObjFrm: TEditGLObjFrm
  Left = 0
  Top = 0
  Caption = 'EditGLObjFrm'
  ClientHeight = 336
  ClientWidth = 744
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 17
  object RightPanel: TPanel
    Left = 432
    Top = 0
    Width = 312
    Height = 336
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    TabOrder = 0
    ExplicitHeight = 384
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 310
      Height = 334
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 310
      ExplicitHeight = 382
      inherited FormChannelsGB: TGroupBox
        Width = 310
        Height = 334
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        ExplicitWidth = 310
        ExplicitHeight = 382
        inherited ChanNamesPanel: TPanel
          Top = 19
          Width = 306
          Height = 137
          Margins.Left = 5
          Margins.Top = 5
          Margins.Right = 5
          Margins.Bottom = 5
          ExplicitTop = 19
          ExplicitWidth = 306
          ExplicitHeight = 137
          inherited FrmTagPropLabel: TLabel
            Left = 7
            Top = 75
            Width = 62
            Height = 17
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 75
            ExplicitWidth = 62
            ExplicitHeight = 17
          end
          inherited FrmTagPropValue: TLabel
            Left = 156
            Top = 77
            Width = 60
            Height = 17
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 156
            ExplicitTop = 77
            ExplicitWidth = 60
            ExplicitHeight = 17
          end
          inherited FilterEdit: TEdit
            Left = 7
            Top = 10
            Width = 290
            Height = 25
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 10
            ExplicitWidth = 290
            ExplicitHeight = 25
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 156
            Top = 105
            Width = 138
            Height = 25
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 156
            ExplicitTop = 105
            ExplicitWidth = 138
            ExplicitHeight = 25
          end
          inherited FrmTagPropNameCB: TComboBox
            Left = 7
            Top = 105
            Width = 138
            Height = 25
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 105
            ExplicitWidth = 138
            ExplicitHeight = 25
          end
        end
        inherited TagsLV: TBtnListView
          Top = 156
          Width = 306
          Height = 176
          Columns = <
            item
              Caption = #1048#1084#1103
              Width = 64
            end
            item
              Caption = #1058#1080#1087
              Width = 64
            end
            item
              Caption = 'Fs'
            end>
          ExplicitTop = 156
          ExplicitWidth = 306
          ExplicitHeight = 224
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 432
    Height = 336
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    TabOrder = 1
    ExplicitHeight = 384
    object NameLabel: TLabel
      Left = 10
      Top = 17
      Width = 82
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
    end
    object NameEdit: TEdit
      Left = 10
      Top = 42
      Width = 232
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 0
    end
    object BottomPanel: TGroupBox
      Left = 1
      Top = 203
      Width = 430
      Height = 132
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      Caption = 'BottomPanel'
      TabOrder = 1
      ExplicitTop = 251
      object XTagLabel: TLabel
        Left = 9
        Top = 68
        Width = 13
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'X:'
      end
      object YTagLabel: TLabel
        Left = 139
        Top = 68
        Width = 13
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Y:'
      end
      object ZTagLabel: TLabel
        Left = 268
        Top = 68
        Width = 13
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Z:'
      end
      object TypeCB: TComboBox
        Left = 9
        Top = 30
        Width = 190
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
        Text = 'TypeCB'
      end
      object Xcb: TRcComboBox
        Left = 9
        Top = 93
        Width = 122
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 1
        Text = 'Xcb'
      end
      object Ycb: TRcComboBox
        Left = 139
        Top = 93
        Width = 121
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 2
        Text = 'Xcb'
      end
      object Zcb: TRcComboBox
        Left = 268
        Top = 93
        Width = 122
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 3
        Text = 'Xcb'
      end
      object ControlCB: TCheckBox
        Left = 207
        Top = 31
        Width = 108
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1059#1087#1088#1072#1074#1083#1103#1090#1100
        TabOrder = 4
      end
    end
  end
end

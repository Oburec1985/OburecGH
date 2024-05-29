object EditGLObjFrm: TEditGLObjFrm
  Left = 0
  Top = 0
  Caption = 'EditGLObjFrm'
  ClientHeight = 294
  ClientWidth = 569
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object RightPanel: TPanel
    Left = 330
    Top = 0
    Width = 239
    Height = 294
    Align = alRight
    TabOrder = 0
    ExplicitLeft = 328
    ExplicitHeight = 365
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 237
      Height = 292
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 245
      ExplicitHeight = 178
      inherited FormChannelsGB: TGroupBox
        Width = 237
        Height = 292
        ExplicitLeft = 5
        ExplicitTop = 4
        ExplicitWidth = 245
        ExplicitHeight = 178
        inherited ChanNamesPanel: TPanel
          Width = 233
          Height = 105
          ExplicitTop = 14
          ExplicitWidth = 241
          ExplicitHeight = 105
          inherited FrmTagPropLabel: TLabel
            Top = 57
            ExplicitTop = 57
          end
          inherited FrmTagPropValue: TLabel
            Left = 119
            Top = 59
            ExplicitLeft = 119
            ExplicitTop = 59
          end
          inherited FilterEdit: TEdit
            Width = 222
            Height = 20
            ExplicitWidth = 236
            ExplicitHeight = 20
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 119
            Top = 80
            Width = 106
            Height = 20
            ExplicitLeft = 119
            ExplicitTop = 80
            ExplicitWidth = 148
            ExplicitHeight = 20
          end
          inherited FrmTagPropNameCB: TComboBox
            Top = 80
            Width = 106
            ExplicitTop = 80
            ExplicitWidth = 106
            ExplicitHeight = 20
          end
        end
        inherited TagsLV: TBtnListView
          Top = 120
          Width = 233
          Height = 170
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          Columns = <
            item
              Caption = #1048#1084#1103
              Width = 49
            end
            item
              Caption = #1058#1080#1087
              Width = 49
            end
            item
              Caption = 'Fs'
              Width = 38
            end>
          ExplicitTop = 119
          ExplicitWidth = 241
          ExplicitHeight = 57
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 330
    Height = 294
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 1
    ExplicitWidth = 370
    object NameLabel: TLabel
      Left = 8
      Top = 13
      Width = 65
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
    end
    object NameEdit: TEdit
      Left = 8
      Top = 32
      Width = 177
      Height = 21
      TabOrder = 0
    end
    object BottomPanel: TGroupBox
      Left = 1
      Top = 192
      Width = 328
      Height = 101
      Align = alBottom
      Caption = 'BottomPanel'
      TabOrder = 1
      ExplicitWidth = 368
      object XTagLabel: TLabel
        Left = 7
        Top = 52
        Width = 10
        Height = 13
        Caption = 'X:'
      end
      object YTagLabel: TLabel
        Left = 106
        Top = 52
        Width = 10
        Height = 13
        Caption = 'Y:'
      end
      object ZTagLabel: TLabel
        Left = 205
        Top = 52
        Width = 10
        Height = 13
        Caption = 'Z:'
      end
      object TypeCB: TComboBox
        Left = 7
        Top = 23
        Width = 145
        Height = 21
        TabOrder = 0
        Text = 'TypeCB'
      end
      object Xcb: TRcComboBox
        Left = 7
        Top = 71
        Width = 93
        Height = 21
        TabOrder = 1
        Text = 'Xcb'
      end
      object Ycb: TRcComboBox
        Left = 106
        Top = 71
        Width = 93
        Height = 21
        TabOrder = 2
        Text = 'Xcb'
      end
      object Zcb: TRcComboBox
        Left = 205
        Top = 71
        Width = 93
        Height = 21
        TabOrder = 3
        Text = 'Xcb'
      end
      object ControlCB: TCheckBox
        Left = 158
        Top = 24
        Width = 83
        Height = 17
        Caption = #1059#1087#1088#1072#1074#1083#1103#1090#1100
        TabOrder = 4
      end
    end
  end
end

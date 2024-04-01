object DigsFrmEdit: TDigsFrmEdit
  Left = 0
  Top = 0
  Caption = 'DigsFrmEdit'
  ClientHeight = 443
  ClientWidth = 557
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object RightPan: TPanel
    Left = 309
    Top = 124
    Width = 248
    Height = 319
    Align = alRight
    TabOrder = 0
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 246
      Height = 317
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 246
      ExplicitHeight = 317
      inherited FormChannelsGB: TGroupBox
        Width = 246
        Height = 317
        ExplicitWidth = 246
        ExplicitHeight = 317
        inherited ChanNamesPanel: TPanel
          Top = 14
          Width = 242
          Height = 107
          ExplicitTop = 14
          ExplicitWidth = 242
          ExplicitHeight = 107
          inherited FrmTagPropLabel: TLabel
            Top = 57
            Width = 46
            Height = 12
            ExplicitTop = 57
            ExplicitWidth = 46
            ExplicitHeight = 12
          end
          inherited FrmTagPropValue: TLabel
            Left = 119
            Top = 59
            Width = 43
            Height = 12
            ExplicitLeft = 119
            ExplicitTop = 59
            ExplicitWidth = 43
            ExplicitHeight = 12
          end
          inherited FilterEdit: TEdit
            Width = 236
            Height = 20
            ExplicitWidth = 236
            ExplicitHeight = 20
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 119
            Top = 80
            Width = 148
            Height = 20
            ExplicitLeft = 119
            ExplicitTop = 80
            ExplicitWidth = 148
            ExplicitHeight = 20
          end
          inherited FrmTagPropNameCB: TComboBox
            Top = 80
            Width = 106
            Height = 20
            ExplicitTop = 80
            ExplicitWidth = 106
            ExplicitHeight = 20
          end
        end
        inherited TagsLV: TBtnListView
          Top = 121
          Width = 242
          Height = 194
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
          ExplicitTop = 121
          ExplicitWidth = 242
          ExplicitHeight = 194
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 557
    Height = 124
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    TabOrder = 1
    object GroupCountLabel: TLabel
      Left = 5
      Top = 50
      Width = 60
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1080#1089#1083#1086' '#1075#1088#1091#1087#1087
    end
    object GroupNameLabel: TLabel
      Left = 5
      Top = 3
      Width = 56
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099
    end
    object ColCountLabel: TLabel
      Left = 90
      Top = 5
      Width = 78
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1080#1089#1083#1086' '#1089#1090#1086#1083#1073#1094#1086#1074
    end
    object FirstL: TLabel
      Left = 88
      Top = 50
      Width = 74
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1053#1086#1084#1077#1088' '#1087#1077#1088#1074'. '#1075#1088'.'
    end
    object AutoGroupCB: TCheckBox
      Left = 5
      Top = 102
      Width = 91
      Height = 11
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1040#1074#1090#1086#1075#1088#1091#1087#1087#1099
      TabOrder = 0
    end
    object GroupNameE: TEdit
      Left = 5
      Top = 22
      Width = 73
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = 'Group'
    end
    object GroupCountIE: TIntEdit
      Left = 5
      Top = 66
      Width = 73
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 2
      Text = '000'
    end
    object AddGroupBtn: TButton
      Left = 90
      Top = 101
      Width = 70
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 3
    end
    object ColumnGB: TGroupBox
      Left = 240
      Top = 1
      Width = 316
      Height = 122
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1090#1086#1073#1094#1086#1074
      TabOrder = 4
      ExplicitTop = -2
      object TagSubstrL: TLabel
        Left = 134
        Top = 17
        Width = 96
        Height = 12
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1086#1076#1089#1090#1088#1086#1082#1072' '#1076#1083#1103' '#1090#1077#1075#1072
      end
      object EstTypeL: TLabel
        Left = 244
        Top = 17
        Width = 56
        Height = 12
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1058#1080#1087' '#1086#1094#1077#1085#1082#1080
      end
      object ColNameL: TLabel
        Left = 11
        Top = 14
        Width = 61
        Height = 12
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1048#1084#1103' '#1089#1090#1086#1083#1073#1094#1072
      end
      object ColNumLabel: TLabel
        Left = 11
        Top = 55
        Width = 73
        Height = 12
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1053#1086#1084#1077#1088' '#1089#1090#1086#1083#1073#1094#1072
      end
      object TagSubstrE: TEdit
        Left = 134
        Top = 33
        Width = 86
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 0
      end
      object CheckBox2: TCheckBox
        Left = 134
        Top = 74
        Width = 86
        Height = 11
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1053#1086#1084#1077#1088' '#1075#1088#1091#1087#1087#1099
        TabOrder = 1
      end
      object EstCB: TComboBox
        Left = 244
        Top = 33
        Width = 101
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        ItemIndex = 0
        TabOrder = 2
        Text = #1052#1072#1090'. '#1086#1078'.'
        Items.Strings = (
          #1052#1072#1090'. '#1086#1078'.'
          'Pk'
          'Pk-Pk'
          'Rms')
      end
      object UpdateTagsBtn: TButton
        Left = 133
        Top = 99
        Width = 56
        Height = 19
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1086#1080#1089#1082
        TabOrder = 3
      end
      object ColNameE: TEdit
        Left = 11
        Top = 33
        Width = 86
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 4
      end
      object ColumnSE: TSpinEdit
        Left = 11
        Top = 71
        Width = 70
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        MaxValue = 0
        MinValue = 0
        TabOrder = 5
        Value = 0
      end
      object ColOkBtn: TButton
        Left = 244
        Top = 66
        Width = 37
        Height = 19
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = 'Ok'
        TabOrder = 6
        OnClick = OkBtnClick
      end
    end
    object ColCountE: TIntEdit
      Left = 88
      Top = 21
      Width = 80
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 5
      Text = '1'
    end
    object FirstIE: TIntEdit
      Left = 88
      Top = 66
      Width = 80
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 6
      Text = '1'
    end
    object OkBtn: TButton
      Left = 172
      Top = 21
      Width = 37
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Ok'
      TabOrder = 7
      OnClick = OkBtnClick
    end
  end
  object SignalsSG: TStringGrid
    Left = 0
    Top = 124
    Width = 309
    Height = 319
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 2
  end
end

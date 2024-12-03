object DigsFrmEdit: TDigsFrmEdit
  Left = 0
  Top = 0
  Caption = 'DigsFrmEdit'
  ClientHeight = 533
  ClientWidth = 904
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object RightPan: TPanel
    Left = 575
    Top = 165
    Width = 329
    Height = 240
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    TabOrder = 0
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 327
      Height = 238
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 327
      ExplicitHeight = 238
      inherited FormChannelsGB: TGroupBox
        Width = 327
        Height = 238
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        ExplicitWidth = 327
        ExplicitHeight = 238
        inherited ChanNamesPanel: TPanel
          Width = 323
          Height = 140
          Margins.Left = 5
          Margins.Top = 5
          Margins.Right = 5
          Margins.Bottom = 5
          ExplicitWidth = 323
          ExplicitHeight = 140
          inherited FrmTagPropLabel: TLabel
            Left = 7
            Top = 76
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 76
          end
          inherited FrmTagPropValue: TLabel
            Left = 159
            Top = 79
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 159
            ExplicitTop = 79
          end
          inherited FilterEdit: TEdit
            Left = 7
            Top = 11
            Width = 314
            Height = 24
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 11
            ExplicitWidth = 314
            ExplicitHeight = 24
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 159
            Top = 107
            Width = 197
            Height = 24
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 159
            ExplicitTop = 107
            ExplicitWidth = 197
            ExplicitHeight = 24
          end
          inherited FrmTagPropNameCB: TComboBox
            Left = 7
            Top = 107
            Width = 141
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 107
            ExplicitWidth = 141
          end
        end
        inherited TagsLV: TBtnListView
          Top = 158
          Width = 323
          Height = 78
          Columns = <
            item
              Caption = #1048#1084#1103
              Width = 65
            end
            item
              Caption = #1058#1080#1087
              Width = 65
            end
            item
              Caption = 'Fs'
              Width = 51
            end>
          ExplicitTop = 158
          ExplicitWidth = 323
          ExplicitHeight = 78
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 904
    Height = 165
    Align = alTop
    TabOrder = 1
    object GroupCountLabel: TLabel
      Left = 7
      Top = 67
      Width = 71
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1075#1088#1091#1087#1087
    end
    object GroupNameLabel: TLabel
      Left = 7
      Top = 4
      Width = 68
      Height = 16
      Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099
    end
    object ColCountLabel: TLabel
      Left = 120
      Top = 7
      Width = 93
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1089#1090#1086#1083#1073#1094#1086#1074
    end
    object FirstL: TLabel
      Left = 117
      Top = 67
      Width = 93
      Height = 16
      Caption = #1053#1086#1084#1077#1088' '#1087#1077#1088#1074'. '#1075#1088'.'
    end
    object GroupNameE: TEdit
      Left = 7
      Top = 28
      Width = 97
      Height = 24
      TabOrder = 0
      Text = 'Group'
    end
    object GroupCountIE: TIntEdit
      Left = 7
      Top = 88
      Width = 97
      Height = 24
      TabOrder = 1
      Text = '000'
    end
    object AddGroupBtn: TButton
      Left = 120
      Top = 120
      Width = 93
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 2
      OnClick = AddGroupBtnClick
    end
    object ColumnGB: TGroupBox
      Left = 363
      Top = 1
      Width = 540
      Height = 163
      Align = alRight
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1090#1086#1073#1094#1086#1074
      TabOrder = 3
      object TagSubstrL: TLabel
        Left = 132
        Top = 23
        Width = 115
        Height = 16
        Caption = #1055#1086#1076#1089#1090#1088#1086#1082#1072' '#1076#1083#1103' '#1090#1077#1075#1072
      end
      object EstTypeL: TLabel
        Left = 271
        Top = 23
        Width = 67
        Height = 16
        Caption = #1058#1080#1087' '#1086#1094#1077#1085#1082#1080
      end
      object ColNameL: TLabel
        Left = 15
        Top = 23
        Width = 74
        Height = 16
        Caption = #1048#1084#1103' '#1089#1090#1086#1083#1073#1094#1072
      end
      object ColNumLabel: TLabel
        Left = 15
        Top = 73
        Width = 88
        Height = 16
        Caption = #1053#1086#1084#1077#1088' '#1089#1090#1086#1083#1073#1094#1072
      end
      object TagSubstrE: TEdit
        Left = 132
        Top = 44
        Width = 115
        Height = 24
        TabOrder = 0
      end
      object EstCB: TComboBox
        Left = 271
        Top = 44
        Width = 101
        Height = 24
        ItemIndex = 0
        TabOrder = 1
        Text = #1052#1072#1090'. '#1086#1078'.'
        Items.Strings = (
          #1052#1072#1090'. '#1086#1078'.'
          'Pk'
          'Pk-Pk'
          'Rms')
      end
      object UpdateTagsBtn: TButton
        Left = 132
        Top = 95
        Width = 75
        Height = 25
        Caption = #1055#1086#1080#1089#1082
        TabOrder = 2
        OnClick = UpdateTagsBtnClick2
      end
      object ColNameE: TEdit
        Left = 15
        Top = 44
        Width = 97
        Height = 24
        TabOrder = 3
      end
      object ColumnSE: TSpinEdit
        Left = 15
        Top = 95
        Width = 97
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 4
        Value = 0
        OnChange = ColumnSEChange
      end
      object ColOkBtn: TButton
        Left = 271
        Top = 95
        Width = 49
        Height = 25
        Caption = 'Ok'
        TabOrder = 5
        OnClick = ColOkBtnClick
      end
      object HHColor: TPanel
        Left = 448
        Top = 40
        Width = 35
        Height = 33
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Color = clRed
        ParentBackground = False
        TabOrder = 6
      end
      object UseThreshold: TCheckBox
        Left = 379
        Top = 47
        Width = 61
        Height = 22
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1055#1086#1088#1086#1075
        TabOrder = 7
      end
      object HHEdit: TFloatEdit
        Left = 379
        Top = 93
        Width = 92
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 8
        Text = '10'
      end
    end
    object ColCountE: TIntEdit
      Left = 117
      Top = 28
      Width = 107
      Height = 24
      TabOrder = 4
      Text = '1'
    end
    object FirstIE: TIntEdit
      Left = 120
      Top = 88
      Width = 107
      Height = 24
      TabOrder = 5
      Text = '1'
    end
  end
  object SignalsSG: TStringGrid
    Left = 0
    Top = 165
    Width = 575
    Height = 240
    Align = alClient
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 2
    OnDragDrop = SignalsSGDragDrop
    OnDragOver = SignalsSGDragOver
    OnDrawCell = SignalsSGDrawCell
    OnKeyDown = SignalsSGKeyDown
    OnSelectCell = SignalsSGSelectCell
  end
  object Panel1: TPanel
    Left = 0
    Top = 405
    Width = 904
    Height = 128
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      904
      128)
    object Label1: TLabel
      Left = 7
      Top = 7
      Width = 67
      Height = 16
      Caption = #1047#1085#1072#1095'. '#1094#1080#1092#1088
    end
    object Label2: TLabel
      Left = 127
      Top = 7
      Width = 93
      Height = 16
      Caption = #1056#1072#1079#1084#1077#1088' '#1096#1088#1080#1092#1090#1072
    end
    object ApplyBtn: TButton
      Left = 759
      Top = 25
      Width = 132
      Height = 26
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = ApplyBtnClick
    end
    object DigitsIE: TIntEdit
      Left = 7
      Top = 25
      Width = 108
      Height = 24
      TabOrder = 1
      Text = '4'
    end
    object FontSizeIE: TIntEdit
      Left = 127
      Top = 25
      Width = 108
      Height = 24
      TabOrder = 2
      Text = '4'
    end
    object DigitFormatCB: TCheckBox
      Left = 7
      Top = 59
      Width = 228
      Height = 22
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1047#1085#1072#1095'. '#1094#1080#1092#1088
      TabOrder = 3
      OnClick = DigitFormatCBClick
    end
  end
end

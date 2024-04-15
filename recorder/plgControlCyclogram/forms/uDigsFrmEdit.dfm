object DigsFrmEdit: TDigsFrmEdit
  Left = 0
  Top = 0
  Caption = 'DigsFrmEdit'
  ClientHeight = 400
  ClientWidth = 678
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
    Left = 431
    Top = 124
    Width = 247
    Height = 180
    Align = alRight
    TabOrder = 0
    ExplicitLeft = 239
    ExplicitHeight = 272
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 245
      Height = 178
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 245
      ExplicitHeight = 270
      inherited FormChannelsGB: TGroupBox
        Width = 245
        Height = 178
        ExplicitWidth = 245
        ExplicitHeight = 270
        inherited ChanNamesPanel: TPanel
          Top = 14
          Width = 241
          Height = 106
          ExplicitTop = 14
          ExplicitWidth = 241
          ExplicitHeight = 106
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
          Top = 120
          Width = 241
          Height = 56
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
          ExplicitTop = 120
          ExplicitWidth = 241
          ExplicitHeight = 148
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 678
    Height = 124
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 486
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
    object GroupNameE: TEdit
      Left = 5
      Top = 21
      Width = 73
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
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
      TabOrder = 1
      Text = '000'
    end
    object AddGroupBtn: TButton
      Left = 90
      Top = 90
      Width = 70
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 2
      OnClick = AddGroupBtnClick
    end
    object ColumnGB: TGroupBox
      Left = 272
      Top = 1
      Width = 405
      Height = 122
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1090#1086#1073#1094#1086#1074
      TabOrder = 3
      ExplicitTop = -2
      object TagSubstrL: TLabel
        Left = 99
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
        Left = 203
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
        Top = 17
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
        Left = 99
        Top = 33
        Width = 86
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 0
      end
      object EstCB: TComboBox
        Left = 203
        Top = 33
        Width = 76
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
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
        Left = 99
        Top = 71
        Width = 56
        Height = 19
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1086#1080#1089#1082
        TabOrder = 2
        OnClick = UpdateTagsBtnClick
      end
      object ColNameE: TEdit
        Left = 11
        Top = 33
        Width = 73
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 3
      end
      object ColumnSE: TSpinEdit
        Left = 11
        Top = 71
        Width = 73
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        MaxValue = 0
        MinValue = 0
        TabOrder = 4
        Value = 0
        OnChange = ColumnSEChange
      end
      object ColOkBtn: TButton
        Left = 203
        Top = 71
        Width = 37
        Height = 19
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = 'Ok'
        TabOrder = 5
        OnClick = ColOkBtnClick
      end
      object HHColor: TPanel
        Left = 336
        Top = 30
        Width = 26
        Height = 25
        Color = clRed
        ParentBackground = False
        TabOrder = 6
      end
      object UseThreshold: TCheckBox
        Left = 284
        Top = 35
        Width = 46
        Height = 17
        Caption = #1055#1086#1088#1086#1075
        TabOrder = 7
      end
      object HHEdit: TFloatEdit
        Left = 284
        Top = 70
        Width = 69
        Height = 20
        TabOrder = 8
        Text = '10'
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
      TabOrder = 4
      Text = '1'
    end
    object FirstIE: TIntEdit
      Left = 90
      Top = 66
      Width = 80
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 5
      Text = '1'
    end
  end
  object SignalsSG: TStringGrid
    Left = 0
    Top = 124
    Width = 431
    Height = 180
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 2
    OnDragDrop = SignalsSGDragDrop
    OnDragOver = SignalsSGDragOver
    OnDrawCell = SignalsSGDrawCell
    OnKeyDown = SignalsSGKeyDown
    OnSelectCell = SignalsSGSelectCell
    ExplicitLeft = 2
    ExplicitTop = 125
    ExplicitWidth = 364
    ExplicitHeight = 221
  end
  object Panel1: TPanel
    Left = 0
    Top = 304
    Width = 678
    Height = 96
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 3
    ExplicitTop = 306
    DesignSize = (
      678
      96)
    object Label1: TLabel
      Left = 5
      Top = 5
      Width = 53
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1047#1085#1072#1095'. '#1094#1080#1092#1088
    end
    object Label2: TLabel
      Left = 95
      Top = 5
      Width = 75
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1056#1072#1079#1084#1077#1088' '#1096#1088#1080#1092#1090#1072
    end
    object ApplyBtn: TButton
      Left = 569
      Top = 19
      Width = 99
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = ApplyBtnClick
      ExplicitLeft = 377
    end
    object DigitsIE: TIntEdit
      Left = 5
      Top = 19
      Width = 81
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = '4'
    end
    object FontSizeIE: TIntEdit
      Left = 95
      Top = 19
      Width = 81
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 2
      Text = '4'
    end
    object DigitFormatCB: TCheckBox
      Left = 5
      Top = 44
      Width = 73
      Height = 17
      Caption = #1047#1085#1072#1095'. '#1094#1080#1092#1088
      TabOrder = 3
      OnClick = DigitFormatCBClick
    end
  end
end

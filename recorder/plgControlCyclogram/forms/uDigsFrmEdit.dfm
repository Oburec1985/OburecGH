object DigsFrmEdit: TDigsFrmEdit
  Left = 0
  Top = 0
  Caption = 'DigsFrmEdit'
  ClientHeight = 398
  ClientWidth = 1076
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Panel3: TPanel
    Left = 745
    Top = 113
    Width = 331
    Height = 285
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    TabOrder = 0
    ExplicitLeft = 648
    ExplicitTop = 0
    ExplicitHeight = 548
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 329
      Height = 283
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 289
      ExplicitHeight = 482
      inherited FormChannelsGB: TGroupBox
        Width = 329
        Height = 283
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        ExplicitWidth = 289
        ExplicitHeight = 482
        inherited ChanNamesPanel: TPanel
          Width = 325
          Height = 143
          Margins.Left = 5
          Margins.Top = 5
          Margins.Right = 5
          Margins.Bottom = 5
          ExplicitWidth = 285
          ExplicitHeight = 143
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
            Left = 158
            Top = 78
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 158
            ExplicitTop = 78
          end
          inherited FilterEdit: TEdit
            Left = 7
            Top = 10
            Width = 314
            Height = 24
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 7
            ExplicitTop = 10
            ExplicitWidth = 274
            ExplicitHeight = 24
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 158
            Top = 107
            Width = 198
            Height = 24
            Margins.Left = 5
            Margins.Top = 5
            Margins.Right = 5
            Margins.Bottom = 5
            ExplicitLeft = 158
            ExplicitTop = 107
            ExplicitWidth = 158
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
          Top = 161
          Width = 325
          Height = 120
          ExplicitTop = 161
          ExplicitWidth = 285
          ExplicitHeight = 319
        end
      end
    end
    object Panel1: TPanel
      Left = -352
      Top = 144
      Width = 185
      Height = 41
      Caption = 'Panel1'
      TabOrder = 1
    end
    object StringGrid1: TStringGrid
      Left = -480
      Top = 112
      Width = 320
      Height = 120
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1076
    Height = 113
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 280
      Top = 4
      Width = 93
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1089#1090#1086#1083#1073#1094#1086#1074
    end
    object Label2: TLabel
      Left = 125
      Top = 29
      Width = 71
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1075#1088#1091#1087#1087
    end
    object Label3: TLabel
      Left = 5
      Top = 17
      Width = 68
      Height = 16
      Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099
    end
    object Label4: TLabel
      Left = 280
      Top = 56
      Width = 93
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1089#1090#1086#1083#1073#1094#1086#1074
    end
    object IntEdit1: TIntEdit
      Left = 280
      Top = 26
      Width = 93
      Height = 24
      TabOrder = 0
      Text = '000'
    end
    object CheckBox1: TCheckBox
      Left = 125
      Top = 9
      Width = 97
      Height = 15
      Caption = #1040#1074#1090#1086#1075#1088#1091#1087#1087#1099
      TabOrder = 1
    end
    object Edit1: TEdit
      Left = 5
      Top = 39
      Width = 97
      Height = 24
      TabOrder = 2
      Text = 'Edit1'
    end
    object IntEdit2: TIntEdit
      Left = 125
      Top = 51
      Width = 75
      Height = 24
      TabOrder = 3
      Text = '000'
    end
    object Button1: TButton
      Left = 125
      Top = 81
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 4
    end
    object GroupBox1: TGroupBox
      Left = 440
      Top = 1
      Width = 635
      Height = 111
      Align = alRight
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1090#1086#1073#1094#1086#1074
      TabOrder = 5
      object Label5: TLabel
        Left = 189
        Top = 22
        Width = 115
        Height = 16
        Caption = #1055#1086#1076#1089#1090#1088#1086#1082#1072' '#1076#1083#1103' '#1090#1077#1075#1072
      end
      object Label6: TLabel
        Left = 336
        Top = 22
        Width = 67
        Height = 16
        Caption = #1058#1080#1087' '#1086#1094#1077#1085#1082#1080
      end
      object Label7: TLabel
        Left = 6
        Top = 22
        Width = 74
        Height = 16
        Caption = #1048#1084#1103' '#1089#1090#1086#1083#1073#1094#1072
      end
      object Edit2: TEdit
        Left = 189
        Top = 44
        Width = 115
        Height = 24
        TabOrder = 0
        Text = 'Edit1'
      end
      object CheckBox2: TCheckBox
        Left = 189
        Top = 81
        Width = 115
        Height = 15
        Caption = #1053#1086#1084#1077#1088' '#1075#1088#1091#1087#1087#1099
        TabOrder = 1
      end
      object ComboBox1: TComboBox
        Left = 336
        Top = 44
        Width = 145
        Height = 24
        TabOrder = 2
        Text = 'ComboBox1'
      end
      object Button2: TButton
        Left = 504
        Top = 43
        Width = 75
        Height = 25
        Caption = #1055#1086#1080#1089#1082
        TabOrder = 3
      end
      object Edit3: TEdit
        Left = 6
        Top = 44
        Width = 115
        Height = 24
        TabOrder = 4
        Text = 'Edit1'
      end
    end
    object ColumnSE: TSpinEdit
      Left = 280
      Top = 78
      Width = 93
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 0
    end
  end
  object SignalsSG: TStringGrid
    Left = 0
    Top = 113
    Width = 745
    Height = 285
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 633
    ExplicitHeight = 421
  end
end

object Form2: TForm2
  Left = 0
  Top = 0
  Caption = #1043#1088#1072#1076#1091#1080#1088#1086#1074#1086#1095#1085#1099#1077' '#1093#1072#1088'-'#1082#1080' '#1076#1072#1090#1095#1080#1082#1086#1074
  ClientHeight = 549
  ClientWidth = 672
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 390
    Width = 672
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 97
    ExplicitWidth = 423
  end
  object BtnListView1: TBtnListView
    Left = 0
    Top = 9
    Width = 672
    Height = 381
    Align = alClient
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103' '#1082#1072#1085#1072#1083#1072
      end
      item
        Caption = #1044#1072#1090#1095#1080#1082
      end
      item
        Caption = #1056#1072#1079#1084#1077#1088#1085#1086#1089#1090#1100', '#1077#1076'.'#1076'/'#1077#1076'. '#1084#1086#1076#1091#1083#1103
      end
      item
        Caption = #1052#1085#1086#1078#1080#1090#1077#1083#1100
      end
      item
        Caption = #1054#1073#1088#1072#1090#1085#1099#1081' '#1084#1085#1086#1078#1080#1090#1077#1083#1100
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ExplicitTop = 8
    ExplicitHeight = 316
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 672
    Height = 9
    Align = alTop
    TabOrder = 1
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 393
    Width = 672
    Height = 156
    Align = alBottom
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1043#1061
    TabOrder = 2
    ExplicitTop = 355
    DesignSize = (
      672
      156)
    object Label1: TLabel
      Left = 3
      Top = 20
      Width = 64
      Height = 13
      Caption = #1058#1080#1087' '#1076#1072#1090#1095#1080#1082#1072
    end
    object Label2: TLabel
      Left = 171
      Top = 21
      Width = 101
      Height = 13
      Caption = #1045#1076#1080#1085#1080#1094#1099' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
    end
    object Label7: TLabel
      Left = 171
      Top = 93
      Width = 59
      Height = 13
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1043#1061
    end
    object ApplyBtn: TButton
      Left = 594
      Top = 128
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitTop = 154
    end
    object CancelBtn: TButton
      Left = 3
      Top = 128
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
      ExplicitTop = 154
    end
    object ComboBox1: TComboBox
      Left = 171
      Top = 40
      Width = 145
      Height = 21
      TabOrder = 2
      Text = #1045#1076#1080#1085#1080#1094#1099' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
    end
    object ComboBox2: TComboBox
      Left = 3
      Top = 39
      Width = 145
      Height = 21
      TabOrder = 3
      Text = #1045#1076#1080#1085#1080#1094#1099' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
    end
    object GroupBox3: TGroupBox
      Left = 322
      Top = 6
      Width = 311
      Height = 121
      Caption = #1043#1061' '#1076#1072#1090#1095#1080#1082#1072
      TabOrder = 4
      object Label4: TLabel
        Left = 3
        Top = 69
        Width = 111
        Height = 13
        Caption = #1054#1073#1088#1072#1090#1085#1099#1081' '#1084#1085#1086#1078#1080#1090#1077#1083#1100
      end
      object Label3: TLabel
        Left = 3
        Top = 21
        Width = 58
        Height = 13
        Caption = #1052#1085#1086#1078#1080#1090#1077#1083#1100
      end
      object Label5: TLabel
        Left = 143
        Top = 43
        Width = 123
        Height = 13
        Caption = ','#1045#1076' '#1076#1072#1090#1095#1080#1082#1072'/ '#1045#1076' '#1084#1086#1076#1091#1083#1103
      end
      object Label6: TLabel
        Left = 143
        Top = 91
        Width = 123
        Height = 13
        Caption = ','#1045#1076' '#1084#1086#1076#1091#1083#1103'/ '#1045#1076' '#1076#1072#1090#1095#1080#1082#1072
      end
      object FloatSpinEdit2: TFloatSpinEdit
        Left = 3
        Top = 88
        Width = 134
        Height = 22
        Increment = 0.100000001490116100
        TabOrder = 0
      end
      object FloatSpinEdit1: TFloatSpinEdit
        Left = 3
        Top = 40
        Width = 134
        Height = 22
        Increment = 0.100000001490116100
        TabOrder = 1
      end
      object Button1: TButton
        Left = 144
        Top = 12
        Width = 75
        Height = 25
        Caption = #1048#1084#1087#1086#1088#1090
        TabOrder = 2
      end
      object Button2: TButton
        Left = 225
        Top = 12
        Width = 75
        Height = 25
        Caption = #1069#1082#1089#1087#1086#1088#1090
        TabOrder = 3
      end
    end
  end
end

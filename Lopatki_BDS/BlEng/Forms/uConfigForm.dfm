object ConfigForm: TConfigForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1090#1091#1088#1073#1080#1085#1099
  ClientHeight = 775
  ClientWidth = 663
  Color = clBtnFace
  Constraints.MinHeight = 706
  Constraints.MinWidth = 584
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    663
    775)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 2
    Top = 432
    Width = 653
    Height = 309
    Anchors = [akLeft, akTop, akRight]
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1076#1072#1090#1095#1080#1082#1086#1074
    Color = clMoneyGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      653
      309)
    object SensorsLV: TBtnListView
      Left = 256
      Top = 16
      Width = 394
      Height = 281
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = #8470
          Width = 28
        end
        item
          Caption = #1048#1084#1103
          Width = 68
        end
        item
          Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087#1091#1083#1100#1089#1086#1074
          Width = 75
        end
        item
          Caption = #1058#1080#1087
          Width = 59
        end
        item
          Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
          Width = 78
        end
        item
          Caption = #1057#1090#1091#1087#1077#1085#1100
          Width = 80
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      GridLines = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClickProcess = SensorsLVDblClickProcess
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
    end
  end
  object CancelBtn: TButton
    Left = 4
    Top = 747
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 1
  end
  object OkBtn: TButton
    Left = 554
    Top = 747
    Width = 106
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 2
  end
  object GroupBox2: TGroupBox
    Left = 2
    Top = 74
    Width = 653
    Height = 363
    Anchors = [akLeft, akTop, akRight]
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1090#1091#1087#1077#1085#1077#1081
    Color = clMoneyGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 3
    DesignSize = (
      653
      363)
    object TabControl: TPageControl
      Left = 3
      Top = 37
      Width = 642
      Height = 310
      ActivePage = Rotor1
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MultiLine = True
      ParentFont = False
      TabOrder = 0
      TabStop = False
      object Rotor1: TTabSheet
        Caption = #1057#1090#1091#1087#1077#1085#1100' 1'
        DesignSize = (
          634
          276)
        object Label1: TLabel
          Left = 2
          Top = 30
          Width = 109
          Height = 19
          Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
        end
        object StageName1: TLabel
          Left = 2
          Top = 3
          Width = 106
          Height = 19
          Caption = #1048#1084#1103' '#1089#1090#1091#1087#1077#1085#1080' 1'
        end
        object Label7: TLabel
          Left = 4
          Top = 163
          Width = 160
          Height = 19
          Caption = #1058#1072#1093#1086' '#1076#1072#1090#1095#1080#1082' '#1089#1090#1091#1087#1077#1085#1080':'
        end
        object BladesListView1: TBtnListView
          Left = 435
          Top = 3
          Width = 192
          Height = 271
          Hint = 
            #1058#1072#1073#1083#1080#1094#1072' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1074#1072#1083#1091':'#13#10'1) '#1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080#13#10'2) '#1057#1084#1077#1097 +
            #1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1089#1084#1077#1097#1077#1085#1080#1077' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10' '#1057#1085#1103#1090#1080#1077' '#1075#1072#1083#1086#1095#1082#1080 +
            ' '#1074#1085#1091#1090#1088#1080' '#1089#1090#1088#1086#1082#1080' '#1086#1079#1085#1072#1095#1072#1077#1090' '#1086#1090#1084#1077#1085#1091' '#1075#1077#1085#1077#1072#1088#1094#1080#1080' '#1074#1080#1073#1088#1072#1094#1080#1080#13#10' '#1087#1086' '#1076#1072#1085#1085#1086#1081' '#1083#1086 +
            #1087#1072#1090#1082#1080' ('#1083#1086#1087#1072#1090#1082#1072' '#1073#1091#1076#1077#1090' '#1085#1077#1087#1086#1076#1074#1080#1078#1085#1072').'
          Anchors = [akTop, akRight, akBottom]
          Checkboxes = True
          Columns = <
            item
              Caption = #8470' '#1051#1086#1087#1072#1090#1082#1080
              Width = 90
            end
            item
              Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
              Width = 98
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          GridLines = True
          ParentFont = False
          TabOrder = 0
          ViewStyle = vsReport
          BtnCol = -1
          QuoteColumnBtnClick = True
          QuoteColumnDblClick = False
        end
        object bladeCountE1: TIntEdit
          Left = 117
          Top = 33
          Width = 87
          Height = 27
          TabOrder = 1
          Text = '0'
        end
        object StageNameEdit1: TEdit
          Left = 117
          Top = 3
          Width = 87
          Height = 24
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 2
        end
        object TahoCBox1: TComboBox
          Left = 4
          Top = 188
          Width = 106
          Height = 24
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 16
          ParentFont = False
          TabOrder = 3
        end
        object GroupBox3: TGroupBox
          Left = 3
          Top = 61
          Width = 338
          Height = 96
          Caption = #1044#1072#1090#1095#1080#1082' '#1076#1083#1103' '#1088#1072#1089#1095#1077#1090#1072' '#1092#1086#1088#1084#1099
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          object Label10: TLabel
            Left = 3
            Top = 37
            Width = 56
            Height = 16
            Caption = #1053#1072#1079#1074#1072#1085#1080#1077
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label11: TLabel
            Left = 124
            Top = 37
            Width = 125
            Height = 16
            Caption = #1057#1084#1077#1089#1090#1080#1090#1100' '#1087#1086#1083#1086#1078#1077#1085#1080#1077
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object SensorsCBox1: TComboBox
            Left = 3
            Top = 60
            Width = 103
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemHeight = 16
            ParentFont = False
            TabOrder = 0
          end
          object PosFE1: TFloatEdit
            Left = 124
            Top = 60
            Width = 87
            Height = 27
            TabOrder = 1
            Text = '0.0'
          end
        end
      end
      object Rotor2: TTabSheet
        Caption = #1057#1090#1091#1087#1077#1085#1100' 2'
        ImageIndex = 1
        DesignSize = (
          634
          276)
        object Label2: TLabel
          Left = 2
          Top = 30
          Width = 109
          Height = 19
          Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
        end
        object Label3: TLabel
          Left = 2
          Top = 3
          Width = 106
          Height = 19
          Caption = #1048#1084#1103' '#1089#1090#1091#1087#1077#1085#1080' 2'
        end
        object Label4: TLabel
          Left = 4
          Top = 163
          Width = 160
          Height = 19
          Caption = #1058#1072#1093#1086' '#1076#1072#1090#1095#1080#1082' '#1089#1090#1091#1087#1077#1085#1080':'
        end
        object BladesListView2: TBtnListView
          Left = 435
          Top = 3
          Width = 196
          Height = 271
          Hint = 
            #1058#1072#1073#1083#1080#1094#1072' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1074#1072#1083#1091':'#13#10'1) '#1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080#13#10'2) '#1057#1084#1077#1097 +
            #1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1089#1084#1077#1097#1077#1085#1080#1077' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10' '#1057#1085#1103#1090#1080#1077' '#1075#1072#1083#1086#1095#1082#1080 +
            ' '#1074#1085#1091#1090#1088#1080' '#1089#1090#1088#1086#1082#1080' '#1086#1079#1085#1072#1095#1072#1077#1090' '#1086#1090#1084#1077#1085#1091' '#1075#1077#1085#1077#1072#1088#1094#1080#1080' '#1074#1080#1073#1088#1072#1094#1080#1080#13#10' '#1087#1086' '#1076#1072#1085#1085#1086#1081' '#1083#1086 +
            #1087#1072#1090#1082#1080' ('#1083#1086#1087#1072#1090#1082#1072' '#1073#1091#1076#1077#1090' '#1085#1077#1087#1086#1076#1074#1080#1078#1085#1072').'
          Anchors = [akTop, akRight, akBottom]
          Checkboxes = True
          Columns = <
            item
              Caption = #8470' '#1083#1086#1087#1072#1090#1082#1080
              Width = 90
            end
            item
              Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
              Width = 98
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          GridLines = True
          ParentFont = False
          TabOrder = 0
          ViewStyle = vsReport
          BtnCol = -1
          QuoteColumnBtnClick = True
          QuoteColumnDblClick = False
        end
        object bladeCountE2: TIntEdit
          Left = 117
          Top = 31
          Width = 87
          Height = 27
          TabOrder = 1
          Text = '0'
        end
        object StageNameEdit2: TEdit
          Left = 117
          Top = 3
          Width = 87
          Height = 24
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object TahoCBox2: TComboBox
          Left = 4
          Top = 188
          Width = 106
          Height = 24
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 16
          ParentFont = False
          TabOrder = 3
        end
        object GroupBox4: TGroupBox
          Left = 4
          Top = 60
          Width = 338
          Height = 96
          Caption = #1044#1072#1090#1095#1080#1082' '#1076#1083#1103' '#1088#1072#1089#1095#1077#1090#1072' '#1092#1086#1088#1084#1099
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          object Label5: TLabel
            Left = 3
            Top = 37
            Width = 56
            Height = 16
            Caption = #1053#1072#1079#1074#1072#1085#1080#1077
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label6: TLabel
            Left = 124
            Top = 37
            Width = 125
            Height = 16
            Caption = #1057#1084#1077#1089#1090#1080#1090#1100' '#1087#1086#1083#1086#1078#1077#1085#1080#1077
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object SensorsCBox2: TComboBox
            Left = 3
            Top = 60
            Width = 103
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemHeight = 16
            ParentFont = False
            TabOrder = 0
          end
          object PosFE2: TFloatEdit
            Left = 123
            Top = 60
            Width = 87
            Height = 27
            TabOrder = 1
            Text = '0.0'
          end
        end
      end
      object Rotor3: TTabSheet
        Caption = #1057#1090#1091#1087#1077#1085#1100' 3'
        ImageIndex = 2
        DesignSize = (
          634
          276)
        object Label15: TLabel
          Left = 2
          Top = 30
          Width = 109
          Height = 19
          Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
        end
        object Label16: TLabel
          Left = 2
          Top = 3
          Width = 106
          Height = 19
          Caption = #1048#1084#1103' '#1089#1090#1091#1087#1077#1085#1080' 3'
        end
        object Label17: TLabel
          Left = 4
          Top = 163
          Width = 160
          Height = 19
          Caption = #1058#1072#1093#1086' '#1076#1072#1090#1095#1080#1082' '#1089#1090#1091#1087#1077#1085#1080':'
        end
        object BladesListView3: TBtnListView
          Left = 435
          Top = 3
          Width = 196
          Height = 271
          Hint = 
            #1058#1072#1073#1083#1080#1094#1072' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1074#1072#1083#1091':'#13#10'1) '#1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080#13#10'2) '#1057#1084#1077#1097 +
            #1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1089#1084#1077#1097#1077#1085#1080#1077' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10' '#1057#1085#1103#1090#1080#1077' '#1075#1072#1083#1086#1095#1082#1080 +
            ' '#1074#1085#1091#1090#1088#1080' '#1089#1090#1088#1086#1082#1080' '#1086#1079#1085#1072#1095#1072#1077#1090' '#1086#1090#1084#1077#1085#1091' '#1075#1077#1085#1077#1072#1088#1094#1080#1080' '#1074#1080#1073#1088#1072#1094#1080#1080#13#10' '#1087#1086' '#1076#1072#1085#1085#1086#1081' '#1083#1086 +
            #1087#1072#1090#1082#1080' ('#1083#1086#1087#1072#1090#1082#1072' '#1073#1091#1076#1077#1090' '#1085#1077#1087#1086#1076#1074#1080#1078#1085#1072').'
          Anchors = [akTop, akRight, akBottom]
          Checkboxes = True
          Columns = <
            item
              Caption = #8470' '#1083#1086#1087#1072#1090#1082#1080
              Width = 90
            end
            item
              Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
              Width = 98
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          GridLines = True
          ParentFont = False
          TabOrder = 0
          ViewStyle = vsReport
          BtnCol = -1
          QuoteColumnBtnClick = True
          QuoteColumnDblClick = False
        end
        object bladeCountE3: TIntEdit
          Left = 117
          Top = 31
          Width = 87
          Height = 27
          TabOrder = 1
          Text = '0'
        end
        object StageNameEdit3: TEdit
          Left = 117
          Top = 3
          Width = 87
          Height = 24
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object TahoCBox3: TComboBox
          Left = 4
          Top = 188
          Width = 106
          Height = 24
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 16
          ParentFont = False
          TabOrder = 3
        end
        object GroupBox5: TGroupBox
          Left = 4
          Top = 60
          Width = 338
          Height = 96
          Caption = #1044#1072#1090#1095#1080#1082' '#1076#1083#1103' '#1088#1072#1089#1095#1077#1090#1072' '#1092#1086#1088#1084#1099
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          object Label8: TLabel
            Left = 3
            Top = 37
            Width = 56
            Height = 16
            Caption = #1053#1072#1079#1074#1072#1085#1080#1077
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label9: TLabel
            Left = 124
            Top = 37
            Width = 125
            Height = 16
            Caption = #1057#1084#1077#1089#1090#1080#1090#1100' '#1087#1086#1083#1086#1078#1077#1085#1080#1077
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object SensorsCBox3: TComboBox
            Left = 3
            Top = 60
            Width = 103
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemHeight = 16
            ParentFont = False
            TabOrder = 0
          end
          object PosFE3: TFloatEdit
            Left = 123
            Top = 60
            Width = 87
            Height = 27
            TabOrder = 1
            Text = '0.0'
          end
        end
      end
    end
  end
  object GroupBox6: TGroupBox
    Left = 2
    Top = 0
    Width = 297
    Height = 68
    Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072' '#1095#1072#1089#1090#1080' '#1089#1080#1075#1085#1072#1083#1072', '#1089#1077#1082#1091#1085#1076#1099
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object Label23: TLabel
      Left = 153
      Top = 24
      Width = 36
      Height = 19
      Caption = #1057#1090#1086#1087
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label22: TLabel
      Left = 6
      Top = 24
      Width = 43
      Height = 19
      Caption = #1057#1090#1072#1088#1090
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object EndFE: TFloatEdit
      Left = 199
      Top = 24
      Width = 87
      Height = 27
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = '0.0'
    end
    object StartFE: TFloatEdit
      Left = 56
      Top = 24
      Width = 87
      Height = 27
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Text = '0.0'
    end
  end
  object EvalShapeBtn: TButton
    Left = 305
    Top = 7
    Width = 142
    Height = 61
    Caption = #1056#1072#1089#1095#1077#1090' '#1092#1086#1088#1084#1099
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = EvalShapeBtnClick
  end
  object LoadCfgBtn: TButton
    Left = 513
    Top = 8
    Width = 142
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = LoadCfgBtnClick
  end
  object OpenDialog: TOpenDialog
    Filter = 'lfm|*.lfm|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Left = 464
  end
end

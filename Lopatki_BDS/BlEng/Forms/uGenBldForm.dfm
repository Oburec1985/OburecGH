object GeneratorForm: TGeneratorForm
  Left = 0
  Top = 0
  Caption = 'GeneratorForm'
  ClientHeight = 574
  ClientWidth = 811
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
    Left = 313
    Top = 0
    Width = 4
    Height = 525
    ExplicitLeft = 439
    ExplicitTop = 8
    ExplicitHeight = 559
  end
  object Splitter2: TSplitter
    Left = 129
    Top = 0
    Width = 4
    Height = 525
    ExplicitLeft = 4
    ExplicitTop = 14
    ExplicitHeight = 542
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 525
    Width = 811
    Height = 49
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      811
      49)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 732
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      OnClick = ApplyBtnClick
    end
  end
  object CfgGB: TGroupBox
    Left = 0
    Top = 0
    Width = 129
    Height = 525
    Align = alLeft
    Caption = #1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103' '#1089#1090#1091#1087#1077#1085#1080':'
    TabOrder = 1
    object CfgTV: TTreeView
      Left = 2
      Top = 15
      Width = 125
      Height = 508
      Align = alClient
      Indent = 19
      TabOrder = 0
      OnChange = CfgTVChange
    end
  end
  object BladesGB: TGroupBox
    Left = 133
    Top = 0
    Width = 180
    Height = 525
    Align = alLeft
    Caption = #1043#1077#1085#1077#1088#1080#1090#1100' '#1074#1080#1073#1088#1072#1094#1080#1080' '#1087#1086' '#1083#1086#1087#1072#1090#1082#1072#1084':'
    TabOrder = 2
    object BladesLV: TBtnListView
      Left = 2
      Top = 15
      Width = 176
      Height = 508
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = BladesLVChange
      OnChanging = BladesLVChanging
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
    end
  end
  object SignalGB: TGroupBox
    Left = 317
    Top = 0
    Width = 494
    Height = 525
    Align = alClient
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1080#1075#1085#1072#1083#1072':'
    TabOrder = 3
    object Splitter3: TSplitter
      Left = 2
      Top = 271
      Width = 490
      Height = 5
      Cursor = crVSplit
      Hint = '10'
      Align = alTop
      ExplicitTop = 193
      ExplicitWidth = 557
    end
    object PropertyGB: TGroupBox
      Left = 2
      Top = 15
      Width = 490
      Height = 256
      Align = alTop
      TabOrder = 0
      object ValueLabel: TLabel
        Left = 135
        Top = 165
        Width = 75
        Height = 13
        Caption = #1056#1072#1079#1073#1088#1086#1089', '#1075#1088#1072#1076':'
      end
      object FreqVibrLabel: TLabel
        Left = 135
        Top = 119
        Width = 93
        Height = 13
        Caption = #1063#1072#1089#1090#1086#1090#1072' '#1074#1080#1073#1088#1072#1094#1080#1080
      end
      object VibrationTypeLabel: TLabel
        Left = 135
        Top = 73
        Width = 85
        Height = 13
        Caption = #1047#1072#1082#1086#1085' '#1074#1080#1073#1088#1072#1094#1080#1080':'
      end
      object Label1: TLabel
        Left = 134
        Top = 33
        Width = 61
        Height = 13
        Caption = #1047#1072#1082#1086#1085' '#1090#1072#1093#1086':'
      end
      object FreqLabel: TLabel
        Left = 6
        Top = 80
        Width = 119
        Height = 13
        Caption = #1063#1072#1089#1090#1086#1090#1072' '#1074#1088#1072#1097#1077#1085#1080#1103', '#1043#1094':'
      end
      object SignalLengthLabel: TLabel
        Left = 6
        Top = 34
        Width = 99
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1079#1072#1087#1080#1089#1080', '#1089#1077#1082'.:'
      end
      object ValueEdit: TFloatEdit
        Left = 135
        Top = 184
        Width = 90
        Height = 21
        TabOrder = 0
        Text = '1'
      end
      object VibrationFloatEdit: TFloatEdit
        Left = 135
        Top = 138
        Width = 90
        Height = 21
        TabOrder = 1
        Text = '1'
      end
      object VibrationTypeCB: TComboBox
        Left = 136
        Top = 92
        Width = 89
        Height = 21
        TabOrder = 2
        Text = #1057#1080#1085#1091#1089
        Items.Strings = (
          #1057#1080#1085#1091#1089
          #1050#1086#1089#1080#1085#1091#1089
          #1055#1088#1086#1080#1079#1074#1086#1083#1100#1085#1072#1103)
      end
      object TahoCB: TComboBox
        Left = 135
        Top = 52
        Width = 90
        Height = 21
        TabOrder = 3
        Text = #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103
        Items.Strings = (
          #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103
          #1055#1088#1103#1084#1072#1103
          #1055#1088#1086#1080#1079#1074#1086#1083#1100#1085#1072#1103)
      end
      object FreqFE: TFloatEdit
        Left = 6
        Top = 99
        Width = 99
        Height = 21
        TabOrder = 4
        Text = '50'
      end
      object SignalLengthFE: TFloatEdit
        Left = 6
        Top = 53
        Width = 99
        Height = 21
        TabOrder = 5
        Text = '10'
      end
      object VibrRootCB: TCheckBox
        Left = 4
        Top = 11
        Width = 190
        Height = 17
        Caption = #1042#1080#1073#1088#1072#1094#1080#1103' '#1087#1086' '#1082#1086#1088#1085#1077#1074#1099#1084' '#1076#1072#1090#1095#1080#1082#1072#1084
        TabOrder = 6
      end
      object SensorGB: TGroupBox
        Left = 234
        Top = 15
        Width = 254
        Height = 239
        Align = alRight
        Caption = #1044#1072#1090#1095#1080#1082
        TabOrder = 7
        DesignSize = (
          254
          239)
        object Label2: TLabel
          Left = 15
          Top = 104
          Width = 133
          Height = 13
          Caption = #1055#1077#1088#1080#1086#1076' '#1087#1088#1086#1087#1091#1089#1082#1072' '#1083#1086#1087#1072#1090#1086#1082
        end
        object Label3: TLabel
          Left = 15
          Top = 58
          Width = 76
          Height = 13
          Caption = #1053#1086#1084#1072#1088' '#1083#1086#1087#1072#1090#1082#1080
        end
        object Label5: TLabel
          Left = 14
          Top = 18
          Width = 125
          Height = 13
          Caption = #1047#1072#1082#1086#1085' '#1087#1088#1086#1087#1091#1089#1082#1072' '#1083#1086#1087#1072#1090#1086#1082
        end
        object SkipFirstLabel: TLabel
          Left = 15
          Top = 178
          Width = 166
          Height = 13
          Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1087#1077#1088#1074#1099#1093' n '#1080#1084#1087#1091#1083#1100#1089#1086#1074
        end
        object SkipBladeCB: TComboBox
          Left = 15
          Top = 37
          Width = 154
          Height = 21
          TabOrder = 0
          Text = #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103
          Items.Strings = (
            #1055#1088#1086#1087#1091#1089#1082#1072#1090#1100' '#1080#1084#1087#1091#1083#1100#1089' '#1087#1086' '#1083#1086#1087#1072#1090#1082#1077' '#1082#1072#1078#1076#1099#1081' i-'#1081' '#1086#1073#1086#1088#1086#1090
            #1055#1088#1086#1087#1091#1089#1082' '#1082#1072#1078#1076#1086#1075#1086' i-'#1086' '#1080#1084#1087#1091#1083#1100#1089#1072
            #1057#1083#1091#1095#1072#1081#1085#1099#1081' '#1087#1088#1086#1087#1091#1089#1082' '#1080#1084#1087#1091#1083#1100#1089#1086#1074)
        end
        object SkipCB: TCheckBox
          Left = 15
          Top = 152
          Width = 130
          Height = 17
          Caption = #1055#1088#1086#1087#1091#1089#1082#1072#1090#1100' '#1083#1086#1087#1072#1090#1082#1080
          TabOrder = 1
        end
        object SkipPeriodSE: TSpinEdit
          Left = 16
          Top = 124
          Width = 153
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 2
          Value = 0
        end
        object SkipBladeSE: TSpinEdit
          Left = 16
          Top = 78
          Width = 153
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 3
          Value = 0
        end
        object Button1: TButton
          Left = 176
          Top = 148
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
          TabOrder = 4
          OnClick = Button1Click
        end
        object SkipFirstSE: TSpinEdit
          Left = 16
          Top = 198
          Width = 153
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 5
          Value = 0
        end
      end
    end
    object SignalSetupPageControl: TPageControl
      Left = 2
      Top = 276
      Width = 490
      Height = 247
      ActivePage = VibrationTabSheet
      Align = alClient
      TabOrder = 1
      object TahoTabSheet: TTabSheet
        Caption = #1058#1072#1093#1086
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object TahoChart: cChart
          Left = 0
          Top = 0
          Width = 482
          Height = 219
          Align = alClient
          Caption = 'TahoChart'
          TabOrder = 0
          OnInit = TahoChartInit
          showTV = True
          showLegend = True
          selectSize = 5
        end
      end
      object VibrationTabSheet: TTabSheet
        Caption = #1042#1080#1073#1088#1072#1094#1080#1103
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object VibrationChart: cChart
          Left = 0
          Top = 0
          Width = 482
          Height = 219
          Align = alClient
          Caption = 'TahoChart'
          TabOrder = 0
          showTV = True
          showLegend = True
          selectSize = 5
        end
      end
    end
  end
end

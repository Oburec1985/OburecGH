object GeneratorForm: TGeneratorForm
  Left = 0
  Top = 0
  Caption = 'GeneratorForm'
  ClientHeight = 751
  ClientWidth = 1061
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 409
    Top = 0
    Width = 6
    Height = 687
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
  end
  object Splitter2: TSplitter
    Left = 169
    Top = 0
    Width = 5
    Height = 687
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 687
    Width = 1061
    Height = 64
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      1061
      64)
    object CancelBtn: TButton
      Left = 10
      Top = 25
      Width = 99
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 957
      Top = 25
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
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
    Width = 169
    Height = 687
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    Caption = #1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103' '#1089#1090#1091#1087#1077#1085#1080':'
    TabOrder = 1
    object CfgTV: TTreeView
      Left = 2
      Top = 19
      Width = 165
      Height = 666
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Indent = 19
      TabOrder = 0
      OnChange = CfgTVChange
    end
  end
  object BladesGB: TGroupBox
    Left = 174
    Top = 0
    Width = 235
    Height = 687
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    Caption = #1043#1077#1085#1077#1088#1080#1090#1100' '#1074#1080#1073#1088#1072#1094#1080#1080' '#1087#1086' '#1083#1086#1087#1072#1090#1082#1072#1084':'
    TabOrder = 2
    object BladesLV: TBtnListView
      Left = 2
      Top = 19
      Width = 231
      Height = 666
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #8470
          Width = 65
        end
        item
          Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
          Width = 65
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
      ChangeTextColor = False
      Editable = False
    end
  end
  object SignalGB: TGroupBox
    Left = 415
    Top = 0
    Width = 646
    Height = 687
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1080#1075#1085#1072#1083#1072':'
    TabOrder = 3
    object Splitter3: TSplitter
      Left = 2
      Top = 353
      Width = 642
      Height = 7
      Cursor = crVSplit
      Hint = '10'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      ExplicitLeft = 3
      ExplicitTop = 354
      ExplicitWidth = 640
    end
    object PropertyGB: TGroupBox
      Left = 2
      Top = 19
      Width = 642
      Height = 334
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      object ValueLabel: TLabel
        Left = 177
        Top = 216
        Width = 94
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1056#1072#1079#1073#1088#1086#1089', '#1075#1088#1072#1076':'
      end
      object FreqVibrLabel: TLabel
        Left = 177
        Top = 156
        Width = 120
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1063#1072#1089#1090#1086#1090#1072' '#1074#1080#1073#1088#1072#1094#1080#1080
      end
      object VibrationTypeLabel: TLabel
        Left = 177
        Top = 95
        Width = 108
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1047#1072#1082#1086#1085' '#1074#1080#1073#1088#1072#1094#1080#1080':'
      end
      object Label1: TLabel
        Left = 175
        Top = 43
        Width = 77
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1047#1072#1082#1086#1085' '#1090#1072#1093#1086':'
      end
      object FreqLabel: TLabel
        Left = 8
        Top = 105
        Width = 149
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1063#1072#1089#1090#1086#1090#1072' '#1074#1088#1072#1097#1077#1085#1080#1103', '#1043#1094':'
      end
      object SignalLengthLabel: TLabel
        Left = 8
        Top = 44
        Width = 125
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1042#1088#1077#1084#1103' '#1079#1072#1087#1080#1089#1080', '#1089#1077#1082'.:'
      end
      object ValueEdit: TFloatEdit
        Left = 177
        Top = 241
        Width = 117
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
        Text = '1'
      end
      object VibrationFloatEdit: TFloatEdit
        Left = 177
        Top = 180
        Width = 117
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 1
        Text = '1'
      end
      object VibrationTypeCB: TComboBox
        Left = 178
        Top = 120
        Width = 116
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 2
        Text = #1057#1080#1085#1091#1089
        Items.Strings = (
          #1057#1080#1085#1091#1089
          #1050#1086#1089#1080#1085#1091#1089
          #1055#1088#1086#1080#1079#1074#1086#1083#1100#1085#1072#1103)
      end
      object TahoCB: TComboBox
        Left = 177
        Top = 68
        Width = 117
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 3
        Text = #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103
        Items.Strings = (
          #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103
          #1055#1088#1103#1084#1072#1103
          #1055#1088#1086#1080#1079#1074#1086#1083#1100#1085#1072#1103)
      end
      object FreqFE: TFloatEdit
        Left = 8
        Top = 129
        Width = 129
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 4
        Text = '50'
      end
      object SignalLengthFE: TFloatEdit
        Left = 8
        Top = 69
        Width = 129
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 5
        Text = '10'
      end
      object VibrRootCB: TCheckBox
        Left = 5
        Top = 14
        Width = 249
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1042#1080#1073#1088#1072#1094#1080#1103' '#1087#1086' '#1082#1086#1088#1085#1077#1074#1099#1084' '#1076#1072#1090#1095#1080#1082#1072#1084
        TabOrder = 6
      end
      object SensorGB: TGroupBox
        Left = 308
        Top = 19
        Width = 332
        Height = 313
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alRight
        Caption = #1044#1072#1090#1095#1080#1082
        TabOrder = 7
        DesignSize = (
          332
          313)
        object Label2: TLabel
          Left = 20
          Top = 136
          Width = 171
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1055#1077#1088#1080#1086#1076' '#1087#1088#1086#1087#1091#1089#1082#1072' '#1083#1086#1087#1072#1090#1086#1082
        end
        object Label3: TLabel
          Left = 20
          Top = 76
          Width = 99
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1053#1086#1084#1072#1088' '#1083#1086#1087#1072#1090#1082#1080
        end
        object Label5: TLabel
          Left = 18
          Top = 24
          Width = 160
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1047#1072#1082#1086#1085' '#1087#1088#1086#1087#1091#1089#1082#1072' '#1083#1086#1087#1072#1090#1086#1082
        end
        object SkipFirstLabel: TLabel
          Left = 20
          Top = 233
          Width = 217
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1087#1077#1088#1074#1099#1093' n '#1080#1084#1087#1091#1083#1100#1089#1086#1074
        end
        object SkipBladeCB: TComboBox
          Left = 20
          Top = 48
          Width = 201
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 0
          Text = #1055#1086#1089#1090#1086#1103#1085#1085#1072#1103
          Items.Strings = (
            #1055#1088#1086#1087#1091#1089#1082#1072#1090#1100' '#1080#1084#1087#1091#1083#1100#1089' '#1087#1086' '#1083#1086#1087#1072#1090#1082#1077' '#1082#1072#1078#1076#1099#1081' i-'#1081' '#1086#1073#1086#1088#1086#1090
            #1055#1088#1086#1087#1091#1089#1082' '#1082#1072#1078#1076#1086#1075#1086' i-'#1086' '#1080#1084#1087#1091#1083#1100#1089#1072
            #1057#1083#1091#1095#1072#1081#1085#1099#1081' '#1087#1088#1086#1087#1091#1089#1082' '#1080#1084#1087#1091#1083#1100#1089#1086#1074)
        end
        object SkipCB: TCheckBox
          Left = 20
          Top = 199
          Width = 170
          Height = 22
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1055#1088#1086#1087#1091#1089#1082#1072#1090#1100' '#1083#1086#1087#1072#1090#1082#1080
          TabOrder = 1
        end
        object SkipPeriodSE: TSpinEdit
          Left = 21
          Top = 162
          Width = 200
          Height = 27
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          MaxValue = 0
          MinValue = 0
          TabOrder = 2
          Value = 0
        end
        object SkipBladeSE: TSpinEdit
          Left = 21
          Top = 102
          Width = 200
          Height = 27
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          MaxValue = 0
          MinValue = 0
          TabOrder = 3
          Value = 0
        end
        object Button1: TButton
          Left = 230
          Top = 194
          Width = 98
          Height = 32
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Anchors = [akTop, akRight]
          Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
          TabOrder = 4
          OnClick = Button1Click
        end
        object SkipFirstSE: TSpinEdit
          Left = 21
          Top = 259
          Width = 200
          Height = 27
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          MaxValue = 0
          MinValue = 0
          TabOrder = 5
          Value = 0
        end
      end
    end
    object SignalSetupPageControl: TPageControl
      Left = 2
      Top = 360
      Width = 642
      Height = 325
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      ActivePage = VibrationTabSheet
      Align = alClient
      TabOrder = 1
      object TahoTabSheet: TTabSheet
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1058#1072#1093#1086
        object TahoChart: cChart
          Left = 0
          Top = 0
          Width = 634
          Height = 293
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          Caption = 'TahoChart'
          TabOrder = 0
          OnInit = TahoChartInit
          allowEditPages = False
          showTV = True
          showLegend = True
          selectSize = 5
        end
      end
      object VibrationTabSheet: TTabSheet
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1042#1080#1073#1088#1072#1094#1080#1103
        ImageIndex = 1
        object VibrationChart: cChart
          Left = 0
          Top = 0
          Width = 634
          Height = 293
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          Caption = 'TahoChart'
          TabOrder = 0
          allowEditPages = False
          showTV = True
          showLegend = True
          selectSize = 5
        end
      end
    end
  end
end

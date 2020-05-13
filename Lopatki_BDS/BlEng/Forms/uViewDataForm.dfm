object ViewDataForm: TViewDataForm
  Left = 133
  Top = 269
  Caption = 'ViewDataForm'
  ClientHeight = 646
  ClientWidth = 831
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesigned
  DesignSize = (
    831
    646)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 527
    Top = 15
    Width = 73
    Height = 23
    Caption = #1044#1072#1090#1095#1080#1082#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 15
    Width = 67
    Height = 23
    Caption = #1058#1088#1077#1085#1076#1099
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 435
    Width = 112
    Height = 19
    Caption = #1042#1099#1073#1086#1088' '#1083#1086#1087#1072#1090#1082#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object BladePosLabel: TLabel
    Left = 8
    Top = 500
    Width = 166
    Height = 19
    Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077' '#1083#1086#1087#1072#1090#1082#1080' ='
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 152
    Top = 25
    Width = 3
    Height = 13
  end
  object Label5: TLabel
    Left = 178
    Top = 20
    Width = 56
    Height = 13
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072
  end
  object Button1: TButton
    Left = 8
    Top = 615
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
    TabOrder = 0
    ExplicitTop = 595
  end
  object Button2: TButton
    Left = 719
    Top = 615
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
    TabOrder = 1
    ExplicitTop = 595
  end
  object cGlChart1: cGlChart
    Left = 8
    Top = 44
    Width = 465
    Height = 376
    onAfterGetData = cGlChart1AfterGetData
  end
  object SensorsListView: TBtnListView
    Left = 479
    Top = 44
    Width = 322
    Height = 376
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = #8470
        Width = 34
      end
      item
        Caption = #1048#1084#1103
        Width = 38
      end
      item
        Caption = #1058#1080#1087
        Width = 40
      end
      item
        Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087#1091#1083#1100#1089#1086#1074
        Width = 91
      end
      item
        Caption = #1057#1090#1091#1087#1077#1085#1100
        Width = 63
      end
      item
        Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
      end>
    GridLines = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
  end
  object BladeNumberSpinEdit: TSpinEdit
    Left = 8
    Top = 463
    Width = 89
    Height = 29
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxValue = 0
    MinValue = 0
    ParentFont = False
    TabOrder = 4
    Value = 0
    OnChange = BladeNumberSpinEditChange
  end
  object PeakFloatEdit: TFloatEdit
    Left = 240
    Top = 17
    Width = 57
    Height = 21
    TabOrder = 5
    Text = '0.0'
  end
  object MainMenu1: TMainMenu
    Left = 664
    Top = 8
    object N1: TMenuItem
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084#1099
      object EvalDensityMenu: TMenuItem
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1089#1090#1072#1090#1080#1089#1090#1080#1082#1080
        OnClick = EvalDensityMenuClick
      end
      object EvalXYTrend: TMenuItem
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1074#1080#1073#1088#1072#1094#1080#1080' '#1087#1086' '#1083#1086#1087#1072#1090#1082#1077
        OnClick = EvalXYTrendClick
      end
    end
    object N3: TMenuItem
      Caption = #1048#1089#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1092#1072#1081#1083#1072
      object SortTicksMenu: TMenuItem
        Caption = #1054#1090#1089#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1080#1082#1080' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080
        OnClick = SortTicksMenuClick
      end
      object FilterTurnsMenu: TMenuItem
        Caption = #1054#1090#1092#1080#1083#1100#1090#1088#1086#1074#1072#1090#1100' '#1086#1073#1086#1088#1086#1090#1099
        OnClick = FilterTurnsMenuClick
      end
    end
  end
end

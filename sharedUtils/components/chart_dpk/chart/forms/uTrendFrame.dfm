object TrendFrame: TTrendFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Constraints.MinHeight = 304
  TabOrder = 0
  object PointGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    Caption = #1054#1090#1088#1080#1089#1086#1074#1082#1072' '#1074#1077#1088#1096#1080#1085
    Constraints.MinHeight = 168
    TabOrder = 0
    object ColorPointLabel: TLabel
      Left = 4
      Top = 17
      Width = 44
      Height = 13
      Caption = #1042#1077#1088#1096#1080#1085#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object WidthLabel: TLabel
      Left = 147
      Top = 68
      Width = 78
      Height = 13
      Caption = #1058#1086#1083#1097#1080#1085#1072' '#1083#1080#1085#1080#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ColorBox: TPanel
      Left = 4
      Top = 38
      Width = 64
      Height = 25
      Color = clCream
      ParentBackground = False
      TabOrder = 0
      OnClick = ColorBoxClick
    end
    object DrawPoints: TCheckBox
      Left = 7
      Top = 69
      Width = 124
      Height = 17
      Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1074#1077#1088#1096#1080#1085#1099
      TabOrder = 1
    end
    object GroupBox1: TGroupBox
      Left = 2
      Top = 135
      Width = 447
      Height = 187
      Align = alBottom
      Caption = #1042#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1074#1077#1088#1096#1080#1085#1099
      TabOrder = 2
      ExplicitTop = 115
      object VectorLineColorLabel: TLabel
        Left = 4
        Top = 75
        Width = 79
        Height = 13
        Caption = #1053#1072#1087#1088#1072#1074#1083#1103#1102#1097#1072#1103
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object VectorPointColorLabel: TLabel
        Left = 4
        Top = 27
        Width = 89
        Height = 13
        Caption = #1042#1077#1088#1096#1080#1085#1072' '#1074#1077#1082#1090#1086#1088#1072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object SelectVectorPointColorLabel: TLabel
        Left = 173
        Top = 78
        Width = 155
        Height = 13
        Caption = #1042#1099#1076#1077#1083#1077#1085#1085#1072#1103' '#1074#1077#1088#1096#1080#1085#1072' '#1074#1077#1082#1090#1086#1088#1072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object ColorSelectPointLabel: TLabel
        Left = 173
        Top = 28
        Width = 110
        Height = 13
        Caption = #1042#1099#1076#1077#1083#1077#1085#1085#1072#1103' '#1074#1077#1088#1096#1080#1085#1072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object VectorLineColor: TPanel
        Left = 4
        Top = 94
        Width = 64
        Height = 25
        Color = clAppWorkSpace
        ParentBackground = False
        TabOrder = 0
        OnClick = ColorBoxClick
      end
      object VectorPointColor: TPanel
        Left = 4
        Top = 44
        Width = 64
        Height = 25
        Color = clAppWorkSpace
        ParentBackground = False
        TabOrder = 1
        OnClick = ColorBoxClick
      end
      object SelectVectorPointColor: TPanel
        Left = 173
        Top = 97
        Width = 64
        Height = 25
        Color = clActiveBorder
        ParentBackground = False
        TabOrder = 2
        OnClick = ColorBoxClick
      end
      object ColorSelectPoint: TPanel
        Left = 173
        Top = 49
        Width = 64
        Height = 25
        Color = clMedGray
        ParentBackground = False
        TabOrder = 3
        OnClick = ColorBoxClick
      end
    end
    object DrawLines: TCheckBox
      Left = 7
      Top = 92
      Width = 124
      Height = 17
      Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1083#1080#1085#1080#1080
      TabOrder = 3
    end
    object WidthSE: TFloatSpinEdit
      Left = 147
      Top = 87
      Width = 121
      Height = 22
      Increment = 0.100000001490116100
      TabOrder = 4
    end
  end
  object BackGroundColorDialog: TColorDialog
    Left = 320
    Top = 66
  end
end

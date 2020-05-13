object SystemInfoFrame: TSystemInfoFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 315
  Align = alTop
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 0
    Top = 122
    Width = 451
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    Color = clGray
    ParentColor = False
    ExplicitLeft = 2
    ExplicitTop = 185
  end
  object CommonInfoGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 122
    Align = alClient
    Caption = #1054#1073#1097#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103
    TabOrder = 0
    ExplicitHeight = 121
    object MemoryUseLabel: TLabel
      Left = 16
      Top = 37
      Width = 109
      Height = 13
      Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103' '#1087#1072#1084#1103#1090#1080
    end
    object kByteLabel: TLabel
      Left = 103
      Top = 59
      Width = 27
      Height = 13
      Caption = 'kByte'
    end
    object CPULabel: TLabel
      Left = 148
      Top = 37
      Width = 107
      Height = 13
      Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1087#1088#1086#1094#1077#1089#1089#1086#1088#1072
    end
    object PercentLabel2: TLabel
      Left = 235
      Top = 59
      Width = 11
      Height = 13
      Caption = '%'
    end
    object OsVersionLabel: TLabel
      Left = 16
      Top = 19
      Width = 48
      Height = 13
      Caption = 'OsVersion'
    end
    object CPUIE: TIntEdit
      Left = 148
      Top = 56
      Width = 81
      Height = 21
      TabOrder = 0
      Text = '000'
    end
    object MemoryUseFE: TFloatEdit
      Left = 16
      Top = 56
      Width = 81
      Height = 21
      TabOrder = 1
      Text = '0.0'
    end
    object GlVisibleCheckBox: TCheckBox
      Left = 16
      Top = 88
      Width = 206
      Height = 17
      Caption = #1054#1090#1086#1073#1088#1072#1079#1080#1090#1100' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102' '#1087#1086' OpenGl'
      TabOrder = 2
      OnClick = GlVisibleCheckBoxClick
    end
    object Button1: TButton
      Left = 264
      Top = 54
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 3
      OnClick = Button1Click
    end
  end
  object GlGB: TGroupBox
    Left = 0
    Top = 126
    Width = 451
    Height = 189
    Align = alBottom
    Caption = 'OpenGl Info'
    TabOrder = 1
    Visible = False
    ExplicitLeft = -3
    ExplicitTop = 128
    object GLExtGB: TGroupBox
      Left = 2
      Top = 64
      Width = 447
      Height = 123
      Align = alBottom
      Caption = 'GLExtGB'
      TabOrder = 0
      ExplicitTop = 104
      object ExtListView: TListView
        Left = 2
        Top = 15
        Width = 443
        Height = 106
        Align = alClient
        Color = clBtnFace
        Columns = <
          item
            Caption = #1055#1086#1076#1076#1077#1088#1078#1080#1074#1072#1077#1084#1099#1077' '#1088#1072#1089#1096#1080#1088#1077#1085#1080#1103
            MinWidth = 100
            Width = 200
          end>
        GridLines = True
        MultiSelect = True
        RowSelect = True
        ParentShowHint = False
        ShowWorkAreas = True
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        ExplicitHeight = 151
      end
    end
    object CommonGlInfoGB: TGroupBox
      Left = 2
      Top = 15
      Width = 447
      Height = 49
      Align = alClient
      Caption = #1054#1073#1097#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' OpenGL'
      TabOrder = 1
      ExplicitHeight = 46
      object GLLabel: TLabel
        Left = 14
        Top = 21
        Width = 44
        Height = 13
        Caption = 'GlVersion'
      end
    end
  end
end

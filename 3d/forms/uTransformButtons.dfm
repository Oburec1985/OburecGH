object TransformToolsFrame: TTransformToolsFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 182
  Align = alBottom
  Color = clMoneyGreen
  ParentColor = False
  TabOrder = 0
  TabStop = True
  object Label8: TLabel
    Left = 314
    Top = 16
    Width = 37
    Height = 16
    Caption = 'MoveZ'
  end
  object Label9: TLabel
    Left = 684
    Top = 22
    Width = 116
    Height = 16
    Caption = #1042#1099#1076#1077#1083#1077#1085#1099#1081' '#1086#1073#1098#1077#1082#1090':'
  end
  object GroupBox2: TGroupBox
    Left = 393
    Top = 1
    Width = 286
    Height = 57
    Caption = 'RotateObject'
    TabOrder = 0
    object Label1: TLabel
      Left = 32
      Top = 16
      Width = 27
      Height = 16
      Caption = 'RotX'
    end
    object Label2: TLabel
      Left = 132
      Top = 16
      Width = 26
      Height = 16
      Caption = 'RotY'
    end
    object Label3: TLabel
      Left = 231
      Top = 16
      Width = 26
      Height = 16
      Caption = 'RotZ'
    end
    object RotZSpinEdit: TFloatSpinEdit
      Left = 198
      Top = 31
      Width = 86
      Height = 26
      Increment = 5.000000000000000000
      TabOrder = 0
      Value = 0.100000001490116000
      OnChange = RotXSpinEditChange
    end
    object RotYSpinEdit: TFloatSpinEdit
      Left = 100
      Top = 31
      Width = 86
      Height = 26
      Increment = 5.000000000000000000
      TabOrder = 1
      Value = 0.100000001490116000
      OnChange = RotXSpinEditChange
    end
    object RotXSpinEdit: TFloatSpinEdit
      Left = 2
      Top = 31
      Width = 86
      Height = 26
      Increment = 5.000000000000000000
      TabOrder = 2
      Value = 0.100000001490116000
      OnChange = RotXSpinEditChange
    end
  end
  object ObjNameE: TEdit
    Left = 681
    Top = 37
    Width = 86
    Height = 24
    TabOrder = 1
    Text = 'ObjNameE'
  end
  object WorldComboBox: TComboBox
    Left = 8
    Top = 32
    Width = 77
    Height = 24
    TabOrder = 2
    Text = 'World'
    OnChange = WorldComboBoxChange
    Items.Strings = (
      'World'
      'Node'
      'Local'
      'Parent'
      'View')
  end
  object TimeCotrolGroupBox: TGroupBox
    Left = 3
    Top = 59
    Width = 419
    Height = 64
    Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1074#1088#1077#1084#1077#1085#1077#1084
    TabOrder = 3
    inline AnimationCtrlFrame1: TAnimationCtrlFrame
      Left = 2
      Top = 18
      Width = 415
      Height = 44
      Align = alClient
      TabOrder = 0
      TabStop = True
      ExplicitLeft = 2
      ExplicitTop = 18
      ExplicitWidth = 415
      ExplicitHeight = 44
      inherited AnimationControlGroupBox: TGroupBox
        Width = 415
        Height = 44
        ExplicitWidth = 415
        ExplicitHeight = 44
        DesignSize = (
          415
          44)
        inherited RewndBtn: TSpeedButton
          Left = 297
          Top = 18
          ExplicitLeft = 297
          ExplicitTop = 18
        end
        inherited PausePlayBtn: TSpeedButton
          Left = 330
          Top = 18
          ExplicitLeft = 330
          ExplicitTop = 18
        end
        inherited FrwBtn: TSpeedButton
          Left = 365
          Top = 18
          ExplicitLeft = 365
          ExplicitTop = 18
        end
        inherited TimeScrollBar: TScrollBar
          Top = 26
          Width = 288
          ExplicitTop = 26
          ExplicitWidth = 288
        end
      end
      inherited AnimationTimer: TTimer
        Left = 200
        Top = 16
      end
    end
  end
  object GroupBox4: TGroupBox
    Left = 424
    Top = 74
    Width = 328
    Height = 48
    Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1074#1080#1076#1086#1084
    TabOrder = 4
    inline CtrlViewFrame1: TCtrlViewFrame
      Left = 2
      Top = 18
      Width = 324
      Height = 28
      Align = alClient
      TabOrder = 0
      TabStop = True
      ExplicitLeft = 2
      ExplicitTop = 18
      ExplicitWidth = 324
      ExplicitHeight = 28
      inherited GroupBox1: TGroupBox
        inherited PanBtn: TSpeedButton
          Top = 0
          ExplicitTop = 0
        end
        inherited RotBtn: TSpeedButton
          Top = 0
          OnClick = CtrlViewFrame1RotBtnClick
          ExplicitTop = 0
        end
        inherited ZoomBtn: TSpeedButton
          Top = 0
          OnClick = CtrlViewFrame1ZoomBtnClick
          ExplicitTop = 0
        end
        inherited SpeedZoom: TSpeedButton
          Left = 88
          Top = 0
          OnClick = CtrlViewFrame1SpeedZoomClick
          ExplicitLeft = 88
          ExplicitTop = 0
        end
      end
    end
  end
  object GroupBox1: TGroupBox
    Left = 91
    Top = 1
    Width = 297
    Height = 57
    Caption = 'MoovObject'
    TabOrder = 5
    OnMouseEnter = GroupBox1MouseEnter
    object Label5: TLabel
      Left = 132
      Top = 16
      Width = 37
      Height = 16
      Caption = 'MoveY'
    end
    object Label6: TLabel
      Left = 30
      Top = 16
      Width = 38
      Height = 16
      Caption = 'MoveX'
    end
    object MoveXSpinEdit: TFloatSpinEdit
      Left = 5
      Top = 31
      Width = 86
      Height = 26
      Increment = 0.500000000000000000
      TabOrder = 0
      Value = 0.100000001490116000
      OnChange = MoovXSpinEditChange
    end
    object MoveYSpinEdit: TFloatSpinEdit
      Left = 103
      Top = 31
      Width = 86
      Height = 26
      Increment = 0.500000000000000000
      TabOrder = 1
      Value = 0.100000001490116000
      OnChange = MoovXSpinEditChange
    end
    object MoveZSpinEdit: TFloatSpinEdit
      Left = 201
      Top = 31
      Width = 86
      Height = 26
      Increment = 0.500000000000000000
      TabOrder = 2
      Value = 0.100000001490116000
      OnChange = MoovXSpinEditChange
    end
  end
end

object ObjEditFrame: TObjEditFrame
  Left = 0
  Top = 0
  Width = 302
  Height = 211
  Align = alClient
  Constraints.MinWidth = 302
  TabOrder = 0
  object PosGB: TGroupBox
    Left = 0
    Top = 0
    Width = 302
    Height = 105
    Align = alTop
    Caption = 'Position:'
    TabOrder = 0
    ExplicitLeft = 40
    ExplicitTop = 80
    ExplicitWidth = 185
    object XposLab: TLabel
      Left = 9
      Top = 18
      Width = 13
      Height = 16
      Caption = 'X:'
    end
    object YposLab: TLabel
      Left = 107
      Top = 18
      Width = 12
      Height = 16
      Caption = 'Y:'
    end
    object ZposLab: TLabel
      Left = 207
      Top = 18
      Width = 12
      Height = 16
      Caption = 'Z:'
    end
    object XposSE: TFloatSpinEdit
      Left = 9
      Top = 36
      Width = 87
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 0
    end
    object YposSE: TFloatSpinEdit
      Left = 107
      Top = 36
      Width = 87
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 1
    end
    object ZposSE: TFloatSpinEdit
      Left = 207
      Top = 36
      Width = 87
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 2
    end
    object XTagCB: TRcComboBox
      Left = 9
      Top = 72
      Width = 87
      Height = 24
      TabOrder = 3
    end
    object YTagCB: TRcComboBox
      Left = 107
      Top = 72
      Width = 87
      Height = 24
      TabOrder = 4
    end
    object ZTagCB: TRcComboBox
      Left = 207
      Top = 72
      Width = 87
      Height = 24
      TabOrder = 5
    end
  end
  object OrientationGB: TGroupBox
    Left = 0
    Top = 105
    Width = 302
    Height = 105
    Align = alTop
    Caption = 'OrientationGB:'
    TabOrder = 1
    ExplicitTop = 8
    object XrotLab: TLabel
      Left = 9
      Top = 18
      Width = 13
      Height = 16
      Caption = 'X:'
    end
    object YrotLab: TLabel
      Left = 107
      Top = 18
      Width = 12
      Height = 16
      Caption = 'Y:'
    end
    object ZrotLab: TLabel
      Left = 207
      Top = 18
      Width = 12
      Height = 16
      Caption = 'Z:'
    end
    object XrotSE: TFloatSpinEdit
      Left = 9
      Top = 36
      Width = 87
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 0
    end
    object YrotSE: TFloatSpinEdit
      Left = 107
      Top = 36
      Width = 87
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 1
    end
    object ZrotSE: TFloatSpinEdit
      Left = 207
      Top = 36
      Width = 87
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 2
    end
    object XrotTagCB: TRcComboBox
      Left = 9
      Top = 72
      Width = 87
      Height = 24
      TabOrder = 3
    end
    object YrotTagCB: TRcComboBox
      Left = 107
      Top = 72
      Width = 87
      Height = 24
      TabOrder = 4
    end
    object ZrotTagCB: TRcComboBox
      Left = 207
      Top = 72
      Width = 87
      Height = 24
      TabOrder = 5
    end
  end
end

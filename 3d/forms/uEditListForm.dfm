object EditObjectForm: TEditObjectForm
  Left = 0
  Top = 0
  Caption = 'EditObjectForm'
  ClientHeight = 540
  ClientWidth = 452
  Color = clBtnFace
  Constraints.MinHeight = 585
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    452
    540)
  PixelsPerInch = 120
  TextHeight = 17
  object Label1: TLabel
    Left = 21
    Top = 10
    Width = 219
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1074#1086#1081#1089#1090#1074' '#1086#1073#1098#1077#1082#1090#1072
  end
  object Label2: TLabel
    Left = 21
    Top = 438
    Width = 82
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
  end
  object Label3: TLabel
    Left = 21
    Top = 35
    Width = 108
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1044#1083#1080#1085#1072' '#1085#1086#1088#1084#1072#1083#1077#1081
  end
  object Label4: TLabel
    Left = 230
    Top = 35
    Width = 75
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1044#1083#1080#1085#1072' '#1086#1089#1077#1081
  end
  object Label5: TLabel
    Left = 230
    Top = 438
    Width = 81
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = #1058#1080#1087' '#1086#1073#1098#1077#1082#1090#1072
  end
  object DrawNormalCheckBox: TCheckBox
    Left = 21
    Top = 99
    Width = 148
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1085#1086#1088#1084#1072#1083#1080
    TabOrder = 0
  end
  object Nameedit: TEdit
    Left = 21
    Top = 463
    Width = 158
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    Text = 'NameEdit'
  end
  object ObjTypeCombobox: TComboBox
    Left = 230
    Top = 463
    Width = 190
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    Items.Strings = (
      #1052#1077#1096
      #1057#1074#1077#1090#1080#1083#1100#1085#1080#1082
      #1050#1072#1084#1077#1088#1072)
  end
  object Button1: TButton
    Left = 349
    Top = 500
    Width = 98
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'OkButton'
    ModalResult = 1
    TabOrder = 3
  end
  object Button2: TButton
    Left = 21
    Top = 500
    Width = 98
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'CancelButton'
    ModalResult = 2
    TabOrder = 4
  end
  object NormalFloatEdit: TFloatEdit
    Left = 21
    Top = 65
    Width = 158
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 5
    Text = '0'
  end
  object AxisLengthFloatEdit: TFloatEdit
    Left = 230
    Top = 65
    Width = 158
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 6
    Text = '0'
  end
  object DrawAxisCheckBox: TCheckBox
    Left = 230
    Top = 105
    Width = 198
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1083#1086#1082#1072#1083#1100#1085#1091#1102' '#1086#1089#1100
    TabOrder = 7
  end
  object DrawNodeCheckBox: TCheckBox
    Left = 230
    Top = 135
    Width = 202
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1091#1079#1077#1083
    TabOrder = 8
  end
  object CameraGroupBox: TGroupBox
    Left = 21
    Top = 129
    Width = 182
    Height = 280
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1050#1072#1084#1077#1088#1072
    TabOrder = 9
    DesignSize = (
      182
      280)
    object Label6: TLabel
      Left = 78
      Top = 51
      Width = 25
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'FOV'
    end
    object Label7: TLabel
      Left = 78
      Top = 88
      Width = 41
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Aspect'
    end
    object Label8: TLabel
      Left = 78
      Top = 124
      Width = 64
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Near Plane'
    end
    object Label9: TLabel
      Left = 78
      Top = 161
      Width = 55
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Far Plane'
    end
    object Label10: TLabel
      Left = 8
      Top = 196
      Width = 102
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1052#1080#1096#1077#1085#1100' '#1082#1072#1084#1077#1088#1099
    end
    object ActivateCameraCheckBox: TCheckBox
      Left = 4
      Top = 25
      Width = 175
      Height = 22
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1040#1082#1090#1080#1074#1080#1088#1086#1074#1072#1090#1100' '#1082#1072#1084#1077#1088#1091
      TabOrder = 0
    end
    object FovSpinEdit: TFloatSpinEdit
      Left = 4
      Top = 51
      Width = 71
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 1.000000000000000000
      TabOrder = 1
      Value = 45.000000000000000000
    end
    object AspectSpinEdit: TFloatSpinEdit
      Left = 4
      Top = 88
      Width = 71
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000001490116100
      TabOrder = 2
    end
    object NearPlaneSpinEdit: TFloatSpinEdit
      Left = 4
      Top = 124
      Width = 71
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000001490116100
      TabOrder = 3
    end
    object FarPlaneSpinEdit: TFloatSpinEdit
      Left = 4
      Top = 161
      Width = 71
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 1.000000000000000000
      TabOrder = 4
    end
    object TargetComboBox: TComboBox
      Left = 4
      Top = 221
      Width = 174
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akBottom]
      TabOrder = 5
      OnChange = TargetComboBoxUpdate
      Items.Strings = (
        #1052#1077#1096
        #1057#1074#1077#1090#1080#1083#1100#1085#1080#1082
        #1050#1072#1084#1077#1088#1072)
    end
  end
end

object ShockFrame: TShockFrame
  Left = 0
  Top = 0
  Width = 326
  Height = 221
  Constraints.MinHeight = 221
  Constraints.MinWidth = 326
  TabOrder = 0
  DesignSize = (
    326
    221)
  object LengthLabel: TLabel
    Left = 8
    Top = 13
    Width = 135
    Height = 16
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1091#1076#1072#1088#1072', '#1089
  end
  object ALabel: TLabel
    Left = 8
    Top = 59
    Width = 101
    Height = 16
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1091#1076#1072#1088#1072
  end
  object BeforeShockLabel: TLabel
    Left = 168
    Top = 13
    Width = 153
    Height = 16
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1076#1086' '#1091#1076#1072#1088#1072', '#1089
  end
  object AfterShockLabel: TLabel
    Left = 168
    Top = 61
    Width = 173
    Height = 16
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1087#1086#1089#1083#1077' '#1091#1076#1072#1088#1072', '#1089
  end
  object DscLabel: TLabel
    Left = 8
    Top = 161
    Width = 57
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object LengthFE: TFloatEdit
    Left = 8
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '0.005'
  end
  object AFE: TFloatEdit
    Left = 8
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '10'
  end
  object BeforeShockFE: TFloatEdit
    Left = 168
    Top = 32
    Width = 151
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object AfterShockFE: TFloatEdit
    Left = 168
    Top = 80
    Width = 151
    Height = 21
    TabOrder = 3
    Text = '2'
  end
  object DscEdit: TEdit
    Left = 8
    Top = 180
    Width = 311
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 4
    Text = 'DscEdit'
  end
end

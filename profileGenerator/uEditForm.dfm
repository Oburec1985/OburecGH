object EditForm: TEditForm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1090#1086#1095#1082#1091' '#1087#1088#1086#1092#1080#1083#1103
  ClientHeight = 249
  ClientWidth = 232
  Color = clBtnFace
  Constraints.MinWidth = 240
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  DesignSize = (
    232
    249)
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 15
    Top = 13
    Width = 22
    Height = 13
    Caption = 'LoLo'
  end
  object Label4: TLabel
    Left = 15
    Top = 57
    Width = 11
    Height = 13
    Caption = 'Lo'
  end
  object Label5: TLabel
    Left = 145
    Top = 13
    Width = 18
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'HiHi'
    ExplicitLeft = 184
  end
  object Label6: TLabel
    Left = 145
    Top = 57
    Width = 9
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Hi'
    ExplicitLeft = 184
  end
  object Label1: TLabel
    Left = 15
    Top = 125
    Width = 45
    Height = 13
    Caption = #1055#1088#1086#1092#1080#1083#1100
  end
  object Label2: TLabel
    Left = 15
    Top = 145
    Width = 48
    Height = 13
    Caption = #1047#1085#1072#1095#1077#1085#1080#1077
  end
  object Label7: TLabel
    Left = 145
    Top = 145
    Width = 42
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1063#1072#1089#1090#1086#1090#1072
    ExplicitLeft = 146
  end
  object Button1: TButton
    Left = 15
    Top = 211
    Width = 75
    Height = 29
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 0
  end
  object Button2: TButton
    Left = 145
    Top = 212
    Width = 75
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 1
  end
  object LoLoSE: TFloatSpinEdit
    Left = 15
    Top = 32
    Width = 75
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 2
    OnKeyDown = FormKeyDown
  end
  object HiHiSE: TFloatSpinEdit
    Left = 145
    Top = 32
    Width = 75
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 0.100000001490116100
    TabOrder = 3
    OnKeyDown = FormKeyDown
  end
  object HiSE: TFloatSpinEdit
    Left = 145
    Top = 76
    Width = 75
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 0.100000001490116100
    TabOrder = 4
    OnKeyDown = FormKeyDown
  end
  object LoSE: TFloatSpinEdit
    Left = 15
    Top = 76
    Width = 75
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 5
    OnKeyDown = FormKeyDown
  end
  object ValSE: TFloatSpinEdit
    Left = 15
    Top = 164
    Width = 75
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 6
    OnKeyDown = FormKeyDown
  end
  object FreqSE: TFloatSpinEdit
    Left = 145
    Top = 164
    Width = 75
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 0.100000001490116100
    TabOrder = 7
    OnKeyDown = FormKeyDown
  end
end

object FilterTurnsForm: TFilterTurnsForm
  Left = 0
  Top = 0
  Caption = 'FilterTurnsForm'
  ClientHeight = 197
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    513
    197)
  PixelsPerInch = 96
  TextHeight = 13
  object OkBtn: TButton
    Left = 430
    Top = 165
    Width = 75
    Height = 27
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 8
    Top = 165
    Width = 75
    Height = 27
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 497
    Height = 66
    BevelOuter = bvRaised
    BorderStyle = bsNone
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      
        #1040#1083#1075#1086#1088#1080#1090#1084' '#1074#1099#1073#1088#1072#1089#1099#1074#1072#1077#1090' '#1080#1079' '#1084#1072#1089#1089#1080#1074#1072' '#1080#1084#1087#1091#1083#1100#1089#1086#1074' '#1076#1072#1090#1095#1080#1082#1072' '#1087#1080#1082#1080', '#1087#1088#1086#1080#1079#1086#1096#1077 +
        #1076#1096#1080#1077' '#1085#1072' '
      
        #1089#1073#1086#1081#1085#1086#1084' '#1086#1073#1086#1088#1086#1090#1077'. '#1054#1073#1086#1088#1086#1090' '#1089#1095#1080#1090#1072#1077#1090#1089#1103' '#1089#1073#1086#1081#1085#1099#1084' '#1077#1089#1083#1080' '#1095#1080#1089#1083#1086' '#1087#1080#1082#1086#1074' '#1085#1072' '#1076#1072 +
        #1090#1095#1080#1082#1077' "<" '
      #1080#1083#1080' ">" '#1095#1080#1089#1083#1072' '#1083#1086#1087#1072#1090#1086#1082'. ')
    ParentColor = True
    ParentFont = False
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 72
    Width = 416
    Height = 85
    Caption = #1054#1087#1094#1080#1080' '#1092#1080#1083#1100#1090#1088#1072#1094#1080#1080' '#1086#1073#1086#1088#1086#1090#1086#1074
    TabOrder = 3
    object LoCheckBox: TCheckBox
      Left = 16
      Top = 20
      Width = 313
      Height = 17
      Caption = #1060#1080#1083#1100#1090#1088#1086#1074#1072#1090#1100' '#1086#1073#1086#1088#1086#1090' '#1077#1089#1083#1080' '#1080#1084#1087#1091#1083#1100#1089#1086#1074' '#1084#1077#1085#1100#1096#1077' '#1095#1077#1084' '#1083#1086#1087#1072#1090#1086#1082
      TabOrder = 0
    end
    object HiCheckBox: TCheckBox
      Left = 16
      Top = 39
      Width = 313
      Height = 17
      Caption = #1060#1080#1083#1100#1090#1088#1086#1074#1072#1090#1100' '#1086#1073#1086#1088#1086#1090' '#1077#1089#1083#1080' '#1080#1084#1087#1091#1083#1100#1089#1086#1074' '#1073#1086#1083#1100#1096#1077' '#1095#1077#1084' '#1083#1086#1087#1072#1090#1086#1082
      TabOrder = 1
    end
    object InsertCheckBox: TCheckBox
      Left = 16
      Top = 57
      Width = 313
      Height = 17
      Caption = #1042#1089#1090#1072#1074#1083#1103#1090#1100' '#1087#1088#1086#1087#1091#1097#1077#1085#1085#1099#1077' '#1080#1084#1087#1091#1083#1100#1089#1099
      TabOrder = 2
    end
  end
end

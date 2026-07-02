object DrawObjEditForm: TDrawObjEditForm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1086#1073#1100#1077#1082#1090
  ClientHeight = 254
  ClientWidth = 310
  Color = clBtnFace
  Constraints.MaxHeight = 288
  Constraints.MaxWidth = 318
  Constraints.MinHeight = 288
  Constraints.MinWidth = 318
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  inline DrawObjFrame1: TDrawObjFrame
    Left = 0
    Top = 0
    Width = 310
    Height = 187
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 310
    ExplicitHeight = 187
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 187
    Width = 310
    Height = 67
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      310
      67)
    object CancelBtn: TButton
      Left = 9
      Top = 24
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 218
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end

object TextLabelForm: TTextLabelForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1090#1088#1072#1085#1080#1094#1099
  ClientHeight = 347
  ClientWidth = 315
  Color = clBtnFace
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
    Width = 315
    Height = 121
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 315
    ExplicitHeight = 121
    inherited ColorBox: TPanel
      Color = clCream
    end
  end
  object TxtGB: TGroupBox
    Left = 0
    Top = 121
    Width = 315
    Height = 159
    Align = alClient
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1089#1090#1088#1072#1085#1080#1094#1099
    TabOrder = 1
    object ColorBgndLabel: TLabel
      Left = 3
      Top = 26
      Width = 58
      Height = 13
      Caption = #1062#1074#1077#1090' '#1089#1077#1090#1082#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object CaptionLabel: TLabel
      Left = 107
      Top = 26
      Width = 65
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
    end
    object BorderColorLabel: TLabel
      Left = 3
      Top = 74
      Width = 72
      Height = 13
      Caption = #1062#1074#1077#1090' '#1075#1088#1072#1085#1080#1094#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ColorBgndBox: TPanel
      Left = 3
      Top = 45
      Width = 72
      Height = 25
      Color = clCream
      ParentBackground = False
      TabOrder = 0
      OnDblClick = ColorBgndBoxDblClick
    end
    object CaptionEdit: TEdit
      Left = 107
      Top = 45
      Width = 121
      Height = 21
      TabOrder = 1
    end
    object TextBgndCB: TCheckBox
      Left = 107
      Top = 72
      Width = 94
      Height = 17
      Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1092#1086#1085
      TabOrder = 2
    end
    object BorderCb: TCheckBox
      Left = 107
      Top = 95
      Width = 121
      Height = 17
      Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1075#1088#1072#1085#1080#1094#1091
      TabOrder = 3
    end
    object BorderColorBox: TPanel
      Left = 3
      Top = 93
      Width = 72
      Height = 25
      Color = clCream
      ParentBackground = False
      TabOrder = 4
      OnDblClick = ColorBgndBoxDblClick
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 280
    Width = 315
    Height = 67
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    DesignSize = (
      315
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
      Left = 223
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

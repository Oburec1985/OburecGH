object SelGraphForm: TSelGraphForm
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1086#1088' '#1075#1088#1072#1092#1080#1082#1072
  ClientHeight = 363
  ClientWidth = 389
  Color = clBtnFace
  Constraints.MaxHeight = 397
  Constraints.MaxWidth = 397
  Constraints.MinHeight = 397
  Constraints.MinWidth = 397
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
  object Splitter1: TSplitter
    Left = 207
    Top = 0
    Height = 314
    Align = alRight
    ExplicitLeft = 112
    ExplicitTop = 160
    ExplicitHeight = 100
  end
  object CfgTV: TTreeView
    Left = 0
    Top = 0
    Width = 207
    Height = 314
    Align = alClient
    Indent = 19
    MultiSelect = True
    MultiSelectStyle = [msControlSelect, msShiftSelect]
    TabOrder = 0
  end
  object CfgGB: TGroupBox
    Left = 210
    Top = 0
    Width = 179
    Height = 314
    Align = alRight
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1074#1099#1073#1086#1088#1072' '#1075#1088#1072#1092#1080#1082#1072
    TabOrder = 1
    DesignSize = (
      179
      314)
    object pageNameLabel: TLabel
      Left = 6
      Top = 45
      Width = 75
      Height = 13
      Caption = #1048#1084#1103' '#1089#1090#1088#1072#1085#1080#1094#1099':'
    end
    object NameAxisLabel: TLabel
      Left = 8
      Top = 125
      Width = 43
      Height = 13
      Caption = #1048#1084#1103' '#1086#1089#1080':'
    end
    object GraphNameLabel: TLabel
      Left = 10
      Top = 213
      Width = 63
      Height = 13
      Caption = #1048#1084#1103' '#1090#1088#1077#1085#1076#1072':'
    end
    object NewAxisCheckBox: TCheckBox
      Left = 6
      Top = 104
      Width = 97
      Height = 17
      Caption = #1042' '#1085#1086#1074#1091#1102'  '#1086#1089#1100
      TabOrder = 0
      OnClick = NewAxisCheckBoxClick
    end
    object PageNameEdit: TEdit
      Left = 6
      Top = 64
      Width = 167
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 1
    end
    object NameAxisEdit: TEdit
      Left = 6
      Top = 144
      Width = 167
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object GraphNameEdit: TEdit
      Left = 6
      Top = 232
      Width = 167
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
    end
    object NewGraphCheckBox: TCheckBox
      Left = 8
      Top = 192
      Width = 97
      Height = 17
      Caption = #1042' '#1085#1086#1074#1099#1081' '#1090#1088#1077#1085#1076
      TabOrder = 4
      OnClick = NewGraphCheckBoxClick
    end
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 314
    Width = 389
    Height = 49
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    DesignSize = (
      389
      49)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 310
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end

object EditTagForm: TEditTagForm
  Left = 0
  Top = 0
  Caption = 'EditTagForm'
  ClientHeight = 529
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ActionGB: TGroupBox
    Left = 0
    Top = 460
    Width = 426
    Height = 69
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      426
      69)
    object ApplyBtn: TButton
      Left = 345
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 9
      Top = 24
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
  inline TagPropertiesFrame1: TTagPropertiesFrame
    Left = 0
    Top = 0
    Width = 426
    Height = 460
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 426
    ExplicitHeight = 460
    inherited TagNameEdit: TEdit
      Width = 420
      ExplicitWidth = 420
    end
    inherited DscEdit: TEdit
      Width = 420
      ExplicitWidth = 420
    end
    inherited TheresholdsLV: TBtnListView
      Width = 420
      Height = 289
      ExplicitWidth = 420
      ExplicitHeight = 289
    end
    inherited DrawObjEdit: TEdit
      Width = 373
      ExplicitWidth = 373
    end
    inherited DrawObjSelectBtn: TButton
      Left = 382
      ExplicitLeft = 382
    end
    inherited ToolBar: TToolBar
      Top = 421
      Width = 426
      ExplicitTop = 421
      ExplicitWidth = 426
    end
  end
end

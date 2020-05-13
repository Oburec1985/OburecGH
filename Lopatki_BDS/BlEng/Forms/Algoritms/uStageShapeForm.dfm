object StageShapeForm: TStageShapeForm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1095#1077#1090' '#1092#1086#1088#1084#1099' '#1082#1086#1083#1077#1089#1072
  ClientHeight = 478
  ClientWidth = 422
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 430
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
  inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
    Left = 0
    Top = 0
    Width = 422
    Height = 412
    Align = alClient
    Constraints.MinHeight = 288
    Constraints.MinWidth = 329
    TabOrder = 0
    ExplicitWidth = 422
    ExplicitHeight = 412
    inherited StageGB: TGroupBox
      Width = 422
      Height = 257
      ExplicitWidth = 422
      ExplicitHeight = 257
      inherited UseBladesPos: TRadioGroup
        Top = 175
        Width = 418
        Height = 80
        ExplicitTop = 175
        ExplicitWidth = 418
        ExplicitHeight = 80
      end
      inherited ValidBladeGB: TGroupBox
        Top = 45
        Width = 418
        Height = 130
        ExplicitTop = 45
        ExplicitWidth = 418
        ExplicitHeight = 130
        inherited UseThresholdCB: TCheckBox
          Width = 176
          Caption = #1048#1089#1087'. '#1087#1086#1088'. ('#1082' '#1073#1083#1080#1078'-'#1077#1081' '#1083#1086#1087#1072#1090#1082#1077')'
          ExplicitWidth = 176
        end
      end
    end
    inherited CommonGB: TGroupBox
      Width = 422
      ExplicitWidth = 422
    end
    inherited TagsGB: TGroupBox
      Top = 408
      Width = 422
      Height = 4
      ExplicitTop = 408
      ExplicitWidth = 422
      ExplicitHeight = 4
      inherited AlgTagList1: TAlgTagListFrame
        Width = 418
        ExplicitWidth = 418
        inherited TagListLV: TBtnListView
          Width = 416
          ExplicitWidth = 416
        end
      end
    end
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 412
    Width = 422
    Height = 66
    Align = alBottom
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      422
      66)
    object OkBtn: TButton
      Left = 344
      Top = 30
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 3
      Top = 30
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
    end
  end
end

object RestoreAlgForm: TRestoreAlgForm
  Left = 0
  Top = 0
  Caption = #1042#1086#1089#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1080#1075#1085#1072#1083
  ClientHeight = 638
  ClientWidth = 461
  Color = clBtnFace
  Constraints.MinHeight = 506
  Constraints.MinWidth = 338
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
    Width = 461
    Height = 572
    Align = alClient
    Constraints.MinHeight = 348
    Constraints.MinWidth = 451
    TabOrder = 0
    ExplicitWidth = 461
    ExplicitHeight = 572
    inherited StageGB: TGroupBox
      Width = 461
      ExplicitWidth = 461
      inherited ValidBladeGB: TGroupBox
        Top = 72
        Width = 457
        Height = 144
        ExplicitTop = 72
        ExplicitWidth = 457
        ExplicitHeight = 144
        inherited UseBladesPos: TRadioGroup
          Left = 252
          Height = 127
          ExplicitLeft = 252
          ExplicitHeight = 127
        end
      end
    end
    inherited CommonGB: TGroupBox
      Width = 461
      ExplicitWidth = 461
      inherited MeraFileCB: TCheckBox
        OnClick = BaseAlgOptsFrame1MeraFileCBClick
      end
    end
    inherited TagsGB: TGroupBox
      Width = 461
      Height = 127
      ExplicitWidth = 461
      ExplicitHeight = 127
      inherited AlgTagList1: TAlgTagListFrame
        Width = 457
        Height = 110
        ExplicitWidth = 457
        ExplicitHeight = 110
        inherited TagListLV: TBtnListView
          Width = 455
          Height = 222
          ExplicitWidth = 455
          ExplicitHeight = 222
        end
      end
    end
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 572
    Width = 461
    Height = 66
    Align = alBottom
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      461
      66)
    object OkBtn: TButton
      Left = 383
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

object XYTrendForm: TXYTrendForm
  Left = 0
  Top = 0
  Caption = 'XYTrendForm'
  ClientHeight = 562
  ClientWidth = 397
  Color = clBtnFace
  Constraints.MinHeight = 596
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  DesignSize = (
    397
    562)
  PixelsPerInch = 96
  TextHeight = 13
  object BladeIndLabel: TLabel
    Left = 197
    Top = 399
    Width = 142
    Height = 13
    Caption = #1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080' ('#1089#1090#1072#1088#1090#1086#1074#1099#1081')'
  end
  object Label1: TLabel
    Left = 197
    Top = 447
    Width = 134
    Height = 13
    Caption = #1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080'('#1082#1086#1085#1077#1095#1085#1099#1081')'
  end
  object CancelBtn: TButton
    Left = 8
    Top = 517
    Width = 75
    Height = 32
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 0
    ExplicitTop = 524
  end
  object OkBtn: TButton
    Left = 315
    Top = 517
    Width = 80
    Height = 32
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 1
    ExplicitLeft = 360
    ExplicitTop = 524
  end
  object StartBladeSE: TSpinEdit
    Left = 197
    Top = 418
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
    Left = 0
    Top = 0
    Width = 397
    Height = 393
    Align = alTop
    Constraints.MinHeight = 288
    Constraints.MinWidth = 329
    TabOrder = 3
    ExplicitWidth = 442
    ExplicitHeight = 393
    inherited StageGB: TGroupBox
      Width = 397
      ExplicitWidth = 442
      inherited ValidBladeGB: TGroupBox
        Width = 393
        ExplicitWidth = 438
        inherited UseBladesPos: TRadioGroup
          Left = -47
          Width = 438
          ExplicitLeft = -2
          ExplicitWidth = 438
        end
      end
    end
    inherited CommonGB: TGroupBox
      Width = 397
      ExplicitWidth = 442
    end
    inherited TagsGB: TGroupBox
      Width = 397
      ExplicitWidth = 442
      inherited AlgTagList1: TAlgTagListFrame
        Width = 393
        ExplicitWidth = 438
        inherited TagListLV: TBtnListView
          Width = 506
          ExplicitWidth = 551
        end
      end
    end
  end
  object EndBladeSE: TSpinEdit
    Left = 197
    Top = 466
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
end

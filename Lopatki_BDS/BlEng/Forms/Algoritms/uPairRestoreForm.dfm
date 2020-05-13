object PairRestoreForm: TPairRestoreForm
  Left = 0
  Top = 0
  Caption = 'PairRestoreForm'
  ClientHeight = 700
  ClientWidth = 451
  Color = clBtnFace
  Constraints.MinHeight = 729
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
    Left = 0
    Top = 0
    Width = 451
    Height = 599
    Align = alTop
    Constraints.MinHeight = 399
    Constraints.MinWidth = 451
    TabOrder = 0
    ExplicitLeft = -25
    ExplicitTop = 15
    inherited TagsGB: TGroupBox
      inherited AlgTagList1: TAlgTagListFrame
        inherited TagListLV: TBtnListView
          Width = 441
          Height = 112
          ExplicitWidth = 441
          ExplicitHeight = 112
        end
      end
    end
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 634
    Width = 451
    Height = 66
    Align = alBottom
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    ExplicitLeft = -10
    ExplicitTop = 572
    ExplicitWidth = 461
    DesignSize = (
      451
      66)
    object OkBtn: TButton
      Left = 373
      Top = 30
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 383
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

object BaseAlgForm: TBaseAlgForm
  Left = 0
  Top = 0
  Caption = #1054#1073#1097#1072#1103' '#1085#1072#1089#1090#1088#1086#1081#1082#1072' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
  ClientHeight = 633
  ClientWidth = 451
  Color = clBtnFace
  Constraints.MinHeight = 503
  Constraints.MinWidth = 459
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
    Height = 608
    Align = alTop
    Constraints.MinHeight = 399
    Constraints.MinWidth = 451
    TabOrder = 0
    inherited TagsGB: TGroupBox
      inherited AlgTagList1: TAlgTagListFrame
        inherited TagListLV: TBtnListView
          Width = 443
          Height = 109
          ExplicitWidth = 443
          ExplicitHeight = 109
        end
      end
    end
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 576
    Width = 451
    Height = 57
    Align = alBottom
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      451
      57)
    object OkBtn: TButton
      Left = 373
      Top = 21
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitTop = 34
    end
    object CancelBtn: TButton
      Left = 3
      Top = 21
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
      ExplicitTop = 34
    end
  end
end

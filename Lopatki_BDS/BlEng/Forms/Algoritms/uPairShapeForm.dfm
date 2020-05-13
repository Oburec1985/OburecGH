object PairShapeForm: TPairShapeForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
  ClientHeight = 725
  ClientWidth = 451
  Color = clBtnFace
  Constraints.MinHeight = 617
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
    Left = 0
    Top = 551
    Width = 451
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitLeft = 2
    ExplicitTop = 15
    ExplicitWidth = 157
  end
  object PairShapeOptsGB: TGroupBox
    Left = 0
    Top = 554
    Width = 451
    Height = 171
    Align = alClient
    Caption = #1054#1087#1094#1080#1080' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
    TabOrder = 0
    ExplicitTop = 399
    ExplicitHeight = 248
    DesignSize = (
      451
      171)
    inline pairShapeFrame1: TpairShapeFrame
      Left = 2
      Top = 15
      Width = 447
      Height = 154
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 447
      ExplicitHeight = 231
    end
    object OkBtn: TButton
      Left = 373
      Top = 143
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      ExplicitTop = 220
    end
    object CancelBtn: TButton
      Left = 3
      Top = 143
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 2
      ExplicitTop = 220
    end
  end
  inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
    Left = 0
    Top = 0
    Width = 451
    Height = 551
    Align = alTop
    Constraints.MinHeight = 399
    Constraints.MinWidth = 451
    TabOrder = 1
    ExplicitHeight = 551
    inherited TagsGB: TGroupBox
      Height = 127
      inherited AlgTagList1: TAlgTagListFrame
        Height = 110
        inherited TagListLV: TBtnListView
          Height = 222
        end
      end
    end
  end
end

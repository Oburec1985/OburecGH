object LoadBldF: TLoadBldF
  Left = 0
  Top = 0
  Caption = 'LoadBldF'
  ClientHeight = 559
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inline LoadBldFrame1: TLoadBldFrame
    Left = 0
    Top = 0
    Width = 392
    Height = 496
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 392
    ExplicitHeight = 496
    inherited SensorsLV: TBtnListView
      Width = 392
      Height = 439
      ExplicitLeft = -6
      ExplicitWidth = 392
      ExplicitHeight = 489
    end
    inherited GroupBox1: TGroupBox
      Width = 392
      ExplicitWidth = 392
      inherited Label1: TLabel
        Left = 5
        Top = 13
        ExplicitLeft = 5
        ExplicitTop = 13
      end
      inherited Edit1: TEdit
        Left = 5
        Top = 30
        Width = 379
        ExplicitLeft = 5
        ExplicitTop = 30
        ExplicitWidth = 379
      end
    end
  end
  inline TreeBldCfgFrame1: TTreeBldCfgFrame
    Left = 392
    Top = 0
    Width = 210
    Height = 496
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 439
    ExplicitWidth = 210
    ExplicitHeight = 496
    inherited CfgTreeView: TTreeView
      Width = 210
      Height = 423
      ExplicitHeight = 473
    end
    inherited ToolBar1: TToolBar
      Width = 210
      ExplicitWidth = 297
    end
    inherited GroupBox1: TGroupBox
      Width = 210
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 496
    Width = 602
    Height = 63
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    DesignSize = (
      602
      63)
    object CancelBtn: TButton
      Left = 5
      Top = 32
      Width = 75
      Height = 26
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 524
      Top = 32
      Width = 75
      Height = 28
      Anchors = [akLeft, akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end

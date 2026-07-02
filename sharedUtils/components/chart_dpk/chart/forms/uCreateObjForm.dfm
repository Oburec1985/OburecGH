object CreateObjForm: TCreateObjForm
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1075#1088#1072#1092#1080#1082#1072
  ClientHeight = 669
  ClientWidth = 731
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 597
    Width = 731
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 642
  end
  object ChartGB: TGroupBox
    Left = 0
    Top = 0
    Width = 731
    Height = 597
    Align = alClient
    Caption = 'ChartGB'
    TabOrder = 0
    inline EditChartCfgFrame1: TEditChartCfgFrame
      Left = 2
      Top = 15
      Width = 727
      Height = 580
      Align = alClient
      Constraints.MinHeight = 238
      Constraints.MinWidth = 639
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 727
      ExplicitHeight = 580
      inherited Splitter1: TSplitter
        Height = 580
        ExplicitHeight = 599
      end
      inherited Splitter2: TSplitter
        Height = 580
        ExplicitHeight = 599
      end
      inherited CfgGB: TGroupBox
        Height = 580
        ExplicitHeight = 580
        inherited addLineBtn: TSpeedButton
          OnClick = EditChartCfgFrame1addLineBtnClick
        end
      end
      inherited CfgTV: TTreeView
        Height = 580
        ExplicitHeight = 580
      end
      inherited ObjGB: TGroupBox
        Width = 418
        Height = 580
        ExplicitWidth = 418
        ExplicitHeight = 580
        inherited EditDrawObjFrame1: TEditDrawObjFrame
          Width = 414
          Height = 563
          ExplicitWidth = 414
          ExplicitHeight = 563
          inherited DrawObjGB: TGroupBox
            Width = 414
            Height = 139
            ExplicitWidth = 414
            ExplicitHeight = 139
            inherited DrawObjFrame1: TDrawObjFrame
              Width = 410
              Height = 122
              ExplicitWidth = 410
              ExplicitHeight = 122
            end
          end
          inherited TrendGB: TGroupBox
            Top = 139
            Width = 414
            ExplicitTop = 139
            ExplicitWidth = 414
            inherited TrendFrame1: TTrendFrame
              Width = 410
              ExplicitWidth = 410
              inherited PointGB: TGroupBox
                Width = 410
                ExplicitWidth = 410
                inherited GroupBox1: TGroupBox
                  Width = 406
                end
              end
            end
          end
          inherited GistGB: TGroupBox
            Top = 460
            Width = 414
            ExplicitTop = 460
            ExplicitWidth = 414
            inherited GistFrame1: TGistFrame
              Width = 410
              ExplicitWidth = 410
            end
          end
        end
      end
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 600
    Width = 731
    Height = 69
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    ExplicitWidth = 643
    DesignSize = (
      731
      69)
    object ApplyBtn: TButton
      Left = 650
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 562
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
end

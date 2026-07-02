object TrendForm: TTrendForm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1090#1088#1077#1085#1076
  ClientHeight = 485
  ClientWidth = 402
  Color = clBtnFace
  Constraints.MinHeight = 381
  Constraints.MinWidth = 305
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
  object CommonGB: TGroupBox
    Left = 0
    Top = 0
    Width = 402
    Height = 113
    Align = alTop
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1072
    Constraints.MinHeight = 113
    Constraints.MinWidth = 298
    TabOrder = 0
    inline DrawObjFrame1: TDrawObjFrame
      Left = 2
      Top = 15
      Width = 398
      Height = 96
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 398
      ExplicitHeight = 96
      inherited ColorLabel: TLabel
        Top = 52
        ExplicitTop = 52
      end
      inherited ColorBox: TPanel
        Color = clWindow
      end
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 418
    Width = 402
    Height = 67
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    ExplicitTop = 370
    DesignSize = (
      402
      67)
    object CancelBtn: TButton
      Left = 9
      Top = 24
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 310
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  inline TrendFrame1: TTrendFrame
    Left = 0
    Top = 113
    Width = 402
    Height = 311
    Align = alClient
    Constraints.MinHeight = 311
    TabOrder = 2
    ExplicitTop = 113
    ExplicitWidth = 402
    ExplicitHeight = 311
    inherited PointGB: TGroupBox
      Width = 402
      ExplicitWidth = 398
      ExplicitHeight = 240
      inherited ColorBox: TPanel
        Left = 5
        Top = 37
        ExplicitLeft = 5
        ExplicitTop = 37
      end
      inherited DrawPoints: TCheckBox
        Top = 91
        ExplicitTop = 91
      end
      inherited GroupBox1: TGroupBox
        Width = 398
        ExplicitTop = 51
        ExplicitWidth = 394
        inherited SelectVectorPointColorLabel: TLabel
          Top = 117
          ExplicitTop = 117
        end
        inherited ColorSelectPointLabel: TLabel
          Top = 67
          ExplicitTop = 67
        end
        inherited SelectVectorPointColor: TPanel
          Top = 136
          ExplicitTop = 136
        end
        inherited ColorSelectPoint: TPanel
          Top = 88
          ExplicitTop = 88
        end
      end
      inherited DrawLines: TCheckBox
        Top = 68
        ExplicitTop = 68
      end
    end
    inherited BackGroundColorDialog: TColorDialog
      Left = 184
      Top = 194
    end
  end
end

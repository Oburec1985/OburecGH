object GistForm: TGistForm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1090#1088#1077#1085#1076
  ClientHeight = 396
  ClientWidth = 481
  Color = clBtnFace
  Constraints.MinHeight = 430
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
    Width = 481
    Height = 113
    Align = alTop
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1072
    Constraints.MinHeight = 113
    Constraints.MinWidth = 298
    TabOrder = 0
    inline DrawObjFrame1: TDrawObjFrame
      Left = 2
      Top = 15
      Width = 477
      Height = 96
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 477
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
  object PointGB: TGroupBox
    Left = 0
    Top = 113
    Width = 481
    Height = 216
    Align = alClient
    Caption = #1054#1090#1088#1080#1089#1086#1074#1082#1072' '#1074#1077#1088#1096#1080#1085
    TabOrder = 1
    inline GistFrame1: TGistFrame
      Left = 2
      Top = 15
      Width = 477
      Height = 199
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 477
      ExplicitHeight = 199
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 329
    Width = 481
    Height = 67
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    DesignSize = (
      481
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
      Left = 389
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end

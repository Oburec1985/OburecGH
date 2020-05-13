object ProgresDlg: TProgresDlg
  Left = 0
  Top = 0
  Caption = 'ProgresDlg'
  ClientHeight = 71
  ClientWidth = 426
  Color = clBtnFace
  Constraints.MaxHeight = 105
  Constraints.MaxWidth = 434
  Constraints.MinHeight = 105
  Constraints.MinWidth = 434
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 0
    Width = 426
    Height = 17
    Align = alTop
    TabOrder = 0
  end
  object UserBtnGB: TGroupBox
    Left = 0
    Top = 17
    Width = 426
    Height = 54
    Align = alClient
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      426
      54)
    object StatusLabel: TLabel
      Left = 96
      Top = 26
      Width = 40
      Height = 13
      Caption = #1057#1090#1072#1090#1091#1089':'
    end
    object MessageLabel: TLabel
      Left = 142
      Top = 26
      Width = 20
      Height = 13
      Caption = '0 %'
    end
    object CancelBtn: TButton
      Left = 0
      Top = 26
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
      OnClick = CancelBtnClick
    end
  end
end

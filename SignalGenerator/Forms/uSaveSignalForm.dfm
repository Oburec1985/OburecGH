object SaveSignalForm: TSaveSignalForm
  Left = 0
  Top = 0
  Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1092#1072#1081#1083
  ClientHeight = 343
  ClientWidth = 370
  Color = clBtnFace
  Constraints.MinHeight = 381
  Constraints.MinWidth = 381
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    370
    343)
  PixelsPerInch = 120
  TextHeight = 17
  object ResFreqLabel: TLabel
    Left = 27
    Top = 20
    Width = 179
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1080', '#1043#1094
  end
  object PathBtn: TButton
    Left = 234
    Top = 101
    Width = 105
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = #1050#1072#1090#1072#1083#1086#1075
    TabOrder = 0
    OnClick = PathBtnClick
  end
  object ResFreqIE: TIntEdit
    Left = 27
    Top = 44
    Width = 185
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 1
    Text = '216000'
  end
  object PathEdit: TEdit
    Left = 27
    Top = 103
    Width = 184
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    Text = 'PathEdit'
  end
  object CancelBtn: TButton
    Left = 27
    Top = 299
    Width = 99
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 3
  end
  object ApplyBtn: TButton
    Left = 241
    Top = 299
    Width = 98
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 4
  end
  object SaveDialog1: TSaveDialog
    Left = 184
    Top = 24
  end
end

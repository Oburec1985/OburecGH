object SaveSignalsForm: TSaveSignalsForm
  Left = 0
  Top = 0
  Caption = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1089#1080#1075#1085#1072#1083#1086#1074
  ClientHeight = 384
  ClientWidth = 437
  Color = clBtnFace
  Constraints.MinHeight = 298
  Constraints.MinWidth = 296
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    437
    384)
  PixelsPerInch = 96
  TextHeight = 13
  object TestNameLabel: TLabel
    Left = 7
    Top = 14
    Width = 81
    Height = 13
    Caption = #1048#1084#1103' '#1080#1089#1087#1099#1090#1072#1085#1080#1103':'
  end
  object DscLabel: TLabel
    Left = 7
    Top = 62
    Width = 111
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077' '#1080#1089#1087#1099#1090#1072#1085#1080#1103':'
  end
  object FilePathLabel: TLabel
    Left = 7
    Top = 264
    Width = 73
    Height = 13
    Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091':'
  end
  object FreqLabel: TLabel
    Left = 3
    Top = 131
    Width = 126
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1080':'
  end
  object Label1: TLabel
    Left = 252
    Top = 177
    Width = 74
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1087#1086#1088#1094#1080#1080
  end
  object Label2: TLabel
    Left = 250
    Top = 131
    Width = 65
    Height = 13
    Caption = #1064#1072#1075' '#1087#1086' '#1086#1089#1080' Z'
  end
  object TestNameEdit: TEdit
    Left = 4
    Top = 32
    Width = 428
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object DscEdit: TEdit
    Left = 4
    Top = 81
    Width = 428
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object FilePathEdit: TEdit
    Left = 4
    Top = 283
    Width = 382
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object Button1: TButton
    Left = 389
    Top = 281
    Width = 43
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = Button1Click
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 335
    Width = 437
    Height = 49
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 4
    DesignSize = (
      437
      49)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 357
      Top = 21
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  object Mera3dCB: TCheckBox
    Left = 249
    Top = 112
    Width = 41
    Height = 17
    Caption = '3D'
    TabOrder = 5
    OnClick = Mera3dCBClick
  end
  object FreqIE: TIntEdit
    Left = 0
    Top = 150
    Width = 129
    Height = 21
    TabOrder = 6
    Text = '1000'
  end
  object ZSize: TIntEdit
    Left = 249
    Top = 196
    Width = 129
    Height = 21
    TabOrder = 7
    Text = '1000'
  end
  object dZ: TIntEdit
    Left = 247
    Top = 150
    Width = 129
    Height = 21
    TabOrder = 8
    Text = '1'
  end
  object WriteXYCheckBox: TCheckBox
    Left = 4
    Top = 112
    Width = 101
    Height = 17
    Caption = #1047#1072#1087#1080#1089#1099#1074#1072#1090#1100' XY'
    TabOrder = 9
    OnClick = WriteXYCheckBoxClick
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Mera '#1092#1072#1081#1083'|*.mera'
    Left = 152
    Top = 128
  end
end

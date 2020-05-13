object MeraFileMngFrm: TMeraFileMngFrm
  Left = 0
  Top = 0
  Anchors = [akTop, akRight]
  Caption = #1056#1072#1073#1086#1090#1072' '#1089' Mera '#1092#1072#1081#1083#1086#1084
  ClientHeight = 596
  ClientWidth = 590
  Color = clBtnFace
  Constraints.MinHeight = 630
  Constraints.MinWidth = 485
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    590
    596)
  PixelsPerInch = 96
  TextHeight = 18
  object Label1: TLabel
    Left = 8
    Top = 17
    Width = 164
    Height = 18
    Caption = #1055#1091#1090#1100' '#1082' '#1087#1077#1088#1074#1086#1084#1091' '#1092#1072#1081#1083#1091
  end
  object Label2: TLabel
    Left = 8
    Top = 73
    Width = 161
    Height = 18
    Caption = #1055#1091#1090#1100' '#1082' '#1074#1090#1086#1088#1086#1084#1091' '#1092#1072#1081#1083#1091
  end
  object Start1: TLabel
    Left = 8
    Top = 252
    Width = 363
    Height = 18
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1074#1090#1086#1088#1086#1075#1086' '#1092#1072#1081#1083#1072' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1087#1077#1088#1074#1086#1075#1086
  end
  object Label3: TLabel
    Left = 8
    Top = 129
    Width = 213
    Height = 18
    Caption = #1055#1091#1090#1100' '#1082' '#1089#1086#1074#1084#1077#1097#1077#1085#1085#1086#1084#1091' '#1092#1072#1081#1083#1091
  end
  object Label4: TLabel
    Left = 8
    Top = 315
    Width = 114
    Height = 18
    Caption = #1057#1087#1080#1089#1086#1082' '#1086#1096#1080#1073#1086#1082
  end
  object FileE1: TEdit
    Left = 8
    Top = 40
    Width = 481
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Color = 8421631
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = FileE1Change
  end
  object FileE2: TEdit
    Left = 8
    Top = 96
    Width = 481
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = FileE1Change
  end
  object SelectPathBtn1: TButton
    Left = 507
    Top = 38
    Width = 75
    Height = 28
    Hint = #1042#1099#1073#1086#1088' '#1087#1077#1088#1074#1086#1075#1086' '#1092#1072#1081#1083#1072' '#1082' '#1082#1086#1090#1086#1088#1086#1084#1091' '#1073#1091#1076#1077#1090' '#1087#1088#1080#1089#1086#1077#1076#1080#1085#1077#1085' '#1074#1090#1086#1088#1086#1081
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 2
    OnClick = SelectPathBtn1Click
  end
  object SelectPathBtn2: TButton
    Left = 507
    Top = 94
    Width = 75
    Height = 28
    Hint = #1042#1099#1073#1086#1088' '#1074#1090#1086#1088#1086#1075#1086' '#1092#1072#1081#1083#1072', '#1082#1086#1090#1086#1088#1099#1081' '#1073#1091#1076#1077#1090' '#1087#1088#1080#1089#1086#1077#1076#1080#1085#1077#1085' '#1074' '#1082#1086#1085#1077#1094' '#1087#1077#1088#1074#1086#1075#1086
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = SelectPathBtn2Click
  end
  object PrtCB: TCheckBox
    Left = 8
    Top = 189
    Width = 177
    Height = 17
    Hint = #1055#1088#1080' '#1074#1082#1083#1102#1095#1077#1085#1080#1080' '#1087#1072#1088#1072#1084#1077#1090#1088' "'#1057#1084#1077#1097#1077#1085#1080#1077' '#1074#1090#1086#1088#1086#1075#1086' '#1092#1072#1081#1083#1072' '#1080#1075#1085#1086#1088#1080#1088#1091#1077#1090#1089#1103'"'
    Caption = #1055#1080#1089#1072#1090#1100' '#1089' '#1088#1072#1079#1088#1099#1074#1072#1084#1080
    TabOrder = 4
    OnClick = PrtCBClick
  end
  object Button1: TButton
    Left = 433
    Top = 563
    Width = 151
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = #1057#1086#1077#1076#1080#1085#1080#1090#1100' '#1092#1072#1081#1083#1099
    TabOrder = 5
    OnClick = Button1Click
  end
  object ErrorLogLB: TListBox
    Left = 8
    Top = 344
    Width = 574
    Height = 213
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object FileE3: TEdit
    Left = 8
    Top = 152
    Width = 481
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnChange = FileE1Change
  end
  object SelectPathBtn3: TButton
    Left = 507
    Top = 150
    Width = 75
    Height = 28
    Hint = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1080#1088#1091#1102#1097#1080#1081' '#1092#1072#1081#1083
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 8
    OnClick = SelectPathBtn3Click
  end
  object StartSE1: TFloatSpinEdit
    Left = 8
    Top = 276
    Width = 121
    Height = 28
    Hint = 
      #1042#1090#1086#1088#1086#1081' '#1092#1072#1081#1083' '#1073#1091#1076#1077#1090' '#1085#1072#1095#1080#1085#1072#1090#1100#1089#1103' '#1089' '#1089#1077#1082#1091#1085#1076#1099' '#1091#1082#1072#1079#1072#1085#1085#1086#1081' '#1074' '#1080#1085#1076#1080#1082#1072#1090#1086#1088#1077' ('#1090 +
      '.'#1077'. '#1074#1088#1077#1084#1103' '#1085#1077' '#1076#1086#1083#1078#1085#1086' '#1073#1099#1090#1100' '#1073#1086#1083#1100#1096#1077' '#1095#1077#1084' '#1076#1083#1080#1085#1072' '#1087#1077#1088#1074#1086#1075#1086' '#1092#1072#1081#1083#1072')'
    Increment = 0.100000001490116100
    TabOrder = 9
    OnEnter = StartSE1Enter
    OnExit = StartSE1Enter
  end
  object EvalOffsetCheckBox: TCheckBox
    Left = 8
    Top = 222
    Width = 281
    Height = 17
    Caption = #1057#1095#1080#1090#1072#1090#1100' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080' '#1079#1072#1087#1080#1089#1080' '#1092#1072#1081#1083#1072
    TabOrder = 10
    OnClick = EvalOffsetCheckBoxClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Mera '#1092#1072#1081#1083'|*.mera|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Left = 320
    Top = 65528
  end
  object OpenDialog2: TOpenDialog
    Filter = 'Mera '#1092#1072#1081#1083'|*.mera|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Left = 384
    Top = 65528
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Mera '#1092#1072#1081#1083'|*.mera|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Options = [ofEnableSizing]
    Left = 432
    Top = 65528
  end
end

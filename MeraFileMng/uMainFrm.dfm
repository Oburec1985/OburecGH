object MeraFileMngFrm: TMeraFileMngFrm
  Left = 0
  Top = 0
  Anchors = [akTop, akRight]
  Caption = 'MergeMeraFile'
  ClientHeight = 728
  ClientWidth = 721
  Color = clBtnFace
  Constraints.MinHeight = 770
  Constraints.MinWidth = 593
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    721
    728)
  PixelsPerInch = 120
  TextHeight = 22
  object Label1: TLabel
    Left = 10
    Top = 21
    Width = 74
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'First file'
  end
  object Label2: TLabel
    Left = 10
    Top = 89
    Width = 104
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'SecondFile'
  end
  object Start1: TLabel
    Left = 10
    Top = 308
    Width = 181
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Offset between files'
  end
  object Label3: TLabel
    Left = 10
    Top = 158
    Width = 63
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Output'
  end
  object Label4: TLabel
    Left = 10
    Top = 385
    Width = 67
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Errors:'
  end
  object FileE1: TEdit
    Left = 10
    Top = 49
    Width = 588
    Height = 27
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Color = 8421631
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = FileE1Change
  end
  object FileE2: TEdit
    Left = 10
    Top = 117
    Width = 588
    Height = 27
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = FileE1Change
  end
  object SelectPathBtn1: TButton
    Left = 620
    Top = 46
    Width = 91
    Height = 35
    Hint = 'Choose first file'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 2
    OnClick = SelectPathBtn1Click
  end
  object SelectPathBtn2: TButton
    Left = 620
    Top = 115
    Width = 91
    Height = 34
    Hint = 'Choose second file'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = SelectPathBtn2Click
  end
  object PrtCB: TCheckBox
    Left = 10
    Top = 231
    Width = 263
    Height = 21
    Hint = #1055#1088#1080' '#1074#1082#1083#1102#1095#1077#1085#1080#1080' '#1087#1072#1088#1072#1084#1077#1090#1088' "'#1057#1084#1077#1097#1077#1085#1080#1077' '#1074#1090#1086#1088#1086#1075#1086' '#1092#1072#1081#1083#1072' '#1080#1075#1085#1086#1088#1080#1088#1091#1077#1090#1089#1103'"'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Write with break'
    TabOrder = 4
    OnClick = PrtCBClick
  end
  object Button1: TButton
    Left = 488
    Top = 688
    Width = 226
    Height = 36
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'MergeFile'
    TabOrder = 5
    OnClick = Button1Click
  end
  object ErrorLogLB: TListBox
    Left = 10
    Top = 420
    Width = 701
    Height = 261
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ItemHeight = 19
    ParentFont = False
    TabOrder = 6
  end
  object FileE3: TEdit
    Left = 10
    Top = 186
    Width = 588
    Height = 27
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnChange = FileE1Change
  end
  object SelectPathBtn3: TButton
    Left = 620
    Top = 183
    Width = 91
    Height = 35
    Hint = 'Choose result file'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 8
    OnClick = SelectPathBtn3Click
  end
  object EvalOffsetCheckBox: TCheckBox
    Left = 10
    Top = 271
    Width = 535
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Eval offset with mera file time'
    TabOrder = 9
    OnClick = EvalOffsetCheckBoxClick
  end
  object StartSE1: TFloatSpinEdit
    Left = 10
    Top = 337
    Width = 148
    Height = 33
    Hint = 
      #1042#1090#1086#1088#1086#1081' '#1092#1072#1081#1083' '#1073#1091#1076#1077#1090' '#1085#1072#1095#1080#1085#1072#1090#1100#1089#1103' '#1089' '#1089#1077#1082#1091#1085#1076#1099' '#1091#1082#1072#1079#1072#1085#1085#1086#1081' '#1074' '#1080#1085#1076#1080#1082#1072#1090#1086#1088#1077' ('#1090 +
      '.'#1077'. '#1074#1088#1077#1084#1103' '#1085#1077' '#1076#1086#1083#1078#1085#1086' '#1073#1099#1090#1100' '#1073#1086#1083#1100#1096#1077' '#1095#1077#1084' '#1076#1083#1080#1085#1072' '#1087#1077#1088#1074#1086#1075#1086' '#1092#1072#1081#1083#1072')'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Increment = 0.100000001490116100
    TabOrder = 10
    OnEnter = StartSE1Enter
    OnExit = StartSE1Enter
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

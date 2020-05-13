object HilbFltFrm: THilbFltFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1092#1080#1083#1100#1090#1088#1072
  ClientHeight = 658
  ClientWidth = 471
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object NumPointsLabel: TLabel
    Left = 10
    Top = 25
    Width = 82
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082
  end
  object Label1: TLabel
    Left = 10
    Top = 320
    Width = 90
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1063#1080#1089#1083#1086' '#1073#1083#1086#1082#1086#1074
  end
  object Label2: TLabel
    Left = 10
    Top = 161
    Width = 112
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1056#1072#1079#1084#1077#1088' '#1087#1086#1088#1094#1080#1080', '#1089
  end
  object Label3: TLabel
    Left = 10
    Top = 415
    Width = 16
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'T1'
  end
  object Label4: TLabel
    Left = 10
    Top = 477
    Width = 16
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'T2'
  end
  object NumPointsCB: TComboBox
    Left = 10
    Top = 50
    Width = 190
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ItemIndex = 5
    TabOrder = 0
    Text = '4096'
    OnChange = NumPointsCBChange
    Items.Strings = (
      '128'
      '256'
      '512'
      '1024'
      '2048'
      '4096'
      '8192'
      '16384'
      '32768'
      '65536'
      '131072'
      '262144'
      '524288')
  end
  object nBlocksIE: TIntEdit
    Left = 10
    Top = 345
    Width = 190
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 1
    Text = '000'
  end
  object TimeFE: TFloatEdit
    Left = 10
    Top = 186
    Width = 180
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Enabled = False
    TabOrder = 2
    Text = '0.0'
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 600
    Width = 471
    Height = 58
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      471
      58)
    object CancelBtn: TButton
      Left = 7
      Top = 17
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 364
      Top = 17
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      OnClick = ApplyBtnClick
    end
  end
  object SignalLB: TListBox
    Left = 251
    Top = 0
    Width = 220
    Height = 600
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    ItemHeight = 17
    TabOrder = 4
    OnClick = SignalLBClick
  end
  object AutoCB: TCheckBox
    Left = 10
    Top = 282
    Width = 127
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1040#1074#1090#1086
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 5
  end
  object ResampleCB: TCheckBox
    Left = 10
    Top = 85
    Width = 127
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1055#1077#1088#1077#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1103
    TabOrder = 6
  end
  object ResampleIE: TIntEdit
    Left = 10
    Top = 123
    Width = 190
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 7
    Text = '-1'
    OnChange = ResampleIEChange
  end
  object T1fe: TFloatEdit
    Left = 10
    Top = 439
    Width = 159
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 8
    Text = '0.0'
  end
  object T2fe: TFloatEdit
    Left = 10
    Top = 502
    Width = 159
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 9
    Text = '0.0'
  end
  object LengthCB: TCheckBox
    Left = 10
    Top = 388
    Width = 127
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1042#1077#1089#1100' '#1089#1080#1075#1085#1072#1083
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 10
  end
end

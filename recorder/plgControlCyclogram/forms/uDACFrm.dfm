object DACFrm: TDACFrm
  Left = 0
  Top = 0
  Caption = 'DAC Control'
  ClientHeight = 220
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 37
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnPlayStop: TButton
      Left = 12
      Top = 12
      Width = 79
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Play'
      TabOrder = 0
      OnClick = btnPlayStopClick
    end
  end
  object rgMode: TRadioGroup
    Left = 12
    Top = 41
    Width = 317
    Height = 44
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Mode'
    Columns = 2
    Items.Strings = (
      'Sin'
      'SweepSin')
    TabOrder = 1
    OnClick = rgModeClick
  end
  object gbSweepSin: TGroupBox
    Left = 12
    Top = 89
    Width = 317
    Height = 116
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'SweepSin Parameters'
    TabOrder = 2
    object lblStartFreq: TLabel
      Left = 12
      Top = 24
      Width = 62
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Start Freq, Hz'
    end
    object lblEndFreq: TLabel
      Left = 12
      Top = 48
      Width = 59
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'End Freq, Hz'
    end
    object lblSweepTime: TLabel
      Left = 12
      Top = 72
      Width = 64
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Sweep Time, s'
    end
    object edStartFreq: TEdit
      Left = 96
      Top = 22
      Width = 91
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
      Text = '100'
    end
    object edEndFreq: TEdit
      Left = 96
      Top = 46
      Width = 91
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = '10000'
    end
    object edSweepTime: TEdit
      Left = 96
      Top = 70
      Width = 91
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 2
      Text = '10'
    end
  end
  object gbSin: TGroupBox
    Left = 12
    Top = 89
    Width = 317
    Height = 116
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Sin Parameters'
    TabOrder = 3
    object lblFreq: TLabel
      Left = 12
      Top = 24
      Width = 38
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Freq, Hz'
    end
    object lblAmpl: TLabel
      Left = 12
      Top = 48
      Width = 45
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Amplitude'
    end
    object edFreq: TEdit
      Left = 96
      Top = 22
      Width = 91
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
      Text = '1000'
    end
    object edAmpl: TEdit
      Left = 96
      Top = 46
      Width = 91
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = '0.8'
    end
  end
end

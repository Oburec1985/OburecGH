object Form1: TForm1
  Left = 240
  Top = 118
  Width = 297
  Height = 147
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 128
    Top = 86
    Width = 37
    Height = 13
    Caption = 'Status'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblTime: TLabel
    Left = 0
    Top = 0
    Width = 289
    Height = 33
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoBk
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 273
    Height = 33
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'XNetDetect performs its action in a separate thread which can be' +
      ' seen as the user interface is not freezing'
    WordWrap = True
  end
  object btnActivate: TButton
    Left = 8
    Top = 80
    Width = 57
    Height = 25
    Hint = 'Monitor'
    Caption = 'Start'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = btnActivateClick
  end
  object tmrClock: TTimer
    Interval = 200
    OnTimer = tmrClockTimer
    Left = 224
  end
  object XNetDetect: TXNetDetect
    Enabled = False
    TimeOut = 500
    Interval = 3000
    Url = 'http://www.guimp.com/'
    OnConnectionStatusChanged = XNetDetectConnectionStatusChanged
    OnConnectionStatus = XNetDetectConnectionStatus
    Left = 256
  end
end

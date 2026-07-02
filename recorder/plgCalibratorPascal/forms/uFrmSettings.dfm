object FrmSettings: TFrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Настройки калибратора Elmetra Pascal'
  ClientHeight = 350
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PortLabel: TLabel
    Left = 24
    Top = 24
    Width = 57
    Height = 13
    Caption = 'COM-порт:'
  end
  object BaudLabel: TLabel
    Left = 24
    Top = 64
    Width = 52
    Height = 13
    Caption = 'Скорость:'
  end
  object ParityLabel: TLabel
    Left = 24
    Top = 104
    Width = 52
    Height = 13
    Caption = 'Четность:'
  end
  object IntervalLabel: TLabel
    Left = 24
    Top = 144
    Width = 99
    Height = 13
    Caption = 'Период опроса, мс:'
  end
  object InputTagLabel: TLabel
    Left = 24
    Top = 184
    Width = 79
    Height = 13
    Caption = 'Тег для чтения:'
  end
  object InputCommandLabel: TLabel
    Left = 24
    Top = 224
    Width = 83
    Height = 13
    Caption = 'Команда чтения:'
  end
  object OutputTagLabel: TLabel
    Left = 24
    Top = 264
    Width = 78
    Height = 13
    Caption = 'Тег для записи:'
  end
  object Bevel1: TBevel
    Left = 16
    Top = 300
    Width = 368
    Height = 2
  end
  object PortCombo: TComboBox
    Left = 160
    Top = 21
    Width = 210
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    Items.Strings = (
      'COM1'
      'COM2'
      'COM3'
      'COM4'
      'COM5'
      'COM6'
      'COM7'
      'COM8'
      'COM9'
      'COM10'
      'COM11'
      'COM12'
      'COM13'
      'COM14'
      'COM15'
      'COM16')
  end
  object BaudCombo: TComboBox
    Left = 160
    Top = 61
    Width = 210
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Items.Strings = (
      '9600'
      '19200'
      '38400'
      '57600'
      '115200')
  end
  object ParityCombo: TComboBox
    Left = 160
    Top = 101
    Width = 210
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    Items.Strings = (
      'None'
      'Odd'
      'Even')
  end
  object IntervalEdit: TEdit
    Left = 160
    Top = 141
    Width = 210
    Height = 21
    TabOrder = 3
  end
  object InputTagEdit: TEdit
    Left = 160
    Top = 181
    Width = 210
    Height = 21
    TabOrder = 4
  end
  object InputCommandEdit: TEdit
    Left = 160
    Top = 221
    Width = 210
    Height = 21
    TabOrder = 5
  end
  object OutputTagEdit: TEdit
    Left = 160
    Top = 261
    Width = 210
    Height = 21
    TabOrder = 6
  end
  object OkBtn: TButton
    Left = 214
    Top = 312
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 7
    OnClick = OkBtnClick
  end
  object CancelBtn: TButton
    Left = 295
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 8
  end
end
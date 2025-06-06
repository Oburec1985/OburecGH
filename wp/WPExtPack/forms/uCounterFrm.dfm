object CounterFrm: TCounterFrm
  Left = 0
  Top = 0
  Caption = 'Counter config'
  ClientHeight = 481
  ClientWidth = 581
  Color = clBtnFace
  Constraints.MinWidth = 546
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 18
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 18
  object ThresholdLabel1: TLabel
    Left = 10
    Top = 21
    Width = 59
    Height = 18
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Hi, lvl, %'
  end
  object ThresholdLabel2: TLabel
    Left = 10
    Top = 109
    Width = 62
    Height = 18
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Lo, lvl, %'
  end
  object Label3: TLabel
    Left = 9
    Top = 218
    Width = 76
    Height = 18
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Portion, sec'
  end
  object HiSE: TFloatSpinEdit
    Left = 10
    Top = 45
    Width = 156
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Increment = 0.100000000000000000
    TabOrder = 0
    Value = 70.000000000000000000
  end
  object LoSE: TFloatSpinEdit
    Left = 10
    Top = 134
    Width = 156
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Increment = 0.100000000000000000
    TabOrder = 1
    Value = 30.000000000000000000
  end
  object GroupBox1: TGroupBox
    Left = 233
    Top = 0
    Width = 348
    Height = 400
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Caption = 'Signals'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object SignalsLV: TBtnListView
      Left = 2
      Top = 19
      Width = 344
      Height = 327
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = 'Signal'
          Width = 64
        end
        item
          Caption = 'Fs'
          Width = 64
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = SignalsLBClick
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
    object Panel2: TPanel
      Left = 2
      Top = 346
      Width = 344
      Height = 52
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      TabOrder = 1
      DesignSize = (
        344
        52)
      object Button1: TButton
        Left = 418
        Top = 8
        Width = 96
        Height = 32
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akTop, akRight]
        Caption = 'Apply'
        ModalResult = 1
        TabOrder = 0
      end
      object SearchSignal: TEdit
        Left = 0
        Top = 8
        Width = 258
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 1
        OnChange = SearchSignalChange
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 400
    Width = 581
    Height = 81
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      581
      81)
    object Label1: TLabel
      Left = 14
      Top = 18
      Width = 50
      Height = 18
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'T1, sec'
    end
    object Label2: TLabel
      Left = 174
      Top = 18
      Width = 50
      Height = 18
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'T2, sec'
    end
    object T1Se: TFloatSpinEdit
      Left = 10
      Top = 44
      Width = 156
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 30.000000000000000000
      OnChange = T2SeChange
    end
    object T2Se: TFloatSpinEdit
      Left = 174
      Top = 44
      Width = 155
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 1
      Value = 30.000000000000000000
      OnChange = T2SeChange
    end
    object EvalBtn: TButton
      Left = 462
      Top = 39
      Width = 96
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = 'Apply'
      ModalResult = 1
      TabOrder = 2
      OnClick = ApplyBtnClick
    end
    object AllTestBtn: TButton
      Left = 337
      Top = 8
      Width = 96
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'AllTest'
      TabOrder = 3
      OnClick = AllTestBtnClick
    end
    object CursorsBtn: TButton
      Left = 337
      Top = 48
      Width = 96
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Cursors'
      TabOrder = 4
      OnClick = CursorsBtnClick
    end
  end
  object FilterTrendCB: TCheckBox
    Left = 10
    Top = 192
    Width = 175
    Height = 17
    Caption = 'Filter trend'
    TabOrder = 4
  end
  object PortionSE: TFloatSpinEdit
    Left = 9
    Top = 243
    Width = 156
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Increment = 0.100000000000000000
    TabOrder = 5
    Value = 1.000000000000000000
  end
end

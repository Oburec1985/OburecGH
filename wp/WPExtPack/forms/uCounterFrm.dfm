object CounterFrm: TCounterFrm
  Left = 0
  Top = 0
  Caption = 'Counter config'
  ClientHeight = 374
  ClientWidth = 452
  Color = clBtnFace
  Constraints.MinWidth = 425
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 14
  object ThresholdLabel1: TLabel
    Left = 8
    Top = 16
    Width = 48
    Height = 14
    Caption = 'Hi, lvl, %'
  end
  object ThresholdLabel2: TLabel
    Left = 8
    Top = 85
    Width = 51
    Height = 14
    Caption = 'Lo, lvl, %'
  end
  object HiSE: TFloatSpinEdit
    Left = 8
    Top = 35
    Width = 121
    Height = 23
    Increment = 0.100000000000000000
    TabOrder = 0
    Value = 70.000000000000000000
  end
  object LoSE: TFloatSpinEdit
    Left = 8
    Top = 104
    Width = 121
    Height = 23
    Increment = 0.100000000000000000
    TabOrder = 1
    Value = 30.000000000000000000
  end
  object GroupBox1: TGroupBox
    Left = 181
    Top = 0
    Width = 271
    Height = 311
    Align = alRight
    Caption = 'Signals'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 14
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitLeft = 138
    ExplicitHeight = 261
    object SignalsLV: TBtnListView
      Left = 2
      Top = 16
      Width = 267
      Height = 252
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = 'Signal'
        end
        item
          Caption = 'Fs'
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
      ExplicitHeight = 202
    end
    object Panel2: TPanel
      Left = 2
      Top = 268
      Width = 267
      Height = 41
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 218
      DesignSize = (
        267
        41)
      object Button1: TButton
        Left = 324
        Top = 6
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Apply'
        ModalResult = 1
        TabOrder = 0
      end
      object SearchSignal: TEdit
        Left = 0
        Top = 6
        Width = 201
        Height = 22
        TabOrder = 1
        OnChange = SearchSignalChange
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 311
    Width = 452
    Height = 63
    Align = alBottom
    TabOrder = 3
    ExplicitTop = 301
    DesignSize = (
      452
      63)
    object Label1: TLabel
      Left = 11
      Top = 14
      Width = 41
      Height = 14
      Caption = 'T1, sec'
    end
    object Label2: TLabel
      Left = 135
      Top = 14
      Width = 41
      Height = 14
      Caption = 'T2, sec'
    end
    object T1Se: TFloatSpinEdit
      Left = 8
      Top = 34
      Width = 121
      Height = 23
      Increment = 0.100000000000000000
      TabOrder = 0
      Value = 30.000000000000000000
      OnChange = T2SeChange
    end
    object T2Se: TFloatSpinEdit
      Left = 135
      Top = 34
      Width = 121
      Height = 23
      Increment = 0.100000000000000000
      TabOrder = 1
      Value = 30.000000000000000000
      OnChange = T2SeChange
    end
    object EvalBtn: TButton
      Left = 359
      Top = 30
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Apply'
      ModalResult = 1
      TabOrder = 2
      OnClick = ApplyBtnClick
      ExplicitLeft = 501
    end
    object AllTestBtn: TButton
      Left = 262
      Top = 6
      Width = 75
      Height = 25
      Caption = 'AllTest'
      TabOrder = 3
      OnClick = AllTestBtnClick
    end
    object CursorsBtn: TButton
      Left = 262
      Top = 37
      Width = 75
      Height = 25
      Caption = 'Cursors'
      TabOrder = 4
      OnClick = CursorsBtnClick
    end
  end
end

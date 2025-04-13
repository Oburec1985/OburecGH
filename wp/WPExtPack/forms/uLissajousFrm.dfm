object LissajousFrm: TLissajousFrm
  Left = 0
  Top = 0
  Caption = 'LissajousFrm'
  ClientHeight = 432
  ClientWidth = 712
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object RightGB: TGroupBox
    Left = 513
    Top = 0
    Width = 199
    Height = 432
    Align = alRight
    Caption = 'RightGB'
    TabOrder = 0
    ExplicitLeft = 518
    object pNumLabel: TLabel
      Left = 10
      Top = 20
      Width = 37
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1055#1086#1088#1094#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 116
      Top = 67
      Width = 6
      Height = 13
      Caption = 'X'
    end
    object Label2: TLabel
      Left = 116
      Top = 98
      Width = 6
      Height = 13
      Caption = 'Y'
    end
    object F1Label: TLabel
      Left = 10
      Top = 129
      Width = 33
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Axis X:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 95
      Top = 129
      Width = 33
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Axis Y:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 10
      Top = 203
      Width = 40
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1080#1075#1085#1072#1083':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 95
      Top = 20
      Width = 30
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1088#1077#1084#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object XCb: TComboBox
      Left = 10
      Top = 65
      Width = 100
      Height = 21
      TabOrder = 0
      Text = 'XCb'
      OnDragDrop = YCbDragDrop
      OnDragOver = XCbDragOver
    end
    object YCb: TComboBox
      Left = 10
      Top = 95
      Width = 100
      Height = 21
      TabOrder = 1
      Text = 'ComboBox1'
      OnDragDrop = YCbDragDrop
      OnDragOver = XCbDragOver
    end
    object Xmaxfe: TFloatSpinEdit
      Left = 11
      Top = 175
      Width = 78
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 2
    end
    object YmaxFe: TFloatSpinEdit
      Left = 95
      Top = 175
      Width = 78
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 3
    end
    object Edit1: TEdit
      Left = 11
      Top = 221
      Width = 174
      Height = 21
      TabOrder = 4
      Text = 'Edit1'
    end
    object SigLV: TBtnListView
      Left = 2
      Top = 272
      Width = 195
      Height = 158
      Align = alBottom
      Columns = <
        item
          Caption = #1057#1080#1075#1085#1072#1083
        end
        item
          Caption = 'Fs'
        end>
      DragMode = dmAutomatic
      RowSelect = True
      TabOrder = 5
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
    object pCount: TIntEdit
      Left = 10
      Top = 38
      Width = 73
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      Text = '512'
    end
    object xminfe: TFloatSpinEdit
      Left = 10
      Top = 147
      Width = 79
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 7
    end
    object YminFe: TFloatSpinEdit
      Left = 95
      Top = 147
      Width = 79
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 8
    end
    object StartFe: TFloatEdit
      Left = 96
      Top = 38
      Width = 73
      Height = 21
      TabOrder = 9
      Text = '0.0'
    end
    object OkBtn: TButton
      Left = 175
      Top = 36
      Width = 21
      Height = 25
      Caption = '...'
      TabOrder = 10
      OnClick = OkBtnClick
    end
  end
  object Chart: cChart
    Left = 0
    Top = 0
    Width = 513
    Height = 432
    Cursor = crSizeAll
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Caption = 'Chart'
    TabOrder = 1
    allowEditPages = False
    showTV = False
    showLegend = True
    selectSize = 5
  end
end

object LissajousFrm: TLissajousFrm
  Left = 0
  Top = 0
  Caption = 'LissajousFrm'
  ClientHeight = 741
  ClientWidth = 970
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 500
    Top = 0
    Height = 741
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Color = clBtnText
    ParentColor = False
  end
  object RightGB: TGroupBox
    Left = 710
    Top = 0
    Width = 260
    Height = 741
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Caption = 'RightGB'
    TabOrder = 0
    object pNumLabel: TLabel
      Left = 13
      Top = 26
      Width = 51
      Height = 18
      Caption = #1055#1086#1088#1094#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 152
      Top = 88
      Width = 8
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'X'
    end
    object Label2: TLabel
      Left = 152
      Top = 128
      Width = 8
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Y'
    end
    object F1Label: TLabel
      Left = 13
      Top = 184
      Width = 45
      Height = 18
      Caption = 'Axis X:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 124
      Top = 184
      Width = 46
      Height = 18
      Caption = 'Axis Y:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 140
      Top = 326
      Width = 43
      Height = 18
      Caption = #1042#1088#1077#1084#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 10
      Top = 326
      Width = 107
      Height = 18
      Caption = #1048#1085#1082#1088#1077#1084#1077#1085#1090', '#1089#1077#1082
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 5
      Top = 399
      Width = 60
      Height = 18
      Caption = #1044#1080#1072#1084#1077#1090#1088
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object XCb: TComboBox
      Left = 13
      Top = 85
      Width = 131
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 0
      Text = 'XCb'
      OnDragDrop = YCbDragDrop
      OnDragOver = XCbDragOver
    end
    object YCb: TComboBox
      Left = 13
      Top = 124
      Width = 131
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 1
      Text = 'ComboBox1'
      OnDragDrop = YCbDragDrop
      OnDragOver = XCbDragOver
    end
    object Xmaxfe: TFloatSpinEdit
      Left = 14
      Top = 245
      Width = 102
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 2
      OnKeyDown = YmaxFeKeyDown
    end
    object YmaxFe: TFloatSpinEdit
      Left = 124
      Top = 245
      Width = 102
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 3
      OnKeyDown = YmaxFeKeyDown
    end
    object SigLV: TBtnListView
      Left = 2
      Top = 532
      Width = 256
      Height = 207
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      Columns = <
        item
          Caption = #1057#1080#1075#1085#1072#1083
          Width = 65
        end
        item
          Caption = 'Fs'
          Width = 65
        end>
      DragMode = dmAutomatic
      RowSelect = True
      TabOrder = 4
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
    object pCount: TIntEdit
      Left = 13
      Top = 50
      Width = 96
      Height = 26
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      Text = '512'
    end
    object xminfe: TFloatSpinEdit
      Left = 13
      Top = 208
      Width = 103
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 6
      OnKeyDown = YminFeKeyDown
    end
    object YminFe: TFloatSpinEdit
      Left = 124
      Top = 208
      Width = 104
      Height = 27
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 0.100000000000000000
      TabOrder = 7
      OnKeyDown = YminFeKeyDown
    end
    object StartFe: TFloatEdit
      Left = 143
      Top = 350
      Width = 94
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 8
      Text = '0.0'
    end
    object OkBtn: TButton
      Left = 143
      Top = 286
      Width = 26
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = '...'
      TabOrder = 9
      OnClick = OkBtnClick
    end
    object AutoCB: TCheckBox
      Left = 13
      Top = 297
      Width = 97
      Height = 17
      Caption = #1072#1074#1090#1086#1088#1072#1089#1095#1077#1090
      TabOrder = 10
    end
    object Panel1: TPanel
      Left = 2
      Top = 472
      Width = 256
      Height = 60
      Align = alBottom
      TabOrder = 11
      object Label4: TLabel
        Left = 4
        Top = 7
        Width = 52
        Height = 18
        Caption = #1057#1080#1075#1085#1072#1083':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object SearchEdit: TEdit
        Left = 3
        Top = 31
        Width = 228
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
        OnChange = SearchEditChange
      end
    end
    object IncFe: TFloatEdit
      Left = 7
      Top = 349
      Width = 95
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 12
      Text = '10'
    end
    object DistFe: TFloatEdit
      Left = 7
      Top = 422
      Width = 95
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 13
      Text = '10'
    end
  end
  object Chart: cChart
    Left = 0
    Top = 0
    Width = 500
    Height = 741
    Cursor = crSizeAll
    Align = alClient
    Caption = 'Chart'
    TabOrder = 1
    allowEditPages = False
    showTV = False
    showLegend = True
    selectSize = 5
  end
  object GraphLV: TBtnListView
    Left = 503
    Top = 0
    Width = 207
    Height = 741
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Columns = <
      item
        Caption = #8470
        Width = 65
      end
      item
        Caption = 'Sx'
        Width = 65
      end
      item
        Caption = 'Sy'
        Width = 65
      end>
    DragMode = dmAutomatic
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnDragDrop = GraphLVDragDrop
    OnDragOver = GraphLVDragOver
    OnKeyDown = GraphLVKeyDown
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
  object Timer1: TTimer
    Interval = 300
    OnTimer = Timer1Timer
    Left = 680
  end
end

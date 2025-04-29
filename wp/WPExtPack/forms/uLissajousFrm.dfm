object LissajousFrm: TLissajousFrm
  Left = 0
  Top = 0
  Caption = 'LissajousFrm'
  ClientHeight = 567
  ClientWidth = 742
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
  object Splitter1: TSplitter
    Left = 382
    Top = 0
    Height = 567
    Align = alRight
    Color = clBtnText
    ParentColor = False
    ExplicitLeft = 360
    ExplicitTop = 192
    ExplicitHeight = 100
  end
  object RightGB: TGroupBox
    Left = 543
    Top = 0
    Width = 199
    Height = 567
    Align = alRight
    Caption = 'RightGB'
    TabOrder = 0
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
      Top = 141
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
      Top = 141
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
    object Label5: TLabel
      Left = 107
      Top = 249
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
    object Label6: TLabel
      Left = 8
      Top = 249
      Width = 79
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1085#1082#1088#1077#1084#1077#1085#1090', '#1089#1077#1082
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 4
      Top = 305
      Width = 44
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1080#1072#1084#1077#1090#1088
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
      Top = 187
      Width = 78
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 2
      OnKeyDown = YmaxFeKeyDown
    end
    object YmaxFe: TFloatSpinEdit
      Left = 95
      Top = 187
      Width = 78
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 3
      OnKeyDown = YmaxFeKeyDown
    end
    object SigLV: TBtnListView
      Left = 2
      Top = 407
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
      TabOrder = 5
      Text = '512'
    end
    object xminfe: TFloatSpinEdit
      Left = 10
      Top = 159
      Width = 79
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 6
      OnKeyDown = YminFeKeyDown
    end
    object YminFe: TFloatSpinEdit
      Left = 95
      Top = 159
      Width = 79
      Height = 22
      Increment = 0.100000000000000000
      TabOrder = 7
      OnKeyDown = YminFeKeyDown
    end
    object StartFe: TFloatEdit
      Left = 109
      Top = 268
      Width = 72
      Height = 21
      TabOrder = 8
      Text = '0.0'
    end
    object OkBtn: TButton
      Left = 109
      Top = 219
      Width = 20
      Height = 25
      Caption = '...'
      TabOrder = 9
      OnClick = OkBtnClick
    end
    object AutoCB: TCheckBox
      Left = 10
      Top = 227
      Width = 74
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1072#1074#1090#1086#1088#1072#1089#1095#1077#1090
      TabOrder = 10
    end
    object Panel1: TPanel
      Left = 2
      Top = 361
      Width = 195
      Height = 46
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alBottom
      TabOrder = 11
      object Label4: TLabel
        Left = 3
        Top = 5
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
      object SearchEdit: TEdit
        Left = 2
        Top = 24
        Width = 175
        Height = 21
        TabOrder = 0
        OnChange = SearchEditChange
      end
    end
    object IncFe: TFloatEdit
      Left = 5
      Top = 267
      Width = 73
      Height = 21
      TabOrder = 12
      Text = '10'
    end
    object DistFe: TFloatEdit
      Left = 5
      Top = 323
      Width = 73
      Height = 21
      TabOrder = 13
      Text = '10'
    end
  end
  object Chart: cChart
    Left = 0
    Top = 0
    Width = 382
    Height = 567
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
    ExplicitWidth = 385
  end
  object GraphLV: TBtnListView
    Left = 385
    Top = 0
    Width = 158
    Height = 567
    Align = alRight
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = 'Sx'
      end
      item
        Caption = 'Sy'
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
    ExplicitLeft = 384
  end
  object Timer1: TTimer
    Interval = 300
    OnTimer = Timer1Timer
    Left = 680
  end
end

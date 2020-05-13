object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'ME-415'
  ClientHeight = 442
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 17
    Width = 111
    Height = 16
    Caption = #1053#1086#1084#1077#1088' COM '#1087#1086#1088#1090#1072':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 79
    Width = 104
    Height = 16
    Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 267
    Width = 49
    Height = 18
    Caption = #1050#1072#1085#1072#1083#1099':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 208
    Top = 79
    Width = 40
    Height = 16
    Caption = #1040#1076#1088#1077#1089':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 8
    Top = 141
    Width = 53
    Height = 16
    Caption = #1060#1053#1063', '#1043#1094':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 8
    Top = 197
    Width = 144
    Height = 16
    Caption = #1055#1086#1088#1086#1075#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077', '#1084#1042
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 208
    Top = 197
    Width = 70
    Height = 16
    Caption = #1042#1099#1093#1086#1076' '#1062#1040#1055':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 44
    Width = 177
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    ParentFont = False
    TabOrder = 0
    Text = 'COM1'
    Items.Strings = (
      'COM1')
  end
  object Edit1: TEdit
    Left = 8
    Top = 101
    Width = 177
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '1'
  end
  object Button1: TButton
    Left = 208
    Top = 44
    Width = 153
    Height = 25
    Caption = #1053#1072#1081#1090#1080
    TabOrder = 2
  end
  object Num: TBtnListView
    Left = 0
    Top = 297
    Width = 389
    Height = 145
    Align = alBottom
    Columns = <
      item
        Caption = #8470' '#1050#1072#1085#1072#1083#1072
      end
      item
        Caption = #1040#1076#1088#1077#1089
      end
      item
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      end>
    Items.ItemData = {
      03100200000800000000000000FFFFFFFFFFFFFFFF02000000FFFFFFFF000000
      000131000331002D0031000D3500300020003C0412042F002000310030002000
      3A041304460400000000FFFFFFFFFFFFFFFF02000000FFFFFFFF000000000132
      000331002D0032000D3500300020003C0412042F0020003100300020003A0413
      04460400000000FFFFFFFFFFFFFFFF02000000FFFFFFFF000000000133000331
      002D0033000D3500300020003C0412042F0020003100300020003A0413044604
      00000000FFFFFFFFFFFFFFFF02000000FFFFFFFF000000000134000331002D00
      34000D3500300020003C0412042F0020003100300020003A0413044604000000
      00FFFFFFFFFFFFFFFF02000000FFFFFFFF000000000135000331002D0035000D
      3500300020003C0412042F0020003100300020003A041304460400000000FFFF
      FFFFFFFFFFFF02000000FFFFFFFF000000000136000331002D0036000D350030
      0020003C0412042F0020003100300020003A041304460400000000FFFFFFFFFF
      FFFFFF02000000FFFFFFFF000000000137000331002D0037000D350030002000
      3C0412042F0020003100300020003A041304460400000000FFFFFFFFFFFFFFFF
      02000000FFFFFFFF000000000138000331002D0038000D3500300020003C0412
      042F0020003100300020003A0413044604FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ExplicitTop = 368
  end
  object Edit2: TEdit
    Left = 208
    Top = 101
    Width = 153
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Text = '1'
  end
  object ComboBox2: TComboBox
    Left = 8
    Top = 164
    Width = 177
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    ParentFont = False
    TabOrder = 5
    Text = '10000'
    Items.Strings = (
      '10000')
  end
  object ComboBox3: TComboBox
    Left = 8
    Top = 220
    Width = 177
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    ParentFont = False
    TabOrder = 6
    Text = '50'
    Items.Strings = (
      '50')
  end
  object ComboBox4: TComboBox
    Left = 208
    Top = 220
    Width = 153
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    ParentFont = False
    TabOrder = 7
    Text = #1042#1093#1086#1076
    Items.Strings = (
      #1042#1093#1086#1076)
  end
end

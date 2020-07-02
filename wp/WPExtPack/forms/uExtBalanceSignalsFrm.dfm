object BalanceZeroFrm: TBalanceZeroFrm
  Left = 0
  Top = 0
  Caption = #1041#1072#1083#1072#1085#1089#1080#1088#1086#1074#1082#1072' '#1085#1091#1083#1103
  ClientHeight = 528
  ClientWidth = 667
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 375
    Height = 528
    Align = alClient
    TabOrder = 0
    object ChannelsLV: TBtnListView
      Left = 1
      Top = 1
      Width = 373
      Height = 526
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = #1048#1084#1103
          Width = 51
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
  object Panel2: TPanel
    Left = 375
    Top = 0
    Width = 292
    Height = 528
    Align = alRight
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 4
      Width = 43
      Height = 16
      Caption = #1053#1072#1095#1072#1083#1086
    end
    object Label2: TLabel
      Left = 143
      Top = 29
      Width = 23
      Height = 16
      Caption = ','#1089#1077#1082
    end
    object Label4: TLabel
      Left = 16
      Top = 52
      Width = 35
      Height = 16
      Caption = #1050#1086#1085#1077#1094
    end
    object Label5: TLabel
      Left = 143
      Top = 77
      Width = 23
      Height = 16
      Caption = ','#1089#1077#1082
    end
    object Label3: TLabel
      Left = 16
      Top = 147
      Width = 98
      Height = 16
      Caption = #1057#1087#1080#1089#1086#1082' '#1089#1080#1075#1085#1072#1083#1086#1074
    end
    object BeginFE: TFloatEdit
      Left = 16
      Top = 27
      Width = 121
      Height = 24
      TabOrder = 0
      Text = '0.0'
    end
    object EndFE: TFloatEdit
      Left = 16
      Top = 75
      Width = 121
      Height = 24
      TabOrder = 1
      Text = '0.0'
    end
    object PathEdit: TEdit
      Left = 16
      Top = 168
      Width = 257
      Height = 24
      TabOrder = 2
      Text = 'PathEdit'
      OnChange = PathEditChange
    end
    object SaveBtn: TButton
      Left = 16
      Top = 216
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 3
      OnClick = SaveBtnClick
    end
    object LoadBtn: TButton
      Left = 112
      Top = 216
      Width = 75
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 4
      OnClick = LoadBtnClick
    end
    object ApplyBtn: TButton
      Left = 16
      Top = 419
      Width = 75
      Height = 25
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 5
      OnClick = ApplyBtnClick
    end
  end
end

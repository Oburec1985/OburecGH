inherited MDBRegObjFrame: TMDBRegObjFrame
  Height = 263
  inherited PathEdit: TEdit
    ExplicitWidth = 412
  end
  inherited DscEdit: TEdit
    ExplicitWidth = 412
  end
  inherited Panel1: TPanel
    Top = 199
    Height = 64
    ExplicitTop = 272
    ExplicitWidth = 451
    ExplicitHeight = 64
    object TestDateLabel: TLabel
      Left = 19
      Top = 6
      Width = 106
      Height = 16
      Caption = #1044#1072#1090#1072' '#1088#1077#1075#1080#1089#1090#1088#1072#1094#1080#1080
    end
    object TestDate: TDateTimePicker
      Left = 19
      Top = 32
      Width = 186
      Height = 24
      Date = 43134.961182476850000000
      Time = 43134.961182476850000000
      Enabled = False
      TabOrder = 0
    end
  end
  object RegistratorLV: TBtnListView
    Left = 0
    Top = 119
    Width = 451
    Height = 80
    Align = alBottom
    Columns = <
      item
        Caption = #1056#1077#1075#1080#1089#1090#1088#1072#1090#1086#1088
      end
      item
        Caption = #1047#1072#1084#1077#1088
      end>
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    Editable = False
    ExplicitTop = 192
  end
end

inherited MDBTestObjFrame: TMDBTestObjFrame
  ExplicitWidth = 313
  ExplicitHeight = 209
  inherited PathEdit: TEdit
    Width = 274
    ExplicitWidth = 274
  end
  inherited DscEdit: TEdit
    Width = 274
    ExplicitWidth = 274
  end
  inherited Panel1: TPanel
    Top = 102
    Width = 313
    Height = 123
    ExplicitTop = 102
    ExplicitWidth = 345
    ExplicitHeight = 123
    object TestTypeLabel: TLabel
      Left = 19
      Top = 10
      Width = 80
      Height = 13
      Caption = #1058#1080#1087' '#1080#1089#1087#1099#1090#1072#1085#1080#1103':'
    end
    object TestDateLabel: TLabel
      Left = 19
      Top = 62
      Width = 84
      Height = 13
      Caption = #1044#1072#1090#1072' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    end
    object TestTypeCB: TComboBox
      Left = 19
      Top = 32
      Width = 276
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object TestDate: TDateTimePicker
      Left = 19
      Top = 88
      Width = 186
      Height = 24
      Date = 43134.961182476850000000
      Time = 43134.961182476850000000
      Enabled = False
      TabOrder = 1
    end
  end
end

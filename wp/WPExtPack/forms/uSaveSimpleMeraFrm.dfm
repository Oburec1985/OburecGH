object SaveSimpleMeraFrm: TSaveSimpleMeraFrm
  Left = 0
  Top = 0
  Caption = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1091#1087#1088#1086#1097#1077#1085#1085#1086#1075#1086' Mera '#1092#1072#1081#1083#1072
  ClientHeight = 426
  ClientWidth = 752
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 752
    Height = 361
    Align = alTop
    TabOrder = 0
    inline WPNameFltFrame1: TWPNameFltFrame
      Left = 1
      Top = 1
      Width = 750
      Height = 359
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 750
      ExplicitHeight = 359
      inherited NamesLB: TListBox
        Height = 359
        ExplicitHeight = 359
      end
      inherited Panel1: TPanel
        Width = 477
        Height = 359
        ExplicitWidth = 477
        ExplicitHeight = 359
        inherited PropList: TBtnListView
          Width = 475
          Height = 173
          ExplicitWidth = 475
          ExplicitHeight = 173
        end
        inherited Panel2: TPanel
          Width = 475
          ExplicitWidth = 475
          inherited NameFlt: TEdit
            Width = 454
            ExplicitWidth = 454
          end
          inherited NameFltCB: TCheckBox
            Width = 188
            ExplicitWidth = 188
          end
          inherited DscFltCB: TCheckBox
            Width = 202
            ExplicitWidth = 202
          end
          inherited DscFlt: TEdit
            Width = 454
            ExplicitWidth = 454
          end
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 367
    Width = 752
    Height = 59
    Align = alBottom
    TabOrder = 1
    object CancelBtn: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 662
      Top = 16
      Width = 84
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end

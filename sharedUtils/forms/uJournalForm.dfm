object JournalForm: TJournalForm
  Left = 0
  Top = 0
  Caption = #1046#1091#1088#1085#1072#1083
  ClientHeight = 626
  ClientWidth = 711
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LogGB: TGroupBox
    Left = 0
    Top = 0
    Width = 711
    Height = 626
    Align = alClient
    TabOrder = 0
    inline LogFrame1: TLogFrame
      Left = 2
      Top = 15
      Width = 707
      Height = 609
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 707
      ExplicitHeight = 609
      inherited ControlGB: TGroupBox
        Top = 569
        Width = 707
        ExplicitTop = 569
        ExplicitWidth = 707
        DesignSize = (
          707
          40)
        inherited FilterLabel: TLabel
          Left = 537
          ExplicitLeft = 306
        end
        inherited FilterCB: TComboBox
          Left = 591
          ExplicitLeft = 591
        end
      end
      inherited LogSg: TStringGrid
        Width = 707
        Height = 569
        Font.Height = -16
        ParentFont = False
        ExplicitWidth = 707
        ExplicitHeight = 569
      end
    end
  end
end

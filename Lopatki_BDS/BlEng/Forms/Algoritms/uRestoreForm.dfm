object RestoreForm: TRestoreForm
  Left = 0
  Top = 0
  Caption = #1042#1086#1089#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1080#1075#1085#1072#1083
  ClientHeight = 487
  ClientWidth = 749
  Color = clBtnFace
  Constraints.MinHeight = 486
  Constraints.MinWidth = 757
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StageGb: TGroupBox
    Left = 0
    Top = 0
    Width = 749
    Height = 329
    Align = alTop
    Caption = #1057#1090#1091#1087#1077#1085#1100
    TabOrder = 0
    ExplicitWidth = 791
    inline StageFrame1: TStageFrame
      Left = 2
      Top = 15
      Width = 745
      Height = 312
      Align = alClient
      Constraints.MinWidth = 265
      TabOrder = 0
      TabStop = True
      Visible = False
      ExplicitLeft = 136
      ExplicitTop = 7
      ExplicitWidth = 787
      ExplicitHeight = 312
      inherited StageGB: TGroupBox
        Width = 745
        Height = 312
        ExplicitWidth = 791
        ExplicitHeight = 447
        inherited Splitter1: TSplitter
          Left = 403
          Height = 295
          ExplicitLeft = 449
          ExplicitHeight = 430
        end
        inherited Splitter2: TSplitter
          Left = 249
          Height = 295
          ExplicitLeft = 295
          ExplicitHeight = 430
        end
        inherited SensorsGB: TGroupBox
          Left = 408
          Height = 295
          ExplicitLeft = 454
          ExplicitHeight = 430
          inherited SensorsSG: TStringGrid
            Height = 278
            ExplicitHeight = 413
          end
        end
        inherited BladesGB: TGroupBox
          Left = 101
          Height = 295
          ExplicitLeft = 147
          ExplicitHeight = 430
          inherited BladesLV: TBtnListView
            Height = 278
            ExplicitHeight = 413
          end
        end
        inherited ShapeGB: TGroupBox
          Left = 254
          Height = 295
          ExplicitLeft = 300
          ExplicitHeight = 430
          inherited ShapeLV: TBtnListView
            Height = 278
            ExplicitHeight = 413
          end
        end
      end
    end
  end
  object AlgOptsGB: TGroupBox
    Left = 0
    Top = 329
    Width = 749
    Height = 158
    Align = alClient
    Caption = #1054#1087#1094#1080#1080' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
    TabOrder = 1
    ExplicitLeft = 216
    ExplicitTop = 384
    ExplicitWidth = 185
    ExplicitHeight = 105
    DesignSize = (
      749
      158)
    object StageLabel: TLabel
      Left = 8
      Top = 22
      Width = 63
      Height = 13
      Caption = #1048#1084#1103' '#1089#1090#1091#1087#1077#1085#1080
    end
    object OkBtn: TButton
      Left = 663
      Top = 110
      Width = 80
      Height = 32
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitTop = 120
    end
    object CancelBtn: TButton
      Left = 8
      Top = 110
      Width = 75
      Height = 32
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
      ExplicitTop = 120
    end
    object UseBladesPos: TCheckBox
      Left = 8
      Top = 84
      Width = 254
      Height = 17
      Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082'/ '#1089#1084#1077#1097#1077#1085#1080#1103
      TabOrder = 2
    end
    object Edit1: TEdit
      Left = 8
      Top = 41
      Width = 254
      Height = 21
      TabOrder = 3
      Text = 'Edit1'
    end
  end
end

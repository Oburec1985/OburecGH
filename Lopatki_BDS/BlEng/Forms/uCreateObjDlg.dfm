object CreateObjDlg: TCreateObjDlg
  Left = 0
  Top = 0
  Width = 741
  Height = 440
  AutoScroll = True
  Caption = 'CreateObjDlg'
  Color = clBtnFace
  Constraints.MinWidth = 233
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 388
    Top = 0
    Width = 7
    Height = 324
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Color = clGray
    ParentColor = False
    ExplicitHeight = 892
  end
  object SelectObjTypeGB: TGroupBox
    Left = 0
    Top = 0
    Width = 388
    Height = 324
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    Caption = #1042#1099#1073#1086#1088' '#1057#1086#1079#1076#1072#1074#1072#1077#1084#1086#1075#1086' '#1086#1073#1098#1077#1082#1090#1072
    TabOrder = 0
    ExplicitHeight = 653
    object PossibleObjLV: TListBox
      Left = 2
      Top = 19
      Width = 384
      Height = 303
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ItemHeight = 17
      Items.Strings = (
        #1058#1091#1088#1073#1080#1085#1072
        #1057#1090#1091#1087#1077#1085#1100
        #1055#1072#1088#1072' '#1076#1072#1090#1095#1080#1082#1086#1074
        #1044#1072#1090#1095#1080#1082
        #1050#1072#1085#1072#1083' '#1087#1083#1072#1090#1099
        'M2070'
        'M2081')
      TabOrder = 0
      OnClick = PossibleObjLVClick
      ExplicitHeight = 632
    end
  end
  object UserBtnGB: TGroupBox
    Left = 0
    Top = 324
    Width = 723
    Height = 69
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    ExplicitTop = 653
    ExplicitWidth = 702
    DesignSize = (
      723
      69)
    object CancelBtn: TButton
      Left = 4
      Top = 26
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 594
      Top = 22
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  object ObjPropertyGB: TGroupBox
    Left = 395
    Top = 0
    Width = 328
    Height = 324
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = 'ObjPropertyGB'
    TabOrder = 2
    inline CompaundFrame1: TCompaundFrame
      Left = 2
      Top = 19
      Width = 324
      Height = 303
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 19
      ExplicitWidth = 324
      ExplicitHeight = 303
      inherited MainObjSB: TScrollBox
        Width = 324
        Height = 303
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ExplicitWidth = 324
        ExplicitHeight = 303
        inherited Splitter1: TSplitter
          Top = 358
          Width = 299
          Height = 4
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Constraints.MaxHeight = 5
          ExplicitTop = 358
          ExplicitWidth = 526
          ExplicitHeight = 4
        end
        inherited BaseObjPropertyFrame1: TBaseObjPropertyFrame
          Width = 299
          Height = 358
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Constraints.MinHeight = 84
          Constraints.MinWidth = 299
          ExplicitWidth = 299
          ExplicitHeight = 358
          inherited NameLabel: TLabel
            Left = 4
            Width = 82
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitWidth = 82
            ExplicitHeight = 17
          end
          inherited TypeLabel: TLabel
            Left = 199
            Width = 81
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 199
            ExplicitWidth = 81
            ExplicitHeight = 17
          end
          inherited TypeImage: TImage
            Left = 365
            Top = 12
            Width = 42
            Height = 42
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 365
            ExplicitTop = 12
            ExplicitWidth = 42
            ExplicitHeight = 42
          end
          inherited Label1: TLabel
            Left = 4
            Top = 59
            Width = 118
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitTop = 59
            ExplicitWidth = 118
            ExplicitHeight = 17
          end
          inherited NameEdit: TEdit
            Left = 4
            Top = 26
            Width = 158
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitTop = 26
            ExplicitWidth = 158
            ExplicitHeight = 25
          end
          inherited TypeEdit: TEdit
            Left = 199
            Top = 26
            Width = 158
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 199
            ExplicitTop = 26
            ExplicitWidth = 158
            ExplicitHeight = 25
          end
          inherited AddFieldBtn: TButton
            Left = 418
            Top = 24
            Width = 148
            Height = 32
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 418
            ExplicitTop = 24
            ExplicitWidth = 148
            ExplicitHeight = 32
          end
          inherited DelPropertieBtn: TButton
            Left = 574
            Top = 24
            Width = 148
            Height = 32
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 574
            ExplicitTop = 24
            ExplicitWidth = 148
            ExplicitHeight = 32
          end
          inherited MetaDataLV: TBtnListView
            Left = 4
            Top = 84
            Width = 868
            Height = 418
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitTop = 84
            ExplicitWidth = 868
            ExplicitHeight = 418
          end
        end
        inherited ChanFrame1: TChanFrame
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 266
          inherited CommonGB: TGroupBox
            Width = 299
            Height = 0
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitWidth = 299
            ExplicitHeight = 266
            inherited ImpulsCountLabel: TLabel
              Left = 12
              Top = 31
              Width = 114
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 31
              ExplicitWidth = 114
              ExplicitHeight = 17
            end
            inherited ChanLVLabel: TLabel
              Left = 199
              Top = 31
              Width = 134
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 199
              ExplicitTop = 31
              ExplicitWidth = 134
              ExplicitHeight = 17
            end
            inherited Label3: TLabel
              Left = 12
              Top = 149
              Width = 30
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 149
              ExplicitWidth = 30
              ExplicitHeight = 17
            end
            inherited Label4: TLabel
              Left = 12
              Top = 256
              Width = 35
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 256
              ExplicitWidth = 35
              ExplicitHeight = 17
            end
            inherited OverflowLabel: TLabel
              Left = 12
              Top = 201
              Width = 54
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 201
              ExplicitWidth = 54
              ExplicitHeight = 17
            end
            inherited ImpulsCountIE: TIntEdit
              Left = 12
              Top = 63
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 63
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
            inherited ChanLV: TBtnListView
              Left = 178
              Top = 63
              Width = 260
              Height = 169
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              Columns = <
                item
                  Caption = #8470
                  Width = 65
                end
                item
                  Caption = #1042#1088#1077#1084#1103' '#1074' '#1090#1080#1082#1072#1093
                  Width = 65
                end
                item
                  Caption = #1042#1088#1077#1084#1103', '#1089#1077#1082'.'
                  Width = 65
                end>
              ExplicitLeft = 178
              ExplicitTop = 63
              ExplicitWidth = 260
              ExplicitHeight = 435
            end
            inherited ShowAllCB: TCheckBox
              Left = 12
              Top = 115
              Width = 200
              Height = 22
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 115
              ExplicitWidth = 200
              ExplicitHeight = 22
            end
            inherited TickEdit: TIntEdit
              Left = 12
              Top = 171
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 171
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
            inherited ResIndEdit: TIntEdit
              Left = 12
              Top = 277
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 277
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
            inherited OverflowIE: TIntEdit
              Left = 12
              Top = 224
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 12
              ExplicitTop = 224
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
          end
        end
        inherited SensorFrame1: TSensorFrame
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Constraints.MinWidth = 299
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 0
          inherited SensorsGB: TGroupBox
            Top = -348
            Width = 299
            Height = 348
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitTop = -348
            ExplicitWidth = 299
            ExplicitHeight = 348
            inherited TypeLabel: TLabel
              Left = 7
              Top = 21
              Width = 81
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 7
              ExplicitTop = 21
              ExplicitWidth = 81
              ExplicitHeight = 17
            end
            inherited OffsetLabel: TLabel
              Left = 177
              Top = 21
              Width = 130
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 177
              ExplicitTop = 21
              ExplicitWidth = 130
              ExplicitHeight = 17
            end
            inherited ChunLabel: TLabel
              Left = 319
              Top = 21
              Width = 89
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 319
              ExplicitTop = 21
              ExplicitWidth = 89
              ExplicitHeight = 17
            end
            inherited TickCountLabel: TLabel
              Left = 452
              Top = 24
              Width = 82
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 452
              ExplicitTop = 24
              ExplicitWidth = 82
              ExplicitHeight = 17
            end
            inherited SkipBladesLabel: TLabel
              Left = 585
              Top = 24
              Width = 137
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 585
              ExplicitTop = 24
              ExplicitWidth = 137
              ExplicitHeight = 17
            end
            inherited TahoDivLabel: TLabel
              Left = 452
              Top = 75
              Width = 120
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 452
              ExplicitTop = 75
              ExplicitWidth = 120
              ExplicitHeight = 17
            end
            inherited TypeCB: TComboBox
              Left = 7
              Top = 43
              Width = 162
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 7
              ExplicitTop = 43
              ExplicitWidth = 162
              ExplicitHeight = 25
            end
            inherited OffsetFE: TFloatEdit
              Left = 177
              Top = 43
              Width = 134
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 177
              ExplicitTop = 43
              ExplicitWidth = 134
              ExplicitHeight = 25
            end
            inherited ChunIE: TIntEdit
              Left = 320
              Top = 43
              Width = 123
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 320
              ExplicitTop = 43
              ExplicitWidth = 123
              ExplicitHeight = 25
            end
            inherited StateGB: TGroupBox
              Top = 130
              Width = 295
              Height = 216
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitTop = 130
              ExplicitWidth = 295
              ExplicitHeight = 216
              inherited PairsLVLabel: TLabel
                Left = 174
                Top = 24
                Width = 74
                Height = 17
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 174
                ExplicitTop = 24
                ExplicitWidth = 74
                ExplicitHeight = 17
              end
              inherited StagesLabel: TLabel
                Left = 7
                Top = 24
                Width = 56
                Height = 17
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 7
                ExplicitTop = 24
                ExplicitWidth = 56
                ExplicitHeight = 17
              end
              inherited StageCB: TComboBox
                Left = 4
                Top = 47
                Width = 162
                Height = 25
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 47
                ExplicitWidth = 162
                ExplicitHeight = 25
              end
              inherited PairsListView: TBtnListView
                Left = 174
                Top = 52
                Width = 512
                Height = 160
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                Columns = <
                  item
                    Caption = #8470
                    Width = 65
                  end
                  item
                    Caption = #1048#1084#1103
                    Width = 65
                  end
                  item
                    Caption = #1050#1086#1088'. '#1076#1072#1090'.'
                    Width = 65
                  end
                  item
                    Caption = #1055#1077#1088'. '#1076#1072#1090'.'
                    Width = 65
                  end>
                ExplicitLeft = 174
                ExplicitTop = 52
                ExplicitWidth = 512
                ExplicitHeight = 160
              end
            end
            inherited TickCountIE: TIntEdit
              Left = 452
              Top = 43
              Width = 123
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 452
              ExplicitTop = 43
              ExplicitWidth = 123
              ExplicitHeight = 25
            end
            inherited SkipBladeIE: TIntEdit
              Left = 585
              Top = 43
              Width = 116
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 585
              ExplicitTop = 43
              ExplicitWidth = 116
              ExplicitHeight = 25
            end
            inherited EvalSkipBladesBtn: TButton
              Left = 709
              Top = 41
              Width = 87
              Height = 32
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 709
              ExplicitTop = 41
              ExplicitWidth = 87
              ExplicitHeight = 32
            end
            inherited TahoDivEdit: TEdit
              Left = 452
              Top = 99
              Width = 249
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 452
              ExplicitTop = 99
              ExplicitWidth = 249
              ExplicitHeight = 25
            end
          end
        end
        inherited StageFrame1: TStageFrame
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Constraints.MinWidth = 299
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 0
          inherited StageGB: TGroupBox
            Width = 299
            Height = 0
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitWidth = 299
            ExplicitHeight = 0
            inherited SignalSetupPageControl: TPageControl
              Top = 19
              Width = 295
              Height = 20
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitTop = 19
              ExplicitWidth = 295
              ExplicitHeight = 20
              inherited TabSheet1: TTabSheet
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitTop = 28
                ExplicitWidth = 287
                ExplicitHeight = 10
                inherited Splitter2: TSplitter
                  Left = 413
                  Width = 8
                  Height = 10
                  Margins.Left = 4
                  Margins.Top = 4
                  Margins.Right = 4
                  Margins.Bottom = 4
                  ExplicitLeft = 413
                  ExplicitWidth = 8
                  ExplicitHeight = 443
                end
                inherited BladesGB: TGroupBox
                  Width = 192
                  Height = 10
                  Margins.Left = 4
                  Margins.Top = 4
                  Margins.Right = 4
                  Margins.Bottom = 4
                  ExplicitWidth = 192
                  ExplicitHeight = 213
                  inherited Splitter1: TSplitter
                    Left = 183
                    Top = 19
                    Width = 7
                    Height = 43
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 183
                    ExplicitTop = 20
                    ExplicitWidth = 7
                    ExplicitHeight = 421
                  end
                  inherited BladesLV: TBtnListView
                    Top = 19
                    Width = 181
                    Height = 43
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Columns = <
                      item
                        Caption = #8470
                        Width = 65
                      end
                      item
                        Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
                        Width = 65
                      end>
                    ExplicitTop = 19
                    ExplicitWidth = 181
                    ExplicitHeight = 192
                  end
                end
                inherited ShapeGB: TGroupBox
                  Left = 421
                  Width = 52
                  Height = 10
                  Margins.Left = 4
                  Margins.Top = 4
                  Margins.Right = 4
                  Margins.Bottom = 4
                  ExplicitLeft = 421
                  ExplicitWidth = 89
                  ExplicitHeight = 213
                  inherited ShapeLV: TBtnListView
                    Top = 19
                    Width = 48
                    Height = 43
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Columns = <
                      item
                        Caption = #8470
                        Width = 65
                      end
                      item
                        Caption = #1055#1086#1083#1086#1078'.'
                        Width = 65
                      end>
                    ExplicitTop = 19
                    ExplicitWidth = 85
                    ExplicitHeight = 192
                  end
                end
                inherited StagePropertysGB: TGroupBox
                  Left = 192
                  Width = 221
                  Height = 10
                  Margins.Left = 4
                  Margins.Top = 4
                  Margins.Right = 4
                  Margins.Bottom = 4
                  ExplicitLeft = 192
                  ExplicitWidth = 221
                  ExplicitHeight = 10
                  inherited DiametrLabel: TLabel
                    Left = 7
                    Top = 88
                    Width = 115
                    Height = 17
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 7
                    ExplicitTop = 88
                    ExplicitWidth = 115
                    ExplicitHeight = 17
                  end
                  inherited StageCountLabel: TLabel
                    Left = 7
                    Top = 144
                    Width = 98
                    Height = 17
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 7
                    ExplicitTop = 144
                    ExplicitWidth = 98
                    ExplicitHeight = 17
                  end
                  inherited TurbineLabel: TLabel
                    Left = 8
                    Top = 27
                    Width = 55
                    Height = 17
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 8
                    ExplicitTop = 27
                    ExplicitWidth = 55
                    ExplicitHeight = 17
                  end
                  inherited BladeCountIE: TIntEdit
                    Left = 7
                    Top = 165
                    Width = 147
                    Height = 25
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 7
                    ExplicitTop = 165
                    ExplicitWidth = 147
                    ExplicitHeight = 25
                  end
                  inherited DiametrFE: TFloatEdit
                    Left = 7
                    Top = 112
                    Width = 147
                    Height = 25
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 7
                    ExplicitTop = 112
                    ExplicitWidth = 147
                    ExplicitHeight = 25
                  end
                  inherited EvalShapeBtn: TButton
                    Left = 4
                    Top = 200
                    Width = 150
                    Height = 33
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 4
                    ExplicitTop = 200
                    ExplicitWidth = 150
                    ExplicitHeight = 33
                  end
                  inherited TurbineCB: TComboBox
                    Left = 4
                    Top = 52
                    Width = 150
                    Height = 25
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 4
                    ExplicitTop = 52
                    ExplicitWidth = 150
                    ExplicitHeight = 25
                  end
                  inherited EvalSensorSkipBtn: TButton
                    Left = 4
                    Top = 307
                    Width = 150
                    Height = 33
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 4
                    ExplicitTop = 307
                    ExplicitWidth = 150
                    ExplicitHeight = 33
                  end
                  inherited UseShapeAlgCB: TCheckBox
                    Left = 7
                    Top = 277
                    Width = 193
                    Height = 22
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 7
                    ExplicitTop = 277
                    ExplicitWidth = 193
                    ExplicitHeight = 22
                  end
                  inherited Button1: TButton
                    Left = 4
                    Top = 235
                    Width = 150
                    Height = 33
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 4
                    ExplicitTop = 235
                    ExplicitWidth = 150
                    ExplicitHeight = 33
                  end
                  inherited EvalSPos: TButton
                    Left = 4
                    Top = 347
                    Width = 150
                    Height = 32
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitLeft = 4
                    ExplicitTop = 347
                    ExplicitWidth = 150
                    ExplicitHeight = 32
                  end
                end
              end
              inherited TabSheet2: TTabSheet
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                inherited SensorsGB: TGroupBox
                  Margins.Left = 4
                  Margins.Top = 4
                  Margins.Right = 4
                  Margins.Bottom = 4
                  inherited SensorsSG: TStringGrid
                    Top = 19
                    Height = 238
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitTop = 19
                    ExplicitHeight = 238
                  end
                end
              end
            end
          end
        end
        inherited TurbineFrame1: TTurbineFrame
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Constraints.MinWidth = 299
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 0
          inherited TurbinePropGB: TGroupBox
            Width = 299
            Height = 0
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitWidth = 299
            ExplicitHeight = 0
            inherited StageCountLabel: TLabel
              Left = 7
              Top = 60
              Width = 105
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 7
              ExplicitTop = 60
              ExplicitWidth = 105
              ExplicitHeight = 17
            end
            inherited CfgLabel: TLabel
              Left = 183
              Top = 61
              Width = 156
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 183
              ExplicitTop = 61
              ExplicitWidth = 156
              ExplicitHeight = 17
            end
            inherited RecentFileLabel: TLabel
              Left = 7
              Top = 30
              Width = 161
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 7
              ExplicitTop = 30
              ExplicitWidth = 161
              ExplicitHeight = 17
            end
            inherited StageCountIE: TIntEdit
              Left = 7
              Top = 86
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 7
              ExplicitTop = 86
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
            inherited CfgTV: TTreeView
              Left = 183
              Top = 86
              Width = 248
              Height = 213
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 183
              ExplicitTop = 86
              ExplicitWidth = 248
              ExplicitHeight = 213
            end
            inherited RecentFileEdit: TEdit
              Left = 183
              Top = 26
              Width = 248
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 183
              ExplicitTop = 26
              ExplicitWidth = 248
              ExplicitHeight = 25
            end
          end
        end
        inherited PairFrame1: TPairFrame
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Constraints.MinWidth = 299
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 0
          inherited PairGB: TGroupBox
            Width = 299
            Height = 0
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitWidth = 299
            ExplicitHeight = 0
            inherited StageCountLabel: TLabel
              Left = 5
              Top = 25
              Width = 137
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 5
              ExplicitTop = 25
              ExplicitWidth = 137
              ExplicitHeight = 17
            end
            inherited StageLabel: TLabel
              Left = 197
              Top = 25
              Width = 55
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 197
              ExplicitTop = 25
              ExplicitWidth = 55
              ExplicitHeight = 17
            end
            inherited SensorNameLabel: TLabel
              Left = 411
              Top = 25
              Width = 82
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 411
              ExplicitTop = 25
              ExplicitWidth = 82
              ExplicitHeight = 17
            end
            inherited BaseLabel: TLabel
              Left = 680
              Top = 25
              Height = 17
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 680
              ExplicitTop = 25
              ExplicitHeight = 17
            end
            inherited SensorsLV: TBtnListView
              Left = 5
              Top = 86
              Width = 435
              Height = 103
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              Columns = <
                item
                  Caption = #8470
                  Width = 65
                end
                item
                  Caption = #1048#1084#1103
                  Width = 65
                end
                item
                  Caption = #1058#1080#1087
                  Width = 48
                end
                item
                  Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087'.'
                  Width = 65
                end
                item
                  Caption = #1055#1086#1083#1086#1078'.'
                  Width = 65
                end>
              ExplicitLeft = 5
              ExplicitTop = 86
              ExplicitWidth = 435
              ExplicitHeight = 369
            end
            inherited BladeLeftIE: TIntEdit
              Left = 5
              Top = 50
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 5
              ExplicitTop = 50
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
            inherited StageCB: TComboBox
              Left = 197
              Top = 50
              Width = 190
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 197
              ExplicitTop = 50
              ExplicitWidth = 190
              ExplicitHeight = 25
            end
            inherited SensorsNameCB: TComboBox
              Left = 412
              Top = 50
              Width = 173
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 412
              ExplicitTop = 50
              ExplicitWidth = 173
              ExplicitHeight = 25
            end
            inherited SelectSensorsBtn: TButton
              Left = 592
              Top = 50
              Width = 66
              Height = 27
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 592
              ExplicitTop = 50
              ExplicitWidth = 66
              ExplicitHeight = 27
            end
            inherited BaseFE: TFloatEdit
              Left = 680
              Top = 50
              Width = 158
              Height = 25
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitLeft = 680
              ExplicitTop = 50
              ExplicitWidth = 158
              ExplicitHeight = 25
            end
          end
        end
        inherited UTSFrame1: TUTSFrame
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 0
          inherited UtsLabel: TLabel
            Left = 21
            Top = 4
            Width = 67
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 21
            ExplicitTop = 4
            ExplicitWidth = 67
            ExplicitHeight = 17
          end
          inherited SignalTypeLabel: TLabel
            Left = 241
            Top = 4
            Width = 79
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 241
            ExplicitTop = 4
            ExplicitWidth = 79
            ExplicitHeight = 17
          end
          inherited UTSChannel: TComboBox
            Left = 21
            Top = 29
            Width = 190
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 21
            ExplicitTop = 29
            ExplicitWidth = 190
            ExplicitHeight = 25
          end
          inherited UTSLV: TBtnListView
            Left = 21
            Top = 64
            Width = 587
            Height = 98
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 21
            ExplicitTop = 64
            ExplicitWidth = 587
            ExplicitHeight = 364
          end
          inherited SEVCB: TComboBox
            Left = 241
            Top = 29
            Width = 189
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 241
            ExplicitTop = 29
            ExplicitWidth = 189
            ExplicitHeight = 25
          end
        end
        inherited Platframe1: TPlatframe
          Top = 362
          Width = 299
          Height = 0
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitTop = 362
          ExplicitWidth = 299
          ExplicitHeight = 0
          inherited BuffSizeLabel: TLabel
            Left = 398
            Top = 17
            Width = 97
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 398
            ExplicitTop = 17
            ExplicitWidth = 97
            ExplicitHeight = 17
          end
          inherited PeriodLabel: TLabel
            Left = 199
            Top = 17
            Width = 129
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 199
            ExplicitTop = 17
            ExplicitWidth = 129
            ExplicitHeight = 17
          end
          inherited Label1: TLabel
            Left = 4
            Top = 17
            Width = 54
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitTop = 17
            ExplicitWidth = 54
            ExplicitHeight = 17
          end
          inherited ModeLabel: TLabel
            Left = 659
            Top = 17
            Width = 42
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 659
            ExplicitTop = 17
            ExplicitWidth = 42
            ExplicitHeight = 17
          end
          inherited BufSizeCB: TComboBox
            Left = 398
            Top = 42
            Width = 221
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 398
            ExplicitTop = 42
            ExplicitWidth = 221
            ExplicitHeight = 25
          end
          inherited PeriodSE: TFloatSpinEdit
            Left = 199
            Top = 42
            Width = 158
            Height = 27
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 199
            ExplicitTop = 42
            ExplicitWidth = 158
            ExplicitHeight = 27
          end
          inherited FreqFE: TFloatSpinEdit
            Left = 4
            Top = 42
            Width = 158
            Height = 27
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitTop = 42
            ExplicitWidth = 158
            ExplicitHeight = 27
          end
          inherited ModeCB: TComboBox
            Left = 659
            Top = 42
            Width = 221
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 659
            ExplicitTop = 42
            ExplicitWidth = 221
            ExplicitHeight = 25
          end
        end
      end
    end
  end
end

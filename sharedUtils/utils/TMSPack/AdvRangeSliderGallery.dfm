object AdvRangeSliderGalleryForm: TAdvRangeSliderGalleryForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'TAdvTrackBar Gallery'
  ClientHeight = 294
  ClientWidth = 498
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 247
    Width = 126
    Height = 13
    Caption = 'Name for saving to gallery'
  end
  object GroupBox1: TGroupBox
    Left = 208
    Top = 8
    Width = 273
    Height = 233
    Caption = 'Preview'
    TabOrder = 0
    object AdvRangeSlider1: TAdvRangeSlider
      Left = 10
      Top = 20
      Width = 150
      Height = 45
      BorderColor = clNone
      BorderColorDisabled = clNone
      ColorTo = clNone
      ColorDisabled = clNone
      ColorDisabledTo = clNone
      Direction = gdHorizontal
      Color = clNone
      Slider.BorderColor = 12752500
      Slider.BorderColorDisabled = clBlack
      Slider.Color = clWhite
      Slider.ColorTo = clBlack
      Slider.ColorDisabled = clBlack
      Slider.ColorDisabledTo = clBlack
      Slider.ColorCompleted = clNone
      Slider.ColorCompletedTo = clNone
      Slider.ColorCompletedDisabled = clNone
      Slider.ColorCompletedDisabledTo = clNone
      Slider.Direction = gdHorizontal
      Slider.ColorRemaining = clNone
      Slider.ColorRemainingTo = clNone
      Slider.ColorRemainingDisabled = clNone
      Slider.ColorRemainingDisabledTo = clNone
      TabOrder = 0
      ThumbLeft.BorderColor = 10317632
      ThumbLeft.BorderColorHot = 10079963
      ThumbLeft.BorderColorDown = 4548219
      ThumbLeft.BorderColorDisabled = clBlack
      ThumbLeft.Color = 15653832
      ThumbLeft.ColorTo = 16178633
      ThumbLeft.ColorDown = 7778289
      ThumbLeft.ColorDownTo = 4296947
      ThumbLeft.ColorHot = 15465983
      ThumbLeft.ColorHotTo = 11332863
      ThumbLeft.ColorDisabled = clBlack
      ThumbLeft.ColorDisabledTo = clBlack
      ThumbLeft.ColorMirror = 15586496
      ThumbLeft.ColorMirrorTo = 16245200
      ThumbLeft.ColorMirrorHot = 5888767
      ThumbLeft.ColorMirrorHotTo = 10807807
      ThumbLeft.ColorMirrorDown = 946929
      ThumbLeft.ColorMirrorDownTo = 5021693
      ThumbLeft.ColorMirrorDisabled = clBlack
      ThumbLeft.ColorMirrorDisabledTo = clBlack
      ThumbLeft.Gradient = ggVertical
      ThumbLeft.GradientMirror = ggRadial
      ThumbLeft.Shape = tsPointer
      ThumbRight.BorderColor = 10317632
      ThumbRight.BorderColorHot = 10079963
      ThumbRight.BorderColorDown = 4548219
      ThumbRight.BorderColorDisabled = clBlack
      ThumbRight.Color = 15653832
      ThumbRight.ColorTo = 16178633
      ThumbRight.ColorDown = 7778289
      ThumbRight.ColorDownTo = 4296947
      ThumbRight.ColorHot = 15465983
      ThumbRight.ColorHotTo = 11332863
      ThumbRight.ColorDisabled = clBlack
      ThumbRight.ColorDisabledTo = clBlack
      ThumbRight.ColorMirror = 15586496
      ThumbRight.ColorMirrorTo = 16245200
      ThumbRight.ColorMirrorHot = 5888767
      ThumbRight.ColorMirrorHotTo = 10807807
      ThumbRight.ColorMirrorDown = 946929
      ThumbRight.ColorMirrorDownTo = 5021693
      ThumbRight.ColorMirrorDisabled = clBlack
      ThumbRight.ColorMirrorDisabledTo = clBlack
      ThumbRight.Gradient = ggVertical
      ThumbRight.GradientMirror = ggRadial
      ThumbRight.Shape = tsPointer
      TickMark.Color = clBlack
      TickMark.ColorDisabled = clBlack
      TickMark.Font.Charset = DEFAULT_CHARSET
      TickMark.Font.Color = clWindowText
      TickMark.Font.Height = -11
      TickMark.Font.Name = 'Tahoma'
      TickMark.Font.Style = []
      TrackHint = False
      TrackLabel.Font.Charset = DEFAULT_CHARSET
      TrackLabel.Font.Color = clWindowText
      TrackLabel.Font.Height = -11
      TrackLabel.Font.Name = 'Tahoma'
      TrackLabel.Font.Style = []
      TrackLabel.Format = 'PosLeft: %d  PosRight: %d'
      Version = '1.6.5.0'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 185
    Height = 233
    Caption = 'Gallery'
    TabOrder = 1
    object ListBox1: TListBox
      Left = 7
      Top = 19
      Width = 170
      Height = 204
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListBox1Click
    end
  end
  object Edit1: TEdit
    Left = 15
    Top = 263
    Width = 170
    Height = 21
    TabOrder = 2
  end
  object Button1: TButton
    Left = 191
    Top = 263
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 325
    Top = 263
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object Button3: TButton
    Left = 406
    Top = 263
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
end

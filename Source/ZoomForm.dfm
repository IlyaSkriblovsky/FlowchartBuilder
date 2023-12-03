object frmZoom: TfrmZoom
  Left = 218
  Top = 129
  Cursor = crSizeAll
  Caption = #1052#1072#1089#1096#1090#1072#1073
  ClientHeight = 453
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object ControlBar: TControlBar
    Left = 0
    Top = 0
    Width = 688
    Height = 30
    Cursor = crArrow
    Align = alTop
    AutoSize = True
    Color = clBtnFace
    ParentColor = False
    TabOrder = 0
    object btnClose: TSpeedButton
      Left = 94
      Top = 2
      Width = 59
      Height = 22
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Flat = True
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnCloseClick
    end
    object ToolBar1: TToolBar
      Left = 11
      Top = 2
      Width = 70
      Height = 22
      ButtonHeight = 20
      Caption = 'ToolBar1'
      TabOrder = 0
      object ZoomBox: TComboBox
        Left = 0
        Top = 0
        Width = 49
        Height = 21
        TabOrder = 0
        Text = '100'
        OnChange = ZoomBoxChange
        Items.Strings = (
          '10'
          '20'
          '30'
          '40'
          '50'
          '60'
          '70'
          '80'
          '90'
          '100'
          '110'
          '120'
          '130'
          '140'
          '150'
          '160'
          '170'
          '180'
          '190'
          '200')
      end
      object Label1: TLabel
        Left = 49
        Top = 0
        Width = 14
        Height = 20
        Caption = '%'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
    end
  end
end

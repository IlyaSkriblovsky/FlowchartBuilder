object frmInterval: TfrmInterval
  Left = 302
  Top = 232
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1080#1090#1100' '#1080#1085#1090#1077#1088#1074#1072#1083
  ClientHeight = 85
  ClientWidth = 192
  Color = 15066597
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 181
    Height = 13
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1079#1072#1076#1077#1088#1078#1082#1091' '#1074' '#1084#1080#1083#1080#1089#1077#1082#1091#1085#1076#1072#1093':'
  end
  object Edit1: TEdit
    Left = 8
    Top = 32
    Width = 57
    Height = 21
    TabOrder = 0
    Text = '1000'
  end
  object UpDown: TUpDown
    Left = 65
    Top = 32
    Width = 16
    Height = 21
    Associate = Edit1
    Min = 0
    Max = 30000
    Position = 1000
    TabOrder = 1
    Thousands = False
    Wrap = False
  end
  object btnOK: TBitBtn
    Left = 8
    Top = 56
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = btnOKClick
    Kind = bkOK
  end
  object CheckBox1: TCheckBox
    Left = 88
    Top = 32
    Width = 97
    Height = 17
    Caption = #1073#1077#1079' '#1079#1072#1076#1077#1088#1078#1082#1080
    TabOrder = 3
    OnClick = CheckBox1Click
  end
end

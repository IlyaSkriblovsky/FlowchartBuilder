object AboutBox: TAboutBox
  Left = 310
  Top = 281
  BorderStyle = bsNone
  Caption = 'About'
  ClientHeight = 265
  ClientWidth = 471
  Color = 16377565
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 471
    Height = 265
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = 16377565
    TabOrder = 0
    OnClick = OnPanelClick
    object Shape5: TShape
      Left = 208
      Top = 96
      Width = 233
      Height = 129
      Brush.Color = clMoneyGreen
      Brush.Style = bsDiagCross
      Pen.Color = 16377565
      Shape = stEllipse
      OnMouseDown = OnShapeClick
    end
    object Shape7: TShape
      Left = 208
      Top = 136
      Width = 233
      Height = 49
      Brush.Color = 16377565
      Pen.Color = 16377565
      Shape = stEllipse
      OnMouseDown = OnShapeClick
    end
    object Shape6: TShape
      Left = 288
      Top = 96
      Width = 73
      Height = 129
      Brush.Color = 16377565
      Pen.Color = 16377565
      Shape = stEllipse
      OnMouseDown = OnShapeClick
    end
    object Shape2: TShape
      Left = 6
      Top = 16
      Width = 41
      Height = 33
      Brush.Color = 16744448
      Pen.Color = 16744448
    end
    object Shape3: TShape
      Left = 14
      Top = 40
      Width = 25
      Height = 33
      Brush.Color = 12418047
      Pen.Color = 16744448
    end
    object Shape4: TShape
      Left = 30
      Top = 32
      Width = 33
      Height = 25
      Brush.Color = 12451773
      Pen.Color = 16744448
    end
    object lblConstructor: TLabel
      Left = 86
      Top = 24
      Width = 308
      Height = 32
      Caption = #1050#1086#1085#1089#1090#1088#1091#1082#1090#1086#1088' '#1073#1083#1086#1082'-'#1089#1093#1077#1084
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -29
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = True
      IsControl = True
    end
    object Label3: TLabel
      Left = 24
      Top = 82
      Width = 200
      Height = 16
      Hint = #1064#1082#1086#1083#1072' 91'
      Caption = #1040#1074#1090#1086#1088': '#1057#1082#1088#1080#1073#1083#1086#1074#1089#1082#1080#1081' '#1048#1083#1100#1103
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
    object Label4: TLabel
      Left = 24
      Top = 114
      Width = 180
      Height = 16
      Hint = #1044#1086#1094#1077#1085#1090' '#1082#1072#1092'. '#1048#1048#1057#1043#1077#1086' '#1082'.'#1090'.'#1085'. '#1057'.'#1043'. '#1050#1091#1079#1080#1085
      Caption = #1053#1072#1091#1095#1085#1099#1081' '#1088#1091#1082#1086#1074#1086#1076#1080#1090#1077#1083#1100':'
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
    object Label8: TLabel
      Left = 208
      Top = 114
      Width = 229
      Height = 16
      Hint = #1048#1048#1057#1043#1077#1086' '#1053#1053#1043#1059
      Caption = #1050#1091#1079#1080#1085' '#1057#1090#1072#1085#1080#1089#1083#1072#1074' '#1043#1088#1080#1075#1086#1088#1100#1077#1074#1080#1095
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
    object Label5: TLabel
      Left = 24
      Top = 98
      Width = 202
      Height = 16
      Hint = #1048#1048#1057#1043#1077#1086' '#1053#1053#1043#1059
      Caption = #1050#1086#1085#1089#1091#1083#1100#1090#1072#1085#1090': '#1052#1080#1090#1080#1085' '#1056#1086#1084#1072#1085
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
    object Copyright: TLabel
      Left = 24
      Top = 180
      Width = 119
      Height = 16
      Caption = #1041#1083#1072#1075#1086#1076#1072#1088#1085#1086#1089#1090#1080':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      IsControl = True
    end
    object CityAndYears: TLabel
      Left = 313
      Top = 248
      Width = 152
      Height = 13
      Caption = #1053#1080#1078#1085#1080#1081' '#1053#1086#1074#1075#1086#1088#1086#1076', 2002'#8212'2005'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Version: TLabel
      Left = 8
      Top = 248
      Width = 35
      Height = 13
      Caption = 'Version'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -8
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      IsControl = True
    end
    object Shape1: TShape
      Left = 46
      Top = 56
      Width = 385
      Height = 9
      Brush.Color = 16744448
      Pen.Color = 16744448
    end
    object Label6: TLabel
      Left = 48
      Top = 228
      Width = 130
      Height = 16
      Hint = #1053#1053#1043#1059
      Caption = #1050#1086#1090#1082#1086#1074#1091' '#1040#1083#1077#1082#1089#1077#1102
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      IsControl = True
    end
    object Label9: TLabel
      Left = 48
      Top = 196
      Width = 215
      Height = 16
      Hint = #1059#1095#1080#1090#1077#1083#1100' '#1080#1085#1092#1086#1088#1084#1072#1090#1080#1082#1080' '#1074' '#1096#1082#1086#1083#1077' '#8470'91'
      Caption = #1050#1072#1089#1100#1082#1086#1074#1086#1081' '#1048#1088#1080#1085#1077' '#1041#1086#1088#1080#1089#1086#1074#1085#1077
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      IsControl = True
    end
    object Label12: TLabel
      Left = 48
      Top = 212
      Width = 137
      Height = 16
      Hint = #1064#1082#1086#1083#1072' '#8470'91'
      Caption = #1052#1086#1088#1086#1079#1086#1074#1091' '#1040#1085#1076#1088#1077#1102
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      IsControl = True
    end
    object Shape8: TShape
      Left = 272
      Top = 128
      Width = 105
      Height = 65
      Brush.Color = clMoneyGreen
      Brush.Style = bsDiagCross
      Pen.Color = 16377565
      Shape = stEllipse
      OnMouseDown = OnShapeClick
    end
    object GoToWeb: TLabel
      Left = 75
      Top = 136
      Width = 143
      Height = 16
      Cursor = crHandPoint
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' '#1085#1072' Github'
      Color = clAqua
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold, fsUnderline]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = GoToWebClick
      IsControl = True
    end
    object GoToEmail: TLabel
      Left = 75
      Top = 158
      Width = 191
      Height = 16
      Cursor = crHandPoint
      Caption = 'ilyaskriblovsky@gmail.com'
      Color = clAqua
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold, fsUnderline]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = GoToEmailClick
      IsControl = True
    end
    object Label1: TLabel
      Left = 24
      Top = 136
      Width = 41
      Height = 16
      Caption = #1057#1072#1081#1090':'
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
    object Label2: TLabel
      Left = 24
      Top = 158
      Width = 49
      Height = 16
      Caption = 'E-Mail:'
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
  end
  object Timer: TTimer
    Interval = 2000
    OnTimer = OnTimer
    Left = 301
    Top = 5
  end
end

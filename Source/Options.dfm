object frmOpt: TfrmOpt
  Left = 356
  Top = 174
  BorderStyle = bsToolWindow
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 382
  ClientWidth = 498
  Color = 15066597
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poDesktopCenter
  OnCreate = FormCreate
  DesignSize = (
    498
    382)
  PixelsPerInch = 96
  TextHeight = 13
  object shpHelp: TShape
    Left = 239
    Top = 16
    Width = 235
    Height = 359
    Brush.Color = 11468799
    Pen.Color = clBlue
  end
  object Label4: TLabel
    Left = 240
    Top = 16
    Width = 81
    Height = 17
    AutoSize = False
    Caption = #1055#1086#1076#1089#1082#1072#1079#1082#1080':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object grpSizes: TGroupBox
    Left = 8
    Top = 192
    Width = 225
    Height = 105
    Caption = ' '#1056#1072#1079#1084#1077#1088#1099' '
    TabOrder = 3
    object Label1: TLabel
      Left = 19
      Top = 16
      Width = 72
      Height = 13
      Caption = #1064#1080#1088#1080#1085#1072' '#1073#1083#1086#1082#1072
    end
    object Label2: TLabel
      Left = 115
      Top = 16
      Width = 71
      Height = 13
      Caption = #1042#1099#1089#1086#1090#1072' '#1073#1083#1086#1082#1072
    end
    object Label7: TLabel
      Left = 19
      Top = 56
      Width = 124
      Height = 13
      Caption = #1044#1080#1072#1084#1077#1090#1088' '#1073#1083#1086#1082#1072' '#1089#1083#1080#1103#1085#1080#1103
    end
    object WidthBlok: TEdit
      Left = 23
      Top = 31
      Width = 74
      Height = 21
      TabOrder = 0
      Text = 'WidthBlok'
    end
    object HeightBlok: TEdit
      Left = 119
      Top = 31
      Width = 74
      Height = 21
      TabOrder = 1
      Text = 'HeightBlok'
    end
    object ConflRad: TEdit
      Left = 24
      Top = 72
      Width = 113
      Height = 21
      TabOrder = 2
      Text = 'ConflRad'
    end
  end
  object BitOk: TBitBtn
    Left = 10
    Top = 350
    Width = 95
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    Default = True
    DoubleBuffered = True
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    ModalResult = 1
    NumGlyphs = 2
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    OnClick = BitOkClick
  end
  object BitCansel: TBitBtn
    Left = 108
    Top = 350
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    DoubleBuffered = True
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      333333333333333333333333000033338833333333333333333F333333333333
      0000333911833333983333333388F333333F3333000033391118333911833333
      38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
      911118111118333338F3338F833338F3000033333911111111833333338F3338
      3333F8330000333333911111183333333338F333333F83330000333333311111
      8333333333338F3333383333000033333339111183333333333338F333833333
      00003333339111118333333333333833338F3333000033333911181118333333
      33338333338F333300003333911183911183333333383338F338F33300003333
      9118333911183333338F33838F338F33000033333913333391113333338FF833
      38F338F300003333333333333919333333388333338FFF830000333333333333
      3333333333333333333888330000333333333333333333333333333333333333
      0000}
    ModalResult = 2
    NumGlyphs = 2
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 1
    OnClick = BitCanselClick
  end
  object grpColor: TGroupBox
    Left = 8
    Top = 8
    Width = 225
    Height = 121
    Caption = ' '#1062#1074#1077#1090#1072' '
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label3: TLabel
      Left = 93
      Top = 16
      Width = 108
      Height = 16
      Caption = #1058#1077#1082#1091#1097#1080#1081' '#1094#1074#1077#1090':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Shape1: TShape
      Left = 96
      Top = 40
      Width = 105
      Height = 33
    end
    object lstColors: TListBox
      Left = 7
      Top = 16
      Width = 82
      Height = 89
      BevelInner = bvNone
      BevelKind = bkFlat
      BorderStyle = bsNone
      ItemHeight = 13
      Items.Strings = (
        #1041#1083#1086#1082#1080
        #1058#1077#1082#1089#1090' '#1074' '#1073#1083#1086#1082#1077
        #1058#1077#1082#1091#1097#1080#1081' '#1073#1083#1086#1082
        #1060#1086#1085)
      TabOrder = 0
      OnClick = lstColorsClick
    end
    object ChangeColor: TButton
      Left = 96
      Top = 80
      Width = 105
      Height = 25
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
      TabOrder = 1
      OnClick = ChangeColorClick
    end
  end
  object grpI13r: TGroupBox
    Left = 8
    Top = 304
    Width = 225
    Height = 41
    Caption = ' '#1048#1085#1090#1077#1088#1087#1088#1077#1090#1072#1090#1086#1088' '
    TabOrder = 4
    object clbInterpr: TCheckListBox
      Left = 8
      Top = 16
      Width = 209
      Height = 17
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 15066597
      ItemHeight = 13
      Items.Strings = (
        #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1088#1086#1074#1077#1088#1103#1090#1100' '#1086#1087#1077#1088#1072#1090#1086#1088#1099)
      TabOrder = 0
    end
  end
  object BitHelp: TBitBtn
    Left = 200
    Top = 350
    Width = 31
    Height = 25
    Anchors = [akLeft, akBottom]
    DoubleBuffered = True
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333336633
      3333333333333FF3333333330000333333364463333333333333388F33333333
      00003333333E66433333333333338F38F3333333000033333333E66333333333
      33338FF8F3333333000033333333333333333333333338833333333300003333
      3333446333333333333333FF3333333300003333333666433333333333333888
      F333333300003333333E66433333333333338F38F333333300003333333E6664
      3333333333338F38F3333333000033333333E6664333333333338F338F333333
      0000333333333E6664333333333338F338F3333300003333344333E666433333
      333F338F338F3333000033336664333E664333333388F338F338F33300003333
      E66644466643333338F38FFF8338F333000033333E6666666663333338F33888
      3338F3330000333333EE666666333333338FF33333383333000033333333EEEE
      E333333333388FFFFF8333330000333333333333333333333333388888333333
      0000}
    NumGlyphs = 2
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 5
    OnClick = BitHelpClick
  end
  object Memo1: TMemo
    Left = 240
    Top = 32
    Width = 233
    Height = 113
    TabStop = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1042' '#1089#1087#1080#1089#1082#1077' '#1089#1083#1077#1074#1072' '#1074#1099#1073#1077#1088#1080#1090#1077' '#1090#1080#1087' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '
      #1076#1080#1072#1075#1088#1072#1084#1084#1099' '#1076#1083#1103' '#1082#1086#1090#1086#1088#1099#1093' '#1078#1077#1083#1072#1077#1090#1077' '#1080#1079#1084#1077#1085#1080#1090#1100' '
      #1094#1074#1077#1090' '#1080' '#1085#1072#1078#1084#1080#1090#1077' '#1082#1085#1086#1087#1082#1091' '#1080#1079#1084#1077#1085#1080#1090#1100'. '
      ''
      #1042' '#1076#1080#1072#1083#1086#1075#1086#1074#1086#1084' '#1086#1082#1085#1077' '#1074#1099#1073#1086#1088#1072' '#1094#1074#1077#1090#1072' '#1074#1099#1073#1077#1088#1080#1090#1077' '
      #1085#1091#1078#1085#1099#1081' '#1080' '#1085#1072#1078#1084#1080#1090#1077' '#1082#1085#1086#1087#1082#1091' '#1087#1088#1080#1084#1077#1085#1080#1090#1100'.')
    ReadOnly = True
    TabOrder = 6
    WantReturns = False
  end
  object Memo2: TMemo
    Left = 240
    Top = 200
    Width = 233
    Height = 105
    TabStop = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1047#1076#1077#1089#1100' '#1042#1099' '#1084#1086#1078#1077#1090#1077' '#1079#1072#1076#1072#1090#1100' '#1088#1072#1079#1084#1077#1088#1099' '#1073#1083#1086#1082#1086#1074','
      #1082#1086#1090#1086#1088#1099#1077' '#1073#1091#1076#1091#1090' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100#1089#1103' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
      #1076#1083#1103' '#1085#1086#1074#1099#1093' '#1073#1083#1086#1082#1086#1074'. '#1057#1083#1077#1076#1091#1077#1090' '#1080#1084#1077#1090#1100' '#1074#1074#1080#1076#1091', '#1095#1090#1086
      #1096#1080#1088#1080#1085#1072' '#1073#1083#1086#1082#1072' '#1080#1079#1084#1077#1085#1103#1077#1090#1089#1103' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1074' '
      #1079#1072#1074#1080#1089#1080#1084#1086#1089#1090#1080' '#1086#1090' '#1090#1077#1082#1089#1090#1072'.')
    ReadOnly = True
    TabOrder = 7
    WantReturns = False
  end
  object grpFonts: TGroupBox
    Left = 8
    Top = 136
    Width = 225
    Height = 49
    Caption = #1064#1088#1080#1092#1090#1099
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    object btnBlockFont: TButton
      Left = 8
      Top = 16
      Width = 121
      Height = 25
      Caption = #1064#1088#1080#1092#1090' '#1073#1083#1086#1082#1086#1074'...'
      TabOrder = 0
      OnClick = btnBlockFontClick
    end
  end
  object Memo3: TMemo
    Left = 240
    Top = 144
    Width = 233
    Height = 57
    TabStop = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1047#1076#1077#1089#1100' B'#1099' '#1084#1086#1078#1077#1090#1077' '#1080#1079#1084#1077#1085#1080#1090#1100' '#1096#1088#1080#1092#1090#1099' '
      #1080#1089#1087#1086#1083#1100#1079#1091#1077#1084#1099#1077' '#1074' '#1087#1088#1086#1075#1088#1072#1084#1084#1077', '#1085#1072#1087#1088#1080#1084#1077#1088' '
      #1096#1088#1080#1092#1090' '#1085#1072#1076#1087#1080#1089#1077#1081' '#1074#1085#1091#1090#1088#1080' '#1073#1083#1086#1082#1086#1074'.')
    ReadOnly = True
    TabOrder = 9
    WantReturns = False
  end
  object Memo4: TMemo
    Left = 240
    Top = 304
    Width = 233
    Height = 70
    TabStop = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1047#1076#1077#1089#1100' B'#1099' '#1084#1086#1078#1077#1090#1077' '#1080#1079#1084#1077#1085#1080#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '
      #1080#1085#1090#1077#1088#1087#1088#1077#1090#1072#1090#1086#1088#1072'. '#1059#1089#1090#1072#1085#1086#1074#1080#1090#1077' '#1092#1083#1072#1078#1086#1082' '
      '"'#1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1088#1086#1074#1077#1088#1103#1090#1100' '#1086#1087#1077#1088#1072#1090#1086#1088#1099'" '
      #1095#1090#1086#1073#1099' '#1074#1082#1083#1102#1095#1080#1090#1100' '#1087#1088#1086#1074#1077#1088#1082#1091' '#1086#1087#1077#1088#1072#1090#1086#1088#1086#1074' '#1089#1088#1072#1079#1091' '
      #1087#1086#1089#1083#1077' '#1074#1074#1086#1076#1072'.')
    ReadOnly = True
    TabOrder = 10
    WantReturns = False
  end
  object ColorDialog: TColorDialog
    Left = 144
    Top = 50
  end
  object FontDialog: TFontDialog
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdScalableOnly, fdApplyButton]
    OnApply = FontDialogApply
    Left = 192
    Top = 148
  end
end

object frmProps: TfrmProps
  Left = 410
  Top = 247
  BorderStyle = bsToolWindow
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072
  ClientHeight = 400
  ClientWidth = 344
  Color = 15066597
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 240
    Top = 16
    Width = 201
    Height = 345
    Brush.Color = 11468799
    Pen.Color = clBlue
  end
  object Label4: TLabel
    Left = 240
    Top = 16
    Width = 70
    Height = 17
    AutoSize = False
    Caption = #1055#1086#1076#1089#1082#1072#1079#1082#1080':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 225
    Height = 353
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1073#1083#1086#1082#1072
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 52
      Height = 13
      Caption = #1054#1087#1077#1088#1072#1090#1086#1088':'
    end
    object Label2: TLabel
      Left = 8
      Top = 156
      Width = 47
      Height = 13
      Caption = #1053#1072#1076#1087#1080#1089#1100':'
    end
    object Label3: TLabel
      Left = 8
      Top = 304
      Width = 59
      Height = 13
      Caption = #1055#1086#1076#1089#1082#1072#1079#1082#1072':'
    end
    object OpMemo: TMemo
      Left = 16
      Top = 32
      Width = 193
      Height = 113
      ScrollBars = ssBoth
      TabOrder = 0
      OnKeyDown = OpMemoKeyDown
    end
    object TxMemo: TMemo
      Left = 16
      Top = 176
      Width = 193
      Height = 113
      ScrollBars = ssBoth
      TabOrder = 1
      OnKeyDown = TxMemoKeyDown
    end
    object RmEdit: TEdit
      Left = 16
      Top = 320
      Width = 193
      Height = 21
      TabOrder = 2
    end
  end
  object Memo1: TMemo
    Left = 241
    Top = 32
    Width = 199
    Height = 169
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1042' '#1087#1086#1083#1077' '#1089#1083#1077#1074#1072' '#1074#1074#1077#1076#1080#1090#1077' '#1086#1087#1077#1088#1072#1090#1086#1088' '#1073#1083#1086#1082#1072'.'
      ''
      #1042#1086' '#1074#1088#1077#1084#1103' '#1088#1072#1073#1086#1090#1099' '#1073#1083#1086#1082'-'#1089#1093#1077#1084#1099' '
      #1086#1087#1077#1088#1072#1090#1086#1088' '#1074#1099#1087#1086#1083#1085#1103#1090#1089#1103' '#1082#1072#1078#1076#1099#1081' '#1088#1072#1079' '
      #1082#1086#1075#1076#1072' '#1074#1080#1088#1090#1091#1072#1083#1100#1085#1099#1081' '#1080#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100' '
      #1073#1083#1086#1082'-'#1089#1093#1077#1084#1099' '#1087#1088#1086#1093#1086#1080#1090' '#1095#1077#1088#1077#1079' '#1076#1072#1085#1085#1099#1081' '
      #1073#1083#1086#1082'.'
      ''
      #1054#1087#1077#1088#1072#1090#1086#1088' '#1076#1086#1083#1078#1077#1085' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1086#1074#1072#1090#1100' '
      #1089#1080#1085#1090#1072#1082#1089#1080#1089#1091' '#1092#1086#1088#1084#1072#1083#1100#1085#1086#1075#1086' '#1103#1079#1099#1082#1072'.')
    ReadOnly = True
    TabOrder = 1
  end
  object Memo2: TMemo
    Left = 241
    Top = 200
    Width = 199
    Height = 105
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1042' '#1087#1086#1083#1077' '#1089#1083#1077#1074#1072' '#1074#1074#1077#1076#1080#1090#1077' '#1085#1072#1076#1087#1080#1089#1100', '
      #1082#1086#1090#1086#1088#1072#1103' '#1073#1091#1076#1077#1090' '#1086#1090#1086#1073#1088#1072#1078#1072#1090#1100#1089#1103' '#1085#1072' '#1073#1083#1086#1082#1077'.'
      ''
      #1045#1089#1083#1080' '#1085#1072#1076#1087#1080#1089#1100' '#1087#1091#1089#1090#1072', '#1090#1086' '#1085#1072' '#1073#1083#1086#1082#1077' '#1073#1091#1076#1077#1090' '
      #1086#1090#1086#1073#1088#1072#1078#1072#1090#1100#1089#1103' '#1086#1087#1077#1088#1072#1090#1086#1088'.')
    ReadOnly = True
    TabOrder = 2
  end
  object Memo3: TMemo
    Left = 241
    Top = 304
    Width = 199
    Height = 56
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      #1042' '#1087#1086#1083#1077' '#1089#1083#1077#1074#1072' '#1074#1074#1077#1076#1080#1090#1077' '#1087#1086#1076#1089#1082#1072#1079#1082#1091', '
      #1082#1086#1090#1086#1088#1072#1103' '#1073#1091#1076#1077#1090' '#1086#1090#1086#1073#1088#1072#1078#1072#1090#1100#1089#1103' '#1074' '#1089#1090#1088#1086#1082#1077' '
      #1089#1086#1089#1090#1086#1103#1085#1080#1103' '#1087#1088#1080' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1080' '#1076#1072#1085#1085#1086#1075#1086' '
      #1073#1083#1086#1082#1072'.')
    ReadOnly = True
    TabOrder = 3
  end
  object btnOK: TBitBtn
    Left = 10
    Top = 367
    Width = 95
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    Default = True
    DoubleBuffered = True
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
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TBitBtn
    Left = 108
    Top = 367
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    DoubleBuffered = True
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
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object btnHelp: TBitBtn
    Left = 200
    Top = 367
    Width = 31
    Height = 25
    DoubleBuffered = True
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
    TabOrder = 6
    OnClick = btnHelpClick
  end
end

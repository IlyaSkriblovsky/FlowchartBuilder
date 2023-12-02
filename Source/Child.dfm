object ChildForm: TChildForm
  Left = 241
  Top = 179
  HorzScrollBar.Smooth = True
  HorzScrollBar.Tracking = True
  VertScrollBar.ParentColor = False
  VertScrollBar.Smooth = True
  VertScrollBar.Tracking = True
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 529
  ClientWidth = 640
  Color = clWhite
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = True
  Position = poDefault
  Visible = True
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel: TPaintBox
    Left = 168
    Top = 112
    Width = 97
    Height = 97
    Visible = False
    OnPaint = BevelPaint
  end
  object BlockMenu: TPopupMenu
    OnPopup = BlockMenuPopup
    Left = 40
    Top = 64
    object mnuReplace: TMenuItem
      Caption = #1047#1072#1084#1077#1085#1080#1090#1100' '#1085#1072
      object mnuRepBlock: TMenuItem
        Caption = #1041#1083#1086#1082
        object mnuRepStat: TMenuItem
          Caption = #1054#1087#1077#1088#1072#1090#1086#1088
          OnClick = mnuRepStatClick
        end
        object mnuRepIO: TMenuItem
          Caption = #1042#1074#1086#1076'/'#1042#1099#1074#1086#1076
          OnClick = mnuRepIOClick
        end
        object mnuRepCall: TMenuItem
          Caption = #1042#1099#1079#1086#1074
          OnClick = mnuRepCallClick
        end
        object mnuRepEnd: TMenuItem
          Caption = #1053#1072#1095#1072#1083#1086'/'#1050#1086#1085#1077#1094
          OnClick = mnuRepEndClick
        end
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuSequence: TMenuItem
        Caption = #1057#1083#1077#1076#1086#1074#1072#1085#1080#1077
        OnClick = mnuSequenceClick
      end
      object mnuIfFull: TMenuItem
        Caption = #1059#1089#1083#1086#1074#1080#1077' ('#1087#1086#1083#1085#1086#1077')'
        OnClick = mnuIfFullClick
      end
      object mnuIfNFull: TMenuItem
        Caption = #1059#1089#1083#1086#1074#1080#1077' ('#1085#1077#1087#1086#1083#1085#1086#1077')'
        OnClick = mnuIfNFullClick
      end
      object mnuLoopPred: TMenuItem
        Caption = #1062#1080#1082#1083' '#1089' '#1087#1088#1077#1076'-'#1091#1089#1083#1086#1074#1080#1077#1084
        OnClick = mnuLoopPredClick
      end
      object mnuLoopPost: TMenuItem
        Caption = #1062#1080#1082#1083' '#1089' '#1087#1086#1089#1090'-'#1091#1089#1083#1086#1074#1080#1077#1084
        OnClick = mnuLoopPostClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuRepNothing: TMenuItem
        Caption = #1053#1080#1095#1077#1075#1086
        OnClick = mnuRepNothingClick
      end
    end
    object mnuInit: TMenuItem
      Caption = #1053#1072#1095#1072#1083#1100#1085#1099#1081' '#1082#1086#1076
      OnClick = mnuInitClick
    end
    object mnuGlob: TMenuItem
      Caption = #1057#1087#1080#1089#1086#1082' '#1075#1083#1086#1073'. '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1093
      Visible = False
      OnClick = mnuGlobClick
    end
    object mnuStat: TMenuItem
      Caption = #1054#1087#1077#1088#1072#1090#1086#1088
      OnClick = mnuStatClick
    end
    object mnuUnfText: TMenuItem
      Caption = #1053#1072#1076#1087#1080#1089#1100
      OnClick = mnuUnfTextClick
    end
    object mnuRem: TMenuItem
      Caption = #1055#1086#1076#1089#1082#1072#1079#1082#1072
      OnClick = mnuRemClick
    end
    object mnuDelete: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = mnuDeleteClick
    end
  end
end

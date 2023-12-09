unit EdTypes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Arrows;

type
  SetBlocks = (stBeginEnd, stStatement, stIf, stInOut, stCall, stGlob, stInit, stComment, stConfl);

  TBlock = class(TTmpBlock)
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;

  private
    FBlok: SetBlocks;

  public
    Statement: TStringList;
    UnfText: TStringList;
    RemText: string;
    GlobStrings: TStringList;
    InitCode: TStringList;

    DrawCanvas: TCanvas;
    XOffs, YOffs: integer;

    function Isd: boolean;

    function IsPortAvail(t: TArrowTail; p: TBlockPort; laa: boolean): boolean; override;

    procedure SetBlok(Value: SetBlocks);
    procedure WriteText;

    procedure DrawPort(Port: TBlockPort); override;
    property Block: SetBlocks read FBlok write SetBlok;
  end;

implementation

uses Child, Math, Main;

(* **  TBlock  ** *)
function TBlock.Isd: boolean;
var
  i: integer;

begin
  Result := false;
  for i := 0 to ChildForm.ArrowList.Count - 1 do
    if (TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Block = Self) and
      (TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port = South) then
      Result := true;
end;

function TBlock.IsPortAvail(t: TArrowTail; p: TBlockPort; laa: boolean): boolean;
var
  i: integer;
  w, s, e: bool;

begin
  if Block <> stIf then
    Result := inherited IsPortAvail(t, p, laa)
  else
  begin
    if t = atStart then
      Result := p in Ins
    else
    begin
      if p in Ins then
        Result := false
      else
      begin
        w := false;
        s := false;
        e := false;
        for i := 0 to ChildForm.ArrowList.Count - 1 do
          if TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Block = Self then
          begin
            if TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port = West then
              w := true;
            if TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port = South then
              s := true;
            if TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port = East then
              e := true;
          end;
        if (w and s) or (s and e) or (e and w) then
        begin
          Result := false;
          exit;
        end;
        if (w and (p = West)) or (s and (p = South)) or (e and (p = East)) then
        begin
          Result := false;
          exit;
        end;
        if e then
        begin
          Result := not(s or w);
          exit;
        end;
        if (w and (p = South)) or (s and (p = West)) then
          Result := false
        else
          Result := true;
      end;
    end;
  end;
end;

procedure TBlock.WriteText;
var
  tW, tH: integer;
  w, H: integer;
  i: integer;
  Lines: TStringList;

  a, b: integer;

const
  HInd = 5;
  VInd = 5;
  LineInd = 1;

  IfCoef = 2;

begin
  if UnfText.Count <> 0 then
    Lines := UnfText
  else
    Lines := Statement;

  if Block = stGlob then
    Lines := GlobStrings;
  if Block = stInit then
    Lines := InitCode;
  if Block = stComment then
    Lines := UnfText;
  if Block = stConfl then
    exit;

  tW := 0;
  tH := 0;
  for i := 0 to Lines.Count - 1 do
  begin
    tW := Max(tW, DrawCanvas.TextWidth(Lines[i]));
    tH := tH + DrawCanvas.TextHeight(Lines[0]) + LineInd;
  end;

  case FBlok of
    stIf:
      begin
        b := Round((IfCoef * tH + tW) / 2);
        a := Round(b / IfCoef);
        w := 2 * b;
        H := 2 * a;
      end;
    stInOut:
      begin
        w := tW + 2 * HInd + 10;
        H := tH + 2 * VInd;
      end;
  else
    w := tW + 2 * HInd;
    H := tH + 2 * VInd;
  end;

  if w < ChildForm.WidthBlok then
    w := ChildForm.WidthBlok;
  if H < ChildForm.HeightBlok then
    H := ChildForm.HeightBlok;

  Left := Left - (w - Width) div 2;
  Top := Top - (H - Height) div 2;
  Width := w;
  Height := H;

  for i := 0 to Lines.Count - 1 do
    DrawCanvas.TextOut(XOffs + (w - tW) div 2, YOffs + (H - tH) div 2 + i * (DrawCanvas.TextHeight('A') + LineInd),
      Lines[i]);
end;

procedure TBlock.SetBlok(Value: SetBlocks);
begin
  FBlok := Value;
  case Value of
    stBeginEnd:
      begin
        Ins := [North];
        Blocked := [East, West];
      end;
    stStatement:
      begin
        Ins := [North];
        Blocked := [East, West];
      end;
    stIf:
      begin
        Ins := [North];
        Blocked := [];
      end;
    stInOut:
      begin
        Ins := [North];
        Blocked := [East, West];
      end;
    stCall:
      begin
        Ins := [North];
        Blocked := [East, West];
      end;
    stGlob:
      begin
        Ins := [];
        Blocked := [North, East, West, South];
      end;
    stInit:
      begin
        Ins := [];
        Blocked := [North, East, West, South];
      end;
    stComment:
      begin
        Ins := [];
        Blocked := [North, East, West, South];
      end;
    stConfl:
      begin
        Ins := [North, East, West];
        Blocked := [];
      end;
  end;
end;

procedure TBlock.DrawPort(Port: TBlockPort);
const
  R = 3;

  procedure Circle(x, y, R: integer);
  begin
    DrawCanvas.Ellipse(XOffs + x - R div 2, y - R div 2, YOffs + x + R div 2, y + R div 2);
  end;

begin
  if not(Block in [stIf, stConfl]) then
    case Port of
      North:
        Circle(Width div 2, 0, 2 * R);
      East:
        Circle(Width, Height div 2, 2 * R);
      West:
        Circle(0, Height div 2, 2 * R);
      South:
        Circle(Width div 2, Height, 2 * R);
    end;
  if Block = stIf then
    case Port of
      North:
        Circle(Width div 2, R, 2 * R - 1);
      East:
        Circle(Width - R, Height div 2, 2 * R - 1);
      West:
        Circle(R, Height div 2, 2 * R - 1);
      South:
        Circle(Width div 2, Height - R, 2 * R - 1);
    end;
  if Block = stConfl then
    case Port of
      North:
        Circle(Width div 2, 0, 6);
      East:
        Circle(Width, Height div 2, 6);
      West:
        Circle(0, Height div 2, 6);
      South:
        Circle(Width div 2, Height, 6);
    end;
end;

constructor TBlock.Create(AOwner: TComponent);
begin
  inherited;
  Color := clBlack;
  Font.Color := clWhite;
  Left := 0;
  Top := 0;
  Width := 20;
  Height := 20;
  Statement := TStringList.Create;
  UnfText := TStringList.Create;
  RemText := '';
  GlobStrings := TStringList.Create;
  InitCode := TStringList.Create;
  XOffs := 0;
  YOffs := 0;
  DrawCanvas := Canvas;
end;

procedure TBlock.Paint;
var
  PointArr: array [1 .. 4] of TPoint;
  tx: integer;
  bs: TBrushStyle;

const
  R = 5;

begin
  DrawCanvas.Pen.Style := psSolid;
  DrawCanvas.Pen.Color := clBlack;
  DrawCanvas.Brush.Color := Color;

  DrawCanvas.Font.Assign(ChildForm.BlockFont);

  if Block = stIf then
    with DrawCanvas do
    begin
      Font.Color := clGray;
      Brush.Color := ChildForm.Color;
      if Isd then
      begin
        TextOut(XOffs + Width - TextWidth('нет'), YOffs, 'нет');
        TextOut(XOffs + Width div 2 + 10, YOffs + Height - TextHeight('да'), 'да');
      end
      else
      begin
        TextOut(XOffs, YOffs, 'нет');
        TextOut(XOffs + Width - TextWidth('да'), YOffs, 'да');
      end;
      Brush.Color := Color;
    end;

  DrawCanvas.Font.Assign(ChildForm.BlockFont); // because we change color above

  // DrawCanvas.Brush.Style:=bsClear;
  for bs := bsSolid to bsClear do
  begin
    DrawCanvas.Brush.Style := bs;

    case Block of
      stBeginEnd:
        begin
          DrawCanvas.Ellipse(XOffs, YOffs, XOffs + Width, YOffs + Height);
        end;
      stCall:
        begin
          DrawCanvas.Rectangle(XOffs, YOffs, XOffs + Width, YOffs + Height);
          DrawCanvas.MoveTo(XOffs + 5, YOffs);
          DrawCanvas.LineTo(XOffs + 5, YOffs + Height);
          DrawCanvas.MoveTo(XOffs + Width - 5, YOffs);
          DrawCanvas.LineTo(XOffs + Width - 5, YOffs + Height);
        end;
      stGlob:
        begin
          Color := $F0F0F0;
          DrawCanvas.RoundRect(XOffs, YOffs, XOffs + Width, YOffs + Height, 30, 30);
        end;
      stInit:
        begin
          Color := $EEDDDD;
          DrawCanvas.RoundRect(XOffs, YOffs, XOffs + Width, YOffs + Height, 30, 30);
        end;
      stStatement:
        begin
          DrawCanvas.Rectangle(XOffs, YOffs, XOffs + Width, YOffs + Height);
        end;
      stIf:
        begin
          PointArr[1].x := XOffs + Width div 2;
          PointArr[1].y := YOffs;

          PointArr[2].x := XOffs;
          PointArr[2].y := YOffs + Height div 2;

          PointArr[3].x := XOffs + Width div 2;
          PointArr[3].y := YOffs + Height - 1;

          PointArr[4].x := XOffs + Width - 1;
          PointArr[4].y := YOffs + Height div 2;

          DrawCanvas.Polygon(PointArr);
        end;
      stInOut:
        begin
          tx := 10;
          PointArr[1].x := XOffs + tx;
          PointArr[1].y := YOffs;

          PointArr[2].x := XOffs;
          PointArr[2].y := YOffs + Height - 1;

          PointArr[3].x := XOffs + Width - tx;
          PointArr[3].y := YOffs + Height - 1;

          PointArr[4].x := XOffs + Width - 1;
          PointArr[4].y := YOffs;

          DrawCanvas.Polygon(PointArr);
        end;
      stComment:
        begin
          DrawCanvas.Pen.Color := $C0C0C0;
          DrawCanvas.Pen.Style := psDot;
          DrawCanvas.Rectangle(XOffs, YOffs, XOffs + Width, YOffs + Height);

          // Added by Roman Mitin because in other case we have problems
          // with arrows line style in exported files.
          DrawCanvas.Pen.Style := psSolid;
          DrawCanvas.Pen.Color := clBlack;
        end;
      stConfl:
        begin
          // Offs added by Roman Mitin
          DrawCanvas.Ellipse(XOffs, YOffs, XOffs + ChildForm.ConflRadius, YOffs + ChildForm.ConflRadius);
        end;
    end;

    if bs = bsSolid then
      WriteText;
  end;

  if ChildForm.Actives.GetActive(Self) then
  begin
    DrawCanvas.Pen.Color := clBlue;
    DrawCanvas.Brush.Color := clBlue;
    DrawCanvas.Ellipse(XOffs - R, YOffs - R, XOffs + R, YOffs + R);
    DrawCanvas.Ellipse(XOffs + Width - R, YOffs - R, XOffs + Width + R, YOffs + R);
    DrawCanvas.Ellipse(XOffs - R, YOffs + Height - R, XOffs + R, YOffs + Height + R);
    DrawCanvas.Ellipse(XOffs + Width - R, YOffs + Height - R, XOffs + Width + R, YOffs + Height + R);
  end;
end;

end.

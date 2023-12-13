unit Block;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Constants;

type
  SetBlocks = (stBeginEnd, stStatement, stIf, stInOut, stCall, stGlob, stInit, stComment, stConfl);

  TBlock = class(TPaintBox)
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;

  private
    FBlockType: SetBlocks;

  public
    Ins: set of TBlockPort;
    Blocked: set of TBlockPort;

    Statement: TStringList;
    UnfText: TStringList;
    RemText: string;
    GlobStrings: TStringList;
    InitCode: TStringList;

    DrawCanvas: TCanvas;
    XOffs, YOffs: integer;

    procedure DrawPort(Port: TBlockPort);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;

    function IsPortAvail(t: TArrowTail; p: TBlockPort; LookAtAlready: boolean): boolean;

    function CanIDock(x, y: integer; Tail: TArrowTail; LookAtAlready: boolean): boolean;
    function GetPort(x, y: integer): TBlockPort;
    function GetPortPoint(Port: TBlockPort): TPoint;

    function Isd: boolean;

    procedure SetBlockType(Value: SetBlocks);
    procedure WriteText;

    property BlockType: SetBlocks read FBlockType write SetBlockType;
  end;

implementation

uses Child, Math, Main, Arrows;

(* **  TBlock  ** *)
procedure TBlock.MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  if ChildForm.ANew.New then
  begin
    ChildForm.FormMouseDown(nil, mbLeft, [], Left + x, Top + y);
    Exit;
  end;

  inherited;

  ChildForm.Refresh;
end;

procedure TBlock.MouseMove(Shift: TShiftState; x, y: integer);
begin
  if ChildForm.ANew.New then
    ChildForm.FormMouseMove(nil, [], Left + x, Top + y)
  else
    inherited;
end;

procedure TBlock.MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  if ChildForm.ANew.New then
    ChildForm.FormMouseUp(nil, mbLeft, [], Left + x, Top + y)
  else
  begin
    inherited;
    ChildForm.Refresh;
  end;
end;

function TBlock.GetPortPoint(Port: TBlockPort): TPoint;
begin
  case Port of
    North:
      Result := Point(Left + Width div 2, Top);
    East:
      Result := Point(Left + Width, Top + Height div 2);
    West:
      Result := Point(Left, Top + Height div 2);
    South:
      Result := Point(Left + Width div 2, Top + Height);
  end;
end;

function TBlock.GetPort(x, y: integer): TBlockPort;
begin
  Dec(x, Left);
  Dec(y, Top);
  Result := North;
  if (x > Width div 4) and (x <= 3 * Width div 4) and (y > -HotRadius) and (y <= Height div 2) then
    Result := North;
  if (x > Width div 4) and (x <= 3 * Width div 4) and (y > Height div 2) and (y <= Height + HotRadius) then
    Result := South;
  if (x > 3 * Width div 4) and (x <= Width + HotRadius) and (y > 0) and (y <= Height) then
    Result := East;
  if (x > 0 - HotRadius) and (x <= Width div 4) and (y > 0) and (y <= Height) then
    Result := West;
end;

// function TBlock.IsPortAvail(t: TArrowTail; p: TBlockPort; LookAtAlready: boolean): boolean;
// var
// i: integer;
//
// begin
// end;

function TBlock.CanIDock(x, y: integer; Tail: TArrowTail; LookAtAlready: boolean): boolean;
var
  t: TBlockPort;

  procedure SetColor(blink: boolean);
  begin
    if blink then
    begin
      Canvas.Pen.Color := clRed;
      Canvas.Brush.Color := clRed;
    end
    else
    begin
      Canvas.Pen.Color := $9900;
      Canvas.Brush.Color := $9900;
    end;
  end;

  function Test(p: TBlockPort): boolean;
  begin
    Result := false;
    case p of
      North:
        if (x > Width div 4) and (x <= 3 * Width div 4) and (y > 0 - HotRadius) and (y <= Height div 2) then
          Result := true;
      East:
        if (x > 3 * Width div 4) and (x <= Width + HotRadius) and (y > 0) and (y <= Height) then
          Result := true;
      West:
        if (x > -HotRadius) and (x <= Width div 4) and (y > 0) and (y <= Height) then
          Result := true;
      South:
        if (x > Width div 4) and (x <= 3 * Width div 4) and (y > Height div 2) and (y <= Height + HotRadius) then
          Result := true;
    end;
  end;

begin
  Result := false;
  SetColor(false);
  Dec(x, Left);
  Dec(y, Top);
  for t := North to South do
  begin
    if IsPortAvail(Tail, t, LookAtAlready) then
    begin
      if Test(t) then
        Result := true;
      SetColor(Test(t));
      DrawPort(t);
    end;
  end;
  SetColor(false);
end;

function TBlock.Isd: boolean;
var
  i: integer;

begin
  Result := false;
  for i := 0 to ChildForm.ArrowList.Count - 1 do
    if (ChildForm.ArrowList.Items[i].Blocks[atEnd].Block = Self) and
      (ChildForm.ArrowList.Items[i].Blocks[atEnd].Port = South) then
      Result := true;
end;

function TBlock.IsPortAvail(t: TArrowTail; p: TBlockPort; LookAtAlready: boolean): boolean;
var
  i: integer;
  w, s, e: bool;
  blockRec: TBlockRec;

begin
  if BlockType <> stIf then
  begin
    // Result := inherited IsPortAvail(t, p, laa)
    Result := true;
    if p in Blocked then
      Result := false;
    if (t = atStart) and (not(p in Ins)) then
      Result := false;
    if t = atEnd then
    begin
      if p in Ins then
        Result := false;
      if LookAtAlready then
        for i := 0 to ChildForm.ArrowList.Count - 1 do
          if (ChildForm.ArrowList.Items[i].Blocks[atEnd].Block = Self) and
            (ChildForm.ArrowList.Items[i].Blocks[atEnd].Port = p) then
            Result := false;
    end
  end
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
        begin
          blockRec := ChildForm.ArrowList.Items[i].Blocks[atEnd];
          if blockRec.Block = Self then
          begin
            if blockRec.Port = West then
              w := true;
            if blockRec.Port = South then
              s := true;
            if blockRec.Port = East then
              e := true;
          end;
        end;
        if (w and s) or (s and e) or (e and w) then
        begin
          Result := false;
          Exit;
        end;
        if (w and (p = West)) or (s and (p = South)) or (e and (p = East)) then
        begin
          Result := false;
          Exit;
        end;
        if e then
        begin
          Result := not(s or w);
          Exit;
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

  if BlockType = stGlob then
    Lines := GlobStrings;
  if BlockType = stInit then
    Lines := InitCode;
  if BlockType = stComment then
    Lines := UnfText;
  if BlockType = stConfl then
    Exit;

  tW := 0;
  tH := 0;
  for i := 0 to Lines.Count - 1 do
  begin
    tW := Max(tW, DrawCanvas.TextWidth(Lines[i]));
    tH := tH + DrawCanvas.TextHeight(Lines[0]) + LineInd;
  end;

  case FBlockType of
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

  if w < ChildForm.WidthBlock then
    w := ChildForm.WidthBlock;
  if H < ChildForm.HeightBlock then
    H := ChildForm.HeightBlock;

  Left := Left - (w - Width) div 2;
  Top := Top - (H - Height) div 2;
  Width := w;
  Height := H;

  for i := 0 to Lines.Count - 1 do
    DrawCanvas.TextOut(XOffs + (w - tW) div 2, YOffs + (H - tH) div 2 + i * (DrawCanvas.TextHeight('A') + LineInd),
      Lines[i]);
end;

procedure TBlock.SetBlockType(Value: SetBlocks);
begin
  FBlockType := Value;
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
  if not(BlockType in [stIf, stConfl]) then
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
  if BlockType = stIf then
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
  if BlockType = stConfl then
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

  if BlockType = stIf then
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

    case BlockType of
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

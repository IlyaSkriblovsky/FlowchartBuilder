unit Arrows;

interface

uses Windows, Classes, Controls, Types, ExtCtrls, Graphics, Math, Block, Constants;

type
  TBlockRec = record
    Block: TBlock;
    Port: TBlockPort;
  end;

  TBlockArr = array [TArrowTail] of TBlockRec;

  TArrow = class
    Blocks: TBlockArr;
    pTail: TArrowTail;
    _Type: TArrowType;

    DragObj: TDragObj;
    IsDrag: boolean;
    Hide: boolean;

    DoesNotUnDock: boolean;

    oldTail: array [TArrowTail] of TPoint;

    Style: TArrowStyle;

    DrawCanvas: TCanvas;
    xo, yo: integer;

    constructor Create;

    procedure Draw;
    procedure Drag(x, y: integer);
    procedure MouseDown(Shift: TShiftState);
    procedure MouseTest;
    procedure GetObj;

    procedure Dock(Block: TBlock; Tl: TArrowTail; Port: TBlockPort);
    procedure UnDock(Tl: TArrowTail);

    procedure StandWell;

    function GetReallyTail(t: TArrowTail): TPoint;

    function GetTail(t: TArrowTail): TPoint;
    procedure SetTail(t: TArrowTail; Value: TPoint);
    function GetP: integer;
    procedure SetP(Value: integer);

    property Tail[t: TArrowTail]: TPoint read GetTail write SetTail;
    property p: integer read GetP write SetP;

  public
    FTail: array [TArrowTail] of TPoint;
    Fp: integer;

  end;

var
  Mouse, dMouse: TPoint;

  // Variables for Undo
  unOrig: array [TArrowTail] of TPoint;
  unP: integer;
  unType: TArrowType;
  unStyle: TArrowStyle;
  unBlock: array [TArrowTail] of TBlock;
  unPort: array [TArrowTail] of TBlockPort;

function Obj2Tail(obj: TDragObj): TArrowTail;
function Tail2Obj(t: TArrowTail): TDragObj;
function SecTail(t: TArrowTail): TArrowTail;

implementation

uses Child, Main;

(* **  Utility Functions  ** *)
function sh: integer;
begin
  Result := ChildForm.HorzScrollBar.Position;
end;

function sv: integer;
begin
  Result := ChildForm.VertScrollBar.Position;
end;

function Obj2Tail(obj: TDragObj): TArrowTail;
begin
  if obj = st then
    Result := atStart
  else
    Result := atEnd;
end;

function Tail2Obj(t: TArrowTail): TDragObj;
begin
  if t = atStart then
    Result := st
  else
    Result := en;
end;

function SecTail(t: TArrowTail): TArrowTail;
begin
  if t = atStart then
    Result := atEnd
  else
    Result := atStart;
end;

(* **  TArrow  ** *)
function TArrow.GetReallyTail(t: TArrowTail): TPoint;
begin
  if Blocks[t].Block = nil then
    Result := Tail[t]
  else
    case Blocks[t].Port of
      North:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y - BlockMargin);
      East:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x + BlockMargin,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y);
      West:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x - BlockMargin,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y);
      South:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y + BlockMargin);
    end;
end;

procedure TArrow.StandWell;
var
  t: TArrowTail;
  b: TBlock;
  s: TArrowStyle;

begin
  s := Style;
  for t := atStart to atEnd do
    if Blocks[t].Block <> nil then
      case Blocks[t].Port of
        North:
          if GetReallyTail(SecTail(t)).y > GetReallyTail(t).y then
            Style := eg4
          else
            Style := eg2;
        East:
          if (GetReallyTail(SecTail(t)).x < GetReallyTail(t).x) or
            ((GetReallyTail(SecTail(t)).y < GetReallyTail(t).y) and (Blocks[SecTail(t)].Block <> nil)) then
            Style := eg4
          else
            Style := eg2;
        West:
          if (GetReallyTail(SecTail(t)).x > GetReallyTail(t).x) or
            ((GetReallyTail(SecTail(t)).y < GetReallyTail(t).y) and (Blocks[SecTail(t)].Block <> nil)) then
            Style := eg4
          else
            Style := eg2;
        South:
          if GetReallyTail(SecTail(t)).y < GetReallyTail(t).y then
            Style := eg4
          else
            Style := eg2;
      end;

  if (s = eg4) and (Style = eg2) and IsDrag then
    Tail[SecTail(Obj2Tail(DragObj))] := oldTail[SecTail(Obj2Tail(DragObj))];

  if (Blocks[atStart].Block = nil) and (Blocks[atEnd].Block = nil) then
    Style := eg4;

  if Style = eg2 then
    for t := atStart to atEnd do
      if Blocks[t].Block <> nil then
        case Blocks[t].Port of
          North, South:
            _Type := vert;
          East, West:
            _Type := horiz;
        end;

  if Style = eg2 then
    for t := atStart to atEnd do
      if Blocks[t].Block <> nil then
        case _Type of
          vert:
            if Abs(Tail[atStart].x - Tail[atEnd].x) < ArrH then
            begin
              _Type := horiz;
              if Blocks[t].Block.GetPortPoint(Blocks[t].Port).y < Tail[SecTail(t)].y then
                Tail[t] := Point(Tail[t].x, Tail[SecTail(t)].y - 20);
            end;
          horiz:
            if Abs(Tail[atStart].y - Tail[atEnd].y) < ArrH then
            begin
              _Type := vert;
              if Blocks[t].Block.GetPortPoint(Blocks[t].Port).x < Tail[SecTail(t)].x then
                Tail[t] := Point(Tail[SecTail(t)].x - 20, Tail[t].y);
            end;
        end;

  if Style = eg2 then
    for t := atStart to atEnd do
      case _Type of
        vert:
          if (Tail[t].x < Tail[SecTail(t)].x) and (GetReallyTail(t).x > Tail[SecTail(t)].x) or
            (Tail[t].x > Tail[SecTail(t)].x) and (GetReallyTail(t).x < Tail[SecTail(t)].x) then
            Tail[t] := GetReallyTail(t);
        horiz:
          if (Tail[t].y < Tail[SecTail(t)].y) and (GetReallyTail(t).y > Tail[SecTail(t)].y) or
            (Tail[t].y > Tail[SecTail(t)].y) and (GetReallyTail(t).y < Tail[SecTail(t)].y) then
            Tail[t] := GetReallyTail(t);
      end;

  {
    если выходим за границу
    то выравниваемся
    }
  (* v:=sv;
    h:=sh;
    for t:=atStart to atEnd
    do begin
    if Tail[t].x+h<l
    then Tail[t]:=Point(l-h, Tail[t].y);
    if Tail[t].x+h>ChildForm.HorzScrollBar.Range-l
    then Tail[t]:=Point(ChildForm.HorzScrollBar.Range-l-h, Tail[t].y);
    if Tail[t].y+v<l
    then Tail[t]:=Point(Tail[t].x, l-v);
    if Tail[t].y+v>ChildForm.VertScrollBar.Range-l
    then Tail[t]:=Point(Tail[t].x, ChildForm.VertScrollBar.Range-l-v);
    end;
    if p<=l
    then p:=l;
    case _Type of
    vert: if p>ChildForm.ClientWidth-l
    then p:=ChildForm.ClientWidth-l;
    horiz: if p>ChildForm.ClientHeight-l
    then p:=ChildForm.ClientHeight-l;
    end; *)

  {
    если 2 звена оказались рядом и не нажат Alt
    то выравниваем
    }
  if IsDrag and (DragObj in [st, en]) and (not GetKeyState(VK_MENU) <= 0) then
    case _Type of
      vert:
        if Abs(Tail[atStart].y - Tail[atEnd].y) <= MinDrag then
          Tail[Obj2Tail(DragObj)] := Point(Tail[Obj2Tail(DragObj)].x, Tail[SecTail(Obj2Tail(DragObj))].y);
      horiz:
        if Abs(Tail[atStart].x - Tail[atEnd].x) <= MinDrag then
          Tail[Obj2Tail(DragObj)] := Point(Tail[SecTail(Obj2Tail(DragObj))].x, Tail[Obj2Tail(DragObj)].y);
    end;

  if IsDrag and (DragObj = pnt) then
    case _Type of
      vert:
        if Abs(Tail[atEnd].x - p) <= MinDrag then
          p := Tail[atEnd].x;
      horiz:
        if Abs(Tail[atEnd].y - p) <= MinDrag then
          p := Tail[atEnd].y;
    end;
  if (Blocks[atStart].Block <> nil) and IsDrag and (DragObj = pnt) then
    case _Type of
      vert:
        if Abs(Tail[atStart].x - p) <= MinDrag then
          p := Tail[atStart].x;
      horiz:
        if Abs(Tail[atStart].y - p) <= MinDrag then
          p := Tail[atStart].y;
    end;

  case _Type of
    vert:
      begin
        for t := atStart to atEnd do
        begin
          if (Tail[t].x <= p) and (Blocks[t].Block <> nil) and (Blocks[t].Port = West) then
            Tail[t] := Point(p, Tail[t].y); // p:=Tail[t].x;
          if (Tail[t].x > p) and (Blocks[t].Block <> nil) and (Blocks[t].Port = East) then
            Tail[t] := Point(p, Tail[t].y); // p:=Tail[t].x;
        end;
      end;
    horiz:
      begin
        for t := atStart to atEnd do
        begin
          if (Tail[t].y <= p) and (Blocks[t].Block <> nil) and (Blocks[t].Port = North) then
            Tail[t] := Point(Tail[t].x, p); // p:=Tail[t].y;
          if (Tail[t].y > p) and (Blocks[t].Block <> nil) and (Blocks[t].Port = South) then
            Tail[t] := Point(Tail[t].x, p); // p:=Tail[t].y;
        end;
      end;
  end;

  {
    если нас тащут и каким-то концом прицеплены за одину сторону блока и другой конец на другой
    стороне блока
    то выравниваемся, обходя блок
    }
  if true // IsDrag
    then
    for t := atStart to atEnd do
      if DragObj = Tail2Obj(SecTail(t)) then
      begin
        b := Blocks[t].Block;
        if b <> nil then
          case Blocks[t].Port of
            North:
              if (Tail[SecTail(t)].y > b.Top
                { +b.Height } ) and (Tail[SecTail(t)].x > b.Left) and (Tail[SecTail(t)].x < b.Left + b.Width) then
              begin
                _Type := vert;
                if Tail[SecTail(t)].x <= b.Left + b.Width div 2 then
                  p := Min(p, b.Left - BlockMargin)
                else
                  p := Max(p, b.Left + b.Width + BlockMargin);
              end;
            East:
              if (Tail[SecTail(t)].x <= b.Left + b.Width) and (Tail[SecTail(t)].y > b.Top) and
                (Tail[SecTail(t)].y < b.Top + b.Height) then
              begin
                _Type := horiz;
                if Tail[SecTail(t)].y <= b.Top + b.Height div 2 then
                  p := Min(p, b.Top - BlockMargin)
                else
                  p := Max(p, b.Top + b.Height + BlockMargin);
              end;
            West:
              if (Tail[SecTail(t)].x > b.Left
                { +b.Width } ) and (Tail[SecTail(t)].y > b.Top) and (Tail[SecTail(t)].y < b.Top + b.Height) then
              begin
                _Type := horiz;
                if Tail[SecTail(t)].y <= b.Top + b.Height div 2 then
                  p := Min(p, b.Top - BlockMargin)
                else
                  p := Max(p, b.Top + b.Height + BlockMargin);
              end;
            South:
              if (Tail[SecTail(t)].y <= b.Top + b.Height) and (Tail[SecTail(t)].x > b.Left) and
                (Tail[SecTail(t)].x < b.Left + b.Width) then
              begin
                _Type := vert;
                if Tail[SecTail(t)].x <= b.Left + b.Width div 2 then
                  p := Min(p, b.Left - BlockMargin)
                else
                  p := Max(p, b.Left + b.Width + BlockMargin);
              end;
          end;
      end;

  {
    ??  если прицеплены и
    }
  for t := atStart to atEnd do
  begin
    b := Blocks[t].Block;
    if b <> nil then
      case Blocks[t].Port of
        North:
          if (Tail[t].x = p) and (Tail[t].y < Tail[SecTail(t)].y) then
            Tail[t] := Point(Tail[t].x, Tail[SecTail(t)].y);
        East:
          if (Tail[t].y = p) and (Tail[t].x > Tail[SecTail(t)].x) then
            Tail[t] := Point(Tail[SecTail(t)].x, Tail[t].y);
        West:
          if (Tail[t].y = p) and (Tail[t].x < Tail[SecTail(t)].x) then
            Tail[t] := Point(Tail[SecTail(t)].x, Tail[t].y);
        South:
          if (Tail[t].x = p) and (Tail[t].y > Tail[SecTail(t)].y) then
            Tail[t] := Point(Tail[t].x, Tail[SecTail(t)].y);
      end;
  end;

  {
    если прицеплены и прицепленый конец тащут слишком близко к блоку
    то оставляем прицепленый конец на должном расстоянии от блока
    }
  for t := atStart to atEnd do
  begin
    b := Blocks[t].Block;
    if b <> nil then
      case Blocks[t].Port of
        North:
          if Tail[t].y > b.GetPortPoint(North).y - BlockMargin then
            Tail[t] := Point(Tail[t].x, b.GetPortPoint(North).y - BlockMargin);
        East:
          if Tail[t].x <= b.GetPortPoint(East).x + BlockMargin then
            Tail[t] := Point(b.GetPortPoint(East).x + BlockMargin, Tail[t].y);
        West:
          if Tail[t].x > b.GetPortPoint(West).x - BlockMargin then
            Tail[t] := Point(b.GetPortPoint(West).x - BlockMargin, Tail[t].y);
        South:
          if Tail[t].y <= b.GetPortPoint(South).y + BlockMargin then
            Tail[t] := Point(Tail[t].x, b.GetPortPoint(South).y + BlockMargin);
      end;
  end;

  {
    если прицеплены и неприцепленый конец тащут слишком близко к блоку
    то оставляем неприцепленый конец на должном расстоянии от блока
    }
  for t := atStart to atEnd do
  begin
    b := Blocks[SecTail(t)].Block;
    if b <> nil then
      case _Type of
        horiz:
          if // (((Tail[t].y>b.Top) and (p<b.Top)) or ((Tail[t].y<b.Top) and (p>b.Top))) and
            (Tail[t].y > b.Top) and (Tail[t].y < b.Top + b.Height) and (Tail[t].x > b.Left - BlockMargin) and
            (Tail[t].x < b.Left + b.Width + BlockMargin) then
            if Tail[t].x < b.Left + b.Width div 2 then
              Tail[t] := Point(b.Left - BlockMargin, Tail[t].y)
            else
              Tail[t] := Point(b.Left + b.Width + BlockMargin, Tail[t].y);
        vert:
          if // (((Tail[t].x>b.Left) {and (p<b.Left)}) or ((Tail[t].x<b.Left) {and (p>b.Left)})) and
            (Tail[t].x > b.Left) and (Tail[t].x < b.Left + b.Width) and (Tail[t].y > b.Top - BlockMargin) and
            (Tail[t].y < b.Top + b.Height + BlockMargin) then
            if Tail[t].y < b.Top + b.Height div 2 then
              Tail[t] := Point(Tail[t].x, b.Top - BlockMargin)
            else
              Tail[t] := Point(Tail[t].x, b.Top + b.Height + BlockMargin);
      end;
  end;

  {
    если прицеплены и среднее звено тащут слишком близко к блоку
    то оставляем среднее звено на должном расстоянии от блока
    }
  for t := atStart to atEnd do
  begin
    b := Blocks[t].Block;
    if b <> nil then
      case Blocks[t].Port of
        East:
          if (_Type = vert) and (p < b.Left + b.Width + BlockMargin) then
            p := b.Left + b.Width + BlockMargin;
        West:
          if (_Type = vert) and (p > b.Left - BlockMargin) then
            p := b.Left - BlockMargin;
        North:
          if (_Type = horiz) and (p > b.Top - BlockMargin) then
            p := b.Top - BlockMargin;
        South:
          if (_Type = horiz) and (p < b.Top + b.Height + BlockMargin) then
            p := b.Top + b.Height + BlockMargin;
      end;
  end;
  for t := atStart to atEnd do
  begin
    b := Blocks[t].Block;
    if b <> nil then
      case Blocks[t].Port of
        North:
          if (_Type = vert) and (Tail[SecTail(t)].y > b.Top) and (p > b.Left - BlockMargin) and
            (p < b.Left + b.Width + BlockMargin) then
          begin
            if p <= b.Left + b.Width div 2 then
              p := b.Left - BlockMargin
            else
              p := b.Left + b.Width + BlockMargin;
          end;
        East:
          if (_Type = horiz) and (Tail[SecTail(t)].x < b.Left + b.Width) and (p > b.Top - BlockMargin) and
            (p < b.Top + b.Height + BlockMargin) then
          begin
            if p <= b.Top + b.Height div 2 then
              p := b.Top - BlockMargin
            else
              p := b.Top + b.Height + BlockMargin;
          end;
        West:
          if (_Type = horiz) and (Tail[SecTail(t)].x > b.Left) and (p > b.Top - BlockMargin) and
            (p < b.Top + b.Height + BlockMargin) then
          begin
            if p <= b.Top + b.Height div 2 then
              p := b.Top - BlockMargin
            else
              p := b.Top + b.Height + BlockMargin;
          end;
        South:
          if (_Type = vert) and (Tail[SecTail(t)].y < b.Top + b.Height) and (p > b.Left - BlockMargin) and
            (p < b.Left + b.Width + BlockMargin) then
          begin
            if p <= b.Left + b.Width div 2 then
              p := b.Left - BlockMargin
            else
              p := b.Left + b.Width + BlockMargin;
          end;
      end;
  end;

  { if (DragObj=st) and (Style=eg4) and (Blocks[atEnd].Block<>nil) and
    (Blocks[atEnd].Port=South) and (Tail[atStart].y<Tail[atEnd].y) and
    (_Type=vert) and (p>Blocks[atEnd].Block.Left-l)
    then p:=Blocks[atEnd].Block.Left-l; }
end;

constructor TArrow.Create;
begin
  Blocks[atStart].Block := nil;
  Blocks[atEnd].Block := nil;
  xo := 0;
  yo := 0;
  Style := eg4;
  DrawCanvas := ChildForm.Canvas;
end;

procedure TArrow.UnDock(Tl: TArrowTail);
begin
  Blocks[Tl].Block := nil;

  if IsDrag then
    Tail[SecTail(Obj2Tail(DragObj))] := oldTail[SecTail(Obj2Tail(DragObj))];

  // Draw;
  StandWell;

  Draw;
  if not Hide then
    ChildForm.Refresh;
  // ChildForm.OnPaint(nil);
end;

procedure TArrow.Dock(Block: TBlock; Tl: TArrowTail; Port: TBlockPort);
begin
  Blocks[Tl].Block := Block;
  Blocks[Tl].Port := Port;

  case Port of
    South, North:
      _Type := vert;
    East, West:
      _Type := horiz;
  end;

  if IsDrag and (Style = eg4) then
    Tail[SecTail(Obj2Tail(DragObj))] := oldTail[SecTail(Obj2Tail(DragObj))];

  // Draw;
  StandWell;
  Draw;
  if not Hide then
    ChildForm.Refresh;
  // ChildForm.OnPaint(nil);
end;

function TArrow.GetP: integer;
begin
  Result := 0; // Run away the warning
  case _Type of
    vert:
      Result := Fp - sh;
    horiz:
      Result := Fp - sv;
  end;
end;

procedure TArrow.SetP(Value: integer);
begin
  case _Type of
    vert:
      Fp := Value + sh;
    horiz:
      Fp := Value + sv;
  end;
end;

function TArrow.GetTail(t: TArrowTail): TPoint;
var
  b: TBlock;
  q: TPoint;

begin
  b := Blocks[t].Block;
  if b = nil then
    Result := FTail[t]
  else
    case Blocks[t].Port of
      North:
        Result := Point(b.Left + b.Width div 2 + sh, FTail[t].y);
      East:
        Result := Point(FTail[t].x, b.Top + b.Height div 2 + sv);
      West:
        Result := Point(FTail[t].x, b.Top + b.Height div 2 + sv);
      South:
        Result := Point(b.Left + b.Width div 2 + sh, FTail[t].y);
    end;
  q := Result;
  Result := Point(q.x - sh, q.y - sv);
end;

procedure TArrow.SetTail(t: TArrowTail; Value: TPoint);
begin
  FTail[t] := Point(Value.x + sh, Value.y + sv);
  if Style = eg2 then
    case _Type of
      vert:
        begin
          FTail[SecTail(t)].y := FTail[t].y;
          p := (Tail[t].x + Tail[SecTail(t)].x) div 2;
        end;
      horiz:
        begin
          FTail[SecTail(t)].x := FTail[t].x;
          p := (Tail[t].y + Tail[SecTail(t)].y) div 2;
        end;
    end;
end;

procedure TArrow.Draw;
var
  i: TArrowTail;
  b: TBlock;
  DrawElls: boolean;

  procedure Ell(x, y: integer);
  const
    R = 3;
  begin
    DrawCanvas.Brush.Color := clBlue;
    DrawCanvas.Pen.Color := clBlue;
    DrawCanvas.Pen.Mode := pmCopy;
    DrawCanvas.Ellipse(xo + x - R, yo + y - R, xo + x + R, yo + y + R);
    if IsDrag then
      DrawCanvas.Pen.Mode := pmNot;
    DrawCanvas.Pen.Color := clBlack;
  end;

  procedure Pntr(x, y: integer; Dir: TBlockPort);
  var
    i: integer;

  begin
    for i := 0 to ArrH - 1 do
      case Dir of
        North:
          begin
            DrawCanvas.MoveTo(xo + x - Round(i / ArrH * ArrW), yo + y - i);
            DrawCanvas.LineTo(xo + x + Round(i / ArrH * ArrW), yo + y - i);
          end;
        East:
          begin
            DrawCanvas.MoveTo(xo + x + i, yo + y - Round(i / ArrH * ArrW));
            DrawCanvas.LineTo(xo + x + i, yo + y + Round(i / ArrH * ArrW));
          end;
        West:
          begin
            DrawCanvas.MoveTo(xo + x - i, yo + y - Round(i / ArrH * ArrW));
            DrawCanvas.LineTo(xo + x - i, yo + y + Round(i / ArrH * ArrW));
          end;
        South:
          begin
            DrawCanvas.MoveTo(xo + x - Round(i / ArrH * ArrW), yo + y + i);
            DrawCanvas.LineTo(xo + x + Round(i / ArrH * ArrW), yo + y + i);
          end;
      end;
    DrawCanvas.MoveTo(xo + x, yo + y);
    case Dir of
      North:
        DrawCanvas.LineTo(xo + x, yo + y - ArrH);
      East:
        DrawCanvas.LineTo(xo + x + ArrH, yo + y);
      West:
        DrawCanvas.LineTo(xo + x - ArrH, yo + y);
      South:
        DrawCanvas.LineTo(xo + x, yo + y + ArrH);
    end;
  end;

begin
  if Hide then
    Exit;

  DrawCanvas.Pen.Mode := pmCopy;
  if IsDrag then
    DrawCanvas.Pen.Mode := pmNot;
  DrawCanvas.Pen.Color := clBlack;
  DrawCanvas.MoveTo(xo + Tail[atStart].x, yo + Tail[atStart].y);
  if Style = eg4 then
    case _Type of
      horiz:
        begin
          DrawCanvas.LineTo(xo + Tail[atStart].x, yo + p);
          DrawCanvas.LineTo(xo + Tail[atEnd].x, yo + p);
          DrawCanvas.LineTo(xo + Tail[atEnd].x, yo + Tail[atEnd].y);
        end;
      vert:
        begin
          DrawCanvas.LineTo(xo + p, yo + Tail[atStart].y);
          DrawCanvas.LineTo(xo + p, yo + Tail[atEnd].y);
          DrawCanvas.LineTo(xo + Tail[atEnd].x, yo + Tail[atEnd].y);
        end;
    end
  else
  begin
    Tail[atStart] := Tail[atStart];
    Tail[atEnd] := Tail[atEnd];
    DrawCanvas.LineTo(xo + Tail[atEnd].x, yo + Tail[atEnd].y);
  end;

  i := atStart;
  if Blocks[i].Block <> nil then
    Pntr(Blocks[i].Block.GetPortPoint(Blocks[i].Port).x, Blocks[i].Block.GetPortPoint(Blocks[i].Port).y, Blocks[i].Port)
  else
    case _Type of
      vert:
        if Tail[i].x > p then
          Pntr(Tail[i].x, Tail[i].y, West)
        else
          Pntr(Tail[i].x, Tail[i].y, East);
      horiz:
        if Tail[i].y > p then
          Pntr(Tail[i].x, Tail[i].y, North)
        else
          Pntr(Tail[i].x, Tail[i].y, South);
    end;

  DrawElls := true;
  if IsDrag then
    DrawElls := false;
  if not ChildForm.Actives.GetActive(Self) then
    DrawElls := false;

  if DrawElls then
  begin
    for i := atStart to atEnd do
      Ell(Tail[i].x, Tail[i].y);
    if Style = eg4 then
      case _Type of
        vert:
          begin
            Ell(p, Tail[atStart].y);
            Ell(p, Tail[atEnd].y);
          end;
        horiz:
          begin
            Ell(Tail[atStart].x, p);
            Ell(Tail[atEnd].x, p);
          end;
      end;
    for i := atStart to atEnd do
      if Blocks[i].Block <> nil then
        Ell(Blocks[i].Block.GetPortPoint(Blocks[i].Port).x, Blocks[i].Block.GetPortPoint(Blocks[i].Port).y);
  end;

  for i := atStart to atEnd do
  begin
    b := Blocks[i].Block;
    if b <> nil then
    begin
      DrawCanvas.MoveTo(xo + Tail[i].x, yo + Tail[i].y);
      case Blocks[i].Port of
        North:
          DrawCanvas.LineTo(xo + b.Left + b.Width div 2, yo + b.Top);
        East:
          DrawCanvas.LineTo(xo + b.Left + b.Width - 1, yo + b.Top + b.Height div 2);
        West:
          DrawCanvas.LineTo(xo + b.Left, yo + b.Top + b.Height div 2);
        South:
          DrawCanvas.LineTo(xo + b.Left + b.Width div 2, yo + b.Top + b.Height - 1);
      end;
    end;
  end;
end;

procedure TArrow.MouseTest;
var
  t: TDragObj;
  q: TArrowTail;

begin
  if Viewer then
    Exit;

  t := DragObj;
  q := pTail;
  GetObj;
  { if DragObj<>none
    then ChildForm.Cursor:=crSizeWE; }
  pTail := q;
  DragObj := t;
end;

procedure TArrow.Drag(x, y: integer);
var
  i, j: integer;

begin
  if not Hide then
    Draw;
  StandWell;
  case DragObj of
    st:
      Tail[atStart] := Point(x, y);
    en:
      Tail[atEnd] := Point(x, y);
    pnt:
      case _Type of
        horiz:
          begin
            p := y;
            Tail[pTail] := Point(x, dMouse.y + Tail[pTail].y);
          end;
        vert:
          begin
            p := x;
            Tail[pTail] := Point(dMouse.x + Tail[pTail].x, y);
          end;
      end;
  end;

  {
    если нас тащут за конец и он может быть прицеплен
    то прицепляемся
    если нас тащут за конец и этот конец прицеплен и он не может быть прицеплен
    то отцепляемся
    }
  if not DoesNotUnDock then
  begin
    for i := 0 to ChildForm.BlockList.Count - 1 do
      if ChildForm.BlockList.Items[i].CanIDock(x, y, Obj2Tail(DragObj), true) then
      begin
        if Blocks[Obj2Tail(DragObj)].Block <> nil then
          UnDock(Obj2Tail(DragObj));
        Dock(ChildForm.BlockList[i], Obj2Tail(DragObj), ChildForm.BlockList.Items[i].GetPort(x, y));
        if not ChildForm.ANew.New then
          Draw;
      end;
    if Blocks[Obj2Tail(DragObj)].Block <> nil then
    begin
      if not Blocks[Obj2Tail(DragObj)].Block.CanIDock(x, y, Obj2Tail(DragObj), false) then
      begin
        UnDock(Obj2Tail(DragObj));
        if not ChildForm.ANew.New then
          Draw;
      end;
    end;
  end;

  {
    если нас тащут за конец и второй конец не прицеплен
    то если разность между абсциссами концов больше разности между ординатами концов
    то устанавливаем среднее звено вертикально
    иначе устанавливаем среднее звено горизонтально
    устанавливаем среднее звено посередине
    }
  if (DragObj <> pnt) and (Blocks[SecTail(Obj2Tail(DragObj))].Block = nil) then
  begin
    if Abs(Tail[atStart].x - Tail[atEnd].x) > Abs(Tail[atStart].y - Tail[atEnd].y) then
      _Type := vert
    else
      _Type := horiz;
    case _Type of
      vert:
        p := (Tail[atStart].x + Tail[atEnd].x) div 2;
      horiz:
        p := (Tail[atStart].y + Tail[atEnd].y) div 2;
    end;
  end;

  StandWell;

  if not Hide then
    Draw;

  if (DragObj in [st, en]) and (Blocks[Obj2Tail(DragObj)].Block = nil) then
  begin
    for j := 0 to ChildForm.BlockList.Count - 1 do
      ChildForm.BlockList.Items[j].CanIDock(Mouse.x, Mouse.y, Obj2Tail(DragObj), true);
  end;
end;

procedure TArrow.GetObj;
begin
  DragObj := none;
  if (Mouse.x > Tail[atStart].x - HotRadius) and (Mouse.x < Tail[atStart].x + HotRadius) and
    (Mouse.y > Tail[atStart].y - HotRadius) and (Mouse.y < Tail[atStart].y + HotRadius) then
    DragObj := st;
  if (Mouse.x > Tail[atEnd].x - HotRadius) and (Mouse.x < Tail[atEnd].x + HotRadius) and
    (Mouse.y > Tail[atEnd].y - HotRadius) and (Mouse.y < Tail[atEnd].y + HotRadius) then
    DragObj := en;
  case _Type of
    horiz:
      begin
        if (Mouse.x > Tail[atStart].x - HotRadius) and (Mouse.x < Tail[atStart].x + HotRadius) and
          (Mouse.y > p - HotRadius) and (Mouse.y < p + HotRadius) then
        begin
          DragObj := pnt;
          pTail := atStart;
        end;
        if (Mouse.x > Tail[atEnd].x - HotRadius) and (Mouse.x < Tail[atEnd].x + HotRadius) and (Mouse.y > p - HotRadius)
          and (Mouse.y < p + HotRadius) then
        begin
          DragObj := pnt;
          pTail := atEnd;
        end;
      end;
    vert:
      begin
        if (Mouse.x > p - HotRadius) and (Mouse.x < p + HotRadius) and (Mouse.y > Tail[atStart].y - HotRadius) and
          (Mouse.y < Tail[atStart].y + HotRadius) then
        begin
          DragObj := pnt;
          pTail := atStart;
        end;
        if (Mouse.x > p - HotRadius) and (Mouse.x < p + HotRadius) and (Mouse.y > Tail[atEnd].y - HotRadius) and
          (Mouse.y < Tail[atEnd].y + HotRadius) then
        begin
          DragObj := pnt;
          pTail := atEnd;
        end;
      end;
  end;
end;

procedure TArrow.MouseDown(Shift: TShiftState);
var
  i: TArrowTail;
  j: integer;
  Backup: TBlockArr;

begin
  if Viewer then
    Exit;

  Backup := Blocks;
  for i := atStart to atEnd do
    if Blocks[i].Block <> nil then
      if (Mouse.x > Blocks[i].Block.GetPortPoint(Blocks[i].Port).x - HotRadius) and
        (Mouse.x < Blocks[i].Block.GetPortPoint(Blocks[i].Port).x + HotRadius) and
        (Mouse.y > Blocks[i].Block.GetPortPoint(Blocks[i].Port).y - HotRadius) and
        (Mouse.y < Blocks[i].Block.GetPortPoint(Blocks[i].Port).y + HotRadius) then
      begin
        UnDock(i);
        Tail[i] := Point(Mouse.x, Mouse.y);
        ChildForm.Refresh;
      end;

  GetObj;
  if DragObj <> none then
  begin
    unOrig[atStart] := Tail[atStart];
    unOrig[atEnd] := Tail[atEnd];
    unP := p;
    unType := _Type;
    unStyle := Style;
    unBlock[atStart] := Backup[atStart].Block;
    unBlock[atEnd] := Backup[atEnd].Block;
    unPort[atStart] := Blocks[atStart].Port;
    unPort[atEnd] := Blocks[atEnd].Port;

    oldTail[atStart] := Tail[atStart];
    oldTail[atEnd] := Tail[atEnd];

    IsDrag := true;
  end;

  if (DragObj in [st, en]) and (Blocks[Obj2Tail(DragObj)].Block <> nil) then
    DoesNotUnDock := true;
  if DragObj = pnt then
    DoesNotUnDock := true;
  if (DragObj in [st, en]) and (Blocks[Obj2Tail(DragObj)].Block = nil) then
  begin
    for j := 0 to ChildForm.BlockList.Count - 1 do
      ChildForm.BlockList.Items[j].CanIDock(Mouse.x, Mouse.y, Obj2Tail(DragObj), true);
  end;

  case _Type of
    vert:
      if ((Mouse.x > Min(Tail[atStart].x, p) - HotRadius) and (Mouse.x < Max(Tail[atStart].x, p) + HotRadius) and
          (Mouse.y > Tail[atStart].y - HotRadius) and (Mouse.y < Tail[atStart].y + HotRadius)) or
        ((Mouse.x > p - HotRadius) and (Mouse.x < p + HotRadius) and (Mouse.y > Min(Tail[atStart].y,
            Tail[atEnd].y) - HotRadius) and (Mouse.y < Max(Tail[atStart].y, Tail[atEnd].y) + HotRadius)) or
        ((Mouse.x > Min(p, Tail[atEnd].x) - HotRadius) and (Mouse.x < Max(p, Tail[atEnd].x) + HotRadius) and
          (Mouse.y > Tail[atEnd].y - HotRadius) and (Mouse.y < Tail[atEnd].y + HotRadius)) then
      begin
        if not(ssShift in Shift) then
          ChildForm.Actives.Clear;
        ChildForm.Actives.SetActive(Self);
        ChildForm.Refresh;
      end;
    horiz:
      if ((Mouse.x > Tail[atStart].x - HotRadius) and (Mouse.x < Tail[atStart].x + HotRadius) and
          (Mouse.y > Min(Tail[atStart].y, p) - HotRadius) and (Mouse.y < Max(Tail[atStart].y, p) + HotRadius)) or
        ((Mouse.x > Min(Tail[atStart].x, Tail[atEnd].x) - HotRadius) and (Mouse.x < Max(Tail[atStart].x,
            Tail[atEnd].x) + HotRadius) and (Mouse.y > p - HotRadius) and (Mouse.y < p + HotRadius)) or
        ((Mouse.x > Tail[atEnd].x - HotRadius) and (Mouse.x < Tail[atEnd].x + HotRadius) and (Mouse.y > Min(p,
            Tail[atEnd].y) - HotRadius) and (Mouse.y < Max(p, Tail[atEnd].y) + HotRadius)) then
      begin
        if not(ssShift in Shift) then
          ChildForm.Actives.Clear;
        ChildForm.Actives.SetActive(Self);
        ChildForm.Refresh;
      end;
  end;
end;

end.

unit Arrows;

interface

uses Windows, Classes, Controls, Types, ExtCtrls, Graphics, Math;

type
  TTmpBlock = class;
  // Не перепутай: atStart - "голова" стрелки (<-), atEnd - "хвост" стрелки (--)
  // То есть выполнение идёт от "хвоста" стрелки к "голове"
  TArrowTail = (atStart, atEnd);
  TArrowStyle = (eg2, eg4);
  TArrowType = (horiz, vert);
  TBlockPort = (North, East, West, South);

  TBlockRec = record
    Block: TTmpBlock;
    Port: TBlockPort;
  end;

  TBlockArr = array [TArrowTail] of TBlockRec;

  TDragObj = (none, st, en, pnt);

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

    procedure Dock(Block: TTmpBlock; Tl: TArrowTail; Port: TBlockPort);
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

  TTmpBlock = class(TPaintBox)
  public
    Ins: set of TBlockPort;
    Blocked: set of TBlockPort;

    procedure DrawPort(p: TBlockPort); virtual; abstract;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;

    function IsPortAvail(t: TArrowTail; p: TBlockPort; LookAtAlready: boolean): boolean; virtual;

    function CanIDock(x, y: integer; Tail: TArrowTail; LookAtAlready: boolean): boolean;
    function GetPort(x, y: integer): TBlockPort;
    function GetPortPoint(Port: TBlockPort): TPoint;
  end;

const
  R = 5;
  arrW = 4;
  arrH = 10;
  l = 12;
  d = 5;

var
  Mous, dMous: TPoint;

  // Variables for Undo
  unOrig: array [TArrowTail] of TPoint;
  unP: integer;
  unType: TArrowType;
  unStyle: TArrowStyle;
  unBlock: array [TArrowTail] of TTmpBlock;
  unPort: array [TArrowTail] of TBlockPort;

function Obj2Tail(obj: TDragObj): TArrowTail;
function Tail2Obj(t: TArrowTail): TDragObj;
function SecTail(t: TArrowTail): TArrowTail;

implementation

uses Child, Main, EdTypes;

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

(* **  TTmpBlock  ** *)
procedure TTmpBlock.MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  if ChildForm.ANew.New then
  begin
    ChildForm.FormMouseDown(nil, mbLeft, [], Left + x, Top + y);
    Exit;
  end;

  inherited;

  ChildForm.Refresh;
end;

procedure TTmpBlock.MouseMove(Shift: TShiftState; x, y: integer);
begin
  if ChildForm.ANew.New then
    ChildForm.FormMouseMove(nil, [], Left + x, Top + y)
  else
    inherited;
end;

procedure TTmpBlock.MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  if ChildForm.ANew.New then
    ChildForm.FormMouseUp(nil, mbLeft, [], Left + x, Top + y)
  else
  begin
    inherited;
    ChildForm.Refresh;
  end;
end;

function TTmpBlock.GetPortPoint(Port: TBlockPort): TPoint;
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

function TTmpBlock.GetPort(x, y: integer): TBlockPort;
begin
  Dec(x, Left);
  Dec(y, Top);
  Result := North;
  if (x > Width div 4) and (x <= 3 * Width div 4) and (y > -R) and (y <= Height div 2) then
    Result := North;
  if (x > Width div 4) and (x <= 3 * Width div 4) and (y > Height div 2) and (y <= Height + R) then
    Result := South;
  if (x > 3 * Width div 4) and (x <= Width + R) and (y > 0) and (y <= Height) then
    Result := East;
  if (x > 0 - R) and (x <= Width div 4) and (y > 0) and (y <= Height) then
    Result := West;
end;

function TTmpBlock.IsPortAvail(t: TArrowTail; p: TBlockPort; LookAtAlready: boolean): boolean;
var
  i: integer;

begin
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
  end;
end;

function TTmpBlock.CanIDock(x, y: integer; Tail: TArrowTail; LookAtAlready: boolean): boolean;
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
        if (x > Width div 4) and (x <= 3 * Width div 4) and (y > 0 - R) and (y <= Height div 2) then
          Result := true;
      East:
        if (x > 3 * Width div 4) and (x <= Width + R) and (y > 0) and (y <= Height) then
          Result := true;
      West:
        if (x > -R) and (x <= Width div 4) and (y > 0) and (y <= Height) then
          Result := true;
      South:
        if (x > Width div 4) and (x <= 3 * Width div 4) and (y > Height div 2) and (y <= Height + R) then
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

(* **  TArrow  ** *)
function TArrow.GetReallyTail(t: TArrowTail): TPoint;
begin
  if Blocks[t].Block = nil then
    Result := Tail[t]
  else
    case Blocks[t].Port of
      North:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y - l);
      East:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x + l,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y);
      West:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x - l,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y);
      South:
        Result := Point(Blocks[t].Block.GetPortPoint(Blocks[t].Port).x,
          Blocks[t].Block.GetPortPoint(Blocks[t].Port).y + l);
    end;
end;

procedure TArrow.StandWell;
var
  t: TArrowTail;
  b: TTmpBlock;
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
            if Abs(Tail[atStart].x - Tail[atEnd].x) < arrH then
            begin
              _Type := horiz;
              if Blocks[t].Block.GetPortPoint(Blocks[t].Port).y < Tail[SecTail(t)].y then
                Tail[t] := Point(Tail[t].x, Tail[SecTail(t)].y - 20);
            end;
          horiz:
            if Abs(Tail[atStart].y - Tail[atEnd].y) < arrH then
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
        if Abs(Tail[atStart].y - Tail[atEnd].y) <= d then
          Tail[Obj2Tail(DragObj)] := Point(Tail[Obj2Tail(DragObj)].x, Tail[SecTail(Obj2Tail(DragObj))].y);
      horiz:
        if Abs(Tail[atStart].x - Tail[atEnd].x) <= d then
          Tail[Obj2Tail(DragObj)] := Point(Tail[SecTail(Obj2Tail(DragObj))].x, Tail[Obj2Tail(DragObj)].y);
    end;

  if IsDrag and (DragObj = pnt) then
    case _Type of
      vert:
        if Abs(Tail[atEnd].x - p) <= d then
          p := Tail[atEnd].x;
      horiz:
        if Abs(Tail[atEnd].y - p) <= d then
          p := Tail[atEnd].y;
    end;
  if (Blocks[atStart].Block <> nil) and IsDrag and (DragObj = pnt) then
    case _Type of
      vert:
        if Abs(Tail[atStart].x - p) <= d then
          p := Tail[atStart].x;
      horiz:
        if Abs(Tail[atStart].y - p) <= d then
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
                  p := Min(p, b.Left - l)
                else
                  p := Max(p, b.Left + b.Width + l);
              end;
            East:
              if (Tail[SecTail(t)].x <= b.Left + b.Width) and (Tail[SecTail(t)].y > b.Top) and
                (Tail[SecTail(t)].y < b.Top + b.Height) then
              begin
                _Type := horiz;
                if Tail[SecTail(t)].y <= b.Top + b.Height div 2 then
                  p := Min(p, b.Top - l)
                else
                  p := Max(p, b.Top + b.Height + l);
              end;
            West:
              if (Tail[SecTail(t)].x > b.Left
                { +b.Width } ) and (Tail[SecTail(t)].y > b.Top) and (Tail[SecTail(t)].y < b.Top + b.Height) then
              begin
                _Type := horiz;
                if Tail[SecTail(t)].y <= b.Top + b.Height div 2 then
                  p := Min(p, b.Top - l)
                else
                  p := Max(p, b.Top + b.Height + l);
              end;
            South:
              if (Tail[SecTail(t)].y <= b.Top + b.Height) and (Tail[SecTail(t)].x > b.Left) and
                (Tail[SecTail(t)].x < b.Left + b.Width) then
              begin
                _Type := vert;
                if Tail[SecTail(t)].x <= b.Left + b.Width div 2 then
                  p := Min(p, b.Left - l)
                else
                  p := Max(p, b.Left + b.Width + l);
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
          if Tail[t].y > b.GetPortPoint(North).y - l then
            Tail[t] := Point(Tail[t].x, b.GetPortPoint(North).y - l);
        East:
          if Tail[t].x <= b.GetPortPoint(East).x + l then
            Tail[t] := Point(b.GetPortPoint(East).x + l, Tail[t].y);
        West:
          if Tail[t].x > b.GetPortPoint(West).x - l then
            Tail[t] := Point(b.GetPortPoint(West).x - l, Tail[t].y);
        South:
          if Tail[t].y <= b.GetPortPoint(South).y + l then
            Tail[t] := Point(Tail[t].x, b.GetPortPoint(South).y + l);
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
            (Tail[t].y > b.Top) and (Tail[t].y < b.Top + b.Height) and (Tail[t].x > b.Left - l) and
            (Tail[t].x < b.Left + b.Width + l) then
            if Tail[t].x < b.Left + b.Width div 2 then
              Tail[t] := Point(b.Left - l, Tail[t].y)
            else
              Tail[t] := Point(b.Left + b.Width + l, Tail[t].y);
        vert:
          if // (((Tail[t].x>b.Left) {and (p<b.Left)}) or ((Tail[t].x<b.Left) {and (p>b.Left)})) and
            (Tail[t].x > b.Left) and (Tail[t].x < b.Left + b.Width) and (Tail[t].y > b.Top - l) and
            (Tail[t].y < b.Top + b.Height + l) then
            if Tail[t].y < b.Top + b.Height div 2 then
              Tail[t] := Point(Tail[t].x, b.Top - l)
            else
              Tail[t] := Point(Tail[t].x, b.Top + b.Height + l);
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
          if (_Type = vert) and (p < b.Left + b.Width + l) then
            p := b.Left + b.Width + l;
        West:
          if (_Type = vert) and (p > b.Left - l) then
            p := b.Left - l;
        North:
          if (_Type = horiz) and (p > b.Top - l) then
            p := b.Top - l;
        South:
          if (_Type = horiz) and (p < b.Top + b.Height + l) then
            p := b.Top + b.Height + l;
      end;
  end;
  for t := atStart to atEnd do
  begin
    b := Blocks[t].Block;
    if b <> nil then
      case Blocks[t].Port of
        North:
          if (_Type = vert) and (Tail[SecTail(t)].y > b.Top) and (p > b.Left - l) and (p < b.Left + b.Width + l) then
          begin
            if p <= b.Left + b.Width div 2 then
              p := b.Left - l
            else
              p := b.Left + b.Width + l;
          end;
        East:
          if (_Type = horiz) and (Tail[SecTail(t)].x < b.Left + b.Width) and (p > b.Top - l) and
            (p < b.Top + b.Height + l) then
          begin
            if p <= b.Top + b.Height div 2 then
              p := b.Top - l
            else
              p := b.Top + b.Height + l;
          end;
        West:
          if (_Type = horiz) and (Tail[SecTail(t)].x > b.Left) and (p > b.Top - l) and (p < b.Top + b.Height + l) then
          begin
            if p <= b.Top + b.Height div 2 then
              p := b.Top - l
            else
              p := b.Top + b.Height + l;
          end;
        South:
          if (_Type = vert) and (Tail[SecTail(t)].y < b.Top + b.Height) and (p > b.Left - l) and
            (p < b.Left + b.Width + l) then
          begin
            if p <= b.Left + b.Width div 2 then
              p := b.Left - l
            else
              p := b.Left + b.Width + l;
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

procedure TArrow.Dock(Block: TTmpBlock; Tl: TArrowTail; Port: TBlockPort);
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
  b: TTmpBlock;
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
  b: TTmpBlock;
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
    for i := 0 to arrH - 1 do
      case Dir of
        North:
          begin
            DrawCanvas.MoveTo(xo + x - Round(i / arrH * arrW), yo + y - i);
            DrawCanvas.LineTo(xo + x + Round(i / arrH * arrW), yo + y - i);
          end;
        East:
          begin
            DrawCanvas.MoveTo(xo + x + i, yo + y - Round(i / arrH * arrW));
            DrawCanvas.LineTo(xo + x + i, yo + y + Round(i / arrH * arrW));
          end;
        West:
          begin
            DrawCanvas.MoveTo(xo + x - i, yo + y - Round(i / arrH * arrW));
            DrawCanvas.LineTo(xo + x - i, yo + y + Round(i / arrH * arrW));
          end;
        South:
          begin
            DrawCanvas.MoveTo(xo + x - Round(i / arrH * arrW), yo + y + i);
            DrawCanvas.LineTo(xo + x + Round(i / arrH * arrW), yo + y + i);
          end;
      end;
    DrawCanvas.MoveTo(xo + x, yo + y);
    case Dir of
      North:
        DrawCanvas.LineTo(xo + x, yo + y - arrH);
      East:
        DrawCanvas.LineTo(xo + x + arrH, yo + y);
      West:
        DrawCanvas.LineTo(xo + x - arrH, yo + y);
      South:
        DrawCanvas.LineTo(xo + x, yo + y + arrH);
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
            Tail[pTail] := Point(x, dMous.y + Tail[pTail].y);
          end;
        vert:
          begin
            p := x;
            Tail[pTail] := Point(dMous.x + Tail[pTail].x, y);
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
      if TTmpBlock(ChildForm.BlockList[i]).CanIDock(x, y, Obj2Tail(DragObj), true) then
      begin
        if Blocks[Obj2Tail(DragObj)].Block <> nil then
          UnDock(Obj2Tail(DragObj));
        Dock(TTmpBlock(ChildForm.BlockList[i]), Obj2Tail(DragObj), TTmpBlock(ChildForm.BlockList[i]).GetPort(x, y));
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
      TTmpBlock(ChildForm.BlockList[j]).CanIDock(Mous.x, Mous.y, Obj2Tail(DragObj), true);
  end;
end;

procedure TArrow.GetObj;
begin
  DragObj := none;
  if (Mous.x > Tail[atStart].x - R) and (Mous.x < Tail[atStart].x + R) and (Mous.y > Tail[atStart].y - R) and
    (Mous.y < Tail[atStart].y + R) then
    DragObj := st;
  if (Mous.x > Tail[atEnd].x - R) and (Mous.x < Tail[atEnd].x + R) and (Mous.y > Tail[atEnd].y - R) and
    (Mous.y < Tail[atEnd].y + R) then
    DragObj := en;
  case _Type of
    horiz:
      begin
        if (Mous.x > Tail[atStart].x - R) and (Mous.x < Tail[atStart].x + R) and (Mous.y > p - R) and (Mous.y < p + R)
          then
        begin
          DragObj := pnt;
          pTail := atStart;
        end;
        if (Mous.x > Tail[atEnd].x - R) and (Mous.x < Tail[atEnd].x + R) and (Mous.y > p - R) and (Mous.y < p + R) then
        begin
          DragObj := pnt;
          pTail := atEnd;
        end;
      end;
    vert:
      begin
        if (Mous.x > p - R) and (Mous.x < p + R) and (Mous.y > Tail[atStart].y - R) and (Mous.y < Tail[atStart].y + R)
          then
        begin
          DragObj := pnt;
          pTail := atStart;
        end;
        if (Mous.x > p - R) and (Mous.x < p + R) and (Mous.y > Tail[atEnd].y - R) and (Mous.y < Tail[atEnd].y + R) then
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
      if (Mous.x > Blocks[i].Block.GetPortPoint(Blocks[i].Port).x - R) and
        (Mous.x < Blocks[i].Block.GetPortPoint(Blocks[i].Port).x + R) and
        (Mous.y > Blocks[i].Block.GetPortPoint(Blocks[i].Port).y - R) and
        (Mous.y < Blocks[i].Block.GetPortPoint(Blocks[i].Port).y + R) then
      begin
        UnDock(i);
        Tail[i] := Point(Mous.x, Mous.y);
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
      TTmpBlock(ChildForm.BlockList[j]).CanIDock(Mous.x, Mous.y, Obj2Tail(DragObj), true);
  end;

  case _Type of
    vert:
      if ((Mous.x > Min(Tail[atStart].x, p) - R) and (Mous.x < Max(Tail[atStart].x, p) + R) and
          (Mous.y > Tail[atStart].y - R) and (Mous.y < Tail[atStart].y + R)) or
        ((Mous.x > p - R) and (Mous.x < p + R) and (Mous.y > Min(Tail[atStart].y, Tail[atEnd].y) - R) and
          (Mous.y < Max(Tail[atStart].y, Tail[atEnd].y) + R)) or
        ((Mous.x > Min(p, Tail[atEnd].x) - R) and (Mous.x < Max(p, Tail[atEnd].x) + R) and
          (Mous.y > Tail[atEnd].y - R) and (Mous.y < Tail[atEnd].y + R)) then
      begin
        if not(ssShift in Shift) then
          ChildForm.Actives.Clear;
        ChildForm.Actives.SetActive(Self);
        ChildForm.Refresh;
      end;
    horiz:
      if ((Mous.x > Tail[atStart].x - R) and (Mous.x < Tail[atStart].x + R) and (Mous.y > Min(Tail[atStart].y, p) - R)
          and (Mous.y < Max(Tail[atStart].y, p) + R)) or
        ((Mous.x > Min(Tail[atStart].x, Tail[atEnd].x) - R) and (Mous.x < Max(Tail[atStart].x, Tail[atEnd].x) + R) and
          (Mous.y > p - R) and (Mous.y < p + R)) or ((Mous.x > Tail[atEnd].x - R) and (Mous.x < Tail[atEnd].x + R) and
          (Mous.y > Min(p, Tail[atEnd].y) - R) and (Mous.y < Max(p, Tail[atEnd].y) + R)) then
      begin
        if not(ssShift in Shift) then
          ChildForm.Actives.Clear;
        ChildForm.Actives.SetActive(Self);
        ChildForm.Refresh;
      end;
  end;
end;

end.

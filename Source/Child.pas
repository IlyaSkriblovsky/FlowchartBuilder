unit Child;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Buttons, ExtCtrls, StdCtrls, IniFiles, EdTypes, OpenUnit, SaveUnit,
  ComCtrls, Printers, Lang, Math, Arrows, Ini, BlockProps, Generics.Collections;

type
  TActives = class;

  TANew = record
    New: Boolean;
    Tail: TArrowTail;
    Arrow: TArrow;
  end;

  TDown = record
    _: Boolean;
    X, Y: Integer;
  end;

  TChildForm = class(TForm)
    BlockMenu: TPopupMenu;
    mnuDelete: TMenuItem;
    Bevel: TPaintBox;
    mnuReplace: TMenuItem;
    mnuSequence: TMenuItem;
    mnuIfFull: TMenuItem;
    mnuIfNFull: TMenuItem;
    mnuLoopPred: TMenuItem;
    mnuLoopPost: TMenuItem;
    N1: TMenuItem;
    N3: TMenuItem;
    mnuRepNothing: TMenuItem;
    mnuRepStat: TMenuItem;
    mnuRepIO: TMenuItem;
    mnuRepCall: TMenuItem;
    mnuRepEnd: TMenuItem;
    mnuEditBlock: TMenuItem;
    procedure DestroyList;
    procedure GoProc(f: Boolean; MakeTakt: Boolean = true);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxDblClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure SetParamBlock(T: TObject);
    procedure NStepClick(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure CreateBlock(Q: SetBlocks);
    function HasFirstBlock: Boolean;

    procedure SetRange;
    function GetNext(Cur: TBlock; Cond: Boolean): TBlock;
    procedure Takt;
    procedure Execute(f: Boolean; MakeTakt: Boolean = true);
    procedure FormDestroy(Sender: TObject);
    procedure BlockMenuPopup(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BevelPaint(Sender: TObject);

    procedure SetButtsEnable(b: Boolean);
    procedure SetButtsUp;

    procedure AlignHoriz;
    procedure AlignVert;

    procedure DeleteBlock(b: TBlock; MakeUndo: Boolean = true);
    procedure DeleteArrow(A: TArrow; MakeUndo: Boolean = true);

    procedure CheckStatement(BackUp: TStringList; Tb: TBlock);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnuSequenceClick(Sender: TObject);
    procedure mnuIfFullClick(Sender: TObject);
    procedure mnuIfNFullClick(Sender: TObject);
    procedure mnuLoopPredClick(Sender: TObject);
    procedure mnuLoopPostClick(Sender: TObject);
    procedure mnuRepStatClick(Sender: TObject);
    procedure mnuRepIOClick(Sender: TObject);
    procedure mnuRepCallClick(Sender: TObject);
    procedure mnuRepNothingClick(Sender: TObject);
    procedure mnuRepEndClick(Sender: TObject);
    procedure mnuEditBlockClick(Sender: TObject);

  private
    XOffset, YOffset: Integer;
    PS: TPaintBox;
    Xd, Yd, Xc, Yc: Integer;
    RamkaOn: Boolean;

  public
    ArrowList: TList<TArrow>;
    ANew: TANew;

    DefCursor: TCursor;

    boolFirst: Boolean;

    Cur: TBlock;

    Actives: TActives;

    ColorFontBlock, ColorCurrentBlock, ColorBlock, ColorChain: TColor;
    ConflRadius: Integer;
    AutoCheck: Boolean;

    WidthBlock: Integer;
    HeightBlock: Integer;

    Xt, Yt: Integer;

    FileName: string;
    flagNextTakt: Boolean;
    flagBreak: Boolean;
    flagInWork: Boolean;

    Vars: TVars;

    BlockList: TList<TBlock>;
    pTmp: Pointer;
    TmpBlock: TBlock;
    FindStartBlock: Boolean;
    StartBlock: TBlock;
    FTbCur: TBlock;
    StrList: TStringList;
    Dragging: Boolean;
    FirstClick: TPoint;

    DblClicked: Boolean;

    BlockFont: TFont;

    procedure CreateArrow;
    function MakeReplace(b1, b2: TBlock; T: TArrowTail; ChangePort: Boolean = false; Port: TBlockPort = North): TArrow;
    procedure MoveAllDown(b1: TTmpBlock; h: Integer);
    procedure MoveAllLeftRight(b1: TTmpBlock; l, r: Integer);

    procedure AllArrowsStandWell;

  end;

  TActives = class
  public
    Blocks: TList<TBlock>;
    Arrows: TList<TArrow>;

    constructor Create;

    function GetActive(A: TArrow): Boolean; overload;
    function GetActive(b: TBlock): Boolean; overload;

    procedure SetActive(A: TArrow; act: Boolean = true); overload;
    procedure SetActive(b: TBlock; act: Boolean = true); overload;

    procedure Clear;
    procedure Delete;
  end;

  TStackNode = record
    ReturnPos: TBlock;
    BlockList: TList<TBlock>;
    ArrowList: TList<TArrow>;
    Vars: TVars;
    StartBlock: TBlock;
    AlreadyGlob: Boolean;
    AlreadyInit: Boolean;
    InitBlock: TBlock;
    GlobBlock: TBlock;
  end;

  PStackNode = ^TStackNode;

var
  ChildForm: TChildForm;
  CreateBlockFromButts: Boolean;
  CreateBlockFromButtsPoint: TPoint;

  dP: TPoint;

  down: TDown;

  StackInfo: TList<PStackNode>;

implementation

uses Options, About, OutProg, Main, Watch, StrsInput, StrUtils;
{$R *.DFM}

(* **  TActives  ** *)
constructor TActives.Create;
begin
  inherited;
  Blocks := TList<TBlock>.Create;
  Arrows := TList<TArrow>.Create;
end;

function TActives.GetActive(A: TArrow): Boolean;
begin
  Result := Arrows.IndexOf(A) <> -1;
end;

function TActives.GetActive(b: TBlock): Boolean;
begin
  Result := Blocks.IndexOf(b) <> -1;
end;

procedure TActives.SetActive(A: TArrow; act: Boolean);
begin
  if act then
  begin
    if not GetActive(A) then
      Arrows.Add(A);
  end
  else
  begin
    if GetActive(A) then
      Arrows.Remove(A);
  end;
end;

procedure TActives.SetActive(b: TBlock; act: Boolean);
begin
  if act then
  begin
    if not GetActive(b) then
      Blocks.Add(b);
  end
  else
  begin
    if GetActive(b) then
      Blocks.Remove(b);
  end;
end;

procedure TActives.Clear;
begin
  Blocks.Clear;
  Arrows.Clear;
end;

procedure TActives.Delete;
var
  i: Integer;
  UN: PUndoNode;
  Count: Integer;

begin
  Count := UndoStack.Count;
  for i := Blocks.Count - 1 downto 0 do
  begin
    ChildForm.DeleteBlock(Blocks[i]);
    Blocks.Delete(i);
  end;
  for i := Arrows.Count - 1 downto 0 do
  begin
    ChildForm.DeleteArrow(Arrows[i]);
    Arrows.Delete(i);
  end;

  New(UN);
  UN._ := utEmpty;
  UN.Group := UndoStack.Count - Count + 1;
  MainForm.AddUndo(UN);

  ChildForm.SetRange;
  MainForm.Modifed := true;
end;

(* **  TChildForm  ** *)
procedure TChildForm.AllArrowsStandWell;
var
  i: Integer;

begin
  for i := 0 to ArrowList.Count - 1 do
    ArrowList.Items[i].StandWell;
end;

procedure TChildForm.SetButtsEnable(b: Boolean);
begin
  MainForm.RectSB.Enabled := b;
  MainForm.RombSB.Enabled := b;
  MainForm.EllipseSB.Enabled := b;
  MainForm.CallSB.Enabled := b;
  MainForm.ParalSB.Enabled := b;
  MainForm.GlobSB.Enabled := b;
  MainForm.InitSB.Enabled := b;
  MainForm.CommSB.Enabled := b;
  MainForm.ConflSB.Enabled := b;
  MainForm.actDelete.Enabled := b;
end;

procedure TChildForm.SetButtsUp;
begin
  MainForm.RectSB.down := false;
  MainForm.RombSB.down := false;
  MainForm.EllipseSB.down := false;
  MainForm.CallSB.down := false;
  MainForm.ParalSB.down := false;
  MainForm.GlobSB.down := false;
  MainForm.InitSB.down := false;
  MainForm.CommSB.down := false;
  MainForm.ConflSB.down := false;
end;

procedure TChildForm.AlignVert;
var
  i: Integer;
  lS: Integer;
  A: TArrow;
  UN: PUndoNode;
  cnt: Integer;

begin
  if Actives.Blocks.Count = 0 then
    Exit;

  lS := 0;
  for i := 0 to Actives.Blocks.Count - 1 do
    Inc(lS, Actives.Blocks.Items[i].Left + Actives.Blocks.Items[i].Width div 2);
  lS := lS div Actives.Blocks.Count;
  for i := 0 to Actives.Blocks.Count - 1 do
  begin
    New(UN);
    UN^.Group := 1;
    UN^._ := utBlocksMove;
    UN^.Block := Actives.Blocks[i];
    UN^.pnt := Point(UN^.Block.Left, UN^.Block.Top);
    MainForm.AddUndo(UN);

    Actives.Blocks.Items[i].Left := lS - Actives.Blocks.Items[i].Width div 2;
  end;

  cnt := 0;
  for i := 0 to ArrowList.Count - 1 do
  begin
    A := ArrowList[i];
    if Actives.GetActive(TBlock(A.Blocks[atStart].Block)) and Actives.GetActive(TBlock(A.Blocks[atEnd].Block)) and
      (A.Blocks[atStart].Port in [North, South]) and (A.Blocks[atEnd].Port in [North, South]) then
    begin
      Inc(cnt);

      New(UN);
      UN._ := utArrowMove;
      UN.Group := Actives.Blocks.Count + cnt;
      UN.Arrow := A;
      UN.pnt := A.Tail[atStart];
      UN.pnt1 := A.Tail[atEnd];
      UN.p := A.p;
      UN.ArrowType := A._Type;
      UN.ArrowStyle := A.Style;
      UN.Block := A.Blocks[atStart].Block as TBlock;
      UN.Block1 := A.Blocks[atEnd].Block as TBlock;
      UN.Port[atStart] := A.Blocks[atStart].Port;
      UN.Port[atEnd] := A.Blocks[atEnd].Port;
      MainForm.AddUndo(UN);

      A.p := A.Tail[atStart].X;
    end;
    A.StandWell;
  end;

  Invalidate;
end;

procedure TChildForm.AlignHoriz;
var
  i: Integer;
  lT: Integer;
  UN: PUndoNode;

begin
  if Actives.Blocks.Count = 0 then
    Exit;

  lT := 0;
  for i := 0 to Actives.Blocks.Count - 1 do
    Inc(lT, Actives.Blocks.Items[i].Top + Actives.Blocks.Items[i].Height div 2);
  lT := lT div Actives.Blocks.Count;
  for i := 0 to Actives.Blocks.Count - 1 do
  begin
    New(UN);
    UN^.Group := Actives.Blocks.Count;
    UN^._ := utBlocksMove;
    UN^.Block := Actives.Blocks[i];
    UN^.pnt := Point(UN^.Block.Left, UN^.Block.Top);
    MainForm.AddUndo(UN);

    Actives.Blocks.Items[i].Top := lT - Actives.Blocks.Items[i].Height div 2;
  end;

  for i := 0 to ArrowList.Count - 1 do
    ArrowList.Items[i].StandWell;

  Invalidate;
end;

procedure TChildForm.CreateArrow;
var
  i: Integer;
  UN: PUndoNode;

begin
  for i := 0 to BlockList.Count - 1 do
    if TTmpBlock(BlockList[i]).CanIDock(Mous.X, Mous.Y, ANew.Tail, true) then
      ANew.Arrow.Dock(TTmpBlock(BlockList[i]), atStart, TTmpBlock(BlockList[i]).GetPort(Mous.X, Mous.Y));

  ANew.New := false;
  MainForm.btnLineRun.down := false;
  ANew.Arrow.IsDrag := false;
  ArrowList.Add(ANew.Arrow);
  DefCursor := crDefault;

  SetButtsEnable(true);

  New(UN);
  UN^._ := utNewArrow;
  UN^.Group := 1;
  UN^.Arrow := ANew.Arrow;
  MainForm.AddUndo(UN);

  MainForm.Modifed := true;
  Refresh;
end;

procedure TChildForm.DestroyList;
var
  i: Integer;

begin
  for i := BlockList.Count - 1 downto 0 do
    BlockList[i].Free;
  BlockList.Clear;

  for i := ArrowList.Count - 1 downto 0 do
    ArrowList[i].Free;
  ArrowList.Clear;

  Actives.Clear;
end;

procedure TChildForm.FormCreate(Sender: TObject);
begin
  Randomize;

  IniFile := GetHomePath + '\flowcharts.ini';

  UndoStack := TList<PUndoNode>.Create;

  BlockList := TList<TBlock>.Create;
  ArrowList := TList<TArrow>.Create;

  Actives := TActives.Create;

  DefCursor := crDefault;

  StackInfo := TList<PStackNode>.Create;
  Vars := TVars.Create;

  BlockFont := TFont.Create;

  Lang.GetFuncValue := Lang.GetFuncResult;

  Dragging := false;
  RamkaOn := false;
  flagBreak := false;
  FindStartBlock := false;
  ReadIniFile;
  CheckRegistry;

  Files := TList<PFile_Rec>.Create;
end;

procedure TChildForm.SetParamBlock(T: TObject);
var
  Tb: TBlock;
begin
  Tb := T as TBlock;
  Tb.Color := ColorBlock;
  Tb.Font.Color := ColorFontBlock;
  Tb.Width := WidthBlock;
  Tb.Height := HeightBlock;
  if Tb.Block = stConfl then
  begin
    Tb.Width := ConflRadius;
    Tb.Height := ConflRadius;
  end;
  Tb.PopupMenu := BlockMenu;
  // Tb.OnPaint := TmpBlock.ShowBlock;
  Tb.OnMouseDown := PaintBoxMouseDown;
  Tb.OnMouseMove := PaintBoxMouseMove;
  Tb.OnMouseUp := PaintBoxMouseUp;
  Tb.OnDblClick := PaintBoxDblClick;
end;

procedure TChildForm.PaintBoxDblClick(Sender: TObject);
begin
  case TBlock(Sender).Block of
    stGlob:
      begin
        MemoInput('Введите значение', 'Введите список глобальных переменных', GlobBlock.GlobStrings);
        GlobBlock.Paint;
      end;
    stInit:
      begin
        MemoInput('Введите значение', 'Введите иницилизационный код', InitBlock.InitCode);
        InitBlock.Paint;
      end;
  else
    frmProps.Block := Sender as TBlock;
    frmProps.ShowModal;
  end;
  DblClicked := true;
end;

function TChildForm.HasFirstBlock: Boolean;
var
  i, j: Integer;
  Block: TBlock;
  suitableBlocks: TList<TBlock>;
  hasIncomingArrows: Boolean;

begin
  if StartBlock <> nil then
  begin
    Result := true;
    Exit;
  end;

  suitableBlocks := TList<TBlock>.Create;

  for i := 0 to BlockList.Count - 1 do
  begin
    Block := BlockList[i];
    hasIncomingArrows := false;
    for j := 0 to ArrowList.Count - 1 do
      if ArrowList.Items[j].Blocks[atStart].Block = Block then
      begin
        hasIncomingArrows := true;
        Break;
      end;

    if hasIncomingArrows then
      continue;

    if Block.Block in [stBeginEnd, stStatement, stIf, stInOut, stCall] then
      suitableBlocks.Add(Block);
  end;

  if suitableBlocks.Count = 1 then
  begin
    StartBlock := suitableBlocks[0];
    Result := true;
  end
  else
    Result := false;
  suitableBlocks.Free;
end;

procedure TChildForm.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (FindStartBlock) and ((Sender as TBlock).Block <> stGlob) and ((Sender as TBlock).Block <> stInit) then
  begin
    StartBlock := Sender as TBlock;
    FindStartBlock := false;
    MainForm.pnlSelectFirstBlock.Visible := false;
    AutoResume;
    Exit;
  end;

  if Button = mbRight then
  begin
    TmpBlock := Sender as TBlock;
    Exit;
  end
  else if not Viewer then
  begin
    if not DblClicked then
    begin
      down.X := X;
      down.Y := Y;
      down._ := true;
    end
    else
      DblClicked := false;
  end;
end;

procedure DrawFocus;
var
  i: Integer;
  b: TBlock;

  procedure DrawFocusRect(r: TRect);
  var
    i: Integer;

  begin
    for i := 0 to (r.Right - r.Left) div 2 do
    begin
      ChildForm.Canvas.MoveTo(r.Left + i * 2, r.Top);
      ChildForm.Canvas.LineTo(r.Left + i * 2, r.Top + 1);
      ChildForm.Canvas.MoveTo(r.Left + i * 2, r.Bottom);
      ChildForm.Canvas.LineTo(r.Left + i * 2, r.Bottom + 1);
    end;
    for i := 1 to (r.Bottom - r.Top) div 2 - 1 do
    begin
      ChildForm.Canvas.MoveTo(r.Left, r.Top + i * 2);
      ChildForm.Canvas.LineTo(r.Left, r.Top + i * 2 + 1);
      ChildForm.Canvas.MoveTo(r.Right, r.Top + i * 2);
      ChildForm.Canvas.LineTo(r.Right, r.Top + i * 2 + 1);
    end;
  end;

begin
  ChildForm.Canvas.Pen.Mode := pmNot;
  for i := 0 to ChildForm.BlockList.Count - 1 do
    if ChildForm.Actives.GetActive(ChildForm.BlockList[i]) then
    begin
      b := ChildForm.BlockList[i];
      DrawFocusRect(Rect(b.Left + dP.X, b.Top + dP.Y, b.Left + b.Width + dP.X - 1, b.Top + b.Height + dP.Y - 1));
    end;
end;

procedure TChildForm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if down._ and ((Abs(X - down.X) > 5) or (Abs(Y - down.Y) > 5)) and not Viewer then
  begin
    Dragging := true;
    if not Actives.GetActive(Sender as TBlock) then
    begin
      Actives.Clear;
      Actives.SetActive(Sender as TBlock);
    end;
    XOffset := down.X;
    YOffset := down.Y;
    PS := Sender as TBlock;
    dP := Point(0, 0);
    boolFirst := false;
    down._ := false;
  end;

  if Dragging then
  begin
    if boolFirst then
      DrawFocus;
    boolFirst := true;
    dP.X := X - XOffset;
    dP.Y := Y - YOffset;
    DrawFocus;
  end;
end;

procedure TChildForm.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  UN: PUndoNode;
  e: TPoint;

begin
  if not Dragging and not Viewer then
    if not(ssShift in Shift) then
    begin
      Actives.Clear;
      Actives.SetActive(Sender as TBlock)
    end
    else
      Actives.SetActive(Sender as TBlock, not Actives.GetActive(Sender as TBlock));

  down._ := false;
  if Dragging then
  begin
    DrawFocus;
    Dragging := false;

    for i := 0 to Actives.Blocks.Count - 1 do
      with Actives.Blocks[i] do
      begin
        New(UN);
        UN._ := utBlocksMove;
        UN.Group := Actives.Blocks.Count;
        UN.Block := Actives.Blocks[i];
        UN.pnt := Point(UN.Block.Left, UN.Block.Top);
        MainForm.AddUndo(UN);

        Left := Left + X - XOffset;
        Top := Top + Y - YOffset;
      end;

    for i := 0 to ArrowList.Count - 1 do
      if Actives.GetActive(ArrowList[i]) then
        with ArrowList.Items[i] do
        begin
          e := Point(Tail[atEnd].X + X - XOffset, Tail[atEnd].Y + Y - YOffset);
          Tail[atStart] := Point(Tail[atStart].X + X - XOffset, Tail[atStart].Y + Y - YOffset);
          Tail[atEnd] := e; // so as not to process one arrow twice
          case _Type of
            vert:
              p := p + X - XOffset;
            horiz:
              p := p + Y - YOffset;
          end;
        end;

    for i := 0 to ArrowList.Count - 1 do
      if (Actives.GetActive(TBlock(ArrowList.Items[i].Blocks[atStart].Block))) or
        (Actives.GetActive(TBlock(ArrowList.Items[i].Blocks[atEnd].Block))) then
        ArrowList.Items[i].StandWell;

    MainForm.Modifed := true;

    for i := 0 to BlockList.Count - 1 do
      BlockList.Items[i].Paint;
    SetRange;
  end;
end;

procedure TChildForm.GoProc(f: Boolean; MakeTakt: Boolean = true);
begin
  Execute(f, MakeTakt);
end;

procedure TChildForm.CheckStatement(BackUp: TStringList; Tb: TBlock);
var
  Lexs: PLexemes;
  tmp: string;
  tPos: Cardinal;
  Lines: TStringList;

begin
  if AutoCheck then
    TRY
      New(Lexs);
      FillChar(Lexs^, SizeOf(Lexs^), 0);
      ReadBlock(Tb.Statement, Lexs);
      case Tb.Block of
        stInOut:
          begin
            begin
              if Lexs[1]._Type = lxQuestion then
              begin
                Lines := TStringList.Create;
                Lines.Assign(Tb.Statement);
                tmp := Lines[0];
                Delete(tmp, System.Pos('?', tmp), 1);
                Lines[0] := tmp;
                Lines[0] := Lines[0] + ':=0';
                ReadBlock(Lines, Lexs);
                CheckOperator(Lexs);
                Lines.Free;
              end
              else
              begin
                Pos := 1;
                tPos := Pos;
                CheckExpr(Lexs);
                Pos := tPos;
                while Lexs^[Pos]._Type = lxComma do
                begin
                  Inc(Pos);
                  tPos := Pos;
                  CheckExpr(Lexs);
                  Pos := tPos;
                end;
              end;
            end;
          end;
        stStatement:
          begin
            Pos := 1;
            CheckOperator(Lexs);
          end;
        stIf:
          begin
            Pos := 1;
            CheckExpr(Lexs);
            if Lexs^[Pos]._Type <> lxUndef then
              raise ECheckError.Create('Ожидалось конец оператора, но найдено лишние символы в позиции ' + IntToStr(Pos)
                );
          end;
      end;
      Dispose(Lexs);
    except
      Tb.Statement.Assign(BackUp);
      ApplicationHandleException(nil);
    end;
end;

procedure TChildForm.Execute(f: Boolean; MakeTakt: Boolean = true);
var
  Med: Integer;
  StackNode: PStackNode;
  i: Integer;
  Lexs: PLexemes;

begin
  if (flagInWork) and (f = false) then
  begin
    FTbCur.Color := ChildForm.ColorBlock;
    flagInWork := false;
    MainForm.AutoExec := false;
    MainForm.actNew.Enabled := true;
    MainForm.actOpen.Enabled := true;
    MainForm.actSave.Enabled := true;

    MainForm.btnLineRun.Enabled := true;
    MainForm.mnuArrow.Enabled := true;
    SetButtsEnable(true);
    mnuDelete.Enabled := true;

    if StackInfo.Count > 1 then
    begin
      // DestroyAllChain;
      for i := 0 to BlockList.Count - 1 do
        BlockList.Items[i].Hide;
      BlockList.Clear;
      BlockList.AddRange(StackInfo.Items[0].BlockList);
      ArrowList.Clear;
      ArrowList.AddRange(StackInfo.Items[0].ArrowList);

      AlreadyGlob := StackInfo.Items[0].AlreadyGlob;
      AlreadyInit := StackInfo.Items[0].AlreadyInit;
      GlobBlock := StackInfo.Items[0].GlobBlock;
      InitBlock := StackInfo.Items[0].InitBlock;

      Vars.Clear;
      Vars.AddRange(StackInfo.Items[0].Vars);

      StartBlock := BlockList[BlockList.IndexOf(StackInfo.Items[0].StartBlock)];

      for i := 0 to StackInfo.Count - 1 do
      begin
        Dispose(PStackNode(StackInfo[0]));
        StackInfo.Delete(0);
      end;

      for i := 0 to BlockList.Count - 1 do
        BlockList.Items[i].Show;
      for i := 0 to ArrowList.Count - 1 do
        ArrowList.Items[i].Hide := false;
      // CreateAllLines;
    end;

    SetRange;
    Refresh;
    Exit;
  end;
  if not flagInWork then
    if ChildForm.StartBlock <> nil then
    begin
      FTbCur := ChildForm.StartBlock;
      FTbCur.Color := ChildForm.ColorCurrentBlock;
      MainForm.StatusBar.Panels[1].Text := FTbCur.RemText;
      flagInWork := true;
      MainForm.actNew.Enabled := false;
      MainForm.actOpen.Enabled := false;
      MainForm.actSave.Enabled := false;

      MainForm.btnLineRun.Enabled := false;
      MainForm.mnuArrow.Enabled := false;
      // MainForm.Stop1.Enabled:=false; Removed by Roman Mitin
      SetButtsEnable(false);
      mnuDelete.Enabled := false;

      for i := 0 to Vars.Count - 1 do
        Dispose(PVar(Vars[i]));
      Vars := TVars.Create;
      frmWatch.VarsRefresh;

      GlobVars := TStringList.Create;
      if AlreadyGlob then
        AddToGlobVars(GlobBlock.GlobStrings);
      if AlreadyInit then
      begin
        New(Lexs);
        ReadBlock(InitBlock.InitCode, Lexs);
        if CheckOperator(Lexs) then
          ExecOperator(Lexs, Vars);
      end;

      New(StackNode);
      StackNode.ReturnPos := nil;
      StackNode.AlreadyGlob := AlreadyGlob;
      StackNode.GlobBlock := GlobBlock;
      StackNode.AlreadyInit := AlreadyInit;
      StackNode.InitBlock := InitBlock;
      StackNode.BlockList := TList<TBlock>.Create;
      StackNode.BlockList.AddRange(BlockList);
      StackNode.ArrowList := TList<TArrow>.Create;
      StackNode.ArrowList.AddRange(ArrowList);
      StackNode.StartBlock := StartBlock;
      StackNode.Vars := TList<PVar>.Create;
      StackNode.Vars.AddRange(Vars);

      StackInfo.Clear;
      StackInfo.Add(StackNode);
    end;
  if MakeTakt then
    Takt
  else
    Exit;
  if Cur = nil then
  begin
    if FTbCur <> nil then
      FTbCur.Color := ChildForm.ColorBlock;
    flagInWork := false;
    MainForm.actNew.Enabled := true;
    MainForm.actOpen.Enabled := true;
    MainForm.actSave.Enabled := true;
    MainForm.AutoExec := false;

    MainForm.btnLineRun.Enabled := true;
    MainForm.mnuArrow.Enabled := true;

    SetButtsEnable(true);

    mnuDelete.Enabled := true;

    if StackInfo.Count > 1 then
    begin
      for i := 0 to BlockList.Count - 1 do
        BlockList.Items[i].Hide;
      BlockList.Clear;
      BlockList.AddRange(StackInfo.Items[1].BlockList);
      ArrowList.Clear;
      ArrowList.AddRange(StackInfo.Items[1].ArrowList);
      Vars.Clear;
      Vars.AddRange(StackInfo.Items[1].Vars);
      StartBlock := BlockList[BlockList.IndexOf(StackInfo.Items[1].StartBlock)];
      StackInfo.Clear;
      for i := 0 to BlockList.Count - 1 do
        BlockList.Items[i].Show;
    end;

    Exit;
  end;
  if FTbCur <> nil then
    FTbCur.Color := ChildForm.ColorBlock;
  FTbCur := Cur;
  FTbCur.Color := ChildForm.ColorCurrentBlock;
  MainForm.StatusBar.Panels[1].Text := FTbCur.RemText;
  Med := FTbCur.Top + FTbCur.Height div 2;
  if (Med > ChildForm.ClientHeight) or (Med < 0) then
    ChildForm.VertScrollBar.Position := FTbCur.Top + ChildForm.VertScrollBar.Position;
end;

function TChildForm.GetNext(Cur: TBlock; Cond: Boolean): TBlock;
var
  i: Integer;
  arrow: TArrow;

begin
  Result := nil;
  for i := 0 to ArrowList.Count - 1 do
  begin
    arrow := ArrowList.Items[i];
    if arrow.Blocks[atEnd].Block = Cur then
      if Cur.Block <> stIf then
        Result := TBlock(arrow.Blocks[atStart].Block)
      else if Cond then
      begin
        if (Cur.Isd) and (arrow.Blocks[atEnd].Port = South) then
          Result := TBlock(arrow.Blocks[atStart].Block);
        if (not Cur.Isd) and (arrow.Blocks[atEnd].Port = East) then
          Result := TBlock(arrow.Blocks[atStart].Block);
      end
      else
      begin
        if (Cur.Isd) and (arrow.Blocks[atEnd].Port = East) then
          Result := TBlock(arrow.Blocks[atStart].Block);
        if (not Cur.Isd) and (arrow.Blocks[atEnd].Port = West) then
          Result := TBlock(arrow.Blocks[atStart].Block);
      end;
  end;
  if (Result <> nil) and (Result.Block = stConfl) then
    Result := GetNext(Result, false);
end;

procedure TChildForm.Takt;
var
  Tb: TBlock;
  Lexs: PLexemes;
  Val: TValue;
  Out , tmp: string;
  tPos: Cardinal;
  i: Integer;
  StackNode: PStackNode;
  tmpVars: TVars;
  tmpVarNo: Integer;
  VarNo: Integer;
  qVar: PVar;
  Lines: TStringList;
  fstr: string;

  procedure OnEnd;
  var
    i: Integer;
    StackNode: PStackNode;

  begin
    if StackInfo.Count = 1 then
    begin
      StackNode := StackInfo.Items[0];
      AlreadyGlob := StackNode.AlreadyGlob;
      GlobBlock := StackNode.GlobBlock;
      AlreadyInit := StackNode.AlreadyInit;
      InitBlock := StackNode.InitBlock;
      Cur := nil;
      Exit;
    end;
    Cur := StackInfo.Items[StackInfo.Count - 1].ReturnPos;
    for i := BlockList.Count - 1 downto 0 do
      BlockList[i].Free;
    BlockList.Clear;
    BlockList.AddRange(StackInfo.Items[StackInfo.Count - 1].BlockList);

    for i := ArrowList.Count - 1 downto 0 do
      ArrowList[i].Free;
    ArrowList.Clear;
    ArrowList.AddRange(StackInfo.Items[StackInfo.Count - 1].ArrowList);

    tmpVars := TVars.Create;
    tmpVars.AddRange(Vars);
    Vars.Clear;
    Vars.AddRange(StackInfo.Items[StackInfo.Count - 1].Vars);
    if GlobVars.Count > 0 then
      for i := 0 to GlobVars.Count - 1 do
      begin
        tmpVarNo := GetVarIndex(tmpVars, GlobVars[i]);
        if tmpVarNo <> -1 then
        begin
          VarNo := GetVarIndex(Vars, GlobVars[i]);
          if VarNo = -1 then
          begin
            New(qVar);
            qVar^.Name := GlobVars[i];
            qVar^.Sizes := TList<PInteger>.Create;
            qVar^.Arr := TList<PValue>.Create;
            VarNo := Vars.Add(qVar);
          end;
          Vars.Items[VarNo].Value := tmpVars.Items[tmpVarNo].Value;
          Vars.Items[VarNo].Sizes.Clear;
          Vars.Items[VarNo].Sizes.AddRange(tmpVars.Items[tmpVarNo].Sizes);
          Vars.Items[VarNo].Arr.Clear;
          Vars.Items[VarNo].Arr.AddRange(tmpVars.Items[tmpVarNo].Arr);
        end;
      end;
    tmpVars.Free;

    StartBlock := BlockList[BlockList.IndexOf(StackInfo.Items[StackInfo.Count - 1].StartBlock)];
    StackNode := StackInfo.Items[StackInfo.Count - 1];
    AlreadyGlob := StackNode.AlreadyGlob;
    GlobBlock := StackNode.GlobBlock;
    AlreadyInit := StackNode.AlreadyInit;
    InitBlock := StackNode.InitBlock;
    StackInfo.Delete(StackInfo.Count - 1);
    for i := 0 to BlockList.Count - 1 do
      BlockList.Items[i].Show;
    for i := 0 to ArrowList.Count - 1 do
      ArrowList.Items[i].Hide := false;

    Refresh;

    // FTbCur:=StarTBlock;
    FTbCur := nil;
  end;

begin
  if FTbCur = Nil then
  begin
    ShowMessage('Не указан первый элемент.');
    Exit;
  end;
  Tb := FTbCur;
  New(Lexs);

  case Tb.Block of
    stBeginEnd:
      begin
        if Tb.Statement.Count = 0 then
          fstr := ''
        else
          fstr := ANSIUpperCase(Tb.Statement[0]);
        if (fstr = 'Конец') or (fstr = 'END') or (GetNext(Tb, false) = nil) then
        begin
          OnEnd;
        end
        else if GetNext(Tb, false) <> nil then
          Cur := GetNext(Tb, false);
      end;

    stInOut:
      begin
        ReadBlock(Tb.Statement, Lexs);
        if Lexs[1]._Type = lxQuestion then
        begin
          Lines := TStringList.Create;
          Lines.Assign(Tb.Statement);
          tmp := Lines[0];
          Delete(tmp, System.Pos('?', tmp), 1);
          Lines[0] := tmp;
          AutoPause;
          Lines[0] := Lines[0] + ' := ' + InputBox('Ввод', IfThen(MainForm.StatusBar.Panels[1].Text <> '',
              MainForm.StatusBar.Panels[1].Text, 'Введите значение: '), '');
          AutoResume;
          ReadBlock(Lines, Lexs);
          if CheckOperator(Lexs) then
            ExecOperator(Lexs, Vars)
          else
            Cur := nil;
          Lines.Free;
        end
        else
        begin
          try
            Pos := 1;
            tPos := Pos;
            CheckExpr(Lexs);
            Pos := tPos;
            Val := ExecExpr(Lexs, Vars);
            case Val._Type of
              tyReal:
                Out := Out + FloatToStr(Val.Real);
              tyStr:
                Out := Out + Val.Str;
            end;
            while Lexs^[Pos]._Type = lxComma do
            begin
              Inc(Pos);
              tPos := Pos;
              CheckExpr(Lexs);
              Pos := tPos;
              Val := ExecExpr(Lexs, Vars);
              case Val._Type of
                tyReal:
                  Out := Out + FloatToStr(Val.Real);
                tyStr:
                  Out := Out + Val.Str;
              end;
            end;
          finally
          end;
          frmOutProg.Memo.Lines.Add(Out );
          frmOutProg.Show;
          frmOutProg.Memo.SelStart := Length(frmOutProg.Memo.Text);
        end;
        Cur := GetNext(Tb, false);
      end;

    stStatement:
      begin
        ReadBlock(Tb.Statement, Lexs);
        if CheckOperator(Lexs) then
          ExecOperator(Lexs, Vars)
        else
          Cur := nil;
        Cur := GetNext(Tb, false);
      end;

    stConfl:
      begin
        Cur := GetNext(Tb, false);
      end;

    stCall:
      begin
        if Tb.Statement.Count = 0 then
          fstr := 'НИЧЕГО'
        else
          fstr := Tb.Statement[0];
        if FileExists(fstr + '.BSH') then
        begin
          New(StackNode);
          StackNode.ReturnPos := GetNext(Tb, false);
          StackNode.BlockList := TList<TBlock>.Create;
          StackNode.BlockList.AddRange(BlockList);
          StackNode.ArrowList := TList<TArrow>.Create;
          StackNode.ArrowList.AddRange(ArrowList);
          StackNode.Vars := TVars.Create;
          StackNode.Vars.AddRange(Vars);
          StackNode.StartBlock := StartBlock;
          StackNode.AlreadyGlob := AlreadyGlob;
          StackNode.GlobBlock := GlobBlock;
          StackNode.AlreadyInit := AlreadyInit;
          StackNode.InitBlock := InitBlock;
          tmpVars := TVars.Create;
          tmpVars.AddRange(Vars);
          Vars.Clear;
          StackInfo.Add(StackNode);
          Cur := StartBlock;

          for i := 0 to BlockList.Count - 1 do
            BlockList.Items[i].Hide;
          BlockList.Clear;

          for i := 0 to ArrowList.Count - 1 do
            ArrowList.Items[i].Hide := true;
          ArrowList.Clear;
          Actives.Clear;
          StartBlock := nil;
          AlreadyGlob := false;
          AlreadyInit := false;
          LoadScheme(fstr + '.BSH');
          Refresh;
          if AlreadyGlob then
          begin
            AddToGlobVars(GlobBlock.GlobStrings);

            if GlobVars.Count > 0 then
              for i := 0 to GlobVars.Count - 1 do
              begin
                tmpVarNo := GetVarIndex(tmpVars, GlobVars[i]);
                if tmpVarNo <> -1 then
                begin
                  VarNo := GetVarIndex(Vars, GlobVars[i]);
                  if VarNo = -1 then
                  begin
                    New(qVar);
                    qVar^.Name := GlobVars[i];
                    qVar^.Sizes := TList<PInteger>.Create;
                    qVar^.Arr := TList<PValue>.Create;
                    VarNo := Vars.Add(qVar);
                  end;
                  Vars.Items[VarNo].Value := tmpVars.Items[tmpVarNo].Value;
                  Vars.Items[VarNo].Sizes.Clear;
                  Vars.Items[VarNo].Sizes.AddRange(tmpVars.Items[tmpVarNo].Sizes);
                  Vars.Items[VarNo].Arr.Clear;
                  Vars.Items[VarNo].Arr.AddRange(tmpVars.Items[tmpVarNo].Arr);
                end;
              end;
          end;
          tmpVars.Free;
          if AlreadyInit then
          begin
            New(Lexs);
            ReadBlock(InitBlock.InitCode, Lexs);
            if CheckOperator(Lexs) then
              ExecOperator(Lexs, Vars);
          end;
          SetRange;
          FTbCur.Color := ChildForm.ColorBlock;
          if not HasFirstBlock then
          begin
            AutoPause;
            MessageDlg(
              'В вызываемой схеме не указан первый элемент'#10#13'Откройте эту схему, задайте первый элемент и сохраните ее.'
                , mtError, [mbOK], 0);
            AutoResume;
            Cur := nil;
          end
          else
          begin
            FTbCur := StartBlock;
            Cur := StartBlock;
          end;
        end
        else
        begin
          AutoPause;
          MessageDlg('Схема ' + fstr + '.bsh не существует.'#10#13'Pабота схемы завершена', mtError, [mbOK], 0);
          AutoResume;
          Cur := nil;
        end;
      end;

    stIf:
      begin
        ReadBlock(Tb.Statement, Lexs);
        Pos := 1;
        if CheckExpr(Lexs) then
        begin
          Pos := 1;
          Val := ExecExpr(Lexs, Vars);
          if Val._Type = tyReal then
            if Val.Real = 0 then
              Cur := GetNext(Tb, false)
            else
              Cur := GetNext(Tb, true)
            else
              RunTimeError('Ожидалось условие, но найдена строка');
        end
        else
          Cur := nil;
      end;
  end;

  if (Cur = nil) and (StackInfo.Count <> 0) then
    OnEnd;

  Dispose(Lexs);

  frmWatch.VarsRefresh;
end;

procedure TChildForm.NStepClick(Sender: TObject);
begin
  flagNextTakt := true;
end;

procedure TChildForm.mnuDeleteClick(Sender: TObject);
begin
  MainForm.btnDeleteClick(Sender);
  // Modified by Roman Mitin

  // DeleteBlock(TmpBlock); <- old code by I. Skriblovsky
end;

procedure TChildForm.mnuEditBlockClick(Sender: TObject);
begin
  PaintBoxDblClick(TmpBlock);
  Refresh;
end;

procedure TChildForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  DoExit: Boolean;

begin
  if ANew.New then
  begin
    if ANew.Tail = atEnd then
    begin
      ANew.Tail := atStart;
      FirstClick := Point(X, Y);
      Refresh;
      ANew.Arrow.Hide := false;
      ANew.Arrow.oldTail[atEnd] := ANew.Arrow.Tail[atEnd];
      ANew.Arrow.Tail[atStart] := Point(X, Y);
      ANew.Arrow.Draw;
      with ANew.Arrow do
      begin
        ANew.Arrow.Draw;
        case ANew.Arrow._Type of
          horiz:
            p := Tail[atEnd].Y;
          vert:
            p := Tail[atEnd].X;
        end;
        ANew.Arrow.Draw;
      end;
    end;
    Exit;
  end;

  if not(ssShift in Shift) then
    Actives.Clear;

  Mous := Point(X, Y);
  DoExit := false;
  for i := 0 to ArrowList.Count - 1 do
  begin
    ArrowList.Items[i].MouseDown(Shift);
    if ArrowList.Items[i].IsDrag then
    begin
      DoExit := true;
      Break;
    end;
  end;
  if DoExit then
    Exit;

  Xd := X;
  Yd := Y;
  Xc := X;
  Yc := Y;
  if not Viewer then
    Bevel.Visible := true;
  Bevel.Width := 0;
  Bevel.Height := 0;
  if MainForm.WhatDown <> wdNone then
  begin
    CreateBlockFromButts := true;
    CreateBlockFromButtsPoint := Point(X, Y);
    case MainForm.WhatDown of
      wdEllipse:
        begin
          CreateBlock(stBeginEnd);
          MainForm.EllipseSB.down := false;
        end;
      wdRect:
        begin
          CreateBlock(stStatement);
          MainForm.RectSB.down := false;
        end;
      wdRomb:
        begin
          CreateBlock(stIf);
          MainForm.RombSB.down := false;
        end;
      wdParal:
        begin
          CreateBlock(stInOut);
          MainForm.ParalSB.down := false;
        end;
      wdCall:
        begin
          CreateBlock(stCall);
          MainForm.CallSB.down := false;
        end;
      wdGlob:
        begin
          CreateBlock(stGlob);
          MainForm.GlobSB.down := false;
        end;
      wdInit:
        begin
          CreateBlock(stInit);
          MainForm.InitSB.down := false;
        end;
      wdComment:
        begin
          CreateBlock(stComment);
          MainForm.CommSB.down := false;
        end;
      wdConfl:
        begin
          CreateBlock(stConfl);
          MainForm.ConflSB.down := false;
        end;
    end;
    DefCursor := crDefault;
    MainForm.WhatDown := wdNone;
    CreateBlockFromButts := false;
  end;
end;

procedure TChildForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;

begin
  dMous := Point(X - Mous.X, Y - Mous.Y);
  Mous := Point(X, Y);

  if ANew.New then
  begin
    ANew.Arrow.DragObj := Tail2Obj(ANew.Tail);
    ANew.Arrow.IsDrag := true;
    ANew.Arrow.Drag(X, Y);
    Exit;
  end;

  Cursor := DefCursor;
  for i := 0 to ArrowList.Count - 1 do
  begin
    ArrowList.Items[i].MouseTest;
    if ArrowList.Items[i].IsDrag then
      ArrowList.Items[i].Drag(X, Y);
  end;

  if Bevel.Visible then
  begin
    Xc := X;
    Yc := Y;
    Bevel.Left := min(Xd, Xc);
    Bevel.Top := min(Yd, Yc);
    Bevel.Width := max(Xd, Xc) - Bevel.Left;
    Bevel.Height := max(Yd, Yc) - Bevel.Top;
  end;

  // AboutBox
  with AboutBox do
  begin
    with GoToWeb do
    begin
      Font.Color := clPurple;
      Font.Style := GoToWeb.Font.Style - [fsUnderline];
    end;
  end;
end;

procedure TChildForm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  j, i: Integer;
  b: TBlock;
  A: TArrow;
  f: Boolean;
  T: TArrowTail;
  UN: PUndoNode;

begin
  for i := 0 to ArrowList.Count - 1 do
    ArrowList.Items[i].DoesNotUnDock := false;

  if ANew.New then
  begin
    if (Abs(X - FirstClick.X) > 5) or (Abs(Y - FirstClick.Y) > 5) then
    begin
      CreateArrow;
      Exit;
    end;
    Refresh;
  end;

  for j := 0 to ArrowList.Count - 1 do
    if (ArrowList.Items[j].IsDrag) and (ArrowList.Items[j].DragObj in [st, en]) then
    begin
      for i := 0 to BlockList.Count - 1 do
        if TTmpBlock(BlockList[i]).CanIDock(X, Y, Obj2Tail(ArrowList.Items[j].DragObj), true) then
          ArrowList.Items[j].Dock(TTmpBlock(BlockList[i]), Obj2Tail(ArrowList.Items[j].DragObj),
            TTmpBlock(BlockList[i]).GetPort(X, Y));
    end;

  for i := 0 to ArrowList.Count - 1 do
    if ArrowList.Items[i].IsDrag then
    begin
      A := ArrowList[i];

      New(UN);
      UN._ := utArrowMove;
      UN.Group := 1;
      UN.Arrow := A;
      UN.pnt := unOrig[atStart];
      UN.pnt1 := unOrig[atEnd];
      UN.p := unP;
      UN.ArrowType := unType;
      UN.ArrowStyle := unStyle;
      UN.Block := unBlock[atStart] as TBlock;
      UN.Block1 := unBlock[atEnd] as TBlock;
      UN.Port[atStart] := unPort[atStart];
      UN.Port[atEnd] := unPort[atEnd];
      MainForm.AddUndo(UN);

      A.IsDrag := false;

      A.DragObj := none;
    end;
  Refresh;

  if Bevel.Visible then
  begin
    for i := 0 to BlockList.Count - 1 do
    begin
      b := BlockList[i];
      if (b.Left > Bevel.Left - b.Width) and (b.Left < Bevel.Left + Bevel.Width) and (b.Top > Bevel.Top - b.Height) and
        (b.Top < Bevel.Top + Bevel.Height) then
        Actives.SetActive(b);
    end;
    for i := 0 to ArrowList.Count - 1 do
    begin
      A := ArrowList[i];
      f := false;
      for T := atStart to atEnd do
        if (A.Tail[T].X > Bevel.Left) and (A.Tail[T].X < Bevel.Left + Bevel.Width) and (A.Tail[T].Y > Bevel.Top) and
          (A.Tail[T].Y < Bevel.Top + Bevel.Height) then
          f := true;
      case A._Type of
        vert:
          if ((A.p > Bevel.Left) and (A.p < Bevel.Left + Bevel.Width) and (A.Tail[atStart].Y > Bevel.Top) and
              (A.Tail[atStart].Y < Bevel.Top + Bevel.Height)) or
            ((A.p > Bevel.Left) and (A.p < Bevel.Left + Bevel.Width) and (A.Tail[atEnd].Y > Bevel.Top) and
              (A.Tail[atEnd].Y < Bevel.Top + Bevel.Height)) then
            f := true;
        horiz:
          if ((A.p > Bevel.Top) and (A.p < Bevel.Top + Bevel.Height) and (A.Tail[atStart].X > Bevel.Left) and
              (A.Tail[atStart].X < Bevel.Left + Bevel.Width)) or
            ((A.p > Bevel.Top) and (A.p < Bevel.Top + Bevel.Height) and (A.Tail[atEnd].X > Bevel.Left) and
              (A.Tail[atEnd].X < Bevel.Left + Bevel.Width)) then
            f := true;
      end;
      if f then
        Actives.SetActive(A);
    end;
    Bevel.Visible := false;
    Refresh;
  end;

  if ANew.New then
    ANew.Arrow.Draw;

  SetRange;
end;

procedure TChildForm.CreateBlock(Q: SetBlocks);
var
  UN: PUndoNode;

begin
  TmpBlock := TBlock.Create(ChildForm);
  TmpBlock.Parent := ChildForm;
  TmpBlock.Block := Q;
  if Q = stGlob then
  begin
    GlobBlock := TmpBlock;
    AlreadyGlob := true;
  end;
  if Q = stInit then
  begin
    InitBlock := TmpBlock;
    AlreadyInit := true;
  end;
  SetParamBlock(TmpBlock);
  pTmp := TmpBlock;
  BlockList.Add(ChildForm.pTmp);
  if CreateBlockFromButts then
    if Q <> stConfl then
    begin
      TmpBlock.Left := CreateBlockFromButtsPoint.X - TmpBlock.Width div 2;
      TmpBlock.Top := CreateBlockFromButtsPoint.Y - TmpBlock.Height div 2;
    end
    else
    begin
      TmpBlock.Left := CreateBlockFromButtsPoint.X - ConflRadius div 2;
      TmpBlock.Top := CreateBlockFromButtsPoint.Y - ConflRadius div 2;
    end;

  New(UN);
  UN^._ := utNewBlock;
  UN^.Group := 1;
  UN^.Block := TmpBlock;
  MainForm.AddUndo(UN);

  SetRange;

  TmpBlock.Paint;
end;

procedure TChildForm.SetRange;
var
  xi, xa, yi, ya: Integer;
  i: Integer;
  b: TBlock;
  A: TArrow;
  T: TArrowTail;
  vp, hp: Integer;

begin
  if BlockList.Count = 0 then
    Exit;
  b := BlockList[0];
  xi := b.Left;
  xa := b.Left + b.Width;
  yi := b.Top;
  ya := b.Top + b.Height;
  for i := 1 to BlockList.Count - 1 do
  begin
    b := BlockList[i];
    if b.Left < xi then
      xi := b.Left;
    if b.Left + b.Width > xa then
      xa := b.Left + b.Width;
    if b.Top < yi then
      yi := b.Top;
    if b.Top + b.Height > ya then
      ya := b.Top + b.Height;
  end;
  for i := 0 to ArrowList.Count - 1 do
  begin
    A := ArrowList[i];
    for T := atStart to atEnd do
    begin
      xi := min(xi, A.Tail[T].X);
      xa := max(xa, A.Tail[T].X);
      yi := min(yi, A.Tail[T].Y);
      ya := max(ya, A.Tail[T].Y);
    end;
    case A._Type of
      vert:
        begin
          xi := min(xi, A.p);
          xa := max(xa, A.p);
        end;
      horiz:
        begin
          yi := min(yi, A.p);
          ya := max(ya, A.p);
        end;
    end;
  end;

  VertScrollBar.Range := max(VertScrollBar.Range, ClientHeight);
  HorzScrollBar.Range := max(HorzScrollBar.Range, ClientWidth);

  xi := xi - 150;
  xa := xa + 150;
  yi := yi - 150;
  ya := ya + 150;

  vp := VertScrollBar.Position;
  hp := HorzScrollBar.Position;

  xi := xi + hp;
  xa := xa + hp;
  yi := yi + vp;
  ya := ya + vp;

  xi := min(xi, HorzScrollBar.Position);
  xa := max(xa, ClientWidth + HorzScrollBar.Position);
  yi := min(yi, VertScrollBar.Position);
  ya := max(ya, ClientHeight + VertScrollBar.Position);

  VertScrollBar.Range := ya - yi;
  HorzScrollBar.Range := xa - xi;
  VertScrollBar.Position := vp - yi;
  HorzScrollBar.Position := hp - xi;

  for i := 0 to BlockList.Count - 1 do
  begin
    b := BlockList[i];
    b.Left := b.Left - xi;
    b.Top := b.Top - yi;
  end;

  { for i:=0 to ArrowList.Count-1
    do begin
    a:=ArrowList[i];
    for t:=atStart to atEnd
    do a.Tail[t]:=Point(a.Tail[t].x-xi, a.Tail[t].Y-yi);
    case a._Type of
    vert: a.p:=a.p-xi;
    horiz: a.p:=a.p-yi;
    end;
    end; }
  for i := 0 to ArrowList.Count - 1 do
  begin
    A := ArrowList[i];
    for T := atStart to atEnd do
      A.FTail[T] := Point(A.FTail[T].X - xi, A.FTail[T].Y - yi);
    case A._Type of
      vert:
        A.Fp := A.Fp - xi;
      horiz:
        A.Fp := A.Fp - yi;
    end;
  end;

  Refresh;
end;

procedure TChildForm.FormDestroy(Sender: TObject);
var
  pv: PVar;
  pvl: PValue;
  pi: PInteger;
  i, j: Integer;

  pfr: PFile_Rec;

begin
  UndoStack.Free;
  StackInfo.Free;
  for i := Vars.Count - 1 downto 0 do
  begin
    pv := Vars[i];
    for j := pv.Sizes.Count - 1 downto 0 do
    begin
      pi := pv.Sizes[j];
      Dispose(pi);
    end;
    for j := pv.Arr.Count - 1 downto 0 do
    begin
      pvl := pv.Arr[j];
      Dispose(pvl);
    end;
    Dispose(pv);
  end;
  Vars.Free;
  ArrowList.Free;
  BlockList.Free;

  for i := Files.Count - 1 downto 0 do
  begin
    pfr := Files[i];
    pfr.Strings.Free;
    Dispose(pfr);
  end;
  Files.Free;
end;

procedure TChildForm.BlockMenuPopup(Sender: TObject);
var
  i: Integer;
  T: TArrowTail;
  Arrows: array [TArrowTail] of Boolean;

begin
  mnuReplace.Visible := (not Viewer) and (not flagInWork) and (TmpBlock.Block in [stStatement, stInOut, stCall]);

  FillChar(Arrows, SizeOf(Arrows), false);
  for i := 0 to ArrowList.Count - 1 do
    for T := atStart to atEnd do
      if ArrowList.Items[i].Blocks[T].Block = TmpBlock then
        Arrows[T] := true;

  mnuRepNothing.Visible := Arrows[atStart] and Arrows[atEnd];
end;

procedure TChildForm.FormPaint(Sender: TObject);
var
  i: Integer;

begin
  ChildForm.Canvas.Pen.Style := psSolid;
  ChildForm.Canvas.Pen.Color := clBlack;
  for i := 0 to ArrowList.Count - 1 do
    if not ArrowList.Items[i].Hide then
      ArrowList.Items[i].Draw;
end;

procedure TChildForm.BevelPaint(Sender: TObject);
begin
  Bevel.SendToBack;
  Bevel.Canvas.Pen.Color := clGray;
  Bevel.Canvas.Pen.Style := psDot;
  Bevel.Canvas.MoveTo(0, 0);
  Bevel.Canvas.LineTo(Bevel.Width - 1, 0);
  Bevel.Canvas.LineTo(Bevel.Width - 1, Bevel.Height - 1);
  Bevel.Canvas.LineTo(0, Bevel.Height - 1);
  Bevel.Canvas.LineTo(0, 0);
end;

procedure TChildForm.DeleteBlock(b: TBlock; MakeUndo: Boolean = true);
var
  i: Integer;
  T: TArrowTail;
  UN: PUndoNode;
  A: TArrow;
  counter: Integer;

begin
  if b.Block = stGlob then
    AlreadyGlob := false;

  if b.Block = stInit then
    AlreadyInit := false;

  counter := 0;
  for i := 0 to ArrowList.Count - 1 do
    for T := atStart to atEnd do
      if ArrowList.Items[i].Blocks[T].Block = b then
      begin
        if MakeUndo then
        begin
          A := ArrowList[i];
          New(UN);
          UN^.Group := 1;
          UN^._ := utArrowMove;
          UN^.Arrow := A;
          UN^.p := A.p;
          UN^.ArrowType := A._Type;
          UN^.ArrowStyle := A.Style;
          UN^.pnt := A.Tail[atStart];
          UN^.pnt1 := A.Tail[atEnd];
          UN^.Block := TBlock(A.Blocks[atStart].Block);
          UN^.Block1 := TBlock(A.Blocks[atEnd].Block);
          UN^.Port[atStart] := A.Blocks[atStart].Port;
          UN^.Port[atEnd] := A.Blocks[atEnd].Port;
          MainForm.AddUndo(UN);
          Inc(counter);
        end;
        ArrowList.Items[i].UnDock(T);
      end;

  MainForm.Modifed := true;
  BlockList.Remove(b);

  // B.Free;
  b.Hide;
  if MakeUndo then
  begin
    New(UN);
    UN^.Group := counter + 1;
    UN^._ := utDelBlock;
    UN^.Block := b;
    UN^.WasStartBlock := (StartBlock = b);
    MainForm.AddUndo(UN);
  end;

  if StartBlock = b then
    StartBlock := nil;
end;

procedure TChildForm.DeleteArrow(A: TArrow; MakeUndo: Boolean = true);
var
  UN: PUndoNode;

begin
  MainForm.Modifed := true;
  ArrowList.Remove(A);

  // A.Free;
  A.Hide := true;
  if MakeUndo then
  begin
    New(UN);
    UN^.Group := 1;
    UN^._ := utDelArrow;
    UN^.Arrow := A;
    MainForm.AddUndo(UN);
  end;
end;

procedure TChildForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  WriteIniFile;
end;

procedure ToolCreate(var b: TBlock; Block: SetBlocks);
begin
  b := TBlock.Create(ChildForm);
  b.Parent := ChildForm;
  b.Block := Block;
  ChildForm.SetParamBlock(b);
  b.WriteText;
  // ChildForm.BlockList.Add(b);
end;

function TChildForm.MakeReplace(b1, b2: TBlock; T: TArrowTail; ChangePort: Boolean = false;
  Port: TBlockPort = North): TArrow;
var
  i: Integer;

begin
  Result := nil;
  for i := 0 to ArrowList.Count - 1 do
    if ArrowList.Items[i].Blocks[T].Block = b1 then
    begin
      ArrowList.Items[i].Blocks[T].Block := b2;
      if ChangePort then
        ArrowList.Items[i].Blocks[T].Port := Port;
      ArrowList.Items[i].StandWell;
      Result := ArrowList[i];
    end;
end;

(*
  procedure TChildForm.MoveAllDown(b1: TTmpBlock; h: integer);
  const Ind=30;
  var i: integer;

  procedure Check(b: TTmpBlock);
  var
  a: TArrow;
  i: integer;

  begin
  for i:=0 to ArrowList.Count-1
  do begin
  a:=ArrowList[i];
  if (a.Blocks[atEnd].Block=b) and (a.Blocks[atStart].Block<>nil) and (a.Blocks[atStart].Block.Tag1=0)//and (a.Tail[atStart].y>=a.Tail[atEnd].y)
  then begin
  //                if (a.Blocks[atStart].Block.Top>=b{1}.Top) and (a.Blocks[atStart].Block.Top<=b{1}.Top+h) //+ind)
  if (A.Blocks[atStart].Block.Top>=b.Top) and (a.Blocks[atStart].Block.Top<=b.Top+b.Height+ind+h)
  then a.Blocks[atStart].Block.Tag:=1;
  a.Blocks[atStart].Block.Tag1:=1;
  Check(a.Blocks[atStart].Block);
  end;
  end;
  end;

  procedure Move(b: TTmpBlock);
  var
  a: TArrow;
  i: integer;

  begin
  b.Tag:=0;
  for i:=0 to ArrowList.Count-1
  do begin
  a:=ArrowList[i];
  if (a.Blocks[atEnd].Block=b) and (a.Blocks[atStart].Block<>nil) and (a.Blocks[atStart].Block.Tag1=0)
  then if true
  then begin
  if a.Blocks[atStart].Block.Tag=1
  then begin
  //                            a.Blocks[atStart].Block.Top:=b.Top+b.Height+Ind;//a.Blocks[atStart].Block.Top+h;
  if a.Blocks[atStart].Block.Top>=b1.Top
  then a.Blocks[atStart].Block.Top:=a.Blocks[atStart].Block.Top+h;
  a.Blocks[atStart].Block.Tag:=0;
  end;
  a.Blocks[atStart].Block.Tag1:=1;
  Move(a.Blocks[atStart].Block);
  end;
  end;
  end;

  begin
  for i:=0 to BlockList.Count-1
  do TBlock(BlockList[i]).Tag:=0;
  for i:=0 to BlockList.Count-1
  do TBlock(BlockList[i]).Tag1:=0;
  Check(b1);
  b1.Top:=b1.Top+h;
  for i:=0 to BlockList.Count-1
  do TBlock(BlockList[i]).Tag1:=0;
  Move(b1);
  end;
  *)

procedure TChildForm.MoveAllDown(b1: TTmpBlock; h: Integer);
var
  i: Integer;
  b: TBlock;
  A: TArrow;
  j: TArrowTail;

begin
  for i := 0 to BlockList.Count - 1 do
  begin
    b := BlockList[i];
    if (b.Top > b1.Top) then
      b.Top := b.Top + h;
  end;

  for i := 0 to ArrowList.Count - 1 do
  begin
    A := ArrowList[i];
    for j := atStart to atEnd do
      if A.Tail[j].Y > b1.Top then
        A.Tail[j] := Point(A.Tail[j].X, A.Tail[j].Y + h);
    case A._Type of
      horiz:
        if A.p > b1.Top then
          A.p := A.p + h;
    end;
  end;
end;

procedure TChildForm.MoveAllLeftRight(b1: TTmpBlock; l, r: Integer);
var
  i, c, c1: Integer;
  j: TArrowTail;
  b: TBlock;
  A: TArrow;
begin
  c1 := b1.Left + b1.Width div 2;
  for i := 0 to BlockList.Count - 1 do
  begin
    b := BlockList[i];
    c := b.Left + b.Width div 2;
    if c < c1 then
      b.Left := b.Left - l;
    if c > c1 then
      b.Left := b.Left + r;
  end;
  for i := 0 to ArrowList.Count - 1 do
  begin
    A := ArrowList[i];
    for j := atStart to atEnd do
    begin
      if A.Tail[j].X < c1 then
        A.Tail[j] := Point(A.Tail[j].X - l, A.Tail[j].Y);
      if A.Tail[j].X > c1 then
        A.Tail[j] := Point(A.Tail[j].X + r, A.Tail[j].Y);
    end;
    case A._Type of
      vert:
        if A.p < c1 then
          A.p := A.p - l
        else
          A.p := A.p + r;
    end;
  end;
end;

procedure TChildForm.mnuSequenceClick(Sender: TObject);
var
  b, b1: TBlock;
  A: TArrow;

const
  Ind = 30;

begin
  ToolCreate(b, TmpBlock.Block);
  b.Left := TmpBlock.Left + TmpBlock.Width div 2 - b.Width div 2;
  b.Top := TmpBlock.Top;

  ToolCreate(b1, TmpBlock.Block);
  b1.Left := TmpBlock.Left + TmpBlock.Width div 2 - b1.Width div 2;
  b1.Top := b.Top + b.Height + Ind;

  MoveAllDown(TmpBlock, b1.Top - b.Top);

  BlockList.Add(b);
  BlockList.Add(b1);

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := b;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := b1;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := horiz;
  A.StandWell;
  A.p := A.Tail[atEnd].X;
  A.StandWell;

  MakeReplace(TmpBlock, b, atStart);
  MakeReplace(TmpBlock, b1, atEnd);

  DeleteBlock(TmpBlock, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuIfFullClick(Sender: TObject);
var
  if1, s1, s2, c: TBlock;
  A: TArrow;

const
  Ind = 30;

begin
  ToolCreate(if1, stIf);
  if1.Left := TmpBlock.Left + TmpBlock.Width div 2 - if1.Width div 2;
  if1.Top := TmpBlock.Top;
  ToolCreate(s1, stStatement);
  s1.Left := if1.Left - s1.Width;
  s1.Top := if1.Top + if1.Height + Ind;
  ToolCreate(s2, stStatement);
  s2.Left := if1.Left + s2.Width;
  s2.Top := if1.Top + if1.Height + Ind;
  ToolCreate(c, stConfl);
  c.Left := if1.Left + if1.Width div 2 - c.Width div 2;
  c.Top := s1.Top + s1.Height + Ind;

  MoveAllDown(TmpBlock, c.Top - if1.Top); // c.Top-if1.Top-s1.Height+c.Height);
  MoveAllLeftRight(TmpBlock, TmpBlock.Left - s1.Left, s2.Left + s2.Width - TmpBlock.Left - TmpBlock.Width);

  BlockList.Add(if1);
  BlockList.Add(s1);
  BlockList.Add(s2);
  BlockList.Add(c);

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := if1;
  A.Blocks[atEnd].Port := West;
  A.Blocks[atStart].Block := s1;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := if1;
  A.Blocks[atEnd].Port := East;
  A.Blocks[atStart].Block := s2;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := s1;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := c;
  A.Blocks[atStart].Port := West;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := s2;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := c;
  A.Blocks[atStart].Port := East;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  MakeReplace(TmpBlock, if1, atStart);
  MakeReplace(TmpBlock, c, atEnd);

  DeleteBlock(TmpBlock, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuIfNFullClick(Sender: TObject);
var
  if1, s2, c: TBlock;
  A: TArrow;

const
  Ind = 30;

begin
  ToolCreate(if1, stIf);
  if1.Left := TmpBlock.Left + TmpBlock.Width div 2 - if1.Width div 2;
  if1.Top := TmpBlock.Top;
  ToolCreate(s2, stStatement);
  s2.Left := if1.Left + s2.Width;
  s2.Top := if1.Top + if1.Height + Ind;
  ToolCreate(c, stConfl);
  c.Left := if1.Left + if1.Width div 2 - c.Width div 2;
  c.Top := s2.Top + s2.Height + Ind;

  MoveAllDown(TmpBlock, c.Top - if1.Top - s2.Height + c.Height);
  MoveAllLeftRight(TmpBlock, l, s2.Left + s2.Width - TmpBlock.Left - TmpBlock.Width);

  BlockList.Add(if1);
  BlockList.Add(s2);
  BlockList.Add(c);

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := if1;
  A.Blocks[atEnd].Port := West;
  A.Blocks[atStart].Block := c;
  A.Blocks[atStart].Port := West;
  A._Type := vert;
  A.p := if1.Left - Ind;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := if1;
  A.Blocks[atEnd].Port := East;
  A.Blocks[atStart].Block := s2;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := s2;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := c;
  A.Blocks[atStart].Port := East;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  MakeReplace(TmpBlock, if1, atStart);
  MakeReplace(TmpBlock, c, atEnd);

  DeleteBlock(TmpBlock, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuLoopPredClick(Sender: TObject);
var
  f, s, c, c1: TBlock;
  A: TArrow;

const
  Ind = 30;

begin
  ToolCreate(c, stConfl);
  c.Left := TmpBlock.Left + TmpBlock.Width div 2 - c.Width div 2;
  c.Top := TmpBlock.Top;
  ToolCreate(f, stIf);
  f.Left := TmpBlock.Left + TmpBlock.Width div 2 - f.Width div 2;
  f.Top := c.Top + c.Height + Ind;
  ToolCreate(s, stStatement);
  s.Left := TmpBlock.Left + TmpBlock.Width div 2 - s.Width div 2;
  s.Top := f.Top + f.Height + Ind;
  ToolCreate(c1, stConfl);
  c1.Left := TmpBlock.Left + TmpBlock.Width div 2 - c1.Width div 2;
  c1.Top := s.Top + s.Height + Ind;

  MoveAllDown(TmpBlock, c1.Top - c.Top - s.Height + c1.Height);
  MoveAllLeftRight(TmpBlock, Ind, Ind);

  BlockList.Add(f);
  BlockList.Add(s);
  BlockList.Add(c);
  BlockList.Add(c1);

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := c;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := f;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := f;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := s;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := s;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := c;
  A.Blocks[atStart].Port := West;
  A._Type := vert;
  A.p := f.Left - Ind;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := f;
  A.Blocks[atEnd].Port := East;
  A.Blocks[atStart].Block := c1;
  A.Blocks[atStart].Port := East;
  A._Type := vert;
  A.p := f.Left + f.Width + Ind;
  A.StandWell;

  MakeReplace(TmpBlock, c, atStart);
  MakeReplace(TmpBlock, c1, atEnd);

  DeleteBlock(TmpBlock, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuLoopPostClick(Sender: TObject);
var
  f, s, c, c1: TBlock;
  A: TArrow;

const
  Ind = 30;

begin
  ToolCreate(c, stConfl);
  c.Left := TmpBlock.Left + TmpBlock.Width div 2 - c.Width div 2;
  c.Top := TmpBlock.Top;
  ToolCreate(s, stStatement);
  s.Left := TmpBlock.Left + TmpBlock.Width div 2 - s.Width div 2;
  s.Top := c.Top + c.Height + Ind;
  ToolCreate(f, stIf);
  f.Left := TmpBlock.Left + TmpBlock.Width div 2 - f.Width div 2;
  f.Top := s.Top + s.Height + Ind;
  ToolCreate(c1, stConfl);
  c1.Left := TmpBlock.Left + TmpBlock.Width div 2 - c1.Width div 2;
  c1.Top := f.Top + f.Height + Ind;

  MoveAllDown(TmpBlock, c1.Top - c.Top - s.Height + c1.Height);
  MoveAllLeftRight(TmpBlock, Ind, Ind);

  BlockList.Add(f);
  BlockList.Add(s);
  BlockList.Add(c);
  BlockList.Add(c1);

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := c;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := s;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := s;
  A.Blocks[atEnd].Port := South;
  A.Blocks[atStart].Block := f;
  A.Blocks[atStart].Port := North;
  A.Style := eg2;
  A._Type := vert;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := f;
  A.Blocks[atEnd].Port := West;
  A.Blocks[atStart].Block := c;
  A.Blocks[atStart].Port := West;
  A._Type := vert;
  A.p := f.Left - Ind;
  A.StandWell;

  A := TArrow.Create;
  ArrowList.Add(A);
  A.Blocks[atEnd].Block := f;
  A.Blocks[atEnd].Port := East;
  A.Blocks[atStart].Block := c1;
  A.Blocks[atStart].Port := East;
  A._Type := vert;
  A.p := f.Left + f.Width + Ind;
  A.StandWell;

  MakeReplace(TmpBlock, c, atStart);
  MakeReplace(TmpBlock, c1, atEnd);

  DeleteBlock(TmpBlock, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuRepStatClick(Sender: TObject);
begin
  TmpBlock.Block := stStatement;
  MainForm.Modifed := true;
  TmpBlock.Refresh;
end;

procedure TChildForm.mnuRepIOClick(Sender: TObject);
begin
  TmpBlock.Block := stInOut;
  MainForm.Modifed := true;
  TmpBlock.Refresh;
end;

procedure TChildForm.mnuRepCallClick(Sender: TObject);
begin
  TmpBlock.Block := stCall;
  MainForm.Modifed := true;
  TmpBlock.Refresh;
end;

procedure TChildForm.mnuRepNothingClick(Sender: TObject);
var
  Arrows: array [TArrowTail] of TArrow;
  T: TArrowTail;
  i: Integer;

begin
  for i := 0 to ArrowList.Count - 1 do
    for T := atStart to atEnd do
      if ArrowList.Items[i].Blocks[T].Block = TmpBlock then
        Arrows[T] := ArrowList[i];
  Arrows[atStart].Style := eg4;
  Arrows[atStart].StandWell;
  Arrows[atStart].Blocks[atStart] := Arrows[atEnd].Blocks[atStart];
  Arrows[atStart].StandWell;
  Arrows[atStart].Tail[atStart] := Arrows[atEnd].Tail[atStart];
  Arrows[atStart].StandWell;
  DeleteArrow(Arrows[atEnd], false);
  DeleteBlock(TmpBlock, false);
  Refresh;
end;

procedure TChildForm.mnuRepEndClick(Sender: TObject);
var
  i: Integer;
  A: TArrow;

begin
  TmpBlock.Block := stBeginEnd;
  for i := 0 to ArrowList.Count - 1 do
  begin
    A := ArrowList[i];
    if (A.Blocks[atEnd].Block = TmpBlock) then
    begin
      A.Blocks[atEnd].Block := nil;
      A.StandWell;
      Refresh;
    end;
  end;
  MainForm.Modifed := true;
  TmpBlock.Refresh;
end;

end.

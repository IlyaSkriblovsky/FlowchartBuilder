unit Child;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Buttons, ExtCtrls, StdCtrls, IniFiles, EdTypes, OpenUnit, SaveUnit,
  ComCtrls, Printers, Lang, Math, Arrows, Ini, BlockProps;

type
  TActives=class;
  TChildForm = class(TForm)
    BlockMenu: TPopupMenu;
    mnuStat: TMenuItem;
    mnuUnfText: TMenuItem;
    mnuRem: TMenuItem;
    mnuDelete: TMenuItem;
    mnuGlob: TMenuItem;
    mnuInit: TMenuItem;
    Bevel: TPaintBox;
    mnuReplace: TMenuItem;
    mnuSequence: TMenuItem;
    mnuIfFull: TMenuItem;
    mnuIfNFull: TMenuItem;
    mnuLoopPred: TMenuItem;
    mnuLoopPost: TMenuItem;
    N1: TMenuItem;
    mnuRepBlock: TMenuItem;
    N3: TMenuItem;
    mnuRepNothing: TMenuItem;
    mnuRepStat: TMenuItem;
    mnuRepIO: TMenuItem;
    mnuRepCall: TMenuItem;
    mnuRepEnd: TMenuItem;
    procedure DestroyList;
    procedure GoProc(f : Boolean; MakeTakt: boolean=true);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxDblClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure SetParamBlok( T : TObject );
    procedure mnuStatClick(Sender: TObject);
    procedure mnuRemClick(Sender: TObject);
    procedure NStepClick(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure mnuUnfTextClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure CreateBlock(Q: SetBlocks);

    procedure SetRange;
    procedure Takt;
    procedure Execute(f : Boolean; MakeTakt: boolean=true);
    procedure FormDestroy(Sender: TObject);
    procedure BlockMenuPopup(Sender: TObject);
    procedure mnuGlobClick(Sender: TObject);
    procedure mnuInitClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BevelPaint(Sender: TObject);

    procedure SetButtsEnable(b: boolean);
    procedure SetButtsUp;

    procedure AlignHoriz;
    procedure AlignVert;

    procedure DeleteBlock(B: TBlock; MakeUndo: boolean=true);
    procedure DeleteArrow(A: TArrow; MakeUndo: boolean=true);

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


  private
    XOffset, YOffset : Integer;
    PS : TPaintBox;
    Xd, Yd, Xc, Yc: Integer;
    RamkaOn : Boolean;

  public
    ArrowList: TList;
    ANew: record
      New: boolean;
      Tail: TArrowTail;
      Arrow: TArrow;
    end;
    DefCursor: TCursor;

    boolFirst: boolean;

    Cur: TBlock;

    Actives: TActives;

    ColorFontBlok, ColorCurrentBlok, ColorBlok, ColorChain : TColor;
    ConflRadius: integer;
    AutoCheck: boolean;

    WidthBlok : Integer;
    HeightBlok : Integer;

    Xt, Yt : Integer;

    FileName: string;
    flagNextTakt : Boolean;
    flagBreak : Boolean;
    flagInWork : Boolean;

    Vars: TVars;

    BlockList : TList;
    pTmp : Pointer;
    TmpBlok : TBlock;
    FindStartBlok : Boolean;
    StartBlok : TBlock;
    FTbCur : TBlock;
    StrList : TStringList;
    Dragging : Boolean;
    FirstClick: TPoint;

    DblClicked: boolean;

    BlockFont: TFont;

    procedure CreateArrow;
    function MakeReplace(b1, b2: TBlock; t: TArrowTail; ChangePort: boolean=false; Port: TBlockPort=North): TArrow;
    procedure MoveAllDown(b1: TTmpBlock; h: integer);
    procedure MoveAllLeftRight(b1: TTmpBlock; l, r: integer);

    procedure AllArrowsStandWell;

  end;

  TActives=class
  public
    Blocks, Arrows: TList;

    constructor Create;

    function GetActive(A: TArrow): boolean; overload;
    function GetActive(B: TBlock): boolean; overload;

    procedure SetActive(A: TArrow; act: boolean=true); overload;
    procedure SetActive(B: TBlock; act: boolean=true); overload;

    procedure Clear;
    procedure Delete;
  end;

  TStackNode=record
    ReturnPos: TBlock;
    BlockList: TList;
    ArrowList: TList;
    Vars: TVars;
    StartBlock: TBlock;
    AlreadyGlob: boolean;
    AlreadyInit: boolean;
    InitBlock: TBlock;
    GlobBlock: TBlock;
  end;
  PStackNode=^TStackNode;

var
  ChildForm: TChildForm;
  CreateBlokFromButts: boolean;
  CreateBlokFromButtsPoint: TPoint;

  dP: TPoint;

  down: record
    _: boolean;
    x, y: integer;
  end;

  StackInfo: TList;

implementation

uses Options, About, OutProg, Main, Watch, StrsInput, StrUtils;

{$R *.DFM}

(***  TActives  ***)
constructor TActives.Create;
begin
  inherited;
  Blocks:=TList.Create;
  Arrows:=TList.Create;
end;

function TActives.GetActive(A: TArrow): boolean;
begin
  Result:=Arrows.IndexOf(A)<>-1;
end;

function TActives.GetActive(B: TBlock): boolean;
begin
  Result:=Blocks.IndexOf(B)<>-1;
end;

procedure TActives.SetActive(A: TArrow; act: boolean);
begin
  if act
  then begin
         if not GetActive(A)
         then Arrows.Add(A);
       end
  else begin
         if GetActive(A)
         then Arrows.Remove(A);
       end;
end;

procedure TActives.SetActive(B: TBlock; act: boolean);
begin
  if act
  then begin
         if not GetActive(B)
         then Blocks.Add(B);
       end
  else begin
         if GetActive(B)
         then Blocks.Remove(B);
       end;
end;

procedure TActives.Clear;
begin
  Blocks.Clear;
  Arrows.Clear;
end;

procedure TActives.Delete;
var
  i: integer;
  UN: PUndoNode;
  Count: integer;

begin
  Count:=UndoStack.Count;
  for i:=Blocks.Count-1 downto 0
  do begin
       ChildForm.DeleteBlock(Blocks[i]);
       Blocks.Delete(i);
     end;
  for i:=Arrows.Count-1 downto 0
  do begin
       ChildForm.DeleteArrow(Arrows[i]);
       Arrows.Delete(i);
     end;

  New(UN);
  UN._:=utEmpty;
  UN.Group:=UNdoStack.Count-Count+1;
  MainForm.AddUndo(UN);

  ChildForm.SetRange;
  MainForm.Modifed:=true;
end;

(***  TChildForm  ***)
procedure TChildForm.AllArrowsStandWell;
var
  i: integer;

begin
  for i:=0 to ArrowList.Count-1
  do TArrow(ArrowList[i]).StandWell;
end;

procedure TChildForm.SetButtsEnable;
begin
  MainForm.RectSB.Enabled:=b;
  MainForm.RombSB.Enabled:=b;
  MainForm.EllipseSB.Enabled:=b;
  MainForm.CallSB.Enabled:=b;
  MainForm.ParalSB.Enabled:=b;
  MainForm.GlobSB.Enabled:=b;
  MainForm.InitSB.Enabled:=b;
  MainForm.CommSB.Enabled:=b;
  MainForm.ConflSB.Enabled:=b;
  MainForm.actDelete.Enabled:=b;
end;

procedure TChildForm.SetButtsUp;
begin
  MainForm.RectSB.Down:=false;
  MainForm.RombSB.Down:=false;
  MainForm.EllipseSB.Down:=false;
  MainForm.CallSB.Down:=false;
  MainForm.ParalSB.Down:=false;
  MainForm.GlobSB.Down:=false;
  MainForm.InitSB.Down:=false;
  MainForm.CommSB.Down:=false;
  MainForm.ConflSB.Down:=false;
end;

procedure TChildForm.AlignVert;
var
  i: integer;
  lS: integer;
  a: TArrow;
  UN: PUndoNode;
  cnt: integer;

begin
  if Actives.Blocks.Count=0
  then Exit;
  
  lS:=0;
  for i:=0 to Actives.Blocks.Count-1
  do Inc(lS, TBlock(Actives.Blocks[i]).Left+TBlock(Actives.Blocks[i]).Width div 2);
  lS:=lS div Actives.Blocks.Count;
  for i:=0 to Actives.Blocks.Count-1
  do begin
       New(UN);
       UN^.Group:=1;
       UN^._:=utBlocksMove;
       UN^.Block:=Actives.Blocks[i];
       UN^.pnt:=Point(UN^.Block.Left, UN^.Block.Top);
       MainForm.AddUndo(UN);

       TBlock(Actives.Blocks[i]).Left:=lS-TBlock(Actives.Blocks[i]).Width div 2;
     end;

  cnt:=0;
  for i:=0 to ArrowList.Count-1
  do begin
       a:=ArrowList[i];
       if Actives.GetActive(TBlock(a.Blocks[atStart].Block)) and
          Actives.GetActive(TBlock(a.Blocks[atEnd].Block)) and
          (a.Blocks[atStart].Port in [North, South]) and
          (a.Blocks[atEnd].Port in [North, South])
       then begin
              Inc(cnt);

              New(UN);
              UN._:=utArrowMove;
              UN.Group:=Actives.Blocks.Count+cnt;
              UN.Arrow:=a;
              UN.pnt:=a.Tail[atStart];
              UN.pnt1:=a.Tail[atEnd];
              UN.p:=a.p;
              UN.ArrowType:=a._Type;
              UN.ArrowStyle:=a.Style;
              UN.Block:=a.Blocks[atStart].Block as TBlock;
              UN.Block1:=a.Blocks[atEnd].Block as TBlock;
              UN.port[atStart]:=a.Blocks[atStart].Port;
              UN.port[atEnd]:=a.Blocks[atEnd].Port;
              MainForm.AddUndo(UN);

              a.p:=a.Tail[atStart].X;
            end;
       a.StandWell;
     end;

  Invalidate;
end;

procedure TChildForm.AlignHoriz;
var
  i: integer;
  lT: integer;
  UN: PUndoNode;

begin
  if Actives.Blocks.Count=0
  then Exit;

  lT:=0;
  for i:=0 to Actives.Blocks.Count-1
  do Inc(lT, TBlock(Actives.Blocks[i]).Top+TBlock(Actives.Blocks[i]).Height div 2);
  lT:=lT div Actives.Blocks.Count;
  for i:=0 to Actives.Blocks.Count-1
  do begin
       New(UN);
       UN^.Group:=Actives.Blocks.Count;
       UN^._:=utBlocksMove;
       UN^.Block:=Actives.Blocks[i];
       UN^.pnt:=Point(UN^.Block.Left, UN^.Block.Top);
       MainForm.AddUndo(UN);

       TBlock(Actives.Blocks[i]).Top:=lT-TBlock(Actives.Blocks[i]).Height div 2;
     end;

  for i:=0 to ArrowList.Count-1
  do TArrow(ArrowList[i]).StandWell;

  Invalidate;
end;

procedure TChildForm.CreateArrow;
var
  i: integer;
  UN: PUndoNode;

begin
  for i:=0 to BlockList.Count-1
  do if TTmpBlock(BlockList[i]).CanIDock(Mous.X, Mous.Y, ANew.Tail, true)
     then ANew.Arrow.Dock(TTmpBlock(BlockList[i]), atStart, TTmpBlock(BlockList[i]).GetPort(Mous.x, Mous.y));

  ANew.New:=false;
  MainForm.btnLineRun.Down:=false;
  ANew.Arrow.IsDrag:=false;
  ArrowList.Add(ANew.Arrow);
  DefCursor:=crDefault;

  SetButtsEnable(true);

  New(UN);
  UN^._:=utNewArrow;
  UN^.Group:=1;
  UN^.Arrow:=ANew.Arrow;
  MainForm.AddUndo(UN);

  MainForm.Modifed:=true;
  Refresh;
end;

procedure TChildForm.DestroyList;
var
  i: Integer;

begin
  for i:=BlockList.Count - 1 downto 0
  do TBlock(BlockList[i]).Free;
  BlockList.Clear;

  for i:=ArrowList.Count - 1 downto 0
  do TArrow(ArrowList[i]).Free;
  ArrowList.Clear;

  Actives.Clear;
end;

procedure TChildForm.FormCreate(Sender: TObject);
begin
  Randomize;

  IniFile:=GetHomePath+'\flowcharts.ini';

  UndoStack:=TList.Create;

  BlockList:=TList.Create;
  ArrowList:=TList.Create;

  Actives:=TActives.Create;

  DefCursor:=crDefault;

  StackInfo:=TList.Create;
  Vars:=TVars.Create;

  BlockFont:=TFont.Create;

  Lang.GetFuncValue:=Lang.GetFuncResult;

  BlockList:=TList.Create;
  Dragging:=False;
  RamkaOn:=False;
  flagBreak:=False;
  FindStartBlok:=False;
  ReadIniFile;
  CheckRegistry;

  Files:=TList.Create;
end;

procedure TChildForm.SetParamBlok(T: TObject);
var
  Tb : TBlock;
begin
  Tb:=T as TBlock;
  Tb.Color:=ColorBlok;
  Tb.Font.Color:=ColorFontBlok;
  Tb.Width:=WidthBlok;
  Tb.Height:=HeightBlok;
  if Tb.Block=stConfl
  then begin
         Tb.Width:=ConflRadius;
         Tb.Height:=ConflRadius;
       end;
  Tb.PopupMenu:=BlockMenu;
//  Tb.OnPaint:=TmpBlok.ShowBlok;
  Tb.OnMouseDown:=PaintBoxMouseDown;
  Tb.OnMouseMove:=PaintBoxMouseMove;
  Tb.OnMouseUp:=PaintBoxMouseUp;
  Tb.OnDblClick:=PaintBoxDblClick;
end;

procedure TChildForm.PaintBoxDblClick;
begin
  if not (TBlock(Sender).Block in [stGlob, stInit])
  then begin
         frmProps.Block:=Sender as TBlock;
         frmProps.ShowModal;
       end
  else case TBlock(Sender).Block of
         stGlob: mnuGlobClick(Sender);
         stInit: mnuInitClick(Sender);
       end;
  DblClicked:=true;
end;

procedure TChildForm.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (FindStartBlok) and ((Sender as TBlock).Block<>stGlob) and ((Sender as TBlock).Block<>stInit) then
  begin
    StartBlok:=Sender as TBlock;
    FindStartBlok:=False;
    MainForm.pnlSelectFirstBlock.Visible:=false;
    AutoResume;
    Exit;
  end;

  if Button = mbRight then
  begin
    TmpBlok:=Sender as TBlock;
    Exit;
  end
  else if not Viewer 
       then begin
              if not DblCLicked
              then begin
                     down.x:=x;
                     down.y:=y;
                     down._:=true;
                   end
              else DblClicked:=false;
            end;
end;

procedure DrawFocus;
var
  i: integer;
  b: TBlock;

  procedure DrawFocusRect(R: TRect);
  var
    i: integer;

  begin
    for i:=0 to (R.Right-R.Left) div 2
    do begin
         ChildForm.Canvas.MoveTo(R.Left+i*2, R.Top);
         ChildForm.Canvas.LineTo(R.Left+i*2, R.Top+1);
         ChildForm.Canvas.MoveTo(R.Left+i*2, R.Bottom);
         ChildForm.Canvas.LineTo(R.Left+i*2, R.Bottom+1);
       end;
    for i:=1 to (R.Bottom-R.Top) div 2-1
    do begin
         ChildForm.Canvas.MoveTo(R.Left, R.Top+i*2);
         ChildForm.Canvas.LineTo(R.Left, R.Top+i*2+1);
         ChildForm.Canvas.MoveTo(R.Right, R.Top+i*2);
         ChildForm.Canvas.LineTo(R.Right, R.Top+i*2+1);
       end;
  end;

begin
  ChildForm.Canvas.Pen.Mode:=pmNot;
  for i:=0 to ChildForm.BlockList.Count-1
  do if ChildForm.Actives.GetActive(TBlock(ChildForm.BlockList[i]))
     then begin
            b:=TBlock(ChildForm.BlockList[i]);
            DrawFocusRect(Rect(b.Left+dP.X, b.Top+dP.y, b.Left+b.Width+dP.x-1, b.Top+b.Height+dP.y-1));
          end;
end;

procedure TChildForm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Down._ and ((Abs(x-down.x)>5) or (Abs(y-down.y)>5)) and not Viewer
  then begin
         Dragging:=True;
         if not Actives.GetActive(Sender as TBlock)
         then begin
                Actives.Clear;
                Actives.SetActive(Sender as TBlock);
              end;
         XOffset:=down.x;
         YOffset:=down.y;
         PS:=Sender as TBlock;
         dP:=Point(0, 0);
         boolFirst:=false;
         down._:=false;
       end;

  if Dragging then
  begin
    if boolFirst
    then DrawFocus;
    boolFirst:=true;
    dP.X:=X - XOffset;
    dP.Y:=Y - YOffset;
    DrawFocus;
  end;
end;

procedure TChildForm.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  UN: PUndoNode;
  e: TPoint;

begin
  if not Dragging and not Viewer
  then if not (ssShift in Shift)
       then begin
              Actives.Clear;
              Actives.SetActive(Sender as TBlock)
            end
       else Actives.SetActive(Sender as TBlock, not Actives.GetActive(Sender as TBlock));

  down._:=false;
  if Dragging then
  begin
    DrawFocus;
    Dragging:=False;

    for i:=0 to Actives.Blocks.Count-1
    do with TBlock(Actives.Blocks[i])
            do begin
                 New(UN);
                 UN._:=utBlocksMove;
                 UN.Group:=Actives.Blocks.Count;
                 UN.Block:=Actives.Blocks[i];
                 UN.pnt:=Point(UN.Block.Left, UN.Block.Top);
                 MainForm.AddUndo(UN);

                 Left:=Left+X-XOffset;
                 Top:=Top+Y-YOffset;
               end;

    for i:=0 to ArrowList.Count-1
    do if Actives.GetActive(TArrow(ArrowList[i]))
       then with TArrow(ArrowList[i])
            do begin
                 e:=Point(Tail[atEnd].X+X-XOffset, Tail[atEnd].Y+Y-YOffset);
                 Tail[atStart]:=Point(Tail[atStart].X+X-XOffset, Tail[atStart].Y+Y-YOffset);
                 Tail[atEnd]:=e;   // so as not to process one arrow twice 
                 case _Type of
                    vert: p:=p+X-XOffset;
                   horiz: p:=p+Y-YOffset;
                 end;
               end;

    for i:=0 to ArrowList.Count-1
    do if (Actives.GetActive(TBlock(TArrow(ArrowList[i]).Blocks[atStart].Block))) or
          (Actives.GetActive(TBlock(TArrow(ArrowList[i]).Blocks[atEnd].Block)))
       then TArrow(ArrowList[i]).StandWell;

    MainForm.Modifed:=true;

    for i:=0 to BlockList.Count-1
    do TBlock(BlockList[i]).Paint;
    SetRange;
  end;
end;

procedure TChildForm.GoProc(f : Boolean; MakeTakt: boolean=true);
begin
  Execute(f, MakeTakt);
end;

procedure TChildForm.CheckStatement;
var
  Lexs: PLexemes;
  tmp: string;
  tPos: Cardinal;
  Lines: TStringList;

begin
  if AutoCheck
  then TRY
         New(Lexs);
         FillChar(Lexs^, SizeOf(Lexs^), 0);
         ReadBlock(Tb.Statement, Lexs);
         case Tb.Block of
               stInOut: begin
                          begin
                            if Lexs[1]._Type=lxQuestion
                            then begin
                                   Lines:=TStringList.Create;
                                   Lines.Assign(Tb.Statement);
                                   tmp:=Lines[0];
                                   Delete(tmp, System.Pos('?', tmp), 1);
                                   Lines[0]:=tmp;
                                   Lines[0]:=Lines[0]+':=0';
                                   ReadBlock(Lines, Lexs);
                                   CheckOperator(Lexs);
                                   Lines.Free;
                                 end
                            else begin
                                     Pos:=1;
                                     tPos:=Pos;
                                     CheckExpr(Lexs);
                                     Pos:=tPos;
                                     while Lexs^[Pos]._Type=lxComma
                                     do begin
                                          Inc(Pos);
                                          tPos:=Pos;
                                          CheckExpr(Lexs);
                                          Pos:=tPos;
                                        end;
                                 end;
                          end;
                        end;
           stStatement: begin
                          Pos:=1;
                          CheckOperator(Lexs);
                        end;
                stIf: begin
                          Pos:=1;
                          CheckExpr(Lexs);
                          if Lexs^[Pos]._Type<>lxUndef
                          then raise ECheckError.Create('Ожидалось конец оператора, но найдено лишние символы в позиции '+ IntToStr(Pos));
                        end;
         end;
         Dispose(Lexs);
       except
         Tb.Statement.Assign(BackUp);
         ApplicationHandleException(nil);
       end;
end;

procedure TChildForm.mnuStatClick(Sender : TObject);
var
  Tb : TBlock;
  BackUp: TStringList;
  UN: PUndoNode;

begin
  Tb:=TmpBlok;

  New(UN);
  UN._:=utTextChange;
  UN.Group:=1;
  UN.Block:=Tb;
  UN.Statement:=Tb.Statement.Text;
  UN.Text:=Tb.UnfText.Text;
  UN.RemStr:=Tb.RemText;

  MainForm.Modifed:=true;
  BackUp:=TStringList.Create;
  BackUp.Assign(Tb.Statement);
  MemoInput('Поле ввода', 'Введите оператор', Tb.Statement);
  CheckStatement(BackUp, Tb);
  BackUp.Free;

  if not (Tb.Statement.Text=UN.Statement)
  then MainForm.AddUndo(UN)
  else Dispose(UN);

  Refresh;
end;

procedure TChildForm.mnuRemClick(Sender: TObject);
var
  Tb : TBlock;
  UN: PUndoNode;

begin
  Tb:=TmpBlok;

  New(UN);
  UN._:=utTextChange;
  UN.Group:=1;
  UN.Block:=Tb;
  UN.Statement:=Tb.Statement.Text;
  UN.Text:=Tb.UnfText.Text;
  UN.RemStr:=Tb.RemText;

  MainForm.Modifed:=true;
  Tb.RemText:=InputBox('Поле ввода', 'Введите подсказку', Tb.RemText);
  if not (Tb.RemText=UN.RemStr)
  then MainForm.AddUndo(UN)
  else Dispose(UN);
end;

procedure TChildForm.Execute(f : Boolean; MakeTakt: boolean=true);
var
  Med : Integer;
  StackNode: PStackNode;
  I: integer;
  Lexs: PLexemes;

begin
  if (flagInWork) and (f=False) then
  begin
    FTbCur.Color:=ChildForm.ColorBlok;
    flagInWork:=False;
    MainForm.AutoExec:=false;
    MainForm.actNew.Enabled:=true;
    MainForm.actOpen.Enabled:=true;
    MainForm.actSave.Enabled:=true;

    MainForm.btnLineRun.Enabled:=true;
    MainForm.mnuArrow.Enabled:=true;
    SetButtsEnable(true);
    mnuStat.Enabled:=true;
    mnuUnfText.Enabled:=true;
    mnuRem.Enabled:=true;
    mnuDelete.Enabled:=true;
    mnuGlob.Enabled:=true;
    mnuInit.Enabled:=true;

    if StackInfo.Count>1
    then begin
//           DestroyAllChain;
           for i:=0 to BlockList.Count-1
           do TBlock(BlockList[i]).Hide;
           BlockList.Assign(TStackNode(StackInfo[0]^).BlockList);
           ArrowList.Assign(TStackNode(StackInfo[0]^).ArrowList);

           AlreadyGlob:=TStackNode(StackInfo[0]^).AlreadyGlob;
           AlreadyInit:=TStackNode(StackInfo[0]^).AlreadyInit;
           GlobBlock:=TStackNode(StackInfo[0]^).GlobBlock;
           InitBlock:=TStackNode(StackInfo[0]^).InitBlock;

           Vars.Assign(TStackNode(StackInfo[0]^).Vars);

           StartBlok:=TBlock(BlockList[BlockList.IndexOf(TStackNode(StackInfo[0]^).StarTBlock)]);

           for i:=0 to StackInfo.Count-1
           do begin
                Dispose(PStackNode(StackInfo[0]));
                StackInfo.Delete(0);
              end;
           
           for i:=0 to BlockList.Count-1
           do TBlock(BlockList[i]).Show;
           for i:=0 to ArrowList.Count-1
           do TArrow(ArrowList[i]).Hide:=false;
//           CreateAllLines;
         end;  

         SetRange;
         Refresh;
    Exit;
  end;
  if not flagInWork then
    if ChildForm.StartBlok <> nil then
    begin
      FTbCur:=ChildForm.StartBlok;
      FTbCur.Color:=ChildForm.ColorCurrentBlok;
      MainForm.StatusBar.Panels[1].Text:=FTbCur.RemText;
      flagInWork:=True;
      MainForm.actNew.Enabled:=false;
      MainForm.actOpen.Enabled:=false;
      MainForm.actSave.Enabled:=false;

      MainForm.btnLineRun.Enabled:=false;
      MainForm.mnuArrow.Enabled:=false;
//      MainForm.Stop1.Enabled:=false; Removed by Roman Mitin
      SetButtsEnable(false);
      mnuStat.Enabled:=false;
      mnuUnfText.Enabled:=false;
      mnuRem.Enabled:=false;
      mnuDelete.Enabled:=false;
      mnuGlob.Enabled:=false;
      mnuInit.Enabled:=false;

      for i:=0 to Vars.Count-1
      do Dispose(PVar(Vars[i]));
      Vars:=TVars.Create;
      frmWatch.VarsRefresh;

      GlobVars:=TStringList.Create;
      if AlreadyGlob
      then AddToGlobVars(GlobBlock.GlobStrings);
      if AlreadyInit
      then begin
             New(Lexs);
             ReadBlock(InitBlock.InitCode, Lexs);
             if CheckOperator(Lexs)
             then ExecOperator(Lexs, Vars);
           end;

      New(StackNode);
      StackNode.ReturnPos:=nil;
      StackNode.AlreadyGlob:=AlreadyGlob;
      StackNode.GlobBlock:=GlobBlock;
      StackNode.AlreadyInit:=AlreadyInit;
      StackNode.InitBlock:=InitBlock;
      StackNode.BlockList:=TList.Create;
      StackNode.BlockList.Assign(BlockList);
      StackNode.ArrowList:=TList.Create;
      StackNode.ArrowList.Assign(ArrowList);
      StackNode.StartBlock:=StartBlok;
      StackNode.Vars:=TList.Create;
      StackNode.Vars.Assign(Vars);

      StackInfo.Clear;
      StackInfo.Add(StackNode);
    end;
  if MakeTakt
  then Takt
  else Exit;
  if Cur=nil then
  begin
    if FTbCur<>nil
    then FTbCur.Color:=ChildForm.ColorBlok;
    flagInWork:=False;
    MainForm.actNew.Enabled:=true;
    MainForm.actOpen.Enabled:=true;
    MainForm.actSave.Enabled:=true;
    MainForm.AutoExec:=false;

    MainForm.btnLineRun.Enabled:=true;
    MainForm.mnuArrow.Enabled:=true;

    SetButtsEnable(true);
    
    mnuStat.Enabled:=true;
    mnuUnfText.Enabled:=true;
    mnuRem.Enabled:=true;
    mnuDelete.Enabled:=true;
    mnuGlob.Enabled:=true;
    mnuInit.Enabled:=true;

    if StackInfo.Count>1
    then begin
           for i:=0 to BlockList.Count-1
           do TBlock(BlockList[i]).Hide;
           BlockList.Assign(TStackNode(StackInfo[1]^).BlockList);
           ArrowList.Assign(TStackNode(StackInfo[1]^).ArrowList);
           Vars.Assign(TStackNode(StackInfo[1]^).Vars);
           StartBlok:=BlockList[BlockList.IndexOf(TStackNode(StackInfo[1]^).StarTBlock)];
           StackInfo.Clear;
           for i:=0 to BlockList.Count-1
           do TBlock(BlockList[i]).Show;
         end;

    Exit;
  end;
  if FTbCur<>nil
  then FTbCur.Color:=ChildForm.ColorBlok;
  FTbCur:=Cur;
  FTbCur.Color:=ChildForm.ColorCurrentBlok;
  MainForm.StatusBar.Panels[1].Text:=FTbCur.RemText;
  Med:=FTbCur.Top + FTbCur.Height div 2;
  if (Med > ChildForm.ClientHeight) or (Med < 0) then
    ChildForm.VertScrollBar.Position:=FTbCur.Top + ChildForm.VertScrollBar.Position;
end;

procedure TChildForm.Takt;
var
  Tb : TBlock;
  Lexs: PLexemes;
  Val: TValue;
  Out, tmp: string;
  tPos: Cardinal;
  i: integer;
  StackNode: PStackNode;
  tmpVars: TVars;
  tmpVarNo: integer;
  VarNo: integer;
  qVar: PVar;
  Lines: TStringList;
  fstr: string;

  function GetNext(Cur: TBlock; Cond: boolean): TBlock;
  var
    i: integer;
     
  begin
    Result:=nil;
    for i:=0 to ChildForm.ArrowList.Count-1
    do if TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Block=Cur
       then if Cur.Block<>stIf
            then Result:=TBlock(TArrow(ChildForm.ArrowList[i]).Blocks[atStart].Block)
            else if Cond
                 then begin
                        if (Cur.Isd) and (TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port=South)
                        then Result:=TBlock(TArrow(ChildForm.ArrowList[i]).Blocks[atStart].Block);
                        if (not Cur.Isd) and (TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port=East)
                        then Result:=TBlock(TArrow(ChildForm.ArrowList[i]).Blocks[atStart].Block);
                      end
                 else begin
                        if (Cur.Isd) and (TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port=East)
                        then Result:=TBlock(TArrow(ChildForm.ArrowList[i]).Blocks[atStart].Block);
                        if (not Cur.Isd) and (TArrow(ChildForm.ArrowList[i]).Blocks[atEnd].Port=West)
                        then Result:=TBlock(TArrow(ChildForm.ArrowList[i]).Blocks[atStart].Block);
                      end;
    if (Result<>nil) and (Result.Block=stConfl)
    then Result:=GetNext(Result, false);
  end;

  procedure OnEnd;
  var
    i: integer;
    
  begin
    if StackInfo.Count=1
    then begin
           AlreadyGlob:=TStackNode(StackInfo[0]^).AlreadyGlob;
           GlobBlock  :=TStackNode(StackInfo[0]^).GlobBlock  ;
           AlreadyInit:=TStackNode(StackInfo[0]^).AlreadyInit;
           InitBlock  :=TStackNode(StackInfo[0]^).InitBlock  ;
           Cur:=nil;
           Exit;
         end;
    Cur:=TStackNode(StackInfo[StackInfo.Count-1]^).ReturnPos;
    for i:=BlockList.Count-1 downto 0
    do TBlock(BlockList[i]).Free;
    BlockList.Assign(TStackNode(StackInfo[StackInfo.Count-1]^).BlockList);

    for i:=ArrowList.Count-1 downto 0
    do TArrow(ArrowList[i]).Free;
    ArrowList.Assign(TStackNode(StackInfo[StackInfo.Count-1]^).ArrowList);

    tmpVars:=TVars.Create;
    tmpVars.Assign(Vars);
    Vars.Assign(TStackNode(StackInfo[StackInfo.Count-1]^).Vars);
    if GlobVars.Count>0
    then for i:=0 to GlobVars.Count-1
         do begin
              tmpVarNo:=GetVarIndex(tmpVars, GlobVars[i]);
              if tmpVarNo<>-1
              then begin
                     VarNo:=GetVarIndex(Vars, GlobVars[i]);
                     if VarNo=-1
                     then begin
                            New(qVar);
                            qVar^.Name:=GlobVars[i];
                            qVar^.Sizes:=TList.Create;
                            qVar^.Arr:=TList.Create;
                            VarNo:=Vars.Add(qVar);
                          end;
                     TVar(Vars[VarNo]^).Value:=TVar(tmpVars[tmpVarNo]^).Value;
                     TVar(Vars[VarNo]^).Sizes.Assign(TVar(tmpVars[tmpVarNo]^).Sizes);
                     TVar(Vars[VarNo]^).Arr.  Assign(TVar(tmpVars[tmpVarNo]^).Arr);
                   end;
            end;
    tmpVars.Free;

    StartBlok:=BlockList[BlockList.IndexOf(TStackNode(StackInfo[StackInfo.Count-1]^).StartBlock)];
    AlreadyGlob:=TStackNode(StackInfo[StackInfo.Count-1]^).AlreadyGlob;
    GlobBlock:=TStackNode(StackInfo[StackInfo.Count-1]^).GlobBlock;
    AlreadyInit:=TStackNode(StackInfo[StackInfo.Count-1]^).AlreadyInit;
    InitBlock:=TStackNode(StackInfo[StackInfo.Count-1]^).InitBlock;
    StackInfo.Delete(StackInfo.Count-1);
    for i:=0 to BlockList.Count-1
    do TBlock(BlockList[i]).Show;
    for i:=0 to ArrowList.Count-1
    do TArrow(ArrowList[i]).Hide:=false;

    Refresh;

//    FTbCur:=StarTBlock;
    FTbCur:=nil;
  end;

begin
  if FTbCur=Nil then begin
   ShowMessage('Не указан первый элемент.');
   Exit;
  end;
  Tb:=FTbCur;
  New(Lexs);

  case Tb.Block of
    stBeginEnd:
      begin
        if Tb.Statement.Count=0
        then fstr:=''
        else fstr:=ANSIUpperCase(Tb.Statement[0]);
        if (fstr='Конец') or (fstr='END') or (GetNext(Tb, false)=nil)
        then begin
               OnEnd;
             end
        else
          if GetNext(Tb, false) <>nil then
            Cur:=GetNext(Tb, false);
      end;

    stInOut:
      begin
        ReadBlock(Tb.Statement, Lexs);
        if Lexs[1]._Type=lxQuestion
        then begin
               Lines:=TStringList.Create;
               Lines.Assign(Tb.Statement);
               tmp:=Lines[0];
               Delete(tmp, System.Pos('?', tmp), 1);
               Lines[0]:=tmp;
               AutoPause;
               Lines[0]:=Lines[0]+' := '+InputBox('Ввод', IfThen(MainForm.StatusBar.Panels[1].Text<>'', MainForm.StatusBar.Panels[1].Text, 'Введите значение: '), '');
               AutoResume;
               ReadBlock(Lines, Lexs);
               if CheckOperator(Lexs)
               then ExecOperator(Lexs, Vars)
               else Cur:=nil;
               Lines.Free;
             end
        else begin
               try
                 Pos:=1;
                 tPos:=Pos;
                 CheckExpr(Lexs);
                 Pos:=tPos;
                 Val:=ExecExpr(Lexs, Vars);
                 case Val._Type of
                   tyReal: Out:=Out+FloatToStr(Val.Real);
                   tyStr : Out:=Out+Val.Str;
                 end;
                 while Lexs^[Pos]._Type=lxComma
                 do begin
                      Inc(Pos);
                      tPos:=Pos;
                      CheckExpr(Lexs);
                      Pos:=tPos;
                      Val:=ExecExpr(Lexs, Vars);
                      case Val._Type of
                        tyReal: Out:=Out+FloatToStr(Val.Real);
                        tyStr : Out:=Out+Val.Str;
                      end;
                    end;
               finally
               end;
               frmOutProg.Memo.Lines.Add(Out);
               frmOutProg.Show;
               frmOutProg.Memo.SelStart:=Length(frmOutProg.Memo.Text);
             end;
        Cur:=GetNext(Tb, false);
      end;

    stStatement:
      begin
        ReadBlock(Tb.Statement, Lexs);
        if CheckOperator(Lexs)
        then ExecOperator(Lexs, Vars)
        else Cur:=nil;
        Cur:=GetNext(Tb, false);
      end;

    stConfl:
      begin
        Cur:=GetNext(tb, false);
      end;

    stCall:
      begin
        if Tb.Statement.Count=0
        then fstr:='НИЧЕГО'
        else fstr:=Tb.Statement[0];
        if FileExists(fstr+'.BSH')
        then begin
               New(StackNode);
               StackNode.ReturnPos:=GetNext(Tb, false);
               StackNode.BlockList:=TList.Create;
               StackNode.BlockList.Assign(BlockList);
               StackNode.ArrowList:=TList.Create;
               StackNode.ArrowList.Assign(ArrowList);
               StackNode.Vars:=TVars.Create;
               StackNode.Vars.Assign(Vars);
               StackNode.StartBlock:=StartBlok;
               StackNode.AlreadyGlob:=AlreadyGlob;
               StackNode.GlobBlock:=GlobBlock;
               StackNode.AlreadyInit:=AlreadyInit;
               StackNode.InitBlock:=InitBlock;
               tmpVars:=TVars.Create;
               tmpVars.Assign(Vars);
               Vars.Clear;
               StackInfo.Add(StackNode);
               Cur:=StartBlok;

               for i:=0 to BlockList.Count-1
               do TBlock(BlockList[i]).Hide;
               BlockList.Clear;

               for i:=0 to ArrowList.Count-1
               do TArrow(ArrowList[i]).Hide:=true;
               ArrowList.Clear;
               Actives.Clear;
               StartBlok:=nil;
               AlreadyGlob:=false;
               AlreadyInit:=false;
               LoadScheme(fstr+'.BSH');
               Refresh;
               if AlreadyGlob
               then begin
                      AddToGlobVars(GlobBlock.GlobStrings);

                      if GlobVars.Count>0
                      then for i:=0 to GlobVars.Count-1
                           do begin
                                tmpVarNo:=GetVarIndex(tmpVars, GlobVars[i]);
                                if tmpVarNo<>-1
                                then begin
                                       VarNo:=GetVarIndex(Vars, GlobVars[i]);
                                       if VarNo=-1
                                       then begin
                                              New(qVar);
                                              qVar^.Name:=GlobVars[i];
                                              qVar^.Sizes:=TList.Create;
                                              qVar^.Arr:=TList.Create;
                                              VarNo:=Vars.Add(qVar);
                                            end;
                                       TVar(Vars[VarNo]^).Value:=TVar(tmpVars[tmpVarNo]^).Value;
                                       TVar(Vars[VarNo]^).Sizes.Assign(TVar(tmpVars[tmpVarNo]^).Sizes);
                                       TVar(Vars[VarNo]^).Arr  .Assign(TVar(tmpVars[tmpVarNo]^).Arr);
                                     end;
                              end;
                    end;
               tmpVars.Free;
               if AlreadyInit
               then begin
                      New(Lexs);
                      ReadBlock(InitBlock.InitCode, Lexs);
                      if CheckOperator(Lexs)
                      then ExecOperator(Lexs, Vars);
                    end;
               SetRange;
               FTbCur.Color:=ChildForm.ColorBlok;
               if StartBlok=nil
               then begin
                      AutoPause;
                      MessageDlg('В вызываемой схеме не указан первый элемент'#10#13'Откройте эту схему, задайте первый элемент и сохраните ее.',
                                        mtError, [mbOK], 0);
                      AutoResume;
                      Cur:=nil;
                    end
               else begin
                      FTbCur:=StartBlok;
                      Cur:=StartBlok;
                    end;
             end
        else begin
               AutoPause;
               MessageDlg('Схема '+fstr+'.bsh не существует.'#10#13'Pабота схемы завершена',
                            mtError, [mbOK], 0);
               AutoResume;
               Cur:=nil;
             end;
      end;

    stIf:
      begin
        ReadBlock(Tb.Statement, Lexs);
        Pos:=1;
        if CheckExpr(Lexs)
        then begin
               Pos:=1;
               Val:=ExecExpr(Lexs, Vars);
               if Val._Type=tyReal
               then if Val.Real=0
                    then Cur:=GetNext(Tb, false)
                    else Cur:=GetNext(Tb, true)
               else RunTimeError('Ожидалось условие, но найдена строка');
             end
        else Cur:=nil;
      end;
  end;

  if (Cur=nil) and (StackInfo.Count<>0)
  then OnEnd;

  Dispose(Lexs);

  frmWatch.VarsRefresh;
end;

procedure TChildForm.NStepClick(Sender: TObject);
begin
  flagNextTakt:=True;
end;

procedure TChildForm.mnuDeleteClick(Sender: TObject);
begin
    MainForm.btnDeleteClick(Sender);
    // Modified by Roman Mitin

//  DeleteBlock(TmpBlok); <- old code by I. Skriblovsky
end;

procedure TChildForm.mnuUnfTextClick(Sender: TObject);
var
  Tb : TBlock;
  UN: PUndoNode;

begin
  Tb:=TmpBlok;

  New(UN);
  UN._:=utTextChange;
  UN.Group:=1;
  UN.Block:=Tb;
  UN.Statement:=Tb.Statement.Text;
  UN.Text:=Tb.UnfText.Text;
  UN.RemStr:=Tb.RemText;

  MainForm.Modifed:=true;
  MemoInput('Поле ввода', 'Введите надпись на блоке', Tb.UnfText);
  if not (Tb.UnfText.Text=UN.Text)
  then MainForm.AddUndo(UN)
  else Dispose(UN);
  Refresh;
end;

procedure TChildForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  DoExit: boolean;

begin
  if ANew.New
  then begin
         if ANew.Tail=atEnd
         then begin
                ANew.Tail:=atStart;
                FirstClick:=Point(x, y);
                Refresh;
                ANew.Arrow.Hide:=false;
                ANew.Arrow.oldTail[atEnd]:=ANew.Arrow.Tail[atEnd];
                ANew.Arrow.Tail[atStart]:=Point(x, y);
                ANew.Arrow.Draw;
                with ANew.Arrow
                do begin
                     ANew.Arrow.Draw;
                     case ANew.Arrow._Type of
                       horiz: p:=Tail[atEnd].y;
                        vert: p:=Tail[atEnd].x;
                     end;
                     ANew.Arrow.Draw;
                   end;
              end;
         Exit;
       end;

  if not (ssShift in Shift)
  then Actives.Clear;

  Mous:=Point(x, y);
  DoExit:=false;
  for i:=0 to ArrowList.Count-1
  do begin
       TArrow(ArrowList[i]).MouseDown(Shift);
       if TArrow(ArrowList[i]).IsDrag
       then begin
              DoExit:=true;
              Break;
            end;  
     end;
  if DoExit
  then Exit;

  Xd:=X;
  Yd:=Y;
  Xc:=X;
  Yc:=Y;
  if not Viewer
  then Bevel.Visible:=true;
  Bevel.Width:=0;
  Bevel.Height:=0;
  if MainForm.WhatDown<>wdNone
  then begin
         CreateBlokFromButts:=true;
         CreateBlokFromButtsPoint:=Point(X, Y);
         case MainForm.WhatDown of
           wdEllipse: begin
                        CreateBlock(stBeginEnd);
                        MainForm.EllipseSB.Down:=false;
                      end;
              wdRect: begin
                        CreateBlock(stStatement);
                        MainForm.RectSB.Down:=false;
                      end;
              wdRomb: begin
                        CreateBlock(stIf);
                        MainForm.RombSB.Down:=false;
                      end;
             wdParal: begin
                        CreateBlock(stInOut);
                        MainForm.ParalSB.Down:=false;
                      end;
              wdCall: begin
                        CreateBlock(stCall);
                        MainForm.CallSB.Down:=false;
                      end;
              wdGlob: begin
                        CreateBlock(stGlob);
                        MainForm.GlobSB.Down:=false;
                      end;
              wdInit: begin
                        CreateBlock(stInit);
                        MainForm.InitSB.Down:=false;
                      end;
           wdComment: begin
                        CreateBlock(stComment);
                        MainForm.CommSB.Down:=false;
                      end;
             wdConfl: begin
                        CreateBlock(stConfl);
                        MainForm.ConflSB.Down:=false;
                      end;
         end;
         DefCursor:=crDefault;
         MainForm.WhatDown:=wdNone;
         CreateBlokFromButts:=false;
       end;
end;

procedure TChildForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: integer;
  
begin
  dMous:=Point(x-Mous.x, y-Mous.y);
  Mous:=Point(x, y);

  if ANew.New
  then begin
         ANew.Arrow.DragObj:=Tail2Obj(ANew.Tail);
         ANew.Arrow.IsDrag:=true;
         ANew.Arrow.Drag(x, y);
         Exit;
       end;

  Cursor:=DefCursor;
  for i:=0 to ArrowList.Count-1
  do begin
       TArrow(ArrowList[i]).MouseTest;
       if TArrow(ArrowList[i]).IsDrag
       then TArrow(ArrowList[i]).Drag(x, y);
     end;

  if Bevel.Visible then
  begin
    Xc:=X;
    Yc:=Y;
    Bevel.Left:=min(Xd, Xc);
    Bevel.Top:=min(Yd, Yc);
    Bevel.Width:=max(Xd, Xc)-Bevel.Left;
    Bevel.Height:=max(Yd, Yc)-Bevel.Top;
  end;

// AboutBox
  with AboutBox
  do begin
       with GoToWeb do begin
             Font.Color:=clPurple;
             Font.Style:=GoToWeb.Font.Style-[fsUnderline];
       end;
     end;
end;

procedure TChildForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  j, i: integer;
  b: TBlock;
  a: TArrow;
  f: boolean;
  t: TArrowTail;
  UN: PUndoNode;

begin
  for i:=0 to ArrowList.Count-1
  do TArrow(ArrowList[i]).DoesNotUnDock:=false;

  if ANew.New
  then begin
         if (Abs(X-FirstClick.X)>5) or
            (Abs(Y-FirstClick.Y)>5)
         then begin
                CreateArrow;
                Exit;
              end;
         Refresh;                        
       end;

  for j:=0 to ArrowList.Count-1
  do if (TArrow(ArrowList[j]).IsDrag) and (TArrow(ArrowList[j]).DragObj in [st, en])
     then begin
            for i:=0 to BlockList.Count-1
            do if TTmpBlock(BlockList[i]).CanIDock(x, y, Obj2Tail(TArrow(ArrowList[j]).DragObj), true)
               then TArrow(ArrowList[j]).Dock(TTmpBlock(BlockList[i]), Obj2Tail(TArrow(ArrowList[j]).DragObj), TTmpBlock(BlockList[i]).GetPort(x, y));
          end;

  for i:=0 to ArrowList.Count-1
  do if TArrow(ArrowList[i]).IsDrag
     then begin
            a:=ArrowList[i];

            New(UN);
            UN._:=utArrowMove;
            UN.Group:=1;
            UN.Arrow:=a;
            UN.pnt:=unOrig[atStart];
            UN.pnt1:=unOrig[atEnd];
            UN.p:=unP;
            UN.ArrowType:=unType;
            UN.ArrowStyle:=unStyle;
            UN.Block:=unBlock[atStart] as TBlock;
            UN.Block1:=unBlock[atEnd] as TBlock;
            UN.port[atStart]:=unPort[atStart];
            UN.port[atEnd]:=unPort[atEnd];
            MainForm.AddUndo(UN);

            a.IsDrag:=false;

            a.DragObj:=none;
          end;
  Refresh;

  if Bevel.Visible then
  begin
    for i:=0 to BlockList.Count-1
    do begin
         b:=TBlock(BlockList[i]);
         if (b.Left>Bevel.Left-B.Width) and (b.Left<Bevel.Left+Bevel.Width) and (b.Top>Bevel.Top-B.Height) and (b.Top<Bevel.Top+Bevel.Height)
         then Actives.SetActive(b);
       end;
    for i:=0 to ArrowList.Count-1
    do begin
         a:=TArrow(ArrowList[i]);
         f:=false;
         for t:=atStart to atEnd
         do if (a.Tail[t].x>Bevel.Left) and (a.Tail[t].x<Bevel.Left+Bevel.Width) and (a.Tail[t].y>Bevel.Top) and (a.Tail[t].y<Bevel.Top+Bevel.Height)
            then f:=true;
         case a._Type of
            vert: if ((a.p>Bevel.Left) and (a.p<Bevel.Left+Bevel.Width) and (a.Tail[atStart].y>Bevel.Top) and (a.Tail[atStart].y<Bevel.Top+Bevel.Height))
                     or ((a.p>Bevel.Left) and (a.p<Bevel.Left+Bevel.Width) and (a.Tail[atEnd].y>Bevel.Top) and (a.Tail[atEnd].y<Bevel.Top+Bevel.Height))
                  then f:=true;
           horiz: if ((a.p>Bevel.Top) and (a.p<Bevel.Top+Bevel.Height) and (a.Tail[atStart].x>Bevel.Left) and (a.Tail[atStart].x<Bevel.Left+Bevel.Width))
                     or ((a.p>Bevel.Top) and (a.p<Bevel.Top+Bevel.Height) and (a.Tail[atEnd].x>Bevel.Left) and (a.Tail[atEnd].x<Bevel.Left+Bevel.Width))
                  then f:=true;
         end;
         if f
         then Actives.SetActive(a);
       end;
    Bevel.Visible:=false;
    Refresh;
  end;

  if ANew.New
  then ANew.Arrow.Draw;

  SetRange;
end;

procedure TChildForm.CreateBlock(Q: SetBlocks);
var
  UN: PUndoNode;

begin
  TmpBlok:=TBlock.Create(ChildForm);
  TmpBlok.Parent:=ChildForm;
  TmpBlok.Block:=Q;
  if Q=stGlob
  then begin
         GlobBlock:=TmpBlok;
         AlreadyGlob:=true;
       end;
  if Q=stInit
  then begin
         InitBlock:=TmpBlok;
         AlreadyInit:=true;
       end;
  SetParamBlok(TmpBlok);
  pTmp:=TmpBlok;
  BlockList.Add(ChildForm.pTmp);
  if CreateBlokFromButts
  then if Q<>stConfl
       then begin
              TmpBlok.Left:=CreateBlokFromButtsPoint.x-TmpBlok.Width  div 2;
              TmpBlok.Top :=CreateBlokFromButtsPoint.y-TmpBlok.Height div 2;
            end
       else begin
              TmpBlok.Left:=CreateBlokFromButtsPoint.x-ConflRadius div 2;
              TmpBlok.Top :=CreateBlokFromButtsPoint.y-ConflRadius div 2;
            end;

  New(UN);
  UN^._:=utNewBlock;
  UN^.Group:=1;
  UN^.Block:=TmpBlok;
  MainForm.AddUndo(UN);

  SetRange;

  TmpBlok.Paint;
end;

procedure TChildForm.SetRange;
var
  xi, xa, yi, ya: integer;
  i: integer;
  b: TBlock;
  a: TArrow;
  t: TArrowTail;
  vp, hp: integer;

begin
  if BlockList.Count=0
  then Exit;
  xi:=TBlock(BlockList[0]).Left;
  xa:=TBlock(BlockList[0]).Left+TBlock(BlockList[0]).Width;
  yi:=TBlock(BlockList[0]).Top;
  ya:=TBlock(BlockList[0]).Top+TBlock(BlockList[0]).Height;
  for i:=1 to BlockList.Count-1
  do begin
       b:=BlockList[i];
       if b.Left<xi
       then xi:=b.Left;
       if b.Left+b.Width>xa
       then xa:=b.Left+b.Width;
       if b.Top<yi
       then yi:=b.Top;
       if b.Top+b.Height>ya
       then ya:=b.Top+b.Height;
     end;
  for i:=0 to ArrowList.Count-1
  do begin
       a:=ArrowList[i];
       for t:=atStart to atEnd
       do begin
            xi:=min(xi, a.Tail[t].x);
            xa:=max(xa, a.Tail[t].x);
            yi:=min(yi, a.Tail[t].y);
            ya:=max(ya, a.Tail[t].y);
          end;
       case a._Type of
          vert: begin
                  xi:=min(xi, a.p);
                  xa:=max(xa, a.p);
                end;
         horiz: begin
                  yi:=min(yi, a.p);
                  ya:=max(ya, a.p);
                end;
       end;
     end;

  VertScrollBar.Range:=max(VertScrollBar.Range, ClientHeight);
  HorzScrollBar.Range:=max(HorzScrollBar.Range, ClientWidth);

  xi:=xi-150;
  xa:=xa+150;
  yi:=yi-150;
  ya:=ya+150;

  vp:=VertScrollBar.Position;
  hp:=HorzScrollBar.Position;

  xi:=xi+hp;
  xa:=xa+hp;
  yi:=yi+vp;
  ya:=ya+vp;

  xi:=min(xi, HorzScrollBar.Position);
  xa:=max(xa, ClientWidth+HorzScrollBar.Position);
  yi:=min(yi, VertScrollBar.Position);
  ya:=max(ya, ClientHeight+VertScrollBar.Position);


  VertScrollBar.Range:=ya-yi;
  HorzScrollBar.Range:=xa-xi;
  VertScrollBar.Position:=vp-yi;
  HorzScrollBar.Position:=hp-xi;

  for i:=0 to BlockList.Count-1
  do begin
       b:=BlockList[i];
       b.Left:=b.Left-xi;
       b.Top:=b.Top-yi;
     end;


{  for i:=0 to ArrowList.Count-1
  do begin
       a:=ArrowList[i];
       for t:=atStart to atEnd
       do a.Tail[t]:=Point(a.Tail[t].x-xi, a.Tail[t].Y-yi);
       case a._Type of
          vert: a.p:=a.p-xi;
         horiz: a.p:=a.p-yi;
       end;
     end;}
  for i:=0 to ArrowList.Count-1
  do begin
       a:=ArrowList[i];
       for t:=atStart to atEnd
       do a.FTail[t]:=Point(a.FTail[t].x-xi, a.FTail[t].Y-yi);
       case a._Type of
          vert: a.Fp:=a.Fp-xi;
         horiz: a.Fp:=a.Fp-yi;
       end;
     end;


  refresh;

end;

procedure TChildForm.FormDestroy(Sender: TObject);
var
  pv: PVar;
  pvl: PValue;
  pi: PInteger;
  i, j: integer;

  pfr: PFile_Rec;

begin
  UndoStack.Free;
  StackInfo.Free;
  for i:=Vars.Count-1 downto 0
  do begin
       pv:=Vars[i];
       for j:=pv.Sizes.Count-1 downto 0
       do begin
            pi:=pv.Sizes[j];
            Dispose(pi);
          end;
       for j:=pv.Arr.Count-1 downto 0
       do begin
            pvl:=pv.Arr[j];
            Dispose(pvl);
          end;
       Dispose(pv);
     end;
  Vars.Free;
  ArrowList.Free;
  BlockList.Free;

  for i:=Files.Count-1 downto 0
  do begin
       pfr:=Files[i];
       pfr.Strings.Free;
       Dispose(pfr);
     end;
  Files.Free;
end;
             
procedure TChildForm.BlockMenuPopup(Sender: TObject);
var
  b: boolean;
  i: integer;
  t: TArrowTail;
  Arrows: array [TArrowTail] of boolean;

begin
  if not FlagInWork
  then begin
         b:=not ((TmpBlok.Block=stGlob) or (TmpBlok.Block=stInit));
         mnuStat.Enabled:=b;
         mnuUnfText.Enabled:=b;
         mnuRem.Enabled:=b;
       end;
  mnuGlob.Visible:=TmpBlok.Block=stGlob;
  mnuInit.Visible:=TmpBlok.Block=stInit;
  mnuStat.Visible:=TmpBlok.Block<>stComment;
  mnuReplace.Visible:=(not Viewer) and (not FlagInWork) and (TmpBlok.Block in [stStatement, stInOut, stCall]);
  if not Viewer
  then mnuRem.Visible:=TmpBlok.Block<>stComment;

  FillChar(Arrows, SizeOf(Arrows), false);
  for i:=0 to ArrowList.Count-1
  do for t:=atStart to atEnd
     do if TArrow(ArrowList[i]).Blocks[t].Block=TmpBlok
        then Arrows[t]:=true;

  mnuRepNothing.Visible:=Arrows[atStart] and Arrows[atEnd];
end;

procedure TChildForm.mnuGlobClick(Sender: TObject);
begin
  MemoInput('Введите значение', 'Введите список глобальных переменных', GlobBlock.GlobStrings);
  GlobBlock.Paint;
end;

procedure TChildForm.mnuInitClick(Sender: TObject);
begin
  MemoInput('Введите значение', 'Введите иницилизационный код', InitBlock.InitCode);
  InitBlock.Paint;
end;

procedure TChildForm.FormPaint(Sender: TObject);
var
  i: integer;
  
begin
  ChildForm.Canvas.Pen.Style:=psSolid;
  ChildForm.Canvas.Pen.Color:=clBlack;
  for i:=0 to ArrowList.Count-1
  do if not TArrow(ArrowList[i]).Hide
     then TArrow(ArrowList[i]).Draw;
end;

procedure TChildForm.BevelPaint(Sender: TObject);
begin
  Bevel.SendToBack;
  Bevel.Canvas.Pen.Color:=clGray;
  Bevel.Canvas.Pen.Style:=psDot;
  Bevel.Canvas.MoveTo(0, 0);
  Bevel.Canvas.LineTo(Bevel.Width-1, 0);
  Bevel.Canvas.LineTo(Bevel.Width-1, Bevel.Height-1);
  Bevel.Canvas.LineTo(0, Bevel.Height-1);
  Bevel.Canvas.LineTo(0, 0);
end;

procedure TChildForm.DeleteBlock;
var
  i: integer;
  t: TArrowTail;
  UN: PUndoNode;
  a: TArrow;
  counter: integer;

begin
  if B.Block=stGlob
  then AlreadyGlob:=false;

  if B.Block=stInit
  then AlreadyInit:=false;

  counter:=0;
  for i:=0 to ArrowList.Count-1
  do for t:=atStart to atEnd
     do if TArrow(ArrowList[i]).Blocks[t].Block=B
        then begin
               if MakeUndo
               then begin
                      a:=ArrowList[i];
                      New(UN);
                      UN^.Group:=1;
                      UN^._:=utArrowMove;
                      UN^.Arrow:=a;
                      UN^.p:=a.p;
                      UN^.ArrowType:=a._Type;
                      UN^.ArrowStyle:=a.Style;
                      UN^.pnt:=a.Tail[atStart];
                      UN^.pnt1:=a.Tail[atEnd];
                      UN^.Block:=TBlock(a.Blocks[atStart].Block);
                      UN^.Block1:=TBlock(a.Blocks[atEnd].Block);
                      UN^.port[atStart]:=a.Blocks[atStart].Port;
                      UN^.port[atEnd]:=a.Blocks[atEnd].Port;
                      MainForm.AddUndo(UN);
                      Inc(counter);
                    end;
               TArrow(ArrowList[i]).UnDock(t);
             end;

  MainForm.Modifed:=true;
  BlockList.Remove(B);

//  B.Free;
  B.Hide;
  if MakeUndo
  then begin
         New(UN);
         UN^.Group:=counter+1;
         UN^._:=utDelBlock;
         UN^.Block:=B;
         UN^.WasStartBlock:=(StartBlok=B);
         MainForm.AddUndo(UN);
       end;

  if StartBlok=B
  then StartBlok:=nil;
end;

procedure TChildForm.DeleteArrow;
var
  UN: PUNdoNode;

begin
  MainForm.Modifed:=true;
  ArrowList.Remove(A);

//  A.Free;
  A.Hide:=true;
  if MakeUndo
  then begin
         New(UN);
         UN^.Group:=1;
         UN^._:=utDelArrow;
         UN^.Arrow:=A;
         MainForm.AddUndo(UN);
       end;
end;

procedure TChildForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  WriteIniFile;
end;

procedure ToolCreate(var b: TBlock; Block: SetBlocks);
begin
  b:=TBlock.Create(ChildForm);
  b.Parent:=ChildForm;
  b.Block:=Block;
  ChildForm.SetParamBlok(b);
  b.WriteText;
//  ChildForm.BlockList.Add(b);
end;

function TChildForm.MakeReplace(b1, b2: TBlock; t: TArrowTail; ChangePort: boolean=false; Port: TBlockPort=North): TArrow;
var
  i: integer;

begin
  Result:=nil;
  for i:=0 to ArrowList.Count-1
  do if TArrow(ArrowList[i]).Blocks[t].Block=b1
     then begin
            TArrow(ArrowList[i]).Blocks[t].Block:=b2;
            if ChangePort
            then TArrow(ArrowList[i]).Blocks[t].Port:=Port;
            TArrow(ArrowList[i]).StandWell;
            Result:=ArrowList[i];
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

procedure TChildForm.MoveAllDown(b1: TTmpBlock; h: integer);
var
  i: integer;
  b: TBlock;
  a: TArrow; j: TArrowTail;

begin
  for i:=0 to BlockList.Count-1
  do begin
       b:=BlockList[i];
       if (b.top>b1.Top)
       then b.Top:=b.Top+h;
     end;

  for i := 0 to ArrowList.Count - 1
  do begin
       a := ArrowList[i];
       for j := atStart to atEnd
       do if a.Tail[j].Y > b1.Top then a.Tail[j] := Point(a.Tail[j].X, a.Tail[j].Y + h);
       case a._Type of
         horiz: if a.p > b1.Top then a.p := a.p + h;
       end;
     end;
end;

procedure TChildForm.MoveAllLeftRight(b1: TTmpBlock; l, r: integer);
var i, c, c1: integer; j: TArrowTail;
  b: TBlock;
  a: TArrow;
begin
  c1 := b1.Left + b1.Width div 2;
  for i := 0 to BlockList.Count - 1
  do begin
       b := BlockList[i];
       c := b.Left + b.Width div 2;
       if c < c1
       then b.Left := b.Left - l;
       if c > c1
       then b.Left := b.Left + r;
     end;
  for i := 0 to ArrowList.Count - 1
  do begin
       a := ArrowList[i];
       for j := atStart to atEnd
       do begin
            if a.Tail[j].X < c1
            then a.Tail[j] := Point(a.Tail[j].X - l, a.Tail[j].Y);
            if a.Tail[j].X > c1
            then a.Tail[j] := Point(a.Tail[j].X + r, a.Tail[j].Y);
          end;
       case a._Type of
         vert: if a.p < c1 then a.p := a.p - l else a.p := a.p + r;
       end;
     end;
end;

procedure TChildForm.mnuSequenceClick(Sender: TObject);
var
  b, b1: TBlock;
  a: TArrow;

const Ind=30;

begin
  ToolCreate(b, TmpBlok.Block);
  b.Left:=TmpBlok.Left+TmpBlok.Width div 2 - b.Width div 2;
  b.Top:=TmpBlok.Top;

  ToolCreate(b1, TmpBlok.Block);
  b1.Left:=TmpBlok.Left+TmpBlok.Width div 2 - b1.Width div 2;
  b1.Top:=b.Top+b.Height+Ind;

  MoveAllDown(TmpBlok, b1.Top-b.Top);

  BlockList.Add(b);
  BlockList.Add(b1);

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=b;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=b1;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=horiz;
  a.StandWell;
  a.p:=a.Tail[atEnd].x;
  a.StandWell;

  MakeReplace(TmpBlok, b, atStart);
  MakeReplace(TmpBlok, b1, atEnd);

  DeleteBlock(TmpBlok, false);


  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuIfFullClick(Sender: TObject);
var
  if1, s1, s2, c: TBlock;
  a: TArrow;

const Ind=30;

begin
  ToolCreate(if1, stIf);
  if1.Left:=TmpBlok.Left+TmpBlok.Width div 2 - if1.Width div 2;
  if1.Top:=TmpBlok.Top;
  ToolCreate(s1, stStatement);
  s1.Left:=if1.Left-s1.Width;
  s1.Top:=if1.Top+if1.Height+Ind;
  ToolCreate(s2, stStatement);
  s2.Left:=if1.Left+s2.Width;
  s2.Top:=if1.Top+if1.Height+Ind;
  ToolCreate(c, stConfl);
  c.Left:=if1.Left+if1.Width div 2 - c.Width div 2;
  c.Top:=s1.Top+s1.Height+Ind;

  MoveAllDown(TmpBlok, c.top-if1.top);//c.Top-if1.Top-s1.Height+c.Height);
  MoveAllLeftRight(TmpBlok, TmpBlok.Left - s1.Left,
                            s2.Left + s2.Width - TmpBlok.Left - TmpBlok.Width);

  BlockList.Add(if1);
  BlockList.Add(s1);
  BlockList.Add(s2);
  BlockList.Add(c);

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=if1;
  a.Blocks[atEnd].Port:=West;
  a.Blocks[atStart].Block:=s1;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=if1;
  a.Blocks[atEnd].Port:=East;
  a.Blocks[atStart].Block:=s2;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=s1;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=c;
  a.Blocks[atStart].Port:=West;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=s2;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=c;
  a.Blocks[atStart].Port:=East;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  MakeReplace(TmpBlok, if1, atStart);
  MakeReplace(TmpBlok, c, atEnd);

  DeleteBlock(TmpBlok, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuIfNFullClick(Sender: TObject);
var
  if1, s2, c: TBlock;
  a: TArrow;

const Ind=30;

begin
  ToolCreate(if1, stIf);
  if1.Left:=TmpBlok.Left+TmpBlok.Width div 2 - if1.Width div 2;
  if1.Top:=TmpBlok.Top;
  ToolCreate(s2, stStatement);
  s2.Left:=if1.Left+s2.Width;
  s2.Top:=if1.Top+if1.Height+Ind;
  ToolCreate(c, stConfl);
  c.Left:=if1.Left+if1.Width div 2 - c.Width div 2;
  c.Top:=s2.Top+s2.Height+Ind;

  MoveAllDown(TmpBlok, c.Top-if1.Top-s2.Height+c.Height);
  MoveAllLeftRight(TmpBlok, l, s2.Left + s2.Width - TmpBlok.Left - TmpBlok.Width);

  BlockList.Add(if1);
  BlockList.Add(s2);
  BlockList.Add(c);

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=if1;
  a.Blocks[atEnd].Port:=West;
  a.Blocks[atStart].Block:=c;
  a.Blocks[atStart].Port:=West;
  a._Type:=vert;
  a.p:=if1.Left-Ind;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=if1;
  a.Blocks[atEnd].Port:=East;
  a.Blocks[atStart].Block:=s2;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=s2;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=c;
  a.Blocks[atStart].Port:=East;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  MakeReplace(TmpBlok, if1, atStart);
  MakeReplace(TmpBlok, c, atEnd);

  DeleteBlock(TmpBlok, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuLoopPredClick(Sender: TObject);
var
  f, s, c, c1: TBlock;
  a: TArrow;

const Ind=30;

begin
  ToolCreate(c, stConfl);
  c.Left:=TmpBlok.Left+TmpBlok.Width div 2 - c.Width div 2;
  c.Top:=TmpBlok.Top;
  ToolCreate(f, stIf);
  f.Left:=TmpBlok.Left+TmpBlok.Width div 2 - f.Width div 2;
  f.Top:=c.Top+c.Height+Ind;
  ToolCreate(s, stStatement);
  s.Left:=TmpBlok.Left+TmpBlok.Width div 2 - s.Width div 2;
  s.Top:=f.Top+f.Height+Ind;
  ToolCreate(c1, stConfl);
  c1.Left:=TmpBlok.Left+TmpBlok.Width div 2 - c1.Width div 2;
  c1.Top:=s.Top+s.Height+Ind;

  MoveAllDown(TmpBlok, c1.Top-c.Top-s.Height+c1.Height);
  MoveAllLeftRight(TmpBlok, Ind, Ind);

  BlockList.Add(f);
  BlockList.Add(s);
  BlockList.Add(c);
  BlockList.Add(c1);

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=c;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=f;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=f;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=s;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=s;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=c;
  a.Blocks[atStart].Port:=West;
  a._Type:=vert;
  a.p:=f.Left-Ind;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=f;
  a.Blocks[atEnd].Port:=East;
  a.Blocks[atStart].Block:=c1;
  a.Blocks[atStart].Port:=East;
  a._Type:=vert;
  a.p:=f.Left+f.Width+Ind;
  a.StandWell;

  MakeReplace(TmpBlok, c, atStart);
  MakeReplace(TmpBlok, c1, atEnd);

  DeleteBlock(TmpBlok, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuLoopPostClick(Sender: TObject);
var
  f, s, c, c1: TBlock;
  a: TArrow;

const Ind=30;

begin
  ToolCreate(c, stConfl);
  c.Left:=TmpBlok.Left+TmpBlok.Width div 2 - c.Width div 2;
  c.Top:=TmpBlok.Top;
  ToolCreate(s, stStatement);
  s.Left:=TmpBlok.Left+TmpBlok.Width div 2 - s.Width div 2;
  s.Top:=c.Top+c.Height+Ind;
  ToolCreate(f, stIf);
  f.Left:=TmpBlok.Left+TmpBlok.Width div 2 - f.Width div 2;
  f.Top:=s.Top+s.Height+Ind;
  ToolCreate(c1, stConfl);
  c1.Left:=TmpBlok.Left+TmpBlok.Width div 2 - c1.Width div 2;
  c1.Top:=f.Top+f.Height+Ind;

  MoveAllDown(TmpBlok, c1.Top-c.Top-s.Height+c1.Height);
  MoveAllLeftRight(TmpBlok, Ind, Ind);

  BlockList.Add(f);
  BlockList.Add(s);
  BlockList.Add(c);
  BlockList.Add(c1);

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=c;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=s;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=s;
  a.Blocks[atEnd].Port:=South;
  a.Blocks[atStart].Block:=f;
  a.Blocks[atStart].Port:=North;
  a.Style:=eg2;
  a._Type:=vert;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=f;
  a.Blocks[atEnd].Port:=West;
  a.Blocks[atStart].Block:=c;
  a.Blocks[atStart].Port:=West;
  a._Type:=vert;
  a.p:=f.Left-Ind;
  a.StandWell;

  a:=TArrow.Create;
  ArrowList.Add(a);
  a.Blocks[atEnd].Block:=f;
  a.Blocks[atEnd].Port:=East;
  a.Blocks[atStart].Block:=c1;
  a.Blocks[atStart].Port:=East;
  a._Type:=vert;
  a.p:=f.Left+f.Width+Ind;
  a.StandWell;

  MakeReplace(TmpBlok, c, atStart);
  MakeReplace(TmpBlok, c1, atEnd);

  DeleteBlock(TmpBlok, false);

  AllArrowsStandWell;

  SetRange;
  Refresh;
end;

procedure TChildForm.mnuRepStatClick(Sender: TObject);
begin
  TmpBlok.Block:=stStatement;
  MainForm.Modifed:=true;
  TmpBlok.Refresh;
end;

procedure TChildForm.mnuRepIOClick(Sender: TObject);
begin
  TmpBlok.Block:=stInOut;
  MainForm.Modifed:=true;
  TmpBlok.Refresh;
end;

procedure TChildForm.mnuRepCallClick(Sender: TObject);
begin
  TmpBlok.Block:=stCall;                  
  MainForm.Modifed:=true;
  TmpBlok.Refresh;
end;

procedure TChildForm.mnuRepNothingClick(Sender: TObject);
var
  Arrows: array [TArrowTail] of TArrow;
  t: TArrowTail;
  i: integer;

begin
  for i:=0 to ArrowList.Count-1
  do for t:=atStart to atEnd
     do if TArrow(ArrowList[i]).Blocks[t].Block=TmpBlok
        then Arrows[t]:=ArrowList[i];
  Arrows[atStart].Style:=eg4;
  Arrows[atStart].StandWell;
  Arrows[atStart].Blocks[atStart]:=Arrows[atEnd].Blocks[atStart];
  Arrows[atStart].StandWell;
  Arrows[atStart].Tail[atStart]:=Arrows[atEnd].Tail[atStart];
  Arrows[atStart].StandWell;
  DeleteArrow(Arrows[atEnd], false);
  DeleteBlock(TmpBlok, false);
  Refresh;
end;

procedure TChildForm.mnuRepEndClick(Sender: TObject);
var
  i: integer;
  a: TArrow;

begin
  TmpBlok.Block:=stBeginEnd;
  for i:=0 to ArrowList.Count-1
  do begin
       a:=ArrowList[i];
       if (a.Blocks[atEnd].Block = TmpBlok)
       then begin
              a.Blocks[atEnd].Block := nil;
              a.StandWell;
              Refresh;
            end;  
     end;
  MainForm.Modifed:=true;
  TmpBlok.Refresh;
end;


end.

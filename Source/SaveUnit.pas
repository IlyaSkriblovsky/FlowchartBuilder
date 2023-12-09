unit SaveUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, EdTypes, Arrows;

procedure SaveScheme(FileName: string);

procedure WriteEmpty(FileName: string);

var
  Saving: boolean = false;

implementation

uses Main, Child;

var
  F: TextFile;

procedure SaveScheme(FileName: string);
var
  i: integer;
  vp, hp: integer;

  procedure SaveBlock(B: TBlock);
  begin
    WriteLn(F, 'BLOCK ', B.Tag);
    WriteLn(F, B.Left);
    WriteLn(F, B.Top);
    WriteLn(F, B.Width);
    WriteLn(F, B.Height);
    case B.Block of
      stBeginEnd:
        WriteLn(F, 'ELLIPSE');
      stStatement:
        WriteLn(F, 'RECT');
      stIf:
        WriteLn(F, 'ROMB');
      stInOut:
        WriteLn(F, 'PARAL');
      stCall:
        WriteLn(F, 'CALL');
      stGlob:
        WriteLn(F, 'GLOB');
      stInit:
        WriteLn(F, 'INIT');
      stComment:
        WriteLn(F, 'COMMENT');
      stConfl:
        WriteLn(F, 'CONFLUENCE');
    end;
    WriteLn(F, '  STATEMENT');
    Write(F, B.Statement.Text);
    WriteLn(F, '  /STATEMENT');
    WriteLn(F, '  UNFORMAL');
    Write(F, B.UnfText.Text);
    WriteLn(F, '  /UNFORMAL');
    WriteLn(F, B.RemText);
    WriteLn(F, '/BLOCK');
  end;

  procedure SaveArrow(A: TArrow);
  var
    t: TArrowTail;

  begin
    WriteLn(F, 'ARROW');
    case A._Type of
      vert:
        WriteLn(F, 'VERT');
      horiz:
        WriteLn(F, 'HORIZ');
    end;
    A.StandWell;
    for t := atStart to atEnd do
    begin
      WriteLn(F, A.Tail[t].x);
      WriteLn(F, A.Tail[t].y);
    end;
    WriteLn(F, A.p);
    for t := atStart to atEnd do
      if A.Blocks[t].Block <> nil then
      begin
        case A.Blocks[t].Port of
          North:
            WriteLn(F, 'NORTH');
          East:
            WriteLn(F, 'EAST');
          West:
            WriteLn(F, 'WEST');
          South:
            WriteLn(F, 'SOUTH');
        end;
        WriteLn(F, A.Blocks[t].Block.Tag);
      end
      else
        WriteLn(F, 'NIL');
    WriteLn(F, '/ARROW');
  end;

begin
  vp := ChildForm.VertScrollBar.Position;
  hp := ChildForm.HorzScrollBar.Position;
  ChildForm.VertScrollBar.Position := 0;
  ChildForm.HorzScrollBar.Position := 0;
  try
    AssignFile(F, FileName);
    Rewrite(F);
    WriteLn(F, '#FORMAT 0.1temp');
    if AlreadyInit then
    begin
      WriteLn(F, 'INIT');
      for i := 0 to InitBlock.InitCode.Count - 1 do
        WriteLn(F, InitBlock.InitCode[i]);
      WriteLn(F, '/INIT');
    end
    else
      WriteLn(F, 'NIL');
    if AlreadyGlob then
    begin
      WriteLn(F, 'GLOB');
      for i := 0 to GlobBlock.GlobStrings.Count - 1 do
        WriteLn(F, GlobBlock.GlobStrings[i]);
      WriteLn(F, '/GLOB');
    end
    else
      WriteLn(F, 'NIL');

    for i := 0 to ChildForm.BlockList.Count - 1 do
      TBlock(ChildForm.BlockList[i]).Tag := i;
    if ChildForm.StartBlok <> nil then
      WriteLn(F, ChildForm.StartBlok.Tag)
    else
      WriteLn(F, -1);
    for i := 0 to ChildForm.BlockList.Count - 1 do
      SaveBlock(TBlock(ChildForm.BlockList[i]));
    for i := 0 to ChildForm.ArrowList.Count - 1 do
      SaveArrow(TArrow(ChildForm.ArrowList[i]));
  except
    else
      MessageBox(0, 'Ошибка при сохранении схемы', 'Конструктор Блок-Схем', MB_ICONERROR or MB_OK);
    end;
    CloseFile(F);
    ChildForm.VertScrollBar.Position := vp;
    ChildForm.HorzScrollBar.Position := hp;
  end;

  procedure WriteEmpty(FileName: string);
  begin
    AssignFile(F, FileName);
    Rewrite(F);
    WriteLn(F, '#FORMAT 0.1temp');
    WriteLn(F, 'NIL');
    WriteLn(F, 'NIL');
    WriteLn(F, '-1');
    CloseFile(F);
  end;

end.

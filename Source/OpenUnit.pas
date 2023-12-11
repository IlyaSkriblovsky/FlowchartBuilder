unit OpenUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

var
  OpenFileBlok: string;
  tmp: integer;
  GlobLines: TStringList;
  InitLines: TStringList;

procedure LoadScheme(FileName: string);

implementation

uses Main, Child, EdTypes, Arrows;

var
  F: TextFile;
  A: TArrow;
  B: TBlock;
  OBC: integer; // Original Block Count

function DoRead: string;
var
  q: string;

begin
  ReadLn(F, q);
  if q <> #26 then
    Result := q
  else
    raise EReadError.Create('Неожиданный конец файла');
end;

procedure LoadScheme(FileName: string);
var
  str: string;
  Init, Glob: TStringList;
  start: integer;

  procedure LoadBlock;
  var
    x, y, w: integer;

  begin
    B := TBlock.Create(ChildForm);
    B.Parent := ChildForm;
    ChildForm.BlockList.Add(B);
    B.Parent := ChildForm;
    B.PopupMenu := ChildForm.BlockMenu;
    B.Color := ChildForm.ColorBlok;
    B.Font.Color := ChildForm.ColorFontBlok;
    B.OnMouseDown := ChildForm.PaintBoxMouseDown;
    B.OnMouseMove := ChildForm.PaintBoxMouseMove;
    B.OnMouseUp := ChildForm.PaintBoxMouseUp;
    B.Show;

    str := DoRead;
    x := StrToInt(str);
    str := DoRead;
    y := StrToInt(str);
    str := DoRead;
    B.Width := StrToInt(str);
    str := DoRead;
    B.Height := StrToInt(str);
    str := DoRead;
    if str = 'ELLIPSE' then
      B.Block := stBeginEnd;
    if str = 'RECT' then
      B.Block := stStatement;
    if str = 'ROMB' then
      B.Block := stIf;
    if str = 'PARAL' then
      B.Block := stInOut;
    if str = 'CALL' then
      B.Block := stCall;
    if str = 'COMMENT' then
      B.Block := stComment;
    if str = 'CONFLUENCE' then
      B.Block := stConfl;
    if str = 'INIT' then
    begin
      B.Block := stInit;
      InitBlock := B;
      AlreadyInit := true;
      B.InitCode.Assign(Init);
    end;
    if str = 'GLOB' then
    begin
      B.Block := stGlob;
      GlobBlock := B;
      AlreadyGlob := true;
      B.GlobStrings.Assign(Glob);
    end;
    str := DoRead;
    str := DoRead;
    while str <> '  /STATEMENT' do
    begin
      B.Statement.Add(str);
      str := DoRead;
    end;
    str := DoRead;

    str := DoRead;
    while str <> '  /UNFORMAL' do
    begin
      B.UnfText.Add(str);
      str := DoRead;
    end;

    // Order matters here
    w := B.Width; // Ugly hack. Added to handle additional InOut block width added in 3.4
    ChildForm.SetParamBlok(B);
    B.Paint;
    B.WriteText;
    B.Left := x;
    B.Top := y;
    B.Width := w;

    B.RemText := DoRead;

    str := DoRead;
    str := DoRead;
  end;

  procedure LoadArrow;
  var
    t: TArrowTail;
    str1: string;
    p: integer;

  begin
    A := TArrow.Create;
    ChildForm.ArrowList.Add(A);
    str := DoRead;
    if str = 'VERT' then
      A._Type := vert;
    if str = 'HORIZ' then
      A._Type := horiz;
    for t := atStart to atEnd do
    begin
      str := DoRead;
      str1 := DoRead;
      A.Tail[t] := Point(StrToInt(str), StrToInt(str1));
    end;
    str := DoRead;
    // A.p:=StrToInt(str);
    p := StrToInt(str);
    for t := atStart to atEnd do
    begin
      str := DoRead;
      if str <> 'NIL' then
      begin
        if str = 'NORTH' then
          A.Blocks[t].Port := North;
        if str = 'EAST' then
          A.Blocks[t].Port := East;
        if str = 'WEST' then
          A.Blocks[t].Port := West;
        if str = 'SOUTH' then
          A.Blocks[t].Port := South;
        str := DoRead;
        A.Blocks[t].Block := ChildForm.BlockList[StrToInt(str) + OBC];
      end;
      { str:=DoRead; }
    end;
    A.p := p;
    A.StandWell;
    DoRead;
    str := DoRead;
  end;

begin
  try
    ChildForm.VertScrollBar.Position := 0;
    ChildForm.HorzScrollBar.Position := 0;
    OBC := ChildForm.BlockList.Count;
    AssignFile(F, FileName);
    Reset(F);
    str := DoRead;
    if str <> '#FORMAT 0.1temp' then
    begin
      MessageBox(0, 'Эта версия открывает только файлы формата 0.1temp', 'Ошибка', MB_ICONERROR or MB_OK);
      Exit;
    end;
    str := DoRead;
    Init := TStringList.Create;
    Glob := TStringList.Create;
    if str <> 'NIL' then
      while str <> '/INIT' do
      begin
        str := DoRead;
        if str <> '/INIT' then
          Init.Add(str);
      end;
    str := DoRead;
    if str <> 'NIL' then
      while str <> '/GLOB' do
      begin
        str := DoRead;
        if str <> '/GLOB' then
          Glob.Add(str);
      end;
    str := DoRead;
    start := StrToInt(str);
    str := DoRead;

    while Copy(str, 1, 5) = 'BLOCK' do
      LoadBlock;
    Init.Free;
    Glob.Free;
    while Copy(str, 1, 5) = 'ARROW' do
      LoadArrow;

    if start <> -1 then
      ChildForm.StartBlok := ChildForm.BlockList[start];
  except
    else
      MessageBox(0, 'Ошибка при открытии схемы', 'Конструктор Блок-Схем', MB_ICONERROR or MB_OK);
    end;
    CloseFile(F);
  end;

end.

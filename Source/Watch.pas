unit Watch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Lang, Buttons, ExtCtrls, ComCtrls;

type
  TfrmWatch = class(TForm)
    Panel1: TPanel;
    btnAdd: TSpeedButton;
    List: TListView;
    btnDelete: TSpeedButton;
    btnChange: TSpeedButton;
    btnAll: TSpeedButton;
    procedure AddVarClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure ListEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure btnAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetValInWatch(index: integer; r: TValue);
    procedure SetArrInWatch(index: integer; r: TVar);

    procedure VarsRefresh;
    procedure AddAllVars;
  end;

var
  frmWatch: TfrmWatch;

implementation

uses Child, Main;
{$R *.DFM}

procedure TfrmWatch.VarsRefresh;
var
  Lexs: PLexemes;
  i: integer;
  Lines: TStringList;
  Val: TValue;
  tmp: string;
  varIndex: integer;

begin
  if btnAll.Down then
    AddAllVars;

  New(Lexs);
  Lines := TStringList.Create;

  for i := 0 to List.Items.Count - 1 do
  begin
    varIndex := GetVarIndex(ChildForm.Vars, List.Items[i].Caption);
    if (varIndex > -1) and (ChildForm.Vars.Items[varIndex].Sizes.Count > 0) then
      SetArrInWatch(i, ChildForm.Vars[varIndex]^)
    else
    begin
      try
        Lines.Clear;
        Lines.Add(List.Items[i].Caption);
        ReadBlock(Lines, Lexs);
        Pos := 1;
        if CheckExpr(Lexs) then
        begin
          Pos := 1;
          Val := ExecExpr(Lexs, ChildForm.Vars);
          SetValInWatch(i, Val);
        end;
      except
        on E: ECheckError do
          List.Items[i].SubItems[0] := E.Message;
        on E: ERunTimeError do
        begin
          tmp := E.Message;
          Delete(tmp, System.Pos(#10#13, tmp), 2);
          List.Items[i].SubItems[0] := tmp;
        end;
      end;
    end;
  end;

  Lines.Free;
  Dispose(Lexs);
end;

procedure TfrmWatch.AddVarClick(Sender: TObject);
var
  NewNode: TListItem;

begin
  NewNode := List.Items.Add;
  NewNode.Caption := '';
  NewNode.SubItems.Clear;
  NewNode.SubItems.Add('');
  NewNode.EditCaption;
end;

procedure TfrmWatch.SetValInWatch(index: integer; r: TValue);
begin
  case r._Type of
    tyReal:
      List.Items[index].SubItems[0] := FloatToStr(r.Real);
    tyStr:
      List.Items[index].SubItems[0] := '''' + r.Str + '''';
  end;
end;

procedure TfrmWatch.SetArrInWatch(index: integer; r: TVar);
var
  i: integer;

begin
  List.Items[index].SubItems[0] := '(';
  for i := 0 to r.Arr.Count - 2 do
    if r.Arr.Items[i]._Type = tyReal then
      List.Items[index].SubItems[0] := List.Items[index].SubItems[0] + FloatToStr(r.Arr.Items[i].Real) + ', '
    else
      List.Items[index].SubItems[0] := List.Items[index].SubItems[0] + '''' + r.Arr.Items[i].Str + ''', ';
  if r.Arr.Items[r.Arr.Count - 1]._Type = tyReal then
    List.Items[index].SubItems[0] := List.Items[index].SubItems[0] + FloatToStr(r.Arr.Items[r.Arr.Count - 1].Real)
      + ')'
  else
    List.Items[index].SubItems[0] := List.Items[index].SubItems[0] + '''' + r.Arr.Items[r.Arr.Count - 1].Str + ''')';
end;

procedure TfrmWatch.btnDeleteClick(Sender: TObject);
begin
  if List.Selected <> nil then
    List.Selected.Delete;
end;

procedure TfrmWatch.btnChangeClick(Sender: TObject);
begin
  if List.Selected <> nil then
    List.Selected.EditCaption;
end;

procedure TfrmWatch.ListEdited(Sender: TObject; Item: TListItem; var S: String);
begin
  Item.Caption := S;
  VarsRefresh;
end;

procedure TfrmWatch.AddAllVars;
var
  i: integer;
  Node: TListItem;

  function Find(name: string): boolean;
  var
    i: integer;

  begin
    Result := false;
    for i := 0 to List.Items.Count - 1 do
      if List.Items[i].Caption = name then
        Result := true;
  end;

begin
  // List.Clear;
  for i := 0 to ChildForm.Vars.Count - 1 do
  begin
    if not Find(ChildForm.Vars.Items[i].Name) then
    begin
      Node := List.Items.Add;
      Node.Caption := ChildForm.Vars.Items[i].Name;
      Node.SubItems.Clear;
      Node.SubItems.Add('');
    end;
  end;
end;

procedure TfrmWatch.btnAllClick(Sender: TObject);
begin
  VarsRefresh;
end;

procedure TfrmWatch.FormCreate(Sender: TObject);
begin
  Left := Screen.WorkAreaRect.Right - Width;
  Top := Screen.WorkAreaRect.Bottom - Height;
end;

end.

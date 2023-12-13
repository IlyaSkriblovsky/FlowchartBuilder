unit BlockProps;

interface

uses
  Windows, Forms, Block, Classes, Controls, StdCtrls, ExtCtrls, Buttons;

const
  without_help = 318;
  with_help = 526;

type
  TfrmProps = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    OpMemo: TMemo;
    Label2: TLabel;
    TxMemo: TMemo;
    Label3: TLabel;
    RmEdit: TEdit;
    Shape1: TShape;
    Label4: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure OpMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TxMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    Block: TBlock;

  end;

var
  frmProps: TfrmProps;

implementation

uses Child, Main;
{$R *.dfm}

procedure TfrmProps.FormCreate(Sender: TObject);
begin
  Width := without_help;
end;

procedure TfrmProps.btnHelpClick(Sender: TObject);
begin
  if Width = with_help then
    Width := without_help
  else
    Width := with_help;
end;

procedure TfrmProps.FormShow(Sender: TObject);
begin
  if Block = nil then
    Exit;
  if Block.BlockType = stConfl then
    Close;

  OpMemo.Enabled := true;
  OpMemo.Lines.Assign(Block.Statement);
  OpMemo.SelStart := 0;
  TxMemo.Lines.Assign(Block.UnfText);
  RmEdit.Text := Block.RemText;

  if Block.BlockType = stComment then
    OpMemo.Clear;
  if Block.BlockType = stComment then
    RmEdit.Clear; ;

  OpMemo.Enabled := (Block.BlockType <> stComment); // and not Viewer;
  RmEdit.Enabled := (Block.BlockType <> stComment); // and not Viewer;

  if OpMemo.Enabled then
    OpMemo.SetFocus
  else
    TxMemo.SetFocus;
end;

procedure TfrmProps.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmProps.btnOKClick(Sender: TObject);
var
  BackUp: TStringList;
  UN: PUndoNode;

begin
  if Block = nil then
    Exit;
  BackUp := TStringList.Create;
  BackUp.Assign(Block.Statement);

  New(UN);
  UN._ := utTextChange;
  UN.Group := 1;
  UN.Block := Block;
  UN.Statement := Block.Statement.Text;
  UN.Text := Block.UnfText.Text;
  UN.RemStr := Block.RemText;
  MainForm.AddUndo(UN);

  Block.Statement.Assign(OpMemo.Lines);
  ChildForm.CheckStatement(BackUp, Block);
  if not Block.Statement.Equals(BackUp) then
    MainForm.Modifed := true;
  BackUp.Free;

  if not Block.UnfText.Equals(TxMemo.Lines) then
    MainForm.Modifed := true;
  Block.UnfText.Assign(TxMemo.Lines);
  if Block.RemText <> RmEdit.Text then
    MainForm.Modifed := true;
  Block.RemText := RmEdit.Text;
end;

procedure TfrmProps.OpMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (ssCtrl in Shift) then
  begin
    Key := 0;
    btnOK.Click;
  end;
  if Key = VK_ESCAPE then
    btnCancel.Click;
end;

procedure TfrmProps.TxMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (ssCtrl in Shift) then
  begin
    Key := 0;
    btnOK.Click;
  end;
  if Key = VK_ESCAPE then
    btnCancel.Click;
end;

end.

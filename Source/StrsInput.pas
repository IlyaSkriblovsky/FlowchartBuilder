unit StrsInput;

interface

uses
  Forms, StdCtrls, Classes, Controls, Buttons, ExtCtrls;

type
  TStrsForm = class(TForm)
    Memo: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Prompt: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StrsForm: TStrsForm;

function MemoInput(ACaption, APrompt: string; var Strs: TStringList): boolean;

implementation

{$R *.dfm}

function MemoInput;
begin
  StrsForm.Caption:=ACaption;
  StrsForm.Prompt.Caption:=APrompt;
  StrsForm.Memo.Lines.Assign(Strs);
  if StrsForm.ShowModal=mrOK
  then begin
         Strs.Assign(StrsForm.Memo.Lines);
         Result:=true;
       end
  else Result:=false;
end;

procedure TStrsForm.btnOKClick(Sender: TObject);
begin
  ModalResult:=mrOK;
  Memo.SetFocus;     //Makes thish form easy to use. Modified by Roman Mitin
end;

procedure TStrsForm.btnCancelClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

end.

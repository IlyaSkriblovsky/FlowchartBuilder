unit OutProg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TfrmOutProg = class(TForm)
    Memo: TMemo;
    Panel1: TPanel;
    btnClear: TSpeedButton;
    btnClose: TSpeedButton;
    procedure btnClearClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOutProg: TfrmOutProg;

implementation

{$R *.DFM}

procedure TfrmOutProg.btnClearClick(Sender: TObject);
begin
  Memo.Clear;
  Memo.SetFocus;
end;

procedure TfrmOutProg.FormResize(Sender: TObject);
begin
  btnClose.Left:=Width-97;
end;

procedure TfrmOutProg.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

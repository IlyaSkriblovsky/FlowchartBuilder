unit uInterval;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons;

type
  TfrmInterval = class(TForm)
    inpMilliseconds: TEdit;
    UpDown: TUpDown;
    Label1: TLabel;
    btnOK: TBitBtn;
    cbxNoDelay: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbxNoDelayClick(Sender: TObject);
  end;

var
  frmInterval: TfrmInterval;

implementation

uses Main;
{$R *.dfm}

procedure TfrmInterval.FormShow(Sender: TObject);
begin
  if MainForm.AutoTimer.Interval <> 1 then
  begin
    cbxNoDelay.Checked := false;
    UpDown.Position := MainForm.AutoTimer.Interval;
    inpMilliseconds.Text := IntToStr(UpDown.Position);
  end
  else
    cbxNoDelay.Checked := true;
end;

procedure TfrmInterval.btnOKClick(Sender: TObject);
begin
  if cbxNoDelay.Checked then
    MainForm.AutoTimer.Interval := 1
  else
  begin
    try
      MainForm.AutoTimer.Interval := StrToInt(inpMilliseconds.Text);
    except
      on EConvertError do
        raise Exception.Create('Неверное число.');
    end;
  end;
end;

procedure TfrmInterval.cbxNoDelayClick(Sender: TObject);
begin
  inpMilliseconds.Enabled := not cbxNoDelay.Checked;
end;

end.

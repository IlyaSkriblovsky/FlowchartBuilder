unit uInterval;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons;

type
  TfrmInterval = class(TForm)
    Edit1: TEdit;
    UpDown: TUpDown;
    Label1: TLabel;
    btnOK: TBitBtn;
    CheckBox1: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  end;

var
  frmInterval: TfrmInterval;

implementation

uses Main;

{$R *.dfm}

procedure TfrmInterval.FormShow(Sender: TObject);
begin
  if MainForm.AutoTimer.Interval<>1
  then begin
         CheckBox1.Checked:=false;
         UpDown.Position:=MainForm.AutoTimer.Interval;
         Edit1.Text:=IntToStr(UpDown.Position);
       end
  else CheckBox1.Checked:=true;
end;

procedure TfrmInterval.btnOKClick(Sender: TObject);
begin
  if CheckBox1.Checked
  then MainForm.AutoTimer.Interval:=1
  else begin
         try
           MainForm.AutoTimer.Interval:=StrToInt(Edit1.Text);
         except
           on EConvertError
           do raise Exception.Create('Неверное число.');
         end;
       end;
end;

procedure TfrmInterval.CheckBox1Click(Sender: TObject);
begin
  Edit1.Enabled:=not CheckBox1.Checked;
end;

end.

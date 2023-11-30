unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, DateUtils,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    lblConstructor: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    GoToWeb: TLabel;
    Copyright: TLabel;
    CityAndYears: TLabel;
    Version: TLabel;
    Shape1: TShape;
    Label6: TLabel;
    Label9: TLabel;
    lblSN: TLabel;
    SN: TLabel;
    Label12: TLabel;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Label1: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure GoToWebClick(Sender: TObject);
    procedure GoToWebMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Shape5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation
uses Dialogs, ShellAPI, reg, Version;

{$R *.DFM}

procedure TAboutBox.Timer1Timer(Sender: TObject);
begin
 Timer1.Enabled:=false;
 Close;
end;

procedure TAboutBox.GoToWebClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar('https://github.com/IlyaSkriblovsky/FlowchartBuilder'), nil, nil, SW_SHOWNORMAL);
end;

procedure TAboutBox.GoToWebMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  (Sender as TLabel).Font.Color:=clPurple;
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
  GoToWeb.Font.Color:=clBlue;
  GoToWeb.Font.Style:=[fsBold, fsUnderline];
  SN.Caption:=RegNum;
end;

procedure TAboutBox.Label17Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, 'mailto:ilyaskriblovsky@gmail.com?Subject=��������� �� ������ � ��������� Flowchart builder', nil, nil, SW_SHOWNORMAL);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  Version.Caption:='������ '+BuildVersion+' (������ '+IntToStr(BuildNumber)+') �� '+DateTimeToStr(BuildDate);
  CityAndYears.Caption:='������ ��������, 2002�' + IntToStr(YearOf(BuildDate));
end;

procedure TAboutBox.Panel1Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE
  then Close;
end;

procedure TAboutBox.Shape5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Close;
end;

end.


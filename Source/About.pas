unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, DateUtils,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Timer: TTimer;
    Panel1: TPanel;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    lblConstructor: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    Label5: TLabel;
    GoToWeb: TLabel;
    Copyright: TLabel;
    CityAndYears: TLabel;
    Version: TLabel;
    Shape1: TShape;
    Label6: TLabel;
    Label9: TLabel;
    Label12: TLabel;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    GoToEmail: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure OnTimer(Sender: TObject);
    procedure GoToWebClick(Sender: TObject);
    procedure ReportErrorByMail(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnPanelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnShapeClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GoToEmailClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

uses Dialogs, ShellAPI, Version;
{$R *.DFM}

procedure TAboutBox.OnTimer(Sender: TObject);
begin
  Timer.Enabled := false;
  Close;
end;

procedure TAboutBox.GoToEmailClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar('mailto:IlyaSkriblovsky@gmail.com'), nil, nil, SW_SHOWNORMAL);
end;

procedure TAboutBox.GoToWebClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar('https://github.com/IlyaSkriblovsky/FlowchartBuilder'), nil, nil, SW_SHOWNORMAL);
end;

procedure TAboutBox.ReportErrorByMail(Sender: TObject);
begin
  ShellExecute(Handle, nil,
    'mailto:ilyaskriblovsky@gmail.com?Subject=Сообщение об ошибке в программе Flowchart builder', nil, nil, SW_SHOWNORMAL);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  Version.Caption := 'Версия ' + BuildVersion + ' (сборка ' + IntToStr(BuildNumber) + ') от ' + DateTimeToStr
    (BuildDate);
  CityAndYears.Caption := 'Нижний Новгород, 2002—' + IntToStr(YearOf(BuildDate));
end;

procedure TAboutBox.OnPanelClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TAboutBox.OnShapeClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Close;
end;

end.

unit ZoomForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ToolWin, ComCtrls, StdCtrls, Buttons;

type
  TfrmZoom = class(TForm)
    ControlBar: TControlBar;
    ToolBar1: TToolBar;
    ZoomBox: TComboBox;
    Label1: TLabel;
    btnClose: TSpeedButton;
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ZoomBoxChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  public
    MetaFile: TMetaFile;
    Zoom: double;
    p: TPoint;
    Down: record _: boolean;
    X, Y: Integer;
  end;

end;

var
  frmZoom: TfrmZoom;

implementation

const
  crHandUp = 1;
  crHandDown = 2;
{$R *.dfm}

procedure TfrmZoom.FormPaint(Sender: TObject);
begin
  Canvas.StretchDraw(Rect(p.X, p.Y, p.X + Round(MetaFile.Width * Zoom), p.Y + Round(MetaFile.Height * Zoom)), MetaFile);
end;

procedure TfrmZoom.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Down._ := true;
  Down.X := X - p.X;
  Down.Y := Y - p.Y;
  Screen.Cursor := crHandDown;
end;

procedure TfrmZoom.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Down._ := false;
  Screen.Cursor := crDefault;
  ControlBar.Cursor := crArrow;
end;

procedure TfrmZoom.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Down._ then
  begin
    p := Point(X - Down.X, Y - Down.Y);
    Refresh;
  end;
end;

procedure TfrmZoom.FormCreate(Sender: TObject);
begin
  p := Point(0, 0);
  Zoom := 1;
  Screen.Cursors[crHandUp] := LoadCursor(HInstance, 'HANDUP');
  Screen.Cursors[crHandDown] := LoadCursor(HInstance, 'HANDDOWN');
  Cursor := crHandUp;
  DragCursor := crHandDown;
  ZoomBox.ItemIndex := 4;
end;

procedure TfrmZoom.ZoomBoxChange(Sender: TObject);
var
  old: double;

begin
  try
    old := Zoom;
    Zoom := StrToInt(ZoomBox.Text) / 100;
    p.X := p.X + Round(MetaFile.Width * old - MetaFile.Width * Zoom) div 2;
    p.Y := p.Y + Round(MetaFile.Height * old - MetaFile.Height * Zoom) div 2;
    Refresh;
  except
  end;
end;

procedure TfrmZoom.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

// {$DEFINE VIEWER}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Buttons, ExtCtrls, StdCtrls, EdTypes, OpenUnit, SaveUnit, Math,
  ComCtrls, ToolWin, ActnList, AppEvnts, ShellAPI, Arrows, JPEG, ini, StrUtils, Lang;

type
  TUndoType = (utEmpty, utBlocksMove, utTextChange, utArrowMove, utNewBlock, utNewArrow, utDelBlock, utDelArrow);
  PUndoNode = ^TUndoNode;

  TUndoNode = record
    _: TUndoType;
    Group: word;

    Block, Block1: TBlock;
    WasStartBlock: boolean;
    Arrow: TArrow;
    p: integer;
    ArrowType: TArrowType;
    ArrowStyle: TArrowStyle;
    Statement, Text, Init, Glob: string;
    RemStr: string;
    pnt, pnt1: TPoint;
    port: array [TArrowTail] of TBlockPort;
  end;

  TWD = (wdNone, wdEllipse, wdRect, wdRomb, wdParal, wdCall, wdGlob, wdInit, wdComment, wdConfl);

  TMainForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ControlBar: TControlBar;
    tbrFile: TToolBar;
    btnNew: TSpeedButton;
    btnOpen: TSpeedButton;
    btnSave: TSpeedButton;
    tbrDebug: TToolBar;
    tbrBlocks: TToolBar;
    tbrView: TToolBar;
    btnStop: TSpeedButton;
    EllipseSB: TSpeedButton;
    RectSB: TSpeedButton;
    RombSB: TSpeedButton;
    ParalSB: TSpeedButton;
    btnView: TSpeedButton;
    BtnWatch: TSpeedButton;
    btnStep: TSpeedButton;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuNew: TMenuItem;
    mnuOpen: TMenuItem;
    mnuSave: TMenuItem;
    N10: TMenuItem;
    mnuExport: TMenuItem;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    mnuEdit: TMenuItem;
    mnuArrow: TMenuItem;
    mnuDebug: TMenuItem;
    mnuSelFirst: TMenuItem;
    mnuRun: TMenuItem;
    N6: TMenuItem;
    mnuStep: TMenuItem;
    mnuStop: TMenuItem;
    mnuViewDisp: TMenuItem;
    mnuWatch: TMenuItem;
    mnuOptions: TMenuItem;
    mnuSettings: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    N2: TMenuItem;
    StatusBar: TStatusBar;
    mnuRunHelp: TMenuItem;
    PICSave: TSaveDialog;
    N14: TMenuItem;
    mnuNewWindow: TMenuItem;
    CallSB: TSpeedButton;
    ActionList: TActionList;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    GlobSB: TSpeedButton;
    InitSB: TSpeedButton;
    AutoTimer: TTimer;
    btnAuto: TSpeedButton;
    ApplicationEvents: TApplicationEvents;
    mnuInterval: TMenuItem;
    btnLineRun: TSpeedButton;
    btnDelete: TSpeedButton;
    tbrAlign: TToolBar;
    btnAlignV: TSpeedButton;
    btnAlignH: TSpeedButton;
    CommSB: TSpeedButton;
    mnuExpWMF: TMenuItem;
    mnuExpBMP: TMenuItem;
    mnuExpJPEG: TMenuItem;
    ConflSB: TSpeedButton;
    mnuRepError: TMenuItem;
    mnuBlkBegin: TMenuItem;
    mnuBlkIf: TMenuItem;
    mnuBlkIO: TMenuItem;
    mnuBlkCall: TMenuItem;
    mnuBlkGlob: TMenuItem;
    mnuBlkInit: TMenuItem;
    mnuBlkComm: TMenuItem;
    mnuBlkConfl: TMenuItem;
    ToolButton1: TToolButton;
    mnuNewBlock: TMenuItem;
    N25: TMenuItem;
    mnuAlign: TMenuItem;
    mnuDelete: TMenuItem;
    N28: TMenuItem;
    mnuAlignV: TMenuItem;
    mnuAlignH: TMenuItem;
    mnuView: TMenuItem;
    mnuBlkStat: TMenuItem;
    pnlLine: TPanel;
    pnlSelectFirstBlock: TPanel;
    N3: TMenuItem;
    mnuUndo: TMenuItem;
    N4: TMenuItem;
    mnuSaveAs: TMenuItem;
    btnSettings: TSpeedButton;
    mnuPrint: TMenuItem;
    actDelete: TAction;
    AboutShow: TTimer;
    btnZoom: TSpeedButton;
    btnBrowser: TSpeedButton;
    mnuZoom: TMenuItem;
    N5: TMenuItem;
    mnuBrowser: TMenuItem;
    procedure mnuExitClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuArrowClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OptionsClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuSelFirstClick(Sender: TObject);
    procedure StepClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure BtnWatchClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuRunHelpClick(Sender: TObject);
    procedure mnuNewWindowClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure mnuIntervalClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAlignVClick(Sender: TObject);
    procedure btnAlignHClick(Sender: TObject);

    procedure BlockCreateClick(Sender: TObject);

    procedure mnuExpWMFClick(Sender: TObject);
    procedure mnuExpBMPClick(Sender: TObject);
    procedure mnuExpJPEGClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure mnuRepErrorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);

    procedure AddUndo(UN: PUndoNode);
    procedure DoUndo(UN: PUndoNode);
    procedure mnuBlkBeginClick(Sender: TObject);
    procedure mnuBlkStatClick(Sender: TObject);
    procedure mnuBlkIfClick(Sender: TObject);
    procedure mnuBlkIOClick(Sender: TObject);
    procedure mnuBlkCallClick(Sender: TObject);
    procedure mnuBlkConflClick(Sender: TObject);
    procedure mnuBlkGlobClick(Sender: TObject);
    procedure mnuBlkInitClick(Sender: TObject);
    procedure mnuBlkCommClick(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure mnuPrintClick(Sender: TObject);
    procedure btnAutoClick(Sender: TObject);
    procedure AutoTimerTimer(Sender: TObject);
    procedure AboutShowTimer(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure mnuRunClick(Sender: TObject);
    procedure mnuZoomClick(Sender: TObject);
    procedure btnBrowserClick(Sender: TObject);

  private
    FModifed: boolean;
    FAutoExec: boolean;

  public
    WhatDown: TWD;

    procedure SetModifed(Value: boolean);
    property Modifed: boolean read FModifed write SetModifed;

    procedure SetAutoExec(Value: boolean);
    property AutoExec: boolean read FAutoExec write SetAutoExec;
  end;

var
  MainForm: TMainForm;
  AlreadyGlob: boolean = false;
  AlreadyInit: boolean = false;

  GlobBlock: TBlock;
  InitBlock: TBlock;

  GlobVars: TStringList;

  Viewer: boolean;

  AplName: string;

  UndoStack: TList;

procedure AddToGlobVars(Lines: TStringList);
procedure AutoPause;
procedure AutoResume;

function FloatToStr(Value: Extended): string;
function StrToFloat(Value: string): Extended;

var
  MyDir: string;

implementation

uses Child, OutProg, Options, About, Watch, uInterval, Printers, ZoomForm;
{$R *.DFM}
{$WARNINGS OFF}

function FloatToStr(Value: Extended): string;
begin
  Result := SysUtils.FloatToStr(Value);
  while System.Pos(GetLocaleChar(GetThreadLocale, LOCALE_SDECIMAL, '.'), Result) > 0 do
    Result[System.Pos(GetLocaleChar(GetThreadLocale, LOCALE_SDECIMAL, '.'), Result)] := '.';
end;

function StrToFloat(Value: string): Extended;
begin
  while System.Pos('.', Value) > 0 do
    Value[System.Pos('.', Value)] := GetLocaleChar(GetThreadLocale, LOCALE_SDECIMAL, '.');
  Result := SysUtils.StrToFloat(Value);
end;
{$WARNINGS ON}

procedure AutoPause;
begin
  MainForm.AutoTimer.Enabled := false;
end;

procedure AutoResume;
begin
  if ChildForm.StartBlok = Nil then
  begin
    MainForm.mnuSelFirstClick(nil);
    Exit;
  end;

  if MainForm.AutoTimer.Interval = 1 then
  begin
    while MainForm.AutoExec do
    begin
      ChildForm.GoProc(true, ChildForm.flagInWork);
      Application.ProcessMessages;
    end;
  end
  else
    MainForm.AutoTimer.Enabled := MainForm.AutoExec;
end;

procedure TMainForm.SetModifed(Value: boolean);
begin
  FModifed := Value;
  if ChildForm.FileName <> '' then
    ChildForm.Caption := IfThen(Value, ChildForm.FileName + ' (изменен)', ChildForm.FileName)
end;

procedure TMainForm.SetAutoExec(Value: boolean);
begin
  FAutoExec := Value;
  if Value = false then
    AutoPause;
  btnAuto.Down := Value;
end;

procedure TMainForm.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.btnViewClick(Sender: TObject);
begin
  frmOutProg.Show;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  if ChildForm.FindStartBlok then
  begin
    ChildForm.FindStartBlok := false;
    pnlSelectFirstBlock.Visible := false;
    Exit;
  end;

  if ChildForm.flagInWork then
    ChildForm.GoProc(false);

  Refresh;
end;

procedure TMainForm.mnuNewClick(Sender: TObject);
begin
  if Modifed then
  begin
    WriteIniFile;
    ShellExecuteW(0, Nil, PChar(AplName), Nil, Nil, SW_NORMAL);
    Exit;
  end;
  Modifed := false;
  ChildForm.StartBlok := Nil;
  ChildForm.FileName := '';
  ChildForm.Caption := ChildForm.FileName;
  ChildForm.DestroyList;
  ChildForm.RePaint;
  ChildForm.Dragging := false;
  ChildForm.FindStartBlok := false;
  ChildForm.flagInWork := false;
  AlreadyGlob := false;
  AlreadyInit := false;

  ChildForm.Refresh;
end;

procedure TMainForm.mnuOpenClick(Sender: TObject);
var
  i: integer;

begin
  if OpenDialog.Execute then
  begin
    if not FileExists(OpenDialog.FileName) then
      Exit;
    if Modifed then
    begin
      WriteIniFile;
      ShellExecuteW(0, Nil, PChar(AplName), PChar('"' + OpenDialog.FileName + '"'), Nil, SW_NORMAL);
      Exit;
    end;
    ChildForm.StartBlok := Nil;
    ChildForm.FileName := OpenDialog.FileName;
    ChildForm.DestroyList;
    ChildForm.Dragging := false;
    ChildForm.flagInWork := false;
    AlreadyGlob := false;
    AlreadyInit := false;
    ChildForm.Actives.Clear;
    LoadScheme(ChildForm.FileName);
    for i := 0 to ChildForm.ArrowList.Count - 1 do
      TArrow(ChildForm.ArrowList[i]).StandWell;
    ChildForm.Caption := OpenDialog.FileName;
    ChildForm.SetRange;
    Modifed := false;
    for i := 0 to UndoStack.Count - 1 do
      Dispose(PUndoNode(UndoStack[i]));
    UndoStack.Clear;
    mnuUndo.Enabled := false;

    ChildForm.Refresh;
  end;
end;

procedure TMainForm.mnuSaveClick(Sender: TObject);
begin
  if ChildForm.FileName = '' then
  begin
    SaveDialog.FileName := 'Flowchart.bsh';
    if SaveDialog.Execute then
    begin
      ChildForm.FileName := SaveDialog.FileName;
      SaveScheme(ChildForm.FileName);
      ChildForm.Caption := SaveDialog.FileName;
      Modifed := false;
    end;
  end
  else
  begin
    SaveScheme(ChildForm.FileName);
    Modifed := false;
  end;
end;

procedure TMainForm.mnuArrowClick(Sender: TObject);
begin
  Modifed := true;
  btnLineRun.Down := not ChildForm.ANew.New;
  ChildForm.ANew.New := btnLineRun.Down;
  if ChildForm.ANew.New then
  begin
    ChildForm.SetButtsEnable(false);

    ChildForm.ANew.Tail := atEnd;
    ChildForm.ANew.Arrow := TArrow.Create;
    ChildForm.ANew.Arrow.Hide := true;
    ChildForm.DefCursor := crCross;
  end
  else
  begin
    ChildForm.SetButtsEnable(true);

    ChildForm.DefCursor := crDefault;
  end;
  ChildForm.Refresh;
end;

procedure TMainForm.OptionsClick(Sender: TObject);
var
  i: integer;
  t: TBlock;

begin
  if ChildForm = Nil then
    Exit;
  frmOpt.ShowModal;
  for i := 0 to ChildForm.BlockList.Count - 1 do
  begin
    t := ChildForm.BlockList.Items[i];
    t.Color := ChildForm.ColorBlok;
    t.Font.Color := ChildForm.ColorFontBlok;
  end;
end;

procedure TMainForm.mnuAboutClick(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TMainForm.mnuSelFirstClick(Sender: TObject);
begin
  pnlSelectFirstBlock.Visible := true;
  ChildForm.FindStartBlok := true;
end;

procedure TMainForm.StepClick(Sender: TObject);
begin
  if ChildForm.StartBlok = Nil then
  begin
    mnuSelFirstClick(Sender);
    AutoPause;
  end
  else
    ChildForm.GoProc(true, ChildForm.flagInWork);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Modifed then
    if MessageDlg('Текущая схема не сохранена.'#10#13'Вы уверены, что хотите выйти?', mtConfirmation, [mbYes, mbNo], 0)
      <> mrYes then
    begin
      Action := caNone;
      Exit;
    end;
end;

procedure AddToGlobVars(Lines: TStringList);
var
  Text: string;
  tmp: integer;

begin
  Text := Lines.Text;
  while System.Pos(#10, Text) > 0 do
    Delete(Text, System.Pos(#10, Text), 1);
  while System.Pos(#13, Text) > 0 do
    Delete(Text, System.Pos(#13, Text), 1);
  while System.Pos(' ', Text) > 0 do
    Delete(Text, System.Pos(' ', Text), 1);
  while System.Pos(',', Text) > 0 do
  begin
    tmp := System.Pos(',', Text);
    Delete(Text, tmp, 1);
    Insert(#10#13, Text, tmp);
  end;
  GlobVars.Text := GlobVars.Text + #10#13 + Text;
end;

procedure TMainForm.BtnWatchClick(Sender: TObject);
begin
  frmWatch.Show;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  GlobVars.Free;
end;

procedure TMainForm.mnuRunHelpClick(Sender: TObject);
begin
  if not FileExists(MyDir + 'Help\Index.htm') then
    MessageBox(0, 'Файл справочной системы'#10#13'(Help\index.htm) не найден', 'Вызов справочной системы',
      MB_ICONERROR);
  ShellExecute(Handle, nil, PChar(MyDir + 'Help\Index.htm'), nil, nil, SW_SHOW);
end;

procedure TMainForm.mnuNewWindowClick(Sender: TObject);
begin
  WriteIniFile;
  ShellExecuteW(0, Nil, PChar(AplName), Nil, Nil, SW_NORMAL);
end;

procedure TMainForm.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  AutoExec := false;
  if E is EConvertError then
    E.Message := 'Ошибка перевода значения';
  if E is EInOutError then
    E.Message := 'Ошибка ввода/вывода';
  if E is EDivByZero then
    E.Message := 'Деление на ноль';
  if E is EIntOverflow then
    E.Message := 'Целочисленное переполнение';
  if E is ERangeError then
    E.Message := 'Ошибка диапазона';
  if E is EInvalidCast then
    E.Message := 'Ошибка приведения типа';
  if E is EInvalidOperation then
    E.Message := 'Неверная операция над компонентом';
  if E is EInvalidPointer then
    E.Message := 'Ошибка операции над указателями';
  if E is EListError then
    E.Message := 'Ошибка операции над списками';
  if E is EOSError then
    E.Message := 'Ошибка операционной системы';
  if E is EInvalidArgument then
    E.Message := 'Неверный аргумент';
  if E is EInvalidOp then
    E.Message := 'Неверная операция с плавающей точкой';
  if E is EOverflow then
    E.Message := 'Дробное переполнение';
  if E is EUnderflow then
    E.Message := 'Потеря точности';
  if E is EZeroDivide then
    E.Message := 'Деление на ноль';
  if E is EOutOfMemory then
    E.Message := 'Нехватает памяти';
  if E is EPrivilege then
    E.Message := 'Нехватает привилегий';
{$WARN SYMBOL_DEPRECATED OFF}
  if E is EStackOverflow then
    E.Message := 'Переполнение стека';
{$WARN SYMBOL_DEPRECATED ON}
  if E is EFOpenError then
    E.Message := 'Ошибка открытия фала';
  if E is EStringListError then
    E.Message := 'Ошибка операции над списком строк';
  if E is EVariantError then
    E.Message := 'Ошибка операции над вариантными типами';
  if not(E is ERunTimeError) then
    E.Message := 'Ошибка времени выполнения: '#10#13'  ' + E.Message;
  Application.ShowException(E);
end;

procedure TMainForm.mnuIntervalClick(Sender: TObject);
begin
  frmInterval.ShowModal;
end;

procedure TMainForm.btnDeleteClick(Sender: TObject);
begin
  ChildForm.Actives.Delete;
  InvalidateRect(ChildForm.Handle, nil, true);
end;

procedure TMainForm.btnAlignVClick(Sender: TObject);
begin
  ChildForm.AlignVert;
  Modifed := true;
end;

procedure TMainForm.btnAlignHClick(Sender: TObject);
begin
  ChildForm.AlignHoriz;
  Modifed := true;
end;

function MakeMetaFile: TMetaFile;
var
  MF: TMetaFile;
  MFC: TMetaFileCanvas;
  i: integer;
  b: TBlock;
  a: TArrow;
  t: TArrowTail;
  Min, Max: TPoint;

const
  l = 5;

begin
  ChildForm.Actives.Clear;
  MF := TMetaFile.Create;
  Max := Point(0, 0);
  Min := Point(0, 0);
  if ChildForm.BlockList.Count > 0 then
  begin
    Min.X := TBlock(ChildForm.BlockList[0]).Left;
    Min.Y := TBlock(ChildForm.BlockList[0]).Top;
    Max.X := TBlock(ChildForm.BlockList[0]).Left + TBlock(ChildForm.BlockList[0]).Width;
    Max.Y := TBlock(ChildForm.BlockList[0]).Top + TBlock(ChildForm.BlockList[0]).Height;
    for i := 0 to ChildForm.BlockList.Count - 1 do
    begin
      b := TBlock(ChildForm.BlockList[i]);
      if b.Left < Min.X then
        Min.X := b.Left;
      if b.Top < Min.Y then
        Min.Y := b.Top;
      if b.Left + b.Width > Max.X then
        Max.X := b.Left + b.Width;
      if b.Top + b.Height > Max.Y then
        Max.Y := b.Top + b.Height;
    end;
    for i := 0 to ChildForm.ArrowList.Count - 1 do
    begin
      a := TArrow(ChildForm.ArrowList[i]);
      for t := atStart to atEnd do
      begin
        if a.Tail[t].X < Min.X then
          Min.X := a.Tail[t].X;
        if a.Tail[t].X > Max.X then
          Max.X := a.Tail[t].X;
        if a.Tail[t].Y < Min.Y then
          Min.Y := a.Tail[t].Y;
        if a.Tail[t].Y > Max.Y then
          Max.Y := a.Tail[t].Y;
      end;
      if a.Style = eg4 then
        case a._Type of
          vert:
            begin
              if a.p < Min.X then
                Min.X := a.p;
              if a.p > Max.X then
                Max.X := a.p;
            end;
          horiz:
            begin
              if a.p < Min.Y then
                Min.Y := a.p;
              if a.p > Max.Y then
                Max.Y := a.p;
            end;
        end;
    end;
  end;
  with Max do
  begin
    X := X + l;
    Y := Y + l;
  end;
  with Min do
  begin
    X := X - l;
    Y := Y - l;
  end;
  if Max.X < Min.X then
    Max.X := Min.X;
  if Max.Y < Min.Y then
    Max.Y := Min.Y;
  MF.Width := Max.X - Min.X;
  MF.Height := Max.Y - Min.Y;
  MFC := TMetaFileCanvas.CreateWithComment(MF, GetDC(ChildForm.Handle), 'Конструктор Блок-схем',
    MainForm.SaveDialog.FileName);
  for i := 0 to ChildForm.BlockList.Count - 1 do
  begin
    b := TBlock(ChildForm.BlockList[i]);
    b.DrawCanvas := MFC;
    b.XOffs := b.Left - Min.X;
    b.YOffs := b.Top - Min.Y;
    b.Paint;
    b.XOffs := 0;
    b.YOffs := 0;
    b.DrawCanvas := b.Canvas;
  end;
  for i := 0 to ChildForm.ArrowList.Count - 1 do
  begin
    a := TArrow(ChildForm.ArrowList[i]);
    a.DrawCanvas := MFC;
    a.xo := -Min.X;
    a.yo := -Min.Y;
    a.Draw;
    a.xo := 0;
    a.yo := 0;
    a.DrawCanvas := ChildForm.Canvas;
  end;
  MFC.Destroy;
  MF.Transparent := false;
  Result := MF;
end;

procedure TMainForm.mnuExpWMFClick(Sender: TObject);
begin
  PICSave.Title := 'Экспорт в WMF';
  PICSave.DefaultExt := '*.wmf';
  PICSave.Filter := 'Windows Meta Files (*.wmf; *.emf)|*.wmf; *.emf|Все файлы (*.*)|*.*';
  PICSave.FilterIndex := 0;
  PICSave.FileName := '';
  if PICSave.Execute then
    MakeMetaFile.SaveToFile(PICSave.FileName);
end;

procedure TMainForm.mnuExpBMPClick(Sender: TObject);
var
  MF: TMetaFile;
  bmp: TBitmap;

begin
  PICSave.Title := 'Экспорт в BMP';
  PICSave.DefaultExt := '*.wmf';
  PICSave.Filter := 'Windows Bitmaps (*.bmp)|*.bmp|Все файлы (*.*)|*.*';
  PICSave.FilterIndex := 0;
  PICSave.FileName := '';
  if PICSave.Execute then
  begin
    bmp := TBitmap.Create;
    MF := MakeMetaFile;
    bmp.Width := MF.Width;
    bmp.Height := MF.Height;
    bmp.Canvas.Draw(0, 0, MF);
    bmp.SaveToFile(PICSave.FileName);
    bmp.Free;
    MF.Free;
  end;
end;

procedure TMainForm.mnuExpJPEGClick(Sender: TObject);
var
  MF: TMetaFile;
  jpg: TJPEGImage;
  bmp: TBitmap;

begin
  PICSave.Title := 'Экспорт в JPEG';
  PICSave.DefaultExt := '*.jpeg';
  PICSave.Filter := 'JPEG Files(*.jpg; *.jpeg)|*.jpg; *.jpeg|Все файлы (*.*)|*.*';
  PICSave.FilterIndex := 0;
  PICSave.FileName := '';
  if PICSave.Execute then
  begin
    jpg := TJPEGImage.Create;
    bmp := TBitmap.Create;
    MF := MakeMetaFile;
    bmp.Width := MF.Width;
    bmp.Height := MF.Height;
    bmp.Canvas.Draw(0, 0, MF);
    jpg.Assign(bmp);
    jpg.SaveToFile(PICSave.FileName);
    jpg.Free;
    bmp.Free;
    MF.Free;
  end;
end;

procedure TMainForm.StopClick(Sender: TObject);
begin
  ChildForm.ANew.New := false;
  ChildForm.DefCursor := crDefault;
  ChildForm.SetButtsEnable(true);

  btnLineRun.Down := false;

  ChildForm.Refresh;
end;

procedure TMainForm.mnuRepErrorClick(Sender: TObject);
begin
  AboutBox.ReportErrorByMail(Sender);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
{$IFDEF VIEWER}
  Viewer := true;
{$ELSE}
  Viewer := false;
{$ENDIF}
  if FileExists(MyDir + 'FBrowser.exe') or FileExists(MyDir + 'Browser.exe') then
  begin
    mnuBrowser.Visible := true;
    btnBrowser.Visible := true;
    tbrFile.Width := btnBrowser.Left + btnBrowser.Width;
  end;
end;

procedure TMainForm.BlockCreateClick(Sender: TObject);
var
  SB: TSpeedButton;

begin
  SB := Sender as TSpeedButton;

  if (AlreadyGlob and (TWD(SB.Tag) = wdGlob)) or (AlreadyInit and (TWD(SB.Tag) = wdInit)) then
  begin
    MessageBox(0, 'На схеме уже есть этот блок.', 'Ошибка', MB_ICONSTOP);
    WhatDown := wdNone;
    SB.Down := false;
    ChildForm.DefCursor := crDefault;
    Exit;
  end;

  if WhatDown = TWD(SB.Tag) then
  begin
    SB.Down := false;
    WhatDown := wdNone;
    ChildForm.DefCursor := crDefault;
    Exit;
  end;
  ChildForm.SetButtsUp;
  SB.Down := true;
  WhatDown := TWD(SB.Tag);
  ChildForm.SetRange;
  Modifed := true;
  ChildForm.DefCursor := crCross;
end;

procedure TMainForm.AddUndo(UN: PUndoNode);
begin
  UndoStack.Add(UN);
  mnuUndo.Enabled := true;
end;

procedure TMainForm.DoUndo(UN: PUndoNode);
var
  i: integer;
  a: TArrow;

begin
  with ChildForm do
    case UN._ of
      utBlocksMove:
        begin
          UN.Block.Left := UN.pnt.X;
          UN.Block.Top := UN.pnt.Y;
          for i := 0 to ArrowList.Count - 1 do
          begin
            a := ArrowList[i];
            if (a.Blocks[atStart].Block = UN.Block) or (a.Blocks[atEnd].Block = UN.Block) then
              a.StandWell;
          end;
          ChildForm.Refresh;
        end;
      utTextChange:
        begin
          UN.Block.Statement.Text := UN.Statement;
          UN.Block.UnfText.Text := UN.Text;
          UN.Block.RemText := UN.RemStr;
          UN.Block.Paint;
        end;
      utArrowMove:
        begin
          UN.Arrow._Type := UN.ArrowType;
          UN.Arrow.Style := UN.ArrowStyle;

          UN.Arrow.Blocks[atStart].Block := UN.Block;
          UN.Arrow.Blocks[atStart].port := UN.port[atStart];
          UN.Arrow.Tail[atStart] := UN.pnt;

          UN.Arrow.Blocks[atEnd].Block := UN.Block1;
          UN.Arrow.Blocks[atEnd].port := UN.port[atEnd];
          UN.Arrow.Tail[atEnd] := UN.pnt1;

          UN.Arrow.p := UN.p;
          UN.Arrow.StandWell;
          ChildForm.Refresh;
        end;
      utNewBlock:
        begin
          Actives.Blocks.Remove(UN.Block);
          DeleteBlock(UN.Block, false);
        end;
      utNewArrow:
        begin
          Actives.Arrows.Remove(UN.Arrow);
          DeleteArrow(UN.Arrow, false);
          ChildForm.Refresh;
        end;
      utDelBlock:
        begin
          BlockList.Add(UN.Block);
          if UN.Block.Block = stGlob then
            AlreadyGlob := true;
          if UN.Block.Block = stInit then
            AlreadyInit := true;
          UN.Block.Show;
        end;
      utDelArrow:
        begin
          ArrowList.Add(UN.Arrow);
          UN.Arrow.Hide := false;
          ChildForm.Refresh;
        end;
    end;
  UndoStack.Remove(UN);
  Dispose(UN);
  if UndoStack.Count = 0 then
    mnuUndo.Enabled := false;
end;

procedure TMainForm.mnuUndoClick(Sender: TObject);
var
  UN: PUndoNode;
  i: integer;
  Group: integer;
  q: TPaintStruct;

begin
  UN := UndoStack[UndoStack.Count - 1];
  Group := UN.Group;
  Group := Max(Group, 1);

  DoUndo(UN);

  for i := 2 to Group do
    DoUndo(UndoStack[UndoStack.Count - 1]);

  EndPaint(ChildForm.Handle, q);
end;

procedure TMainForm.mnuBlkBeginClick(Sender: TObject);
begin
  EllipseSB.Click;
end;

procedure TMainForm.mnuBlkStatClick(Sender: TObject);
begin
  RectSB.Click;
end;

procedure TMainForm.mnuBlkIfClick(Sender: TObject);
begin
  RombSB.Click;
end;

procedure TMainForm.mnuBlkIOClick(Sender: TObject);
begin
  ParalSB.Click;
end;

procedure TMainForm.mnuBlkCallClick(Sender: TObject);
begin
  CallSB.Click;
end;

procedure TMainForm.mnuBlkConflClick(Sender: TObject);
begin
  ConflSB.Click;
end;

procedure TMainForm.mnuBlkGlobClick(Sender: TObject);
begin
  GlobSB.Click;
end;

procedure TMainForm.mnuBlkInitClick(Sender: TObject);
begin
  InitSB.Click;
end;

procedure TMainForm.mnuBlkCommClick(Sender: TObject);
begin
  CommSB.Click;
end;

procedure TMainForm.mnuSaveAsClick(Sender: TObject);
begin
  SaveDialog.FileName := ChildForm.FileName;
  if SaveDialog.Execute then
  begin
    ChildForm.FileName := SaveDialog.FileName;
    SaveScheme(ChildForm.FileName);
    ChildForm.Caption := SaveDialog.FileName;
    Modifed := false;
  end;
end;

procedure TMainForm.mnuPrintClick(Sender: TObject);
var
  MF: TMetaFile;

begin
  // ChildForm.Print;
  MF := MakeMetaFile;
  Printer.Title := IfThen(ChildForm.FileName <> '', 'Блок-схема (' + ChildForm.FileName + ')', 'Блок-схема');
  Printer.BeginDoc;
  Printer.Canvas.Draw(0, 0, MF);
  Printer.EndDoc;
  MF.Free;
end;

procedure TMainForm.btnAutoClick(Sender: TObject);
begin
  AutoExec := not AutoExec;

  if AutoExec then
  begin
    if ChildForm.StartBlok = nil then
    begin
      ChildForm.FindStartBlok := true;
      pnlSelectFirstBlock.Visible := true;
    end
    else
      AutoResume;
  end
  else
    AutoPause;

  mnuRun.Checked := btnAuto.Down;
end;

procedure TMainForm.AutoTimerTimer(Sender: TObject);
begin
  btnStep.Click;
end;

procedure TMainForm.AboutShowTimer(Sender: TObject);
begin
  AboutShow.Enabled := false;
  AboutBox.ShowModal;
end;

procedure TMainForm.btnZoomClick(Sender: TObject);
var
  MF: TMetaFile;

begin
  with frmZoom do
  begin
    Color := ChildForm.Color;
    MetaFile := TMetaFile.Create;
    MF := MakeMetaFile;
    MetaFile.Assign(MF);
    MF.Free;
    frmZoom.WindowState := wsMaximized;
    frmZoom.p := Point(100, 100);
    frmZoom.ZoomBoxChange(nil);
    ShowModal;
    MetaFile.Free;
  end;
end;

procedure TMainForm.mnuRunClick(Sender: TObject);
begin
  btnAuto.Click;
end;

procedure TMainForm.mnuZoomClick(Sender: TObject);
begin
  btnZoom.Click;
end;

procedure TMainForm.btnBrowserClick(Sender: TObject);
begin
  ShellExecute(0, nil, PChar(MyDir + 'Browser.exe'), nil, nil, 1);
  ShellExecute(0, nil, PChar(MyDir + 'FBrowser.exe'), nil, nil, 1);
end;

end.

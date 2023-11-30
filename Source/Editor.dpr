program Editor;

uses
  Windows,
  Forms,
  Classes,
  SysUtils,
  Dialogs,
  Main in 'Main.pas' {MainForm},
  EdTypes in 'EdTypes.pas',
  About in 'About.pas' {AboutBox},
  OutProg in 'OutProg.pas' {frmOutProg},
  Options in 'Options.pas' {frmOpt},
  OpenUnit in 'OpenUnit.pas',
  SaveUnit in 'SaveUnit.pas',
  Child in 'Child.pas' {ChildForm},
  Watch in 'Watch.pas' {frmWatch},
  Lang in 'Lang.pas',
  uInterval in 'uInterval.pas' {frmInterval},
  Arrows in 'Arrows.pas',
  StrsInput in 'StrsInput.pas' {frmStrsForm},
  ini in 'ini.pas',
  BlockProps in 'BlockProps.pas' {frmProps},
  Version in 'Version.pas',
  ZoomForm in 'ZoomForm.pas' {frmZoom};

{$R *.RES}

begin
  AplName:=ParamStr(0);
  MyDir:=ExtractFileDir(ParamStr(0))+'\';
  Application.Initialize;
  Application.Title:='Конструктор блок-схем';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TfrmInterval, frmInterval);
  Application.CreateForm(TChildForm, ChildForm);
  Application.CreateForm(TStrsForm, StrsForm);
  Application.CreateForm(TfrmProps, frmProps);
  Application.CreateForm(TfrmOutProg, frmOutProg);
  Application.CreateForm(TfrmOpt, frmOpt);
  Application.CreateForm(TfrmWatch, frmWatch);
  Application.CreateForm(TfrmZoom, frmZoom);
  if Viewer
  then begin
         (***  MainForm  ***)
         with MainForm
         do begin
              Caption:='Интерпретатор блок-схем';
              Application.Title:='Интерпретатор блок-схем';

           (***  Hiding Unnecessary ;o)  ***)
              btnNew.Visible:=false;
              if btnBrowser.Visible
              then tbrFile.Width:=btnOpen.Width+btnSave.Width+btnBrowser.Width
              else tbrFile.Width:=btnOpen.Width+btnSave.Width;
              tbrBlocks.Visible:=false;
              tbrAlign.Visible:=false;
              btnLineRun.Visible:=false;
              btnDelete.Visible:=false;
              mnuEdit.Visible:=false;
              mnuEdit.Enabled:=false;
              mnuNew.Visible:=false;

           (***  Aligning toolbars  ***)
              tbrFile.Left:=0;
              tbrDebug.Left:=tbrFile.Width-10;
              tbrView.Left:=tbrDebug.Left+tbrDebug.Width-10;
              btnSettings.Left:=tbrView.Left+tbrView.Width+10;
              btnZoom.Left:=btnSettings.Left+btnSettings.Width;
            end;

         (***  ChildForm  ***)
         with ChildForm
         do begin
              mnuDelete.Visible:=false;
              mnuRem.Visible:=false;  // <-- Too lazy...
              mnuReplace.Visible:=false;
            end;

         (***  frmOpt  ***)
         with frmOpt
         do begin
{              grpI13r.Visible:=false;
              Shape2.Height:=233;
              Memo2.Height:=96;
              Height:=312;}
              clbInterpr.Enabled:=false;
            end;

         (***  frmProps  ***)
         with frmProps
         do begin
              OpMemo.ReadOnly:=true;
              TxMemo.ReadOnly:=true;
              RmEdit.ReadOnly:=true;
            end;

         (***  StrsForm  ***)
         with StrsForm
         do begin
              Memo.ReadOnly:=true;
            end;

         (***  AboutBox  ***)
         with AboutBox
         do begin
              lblConstructor.Caption:='Интерпретатор блок-схем';
            end;
       end;

  MainForm.Modifed:=false;
//////////////////////////////////////////////////////////////////
//  if not Viewer
//  then Registration;
//////////////////////////////////////////////////////////////////
  if FileExists(ParamStr(1)) then
  begin
    ChildForm.StartBlok:=nil;
    ChildForm.FileName:=ParamStr(1);
    ChildForm.DestroyList;
    ChildForm.RePaint;
    ChildForm.BlockList:=TList.Create;
    ChildForm.Dragging:=False;
    ChildForm.flagInWork:=False;
    LoadScheme(ChildForm.FileName);
    ChildForm.Caption:=ParamStr(1);
    ChildForm.SetRange;
  end;
  Application.Run;
end.

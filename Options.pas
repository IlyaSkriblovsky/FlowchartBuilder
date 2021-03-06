unit Options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls, CheckLst;

// Window width constants

type
  TfrmOpt = class(TForm)
    BitOk: TBitBtn;
    BitCansel: TBitBtn;
    ColorDialog1: TColorDialog;
    grpColor: TGroupBox;
    ListBox1: TListBox;
    Label3: TLabel;
    Shape1: TShape;
    ChangeColor: TButton;
    grpSizes: TGroupBox;
    Label1: TLabel;
    WidthBlok: TEdit;
    Label2: TLabel;
    HeightBlok: TEdit;
    grpI13r: TGroupBox;
    clbInterpr: TCheckListBox;
    BitHelp: TBitBtn;
    Memo1: TMemo;
    Memo2: TMemo;
    Shape2: TShape;
    Label4: TLabel;
    Label7: TLabel;
    ConflRad: TEdit;
    grpFonts: TGroupBox;
    btnBlockFont: TButton;
    Memo3: TMemo;
    Memo4: TMemo;
    FontDialog: TFontDialog;
    procedure FormCreate(Sender: TObject);
    procedure BitOkClick(Sender: TObject);
    procedure BitCanselClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ChangeColorClick(Sender: TObject);
    procedure BitHelpClick(Sender: TObject);
    procedure btnBlockFontClick(Sender: TObject);
    procedure FontDialogApply(Sender: TObject; Wnd: HWND);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOpt: TfrmOpt;
  default_width_nohelp: integer=245;
  default_width_help: integer=490;

implementation
uses Main, Child, About, EdTypes;

{$R *.DFM}

procedure TfrmOpt.FormCreate(Sender: TObject);
begin
  default_width_nohelp:=BitHelp.Left+BitHelp.Width+12;
  default_width_help:=Shape2.Left+Shape2.Width+12;

  Width:=default_width_nohelp;

  clbInterpr.Checked[0]:=ChildForm.AutoCheck;

  WidthBlok.Text:=IntToStr(ChildForm.WidthBlok);
  HeightBlok.Text:=IntToStr(ChildForm.HeightBlok);
  ConflRad.Text:=IntToStr(ChildForm.ConflRadius);
end;

procedure TfrmOpt.BitOkClick(Sender: TObject);
var
  i: integer;

begin
  ChildForm.WidthBlok:=StrToInt(WidthBlok.Text);
  ChildForm.HeightBlok:=StrToInt(HeightBlok.Text);
  ChildForm.ConflRadius:=StrToInt(ConflRad.Text);
  for i:=0 to ChildForm.BlockList.Count-1
  do if TBlock(ChildForm.BlockList[i]).Block=stConfl
     then begin
            TBlock(ChildForm.BlockList[i]).Width:=ChildForm.ConflRadius;
            TBlock(ChildForm.BlockList[i]).Height:=ChildForm.ConflRadius;
          end;
  ChildForm.Refresh;

  ChildForm.AutoCheck:=clbInterpr.Checked[0];

  Close;
end;

procedure TfrmOpt.BitCanselClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmOpt.ListBox1Click(Sender: TObject);
begin
  if ListBox1.Selected[0] then
    Shape1.Brush.Color:=ChildForm.ColorBlok;
  if ListBox1.Selected[1] then
    Shape1.Brush.Color:=ChildForm.ColorFontBlok;
  if ListBox1.Selected[2] then
    Shape1.Brush.Color:=ChildForm.ColorCurrentBlok;
  if ListBox1.Selected[3] then
    Shape1.Brush.Color:=ChildForm.Color;
end;

procedure TfrmOpt.ChangeColorClick(Sender: TObject);
begin
  ColorDialog1.Color:=Shape1.Brush.Color;
  if ColorDialog1.Execute then
    Shape1.Brush.Color:=ColorDialog1.Color;

  if ListBox1.Selected[0] then
    ChildForm.ColorBlok:=Shape1.Brush.Color;
  if ListBox1.Selected[1] then
    ChildForm.ColorFontBlok:=Shape1.Brush.Color;
  if ListBox1.Selected[2] then
    ChildForm.ColorCurrentBlok:=Shape1.Brush.Color;
  if ListBox1.Selected[3] then
    ChildForm.Color:=Shape1.Brush.Color;
end;

procedure TfrmOpt.BitHelpClick(Sender: TObject);
begin
 if Width=default_width_help then Width:=default_width_nohelp
 else Width:=default_width_help;
end;

procedure TfrmOpt.btnBlockFontClick(Sender: TObject);
begin
  FontDialog.Font.Assign(ChildForm.BlockFont);
  if FontDialog.Execute
  then begin
         ChildForm.BlockFont.Assign(FontDialog.Font);
         ChildForm.Refresh;
       end;
end;

procedure TfrmOpt.FontDialogApply(Sender: TObject; Wnd: HWND);
begin
  ChildForm.BlockFont.Assign(FontDialog.Font);
  ChildForm.Refresh;
end;

end.

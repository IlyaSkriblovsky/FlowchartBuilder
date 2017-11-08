unit Reg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Mask, ExtCtrls;

type
  TRegForm = class(TForm)
    Label1: TLabel;
    Shape1: TShape;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Edit1: TEdit;
    Label6: TLabel;
    Shape4: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape5: TShape;
    lblConstructor: TLabel;
    Label7: TLabel;
    Bevel1: TBevel;
    procedure BitBtn1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure Registration;

var
  RegForm: TRegForm;
  RegNum:string;

implementation
uses ShellAPI,math;
{$R *.dfm}

//WARNING! PRIVATE CODE! WARNING!

const
  FchBl=9;

{$I Code.pas}
function IsKey(sn:string):boolean;
begin
 if length(sn)<>12 then begin IsKey:=false; exit; end;
 Str2Code(sn);
 IsKey:=Validate(Code, FchBl);
end;

function SimpleCoding(s:string):string;
var     ss:string;
        i:integer;
begin
 ss:=s;
 for i:=1 to length(ss) do
  begin
   ss[i]:=Char((Ord(ss[i-1])+Ord(ss[i])) mod 256);
  end;
  SimpleCoding:=ss;
end;

function SimpleDecoding(s:string):string;
var       ss:string;
          i:integer;
begin
 ss:=s;
 for i:= length(ss) downto 1 do
  begin
   ss[i]:=Char((Ord(ss[i])-Ord(ss[i-1])) mod 256);
  end;
 SimpleDecoding:=ss;
end;


//END OF WARNING!!!

function RegTest:boolean;
var s,s1,s2:string;
    i, n, b: byte;
    f:file of byte;
begin
 s:=ExtractFileDir(ParamStr(0))+'\';
 s1:='A'; s2:='A';
 if FileExists(s+'redakt.key') then begin
        AssignFile(f,s+'redakt.key');
        Reset(f);
        s1:='';
        s2:='';
{        while not EOF(f)
        do begin
             if s1=''           // CHANGED BY ILYA SKRIBLOVSKY
             then ReadLn(f,s1);
             q:=Length(s1);
             if s2<>''
             then begin
//                    Delete(s1, Length(s1)-1, 2);
                    s1:=s1+#$A+s2;
                  end;
             ReadLn(f,s2);
           end;}
        Read(f, n);
        for i:=1 to n
        do begin
             Read(f, b);
             s1:=s1+chr(b);
           end;
        Read(f, n);
        for i:=1 to n
        do begin
             Read(f, b);
             s2:=s2+chr(b);
           end;
        CloseFile(f);
 end;
 s1:=SimpleDecoding(s1);
 s2:=SimpleDecoding(s2);
 RegNum:=s2;
 if (IsKey(s2) and (s=s1))
 then regtest:=true
 else begin
        regtest:=false;
        RegNum:='отсутствует';
      end;
end;

procedure Registration;
begin                  
 if not regtest then
  begin
   regform.ShowModal;
   if not regtest then Halt;
  end;
end;

procedure TRegForm.BitBtn1Click(Sender: TObject);
var s:string;
var i: byte;
    f: file of byte;
    b: byte;
begin
 s:=ExtractFileDir(ParamStr(0))+'\';
 if IsKey(Edit1.Text) then
  begin
   AssignFile(f,s+'redakt.key');
   Rewrite(f);
   s:=SimpleCoding(s);
   b:=Length(s);
   Write(f, b);
   for i:=1 to Length(s)
   do begin
        b:=ord(s[i]);
        Write(f, b);
      end;
   s:=SimpleCoding(Edit1.Text);
   b:=Length(s);
   Write(f, b);
   for i:=1 to Length(s)
   do begin
        b:=ord(s[i]);
        Write(f, b);
      end;
   CloseFile(f);
  end
 else
 begin
   ShowMessage('Неправильный серийный номер. Извините...');
{   if not FileExists(s+'Help\reg.htm')
   then MessageBox(0, 'Файл справочной системы'#10#13'(Help\reg.htm) не найден',
         'Вызов справочной системы', MB_ICONERROR);}
   ShellExecute(Handle, nil, PChar(s+'Help\reg.htm'), nil, nil, SW_SHOW);
   Application.Terminate;
 end;
end;                    

procedure TRegForm.Label3Click(Sender: TObject);
begin
    ShellExecute(Handle, nil, PChar('http://www.unn.ru/vmk/graphmod/index.php?id=registration'), nil, nil, SW_SHOW);
end;

end.

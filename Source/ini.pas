unit ini;

interface

var
  IniFile: string;

procedure WriteIniFile;
procedure ReadIniFile;
procedure CheckRegistry;

function GetHomePath: string;

implementation
uses Child, Main, IniFiles, SysUtils, Graphics, Classes, Registry, Windows, SaveUnit, uInterval,
        Forms;

var
  HomePath: string = '';


function GetHomePath: string;
var
  reg: TRegistry;

begin
  if HomePath=''
  then begin
         reg:=TRegistry.Create;

         reg.RootKey:=HKEY_CURRENT_USER;
         reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', false);

         HomePath:=reg.ReadString('AppData');

         reg.Free;
       end;
  Result:=HomePath;
end;


procedure WriteIniFile;
var
  Ini: TIniFile;

begin
  Ini:=TIniFile.Create(IniFile);
  with ChildForm
  do begin
       Ini.WriteInteger('Color', 'ColorBlok',        ColorBlok);
       Ini.WriteInteger('Color', 'ColorCurrentBlok', ColorCurrentBlok);
       Ini.WriteInteger('Color', 'ColorFontBlok',    ColorFontBlok);
       Ini.WriteInteger('Color', 'ColorForm',        Color);

       Ini.WriteInteger( 'Size', 'WidthBlok',        WidthBlok);
       Ini.WriteInteger( 'Size', 'HeightBlok',       HeightBlok);
       Ini.WriteInteger( 'Size', 'ConflRadius',      ConflRadius);

       Ini.WriteBool   ( 'I13r', 'AutoCheck',        AutoCheck);

       Ini.WriteBool   ('Interval', 'Is',            MainForm.AutoTimer.Interval=1);
       Ini.WriteInteger('Interval', 'Delay',         frmInterval.UpDown.Position);

       Ini.WriteString ('BlockFont', 'Name',         ChildForm.BlockFont.Name);
       Ini.WriteInteger('BlockFont', 'Charset',      ChildForm.BlockFont.Charset);
       Ini.WriteInteger('BlockFont', 'Size',         ChildForm.BlockFont.Size);
       Ini.WriteInteger('BlockFont', 'Color',        ChildForm.BlockFont.Color);
       Ini.WriteBool   ('BlockFont', 'Bold',         fsBold      in ChildForm.BlockFont.Style);
       Ini.WriteBool   ('BlockFont', 'Italic',       fsItalic    in ChildForm.BlockFont.Style);
       Ini.WriteBool   ('BlockFont', 'Underline',    fsUnderline in ChildForm.BlockFont.Style);
       Ini.WriteBool   ('BlockFont', 'StrikeOut',    fsStrikeOut in ChildForm.BlockFont.Style);

       Ini.WriteBool   ('Editor_WindowPos', 'Maximized',    MainForm.WindowState=wsMaximized);
       if MainForm.WindowState<>wsMaximized
       then begin
              Ini.WriteInteger('Editor_WindowPos', 'X',            MainForm.Left);
              Ini.WriteInteger('Editor_WindowPos', 'Y',            MainForm.Top);
              Ini.WriteInteger('Editor_WindowPos', 'W',            MainForm.Width);
              Ini.WriteInteger('Editor_WindowPos', 'H',            MainForm.Height);
            end;
     end;
  Ini.Free;
end;

procedure ReadIniFile;
var
  Ini: TIniFile;

begin
  Ini:=TIniFile.Create(IniFile);
  ChildForm.ColorBlok          :=Ini.ReadInteger('Color', 'ColorBlok', clWhite);
  ChildForm.ColorCurrentBlok   :=Ini.ReadInteger('Color', 'ColorCurrentBlok', clMoneyGreen);
  ChildForm.ColorFontBlok      :=Ini.ReadInteger('Color', 'ColorFontBlok', clBlack);
  ChildForm.Color              :=Ini.ReadInteger('Color', 'ColorForm', clWhite);
  ChildForm.WidthBlok          :=Ini.ReadInteger('Size', 'WidthBlok', 80);
  ChildForm.HeightBlok         :=Ini.ReadInteger('Size', 'HeightBlok', 50);
  ChildForm.ConflRadius        :=Ini.ReadInteger('Size', 'ConflRadius', 10);
  ChildForm.AutoCheck          :=Ini.ReadBool('I13r', 'AutoCheck', false);
  with ChildForm.BlockFont
  do begin
       Name:=   Ini.ReadString ('BlockFont', 'Name', 'Courier New');
       Charset:=Ini.ReadInteger('BlockFont', 'Charset', RUSSIAN_CHARSET);
       Size:=   Ini.ReadInteger('BlockFont', 'Size', 10);
       Color:=  Ini.ReadInteger('BlockFont', 'Color', clBlack);
       if Ini.ReadBool('BlockFont', 'Bold', false)      then Style:=Style+[fsBold];
       if Ini.ReadBool('BlockFont', 'Italic', false)    then Style:=Style+[fsItalic];
       if Ini.ReadBool('BlockFont', 'Underline', false) then Style:=Style+[fsUnderline];
       if Ini.ReadBool('BlockFont', 'StrikeOut', false) then Style:=Style+[fsStrikeOut];
     end;
  frmInterval.UpDown.Position  :=Ini.ReadInteger('Interval', 'Delay', 1000);
  if Ini.ReadBool('Interval', 'Is', false)
  then MainForm.AutoTimer.Interval:=1
  else MainForm.AutoTimer.Interval:=frmInterval.UpDown.Position;

  with MainForm
  do begin
       WindowState:=wsNormal;
       Left:=Ini.ReadInteger('Editor_WindowPos', 'X', 100);
       Top:=Ini.ReadInteger('Editor_WindowPos', 'Y', 100);
       Width:=Ini.ReadInteger('Editor_WindowPos', 'W', Screen.Width-Left-100);
       Height:=Ini.ReadInteger('Editor_WindowPos', 'H', Screen.Height-Top-100);
       if Ini.ReadBool('Editor_WindowPos', 'Maximized', true)
       then WindowState:=wsMaximized;
     end;
  Ini.Free;
end;

procedure CheckRegistry;
var
  reg: TRegistry;

begin
  reg:=TRegistry.Create;
  reg.RootKey:=HKEY_CURRENT_USER;

  if not (reg.KeyExists('\Software\Classes\.bsh'))
  then begin
         reg.OpenKey('\Software\Classes\.bsh', true);
         reg.WriteString('', 'bshfile');
         reg.OpenKey('ShellNew', true);
         reg.WriteString('FileName', 'Flowchart.bsh');
         reg.OpenKey('\Software\Classes\bshfile', true);
         reg.WriteString('', 'Блок-схема');
         reg.OpenKey('shell\open\command', true);
         reg.WriteString('', ParamStr(0)+' "%1"');

         reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', false);

         WriteEmpty(reg.ReadString('Templates')+'\Flowchart.bsh');
       end;

  reg.Free;
end;

end.

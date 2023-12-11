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
  if HomePath = '' then
  begin
    reg := TRegistry.Create;

    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', false);

    HomePath := reg.ReadString('AppData');

    reg.Free;
  end;
  Result := HomePath;
end;

procedure WriteIniFile;
var
  ini: TIniFile;

begin
  ini := TIniFile.Create(IniFile);
  with ChildForm do
  begin
    ini.WriteInteger('Color', 'ColorBlok', ColorBlock);
    ini.WriteInteger('Color', 'ColorCurrentBlok', ColorCurrentBlock);
    ini.WriteInteger('Color', 'ColorFontBlok', ColorFontBlock);
    ini.WriteInteger('Color', 'ColorForm', Color);

    ini.WriteInteger('Size', 'WidthBlok', WidthBlock);
    ini.WriteInteger('Size', 'HeightBlok', HeightBlock);
    ini.WriteInteger('Size', 'ConflRadius', ConflRadius);

    ini.WriteBool('I13r', 'AutoCheck', AutoCheck);

    ini.WriteBool('Interval', 'Is', MainForm.AutoTimer.Interval = 1);
    ini.WriteInteger('Interval', 'Delay', frmInterval.UpDown.Position);

    ini.WriteString('BlockFont', 'Name', ChildForm.BlockFont.Name);
    ini.WriteInteger('BlockFont', 'Charset', ChildForm.BlockFont.Charset);
    ini.WriteInteger('BlockFont', 'Size', ChildForm.BlockFont.Size);
    ini.WriteInteger('BlockFont', 'Color', ChildForm.BlockFont.Color);
    ini.WriteBool('BlockFont', 'Bold', fsBold in ChildForm.BlockFont.Style);
    ini.WriteBool('BlockFont', 'Italic', fsItalic in ChildForm.BlockFont.Style);
    ini.WriteBool('BlockFont', 'Underline', fsUnderline in ChildForm.BlockFont.Style);
    ini.WriteBool('BlockFont', 'StrikeOut', fsStrikeOut in ChildForm.BlockFont.Style);

    ini.WriteBool('Editor_WindowPos', 'Maximized', MainForm.WindowState = wsMaximized);
    if MainForm.WindowState <> wsMaximized then
    begin
      ini.WriteInteger('Editor_WindowPos', 'X', MainForm.Left);
      ini.WriteInteger('Editor_WindowPos', 'Y', MainForm.Top);
      ini.WriteInteger('Editor_WindowPos', 'W', MainForm.Width);
      ini.WriteInteger('Editor_WindowPos', 'H', MainForm.Height);
    end;
  end;
  ini.Free;
end;

procedure ReadIniFile;
var
  ini: TIniFile;

begin
  ini := TIniFile.Create(IniFile);
  ChildForm.ColorBlock := ini.ReadInteger('Color', 'ColorBlok', clWhite);
  ChildForm.ColorCurrentBlock := ini.ReadInteger('Color', 'ColorCurrentBlok', clMoneyGreen);
  ChildForm.ColorFontBlock := ini.ReadInteger('Color', 'ColorFontBlok', clBlack);
  ChildForm.Color := ini.ReadInteger('Color', 'ColorForm', clWhite);
  ChildForm.WidthBlock := ini.ReadInteger('Size', 'WidthBlok', 80);
  ChildForm.HeightBlock := ini.ReadInteger('Size', 'HeightBlok', 50);
  ChildForm.ConflRadius := ini.ReadInteger('Size', 'ConflRadius', 10);
  ChildForm.AutoCheck := ini.ReadBool('I13r', 'AutoCheck', false);
  with ChildForm.BlockFont do
  begin
    Name := ini.ReadString('BlockFont', 'Name', 'Courier New');
    Charset := ini.ReadInteger('BlockFont', 'Charset', RUSSIAN_CHARSET);
    Size := ini.ReadInteger('BlockFont', 'Size', 10);
    Color := ini.ReadInteger('BlockFont', 'Color', clBlack);
    if ini.ReadBool('BlockFont', 'Bold', false) then
      Style := Style + [fsBold];
    if ini.ReadBool('BlockFont', 'Italic', false) then
      Style := Style + [fsItalic];
    if ini.ReadBool('BlockFont', 'Underline', false) then
      Style := Style + [fsUnderline];
    if ini.ReadBool('BlockFont', 'StrikeOut', false) then
      Style := Style + [fsStrikeOut];
  end;
  frmInterval.UpDown.Position := ini.ReadInteger('Interval', 'Delay', 1000);
  if ini.ReadBool('Interval', 'Is', false) then
    MainForm.AutoTimer.Interval := 1
  else
    MainForm.AutoTimer.Interval := frmInterval.UpDown.Position;

  with MainForm do
  begin
    WindowState := wsNormal;
    Left := ini.ReadInteger('Editor_WindowPos', 'X', 100);
    Top := ini.ReadInteger('Editor_WindowPos', 'Y', 100);
    Width := ini.ReadInteger('Editor_WindowPos', 'W', Screen.Width - Left - 100);
    Height := ini.ReadInteger('Editor_WindowPos', 'H', Screen.Height - Top - 100);
    if ini.ReadBool('Editor_WindowPos', 'Maximized', true) then
      WindowState := wsMaximized;
  end;
  ini.Free;
end;

procedure CheckRegistry;
var
  reg: TRegistry;

begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;

  if not(reg.KeyExists('\Software\Classes\.bsh')) then
  begin
    reg.OpenKey('\Software\Classes\.bsh', true);
    reg.WriteString('', 'bshfile');
    reg.OpenKey('ShellNew', true);
    reg.WriteString('FileName', 'Flowchart.bsh');
    reg.OpenKey('\Software\Classes\bshfile', true);
    reg.WriteString('', 'Блок-схема');
    reg.OpenKey('shell\open\command', true);
    reg.WriteString('', ParamStr(0) + ' "%1"');

    reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', false);

    WriteEmpty(reg.ReadString('Templates') + '\Flowchart.bsh');
  end;

  reg.Free;
end;

end.

{
  VersionTool
  This tool can be included in Delphi IDE.
  When VersionTool launched, it is trying to open Version.pas file
  and replacing constants, declarated there by current date, time, etc.
}

program VersionTool;

uses
  Windows,
  Classes,
  SysUtils;

var
  Str: TStringList;
  i: integer;
  n: integer;
  s: string;

begin
  if not FileExists('Version.pas') then
  begin
    MessageBox(0, 'Can''t see Version.pas!', 'VersionTool Error', MB_ICONSTOP);
    Halt;
  end;

  Str := TStringList.Create;
  Str.LoadFromFile('Version.pas');
  for i := 0 to Str.Count - 1 do
  begin
    if Pos('BuildDate', Str[i]) > 0 then
    begin
      s := FloatToStr(Now);
      if Pos(',', s) > 0 then
        s[Pos(',', s)] := '.';
      Str[i] := '  BuildDate = ' + s + ';';
    end;
    if Pos('BuildNumber', Str[i]) > 0 then
    begin
      s := Copy(Str[i], Pos('=', Str[i]) + 1, 999);
      Delete(s, Length(s), 1);
      n := StrToInt(s) + 1;
      Str[i] := '  BuildNumber = ' + IntToStr(n) + ';';
    end;
  end;
  Str.SaveToFile('Version.pas');
  Str.Free;

end.

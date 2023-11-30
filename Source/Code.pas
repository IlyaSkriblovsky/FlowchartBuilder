type TCode=array [1..12] of byte;
var
  tmpc, code: TCode;

const
  A=8;
  B=9;
  C=10;
  D=11;
  E=12;

  procedure FromPN(p: byte; n: word);
  var
    ps: string[2];
    ns: string[5];
    i: word;

  begin
    ps:=''; ns:='';
    for i:=1 to 12 do code[i]:=0;
//    FillChar(ps, 3, 0);
 //   FillChar(ns, 6, 0);

    Str(p:2, ps);
    Str(n:5, ns);
    Code[1]:=max(0,ord(ps[1])-ord('0'));
    Code[2]:=max(0,ord(ps[2])-ord('0'));
    for i:=1 to 5
    do Code[i+2]:=max(0,ord(ns[i])-ord('0'));

  end;

  procedure MakeCRC;
  var
    Sum: LongInt;
    q: LongInt;
    i: integer;

  begin
    Code[D]:=Random(10);

    case Random(3) of
      0: Code[E]:=7;
      1: Code[E]:=4;
      2: Code[E]:=1;
    end;

    Sum:=0;
    for i:=1 to 7
    do Inc(Sum, Code[i]);
    Inc(Sum, Code[D]);
    Code[A]:=Sum mod 10;

    Sum:=(Code[2]*2+Code[5]*5+Code[1]*3+Code[7]*8) mod 9;
    Code[B]:=Sum+(Sum div 8)*Random(2);

    Sum:=0;
    q:=1;
    for i:=1 to 7
    do begin
         Sum:=Sum+Code[i]*q;
         q:=q*10;
       end;
    Inc(Sum, Code[E]);
    Code[C]:=Trunc(Abs(sin(Sum)*10)) mod 10;
  end;

  function Code2Str(Code: TCode): string;
  var
    i: word;
    Res: string;
    c: char;

  begin
    Res:='';
    for i:=1 to 12
    do begin
         c:=Char(Code[i]+48);
         Res:=Res+c;
       end;
    Code2Str:=Res;
  end;

  procedure Str2Code(s: string);
  var i:integer;
  begin
    for i:=1 to 12
    do Code[i]:=Ord(s[i])-48;
  end;

  function Validate(Code: TCode; ProgID: integer): boolean;
    function ECheck: boolean;
    begin
      if Code[E] in [7, 4, 1]
      then ECheck:=true
      else ECheck:=false;
    end;

    function ACheck: boolean;
    var Sum: Word;
        i: integer;
    begin
      Sum:=0;
      for i:=1 to 7
      do Sum:=Sum+Code[i];
      Sum:=Sum+Code[D];
      ACheck:=Sum mod 10=Code[A];
    end;

    function BCheck: boolean;
    var Q: word;
        W: word;
    begin
      Q:=(Code[2]*2+Code[5]*5++Code[1]*3+Code[7]*8) mod 9;
      W:=Code[B];
      if W=9
      then W:=8;
      BCheck:=Q=W;
    end;

    function CCheck: boolean;
    var Sum: LongInt;
        q: LongInt;
        i: integer;
    begin
      Sum:=0;
      q:=1;
      for i:=1 to 7
      do begin
           Sum:=Sum+Code[i]*q;
           q:=q*10;
         end;
      Inc(Sum, Code[E]);
      CCheck:=Trunc(Abs(sin(Sum)*10)) mod 10=Code[C];
    end;

    function IDCheck(ID: byte): boolean;
    var
      q, w: integer;

    begin
      Val(Chr(Code[1]+48)+Chr(Code[2]+48), q, w);
      IDCheck:=q=ID;
    end;

  begin
    Validate:=ACheck and BCheck and CCheck and ECheck and IDCheck(ProgID);
  end;

  procedure SimpleEncode;
  var
    p: integer;
    i: integer;
    o: integer;

  begin
    p:=0;
    for i:=12 downto 1
    do begin
         o:=Code[i];
         Code[i]:=(Code[i]+p) mod 10;
         p:=(p+o) mod 10;
       end;
  end;

  procedure SimpleDecode;
  var
    p: integer;
    i: integer;

  begin
    p:=0;
    for i:=12 downto 1
    do begin
         Code[i]:=(integer(Code[i])+100-p) mod 10;
         p:=(p+Code[i]) mod 10;
       end;
  end;

procedure test;
var i:integer;
begin
  Randomize;
  FillChar(Code, SizeOf(Code), 0);
{  for i:=1 to 100
  do begin
       FromPN(2, i);
       MakeCRC;
       Write(Code2Str(Code));
       Write(#9, Validate(Code));
       ReadLn;
     end;}
{  for i:=1 to 100
  do begin
       ReadLn(s);
       Str2Code(s);
       WriteLn(Validate(Code));
     end;}
  for i:=1 to 100
  do begin
       FromPN(Random(100), i);
       MakeCRC;
       tmpc:=Code;
       Write(Code2Str(Code));
       SimpleEncode;
       Write(#9, Code2Str(Code));
       SimpleDecode;
       Write(#9,Code2Str(Code));
       Write(#9, Validate(Code, 12));
       ReadLn;
     end;
end;
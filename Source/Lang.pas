(*******************************************************************
*        К О Н С Т Р У К Т O Р - И Н Т Е Р П Р Е Т А Т О Р         *
*                      Б Л О К - С Х Е М                           *
********************************************************************
*             М О Д У Л Ь   И Н Т Е Р П Р Е Т А Ц И И              *
*                 Ф О Р М А Л Ь Н Г О   Я З Ы К А                  *
********************************************************************
* Модуль Lang.pas                                                  *
* Разбор и обработка операторов внутреннего языка                  *
* Модуль реализует следующие ф-ии:                                 *
*   1) ReadBlock(Lines, Lexemes) - Чтение строк Lines и деление    *
*       строк на лексемы, которые заносятся в Lexemes              *
*   2) CheckExpr(Lexemes) - Проверка одного выражения в Lexemes.   *
*       true - успешно, false - нет                                *
*   3) ExecExpr(Lexemes, Vars) - Вычисление значения выражения,    *
*       используя список переменных Vars. Возвращает TValue        *
*   4) GetVarValue(Vars, Name, ArrIndex) - Возвращает значение     *
*       переменной Name из списка Vars. ArrIndex - список индексов *
*       массива (пустой - без индекса)                             *
*   5) SetVarValue(Vars, Name, ArrIndex, Value) - Присваивает      *
*       переменной Name из списка Vars значение Value. ArrIndex -  *
*       список инексов массива (пустой - без индекса)              *
*   6) CheckOperator(Lexemes) - Проверка серии операторов через    *
*       точку-с-запятой. true - успешно, false - нет               *
*   7) ExecOperator(Lexemes, Vars) - Выполнение серии операторов   *
*       через точку-с-запятой, используя список переменных Vars    *
*   8) GetVarIndex(Vars, Name) - Возвращает индекс переменной      *
*       в списке Vars                                              *
********************************************************************
* Ф-ии 2 и 6 генерируют исключения класса ECheckError ф-ией        *
*       CheckError                                                 *
* Ф-ии 3, 4, 5, 7 генерируют исключения класса ERunTimeError       *
*       ф-ией RunTimeError                                         *
********************************************************************
* Copyright © 2002-2003 Ilya Skriblovsky                           *
*******************************************************************)


unit Lang;

interface
uses SysUtils, Classes;

const
  LexMax=1000;// Max число лексем
  Alpha=['A'..'Z', 'a'..'z', '_'];
  Num=['0'..'9'];
  Symbol=['+', '-', '*', '/', '(', ')', '<', '=', '>', '''', '"', ',', ';', ':', '[', ']', '{', '}', '?', '&', ' ', '^'];
  Any=Alpha+Num+Symbol;

type
  TReal=double;

  TValType=(tyReal, tyStr);
  TValue=record
    _Type: TValType;
    Str: string;
    Real: TReal;
  end;
  TVar=record
    Name: string;
    Value: TValue;
    Sizes: TList;
    Arr: TList;
  end;
  PVar=^TVar;
  PValue=^TValue;
  TVars=TList;

  TLexeme=(lxUndef{#}, lxName{a}, lxNumber{10}, lxPlus{+}, lxMinus{-}, lxAsterisk{*}, lxSlash{/}, lxPower{^},
           lxLBracket{(}, lxRBracket{)}, lxDiv{div}, lxMod{mod}, lxNot{not}, lxAnd{and}, lxOr{or}, lxXor{xor},
           lxArr{arr}, lxLess{<}, lxLessOrEqual{<=}, lxGreat{>}, lxGreatOrEqual{>=}, lxEqual{=}, lxNotEqual{<>},
           lxSemicolon{;}, lxComma{,}, lxAssignment{:=}, lxString{'qwe'}, lxLSBracket{[}, lxRSBracket{]},
           lxLBrace(*{*), lxRBrace(*}*), lxQuestion{?}, lxAmpersand{&});
                                                          // Все возможные лексемы
  TLexRecord=record
    _Type: TLexeme; // Тип
    Value: Variant; // Значение (напр. для _Type=lxName)
  end;
  TLexemes=array [1..LexMax] of TLexRecord;// Массив лекскм
  PLexemes=^TLexemes;

  ECheckError=class(Exception);// Исключение проверки
  ERunTimeError=class(Exception);// Исключение времени выполнения


  EError=class(Exception);

  TGetFuncProc=function (Vars: TVars; Name: string; Params: TList): TValue;

  PFile_Rec=^TFile_Rec;
  TFile_Rec=record
//    Text: TextFile;
    ID: integer;
    Write: boolean;
    FileName: string;
    Strings: TStringList;
    Pos: integer;
  end;

const
  Lex2Str: array [TLexeme] of string=('ничего', 'имя', 'число', '+', '-', '*', '/', '^', '(', ')', 'DIV', 'MOD',
                                      'NOT', 'AND', 'OR', 'XOR', 'ARR', '<', '<=', '>', '>=', '=', '<>', ';', ',', ':=',
                                      'строка', '[', ']', '{', '}', '?', '&');

var
  LexCount: Cardinal;
//  Lexemes: TLexemes;
  AlreadyError: boolean;
  Pos: Cardinal;
  GetFuncValue: TGetFuncProc;

  Files: TList;
  CurFile: integer=0;


procedure ReadBlock(ALines: TStrings; Lexemes: PLexemes);

function CheckExpr(Lexemes: PLexemes): boolean;
function ExecExpr(Lexemes: PLexemes; Vars: TVars): TValue;

function GetVarValue(Vars: TVars; Name: string; ArrIndex: TList): TValue;
procedure SetVarValue(Vars: TVars; Name: string; ArrIndex: TList; Value: TValue);

function CheckOperator(Lexemes: PLexemes): boolean;
procedure ExecOperator(Lexemes: PLexemes; Vars: TVars);

procedure RunTimeError(Error: string);

function GetVarIndex(Vars: TVars; Name: string): integer;

function GetFuncResult(Vars: TVars; Name: string; Params: TList): TValue;

implementation
uses Main, Math, Windows;

procedure ReadBlock(ALines: TStrings; Lexemes: PLexemes); // Разбиваем программу на лексемы
var
  Lines: TStringList;
  Lex: TLexeme;
  c: Char;
  Pos: integer;
  EOF: boolean;
  Word: string;
  tmp: string;
  f: boolean;
  quote: string;

const
  EOFChar=#0;

  procedure Add(Lex: TLexeme; Val: Variant); overload; // Добавляем элемент в Lexemes
  begin
    if LexCount=LexMax
    then raise ECheckError.Create('Слишком длинноe выражение (больше чем '+IntToStr(LexMax)+' элементов)');
    Inc(LexCount);
    Lexemes^[LexCount]._Type:=Lex;
    Lexemes^[LexCount].Value:=Val;
    if LexCount<>LexMax
    then Lexemes^[LexCount+1]._Type:=lxUndef;
  end;

  procedure Add(Lex: TLexeme); overload;
  begin
    Add(Lex, 0);
  end;

  procedure Read;// Читаем очередной символ
  begin
    Inc(Pos);
    if Pos<=Length(Lines.Text)
    then c:=Lines.Text[Pos]
    else begin
           EOF:=true;
           c:=EOFChar;
         end;
  end;

  procedure UnRead;
  begin
    Dec(Pos, 2);
    Read;
  end;

begin
  Lines:=TStringList.Create;
  Lines.Assign(ALines);

  LexCount:=1;
  FillChar(Lexemes^, SizeOf(Lexemes^), 0);
  LexCount:=0;
  EOF:=false;
  Pos:=0;

  tmp:=Lines.Text;

  while System.Pos(#10, tmp)>0
  do tmp[System.Pos(#10, tmp)]:=' ';//Delete(tmp, System.Pos(#10, tmp), 1);
  while System.Pos(#13, tmp)>0
  do tmp[System.Pos(#13, tmp)]:=' ';//Delete(tmp, System.Pos(#13, tmp), 1);

  Lines.Text:=tmp;

  Read;

  repeat
    if CharInSet(c, Alpha) // читаем имя переменной/ф-ии
    then begin
           Word:='';      
           while CharInset(c, Alpha+Num)
           do begin
                Word:=Word+c;
                Read;
                if c=EOFChar
                then Break;
              end;
           Lex:=lxDiv;
           while (Lex2Str[Lex]<>UpperCase(Word)) and (Lex<=lxArr) // проверяем на совпадение с ключевыми словами (Div..Arr)
           do Lex:=Succ(Lex);
           if Lex2Str[Lex]=UpperCase(Word)
           then Add(Lex)
           else Add(lxName, Word);
         end;

    if CharInSet(c, ['''', '"'])       // читаем строку
    then begin
           quote := c;
           Word:='';
           f:=false;
           repeat
             Read;
             if f
             then Word:=Word+quote;
             while c<>quote                    // repeat...until для чтения апострофов в строке
             do begin
                  Word:=Word+c;
                  Read;
                  if c=EOFChar
                  then Break;
                end;
             f:=true;
             if c=EOFChar
             then Break;
             Read;
           until c<>quote;
           Add(lxString, Word);
         end;

    if CharInset(c, Num) // Читаем число
    then begin
           Word:='';
           while CharInSet(c, Num)
           do begin
                Word:=Word+c;
                Read;                        //  целая часть
                if c=EOFChar
                then Break;
              end;
           if c='.'
           then begin
                  Word:=Word+c;
                  Read;
                  while CharInSet(c, Num)
                  do begin
                       Word:=Word+c;         // дробная часть
                       Read;
                       if c=EOFChar
                       then Break;
                     end;
                end;
           if CharInSet(c, ['e', 'E'])
           then begin
                  Word:=Word+c;
                  Read;
                  if CharInSet(c, Num+['-', '+'])
                  then while CharInSet(c, Num+['-', '+'])
                       do begin
                            Word:=Word+c;
                            Read;
                            while CharInSet(c, Num)           // экспонента
                            do begin
                                 Word:=Word+c;
                                 Read;
                                 if c=EOFChar
                                 then Break;
                               end;
                          end
                  else UnRead;
                end;
           Add(lxNumber, StrToFloat(Word));
         end;

    if CharInSet(c, ['<', '>']) // Читаем знаки сравнения
    then case c of
             '<': begin
                    Read;
                    if c='='
                    then begin
                           Add(lxLessOrEqual);
                           Read;
                         end
                    else if c='>'
                         then begin
                                Add(lxNotEqual);
                                Read;
                              end
                         else Add(lxLess);
                  end;
             '>': begin
                    Read;
                    if c='='
                    then begin
                           Add(lxGreatOrEqual);
                           Read;
                         end
                    else Add(lxGreat);
                  end;
         end;

    if CharInSet(c, ['+', '-', '*', '/', '^', '(', ')', '=', ';', ':', '[', ']', '{', '}', ',', '?', '&'])
    then begin
           case c of // Читаем все остальное
             '+': Add(lxPlus);
             '-': Add(lxMinus);
             '*': Add(lxAsterisk);
             '/': Add(lxSlash);
             '^': Add(lxPower);
             '(': Add(lxLBracket);
             ')': Add(lxRBracket);
             '=': Add(lxEqual);
             ';': Add(lxSemicolon);
             ':': begin
                    Add(lxAssignment);
                    Read;
                  end;
             '[': Add(lxLSBracket);
             ']': Add(lxRSBracket);
             '{': Add(lxLBrace);
             '}': Add(lxRBrace);
             ',': Add(lxComma);
             '?': Add(lxQuestion);
             '&': Add(lxAmpersand);
           end;
           Read;
         end;
    if (not CharInSet(c, Any)) or (c=' ')
    then Read;
  until EOF;
end;

procedure CheckError(ExpectError: boolean; Expect: string; Found: string='');// генерация ошибки
begin
  if not AlreadyError
  then if ExpectError
       then raise ECheckError.Create('Ожидалось '+Expect+', но найдено '+Found)
       else raise ECheckError.Create(Expect);
//  Inc(Pos);
  AlreadyError:=true;
end;

procedure RunTimeError(Error: string);// генерация ошибки
begin
  if not AlreadyError
  then raise ERunTimeError.Create('Ошибка времени выполнения: '#10#13'  '+Error);
//  Inc(Pos);
  AlreadyError:=true;
end;

function GetVarValue(Vars: TVars; Name: string; ArrIndex: TList): TValue;
var
  i, VarNo: LongInt;
  PlainNo: Cardinal;
  q: LongInt;
  _Var: TVar;
  Num: integer;

begin
  if ArrIndex=nil
  then ArrIndex:=TList.Create;

  if Vars.Count=0
  then begin
         Result._Type:=tyReal;
         Result.Str:='';
         Result.Real:=0;
         Exit;
       end;

  VarNo:=0;
  while UpperCase(TVar(Vars[VarNo]^).Name)<>UpperCase(Name)
  do begin
       Inc(VarNo);
       if VarNo=Vars.Count
       then begin
              Result._Type:=tyReal;
              Result.Str:='';
              Result.Real:=0;
              Exit;
            end;
     end;

  _Var:=TVar(Vars[VarNo]^);

  if (_Var.Value._Type=tyStr) and (_Var.Sizes.Count=0) and (ArrIndex.Count=1)  // Обработка выбора символа строки 
  then begin
         Num:=integer(ArrIndex[0]^);
         if (Num>Length(_Var.Value.Str)) or (Num<1) 
         then RunTimeError('Выход за пределы строки');
         Result._Type:=tyStr;
         Result.Str:=_Var.Value.Str[integer(ArrIndex[0]^)];
         Exit;
       end;

  if (_Var.Sizes.Count=0) xor (ArrIndex.Count=0) then
  begin
    RunTimeError('Ошибка указания индекса массива');
    Exit;
  end;

  if ArrIndex.Count=0
  then Result:=_Var.Value
  else begin
         if ArrIndex.Count<>integer(_Var.Sizes.Count)
         then begin
                RunTimeError('Несоответствие количества индексов массива');
                Result._Type:=tyReal;
                Result.Str:='';
                Result.Real:=0;
                Exit;
              end;

         for i:=0 to ArrIndex.Count-1
         do if integer(ArrIndex[i]^)>integer(_Var.Sizes[i]^)-1
            then begin
                   RunTimeError('Выход за пределы массива');
                   Result._Type:=tyReal;
                   Result.Str:='';
                   Result.Real:=0;
                   Exit;
                 end;

         PlainNo:=0;
         q:=1;
         for i:=0 to _Var.Sizes.Count-1
         do begin
              Inc(PlainNo, q*integer(ArrIndex[i]^));
              q:=q*integer(_Var.Sizes[i]^);
            end;
         Result:=TValue(_Var.Arr[PlainNo]^);
       end;
end;

function GetVarIndex(Vars: TVars; Name: string): integer;
var
  VarNo: LongInt;
  
begin
  if Vars.Count=0
  then begin
         Result:=-1;
         Exit;
       end;

  VarNo:=0;
  while UpperCase(TVar(Vars[VarNo]^).Name)<>UpperCase(Name)
  do begin
       Inc(VarNo);
       if VarNo=Vars.Count
       then begin
              Result:=-1;
              Exit;
            end;
     end;
   Result:=VarNo;
end;

procedure SetVarValue(Vars: TVars; Name: string; ArrIndex: TList; Value: TValue);
var
  i, VarNo: LongInt;
  PlainNo: Cardinal;
  q: LongInt;
  myVar: PVar;
  Num: integer;

begin
  if ArrIndex=nil
  then ArrIndex:=TList.Create;

  VarNo:=0;
  New(myVar);
  if Vars.Count=0
  then VarNo:=-1
  else while UpperCase(TVar(Vars[VarNo]^).Name)<>UpperCase(Name)
       do begin
            Inc(VarNo);
            if VarNo=Vars.Count
            then begin
                   VarNo:=-1;
                   Break;
                 end;
          end;

  if VarNo<>-1
  then myVar:=Vars[VarNo]
  else begin
         myVar^.Name:=Name;
         myVar^.Value._Type:=tyReal;
         myVar^.Value.Str:='';
         myVar^.Value.Real:=0;
         myVar^.Sizes:=TList.Create;
         myVar^.Arr:=TList.Create;
         {VarNo:=}Vars.Add(myVar);
       end;

  if (myVar.Value._Type=tyStr) and (myVar.Sizes.Count=0) and (ArrIndex.Count=1)
  then begin
         if Value._Type<>tyStr
         then RunTimeError('Нельзя присвоить символам число');
         Num:=integer(ArrIndex[0]^);
         if (Num+Length(Value.Str)>Length(myVar.Value.Str)+1) or (Num<1)
         then RunTimeError('Выход за пределы строки');
         for i:=1 to Length(Value.Str)
         do myVar.Value.Str[Num+i]:=Value.Str[i];
         Exit;
       end;

  if (myVar.Sizes.Count=0) xor (ArrIndex.Count=0) then
  begin
    RunTimeError('Ошибка указания индекса массива');
    Exit;
  end;

  if ArrIndex.Count=0
  then myVar.Value:=Value
  else begin
         if ArrIndex.Count<>integer(myVar.Sizes.Count)
         then begin
                RunTimeError('Несоответствие количества индексов массива');
                Exit;
              end;

         for i:=0 to ArrIndex.Count-1
         do if integer(ArrIndex[i]^)>integer(myVar.Sizes[i]^)-1
            then begin
                   RunTimeError('Выход за пределы массива');
                   Exit;
                 end;

         PlainNo:=0;
         q:=1;
         for i:=0 to myVar.Sizes.Count-1
         do begin
              Inc(PlainNo, q*integer(ArrIndex[i]^));
              q:=q*integer(myVar.Sizes[i]^);
            end;
         TValue(myVar.Arr[PlainNo]^):=Value;
       end;
end;

function CheckExpr(Lexemes: PLexemes): boolean; // Проверка корректности выражения
  procedure Expr; forward;

  procedure Element;// Проверка элемента
  begin
    if Lexemes^[Pos]._Type=lxName
    then begin
           Inc(Pos);
           if Lexemes^[Pos]._Type=lxLBracket
           then begin
                  Inc(Pos);
                  if Lexemes^[Pos]._Type<>lxRBracket
                  then begin
                         Expr;
                         while Lexemes^[Pos]._Type<>lxRBracket
                         do begin
                              if Lexemes^[Pos]._Type<>lxComma
                              then CheckError(true, 'запятая или скобка', Lex2Str[Lexemes^[Pos]._Type]);
                              Inc(Pos);
                              Expr;
                            end;
                  end;
                  Inc(Pos);
                end
           else begin
                  if Lexemes^[Pos]._Type=lxLSBracket
                  then begin
                         Inc(Pos);
                         Expr;
                         while Lexemes^[Pos]._Type<>lxRSBracket
                         do begin
                              if Lexemes^[Pos]._Type<>lxComma
                              then CheckError(true, 'запятая или квадратная скобка', Lex2Str[Lexemes^[Pos]._Type]);
                              Inc(Pos);
                              Expr;
                            end;
                         Inc(Pos);
                       end;
                end;
         end
    else if Lexemes^[Pos]._Type=lxNumber
         then Inc(Pos)
         else if Lexemes^[Pos]._Type in [lxPlus, lxMinus]
              then begin
                     Inc(Pos);
                     Element;
                   end
              else if Lexemes^[Pos]._Type=lxString
                   then begin
                          Inc(Pos);
                        end
                   else if Lexemes^[Pos]._Type=lxLBracket
                        then begin
                               Inc(Pos);
                               Expr;
                               if Lexemes^[Pos]._Type=lxRBracket
                               then Inc(Pos)
                               else CheckError(true, ')', Lex2Str[Lexemes^[Pos]._Type]);
                             end
                        else if Lexemes^[Pos]._Type=lxAmpersand
                             then begin
                                    Inc(Pos);
                                    if Lexemes^[Pos]._Type=lxName
                                    then Inc(Pos)
                                    else CheckError(true, 'имя', Lex2Str[Lexemes^[Pos]._Type]);
                                  end
                             else begin
                                    CheckError(true, 'элемент', Lex2Str[Lexemes^[Pos]._Type]);
                                    Inc(Pos);
                                  end;
  end;

  procedure Power;// Проверка операций возведение в степень
  begin
    Element;
    while Lexemes^[Pos]._Type = lxPower
    do begin
         Inc(Pos);
         Element;
       end;
  end;

  procedure Term;// Проверка произведений
  begin
    Power;
    while Lexemes^[Pos]._Type in [lxAsterisk, lxSlash, lxDiv, lxMod]
    do begin
         Inc(Pos);
         Power;
       end;
  end;

  procedure SimpleExpr;// Проверка прост. выр. (без сравнений)
  begin
    Term;
    while Lexemes^[Pos]._Type in [lxPlus, lxMinus]
    do begin
         Inc(Pos);
         Term;
       end;
  end;

  procedure IfExpr;// Проверка выражения с условием
  begin
    SimpleExpr;
    if Lexemes^[Pos]._Type in [lxLess, lxLessOrEqual, lxGreat, lxGreatOrEqual, lxEqual, lxNotEqual]
    then begin
           Inc(Pos);
           SimpleExpr;
         end;
  end;

  procedure notExpr;// Проверка IfExpr+not
  begin
    if Lexemes^[Pos]._Type=lxNot
    then Inc(Pos);
    IfExpr;
  end;

  procedure andExpr;// Проверка notExpr+and
  begin
    notExpr;
    while Lexemes^[Pos]._Type=lxAnd
    do begin
         Inc(Pos);
         notExpr;
       end;
  end;

  procedure Expr;// Проверка andExpr+or+xor
  begin
    andExpr;
    while Lexemes^[Pos]._Type in [lxOr, lxXor]
    do begin
         Inc(Pos);
         andExpr;
       end;
  end;

begin
  AlreadyError:=false;
  Expr;
  Result:=not AlreadyError;
end;

function ExecExpr(Lexemes: PLexemes; Vars: TVars): TValue;

  function Expr: TValue; forward;

  function Element: TValue;// Вычисление элемента
  var
    Name: string;
    tmp: TValue;
    ArrIndex: TList;
    pInt: ^Integer;
    pVal: PValue;

  begin
    if Lexemes^[Pos]._Type=lxName // Возвращаем значение переменной
    then begin
           Name:=Lexemes^[Pos].Value;
           Inc(Pos);
           ArrIndex:=TList.Create;
           if Lexemes^[Pos]._Type=lxLBracket
           then if Assigned(GetFuncValue)
                then begin
                       Inc(Pos);
                       if Lexemes^[Pos]._Type<>lxRBracket
                       then begin
                              New(pVal);
                              pVal^:=Expr;
                              ArrIndex.Add(pVal);
                              while Lexemes^[Pos]._Type<>lxRBracket
                              do begin
                                   Inc(Pos);
                                   New(pVal);
                                   pVal^:=Expr;
                                   ArrIndex.Add(pVal);
                                 end;
                       end;
                       Inc(Pos);
                       Result:=GetFuncValue(Vars, Name, ArrIndex);
                     end
                else RunTimeError('Внутренняя ошибка: не установлена процедура обработки функций')
           else begin
                  if Lexemes^[Pos]._Type=lxLSBracket
                  then begin
                         Inc(Pos);
                         New(pInt);
                         tmp:=Expr;
                         if (tmp._Type<>tyReal) or (tmp.Real<0)
                         then RunTimeError('Индекс элемента или символа должен быть целым неотрицательным числом');
                         pInt^:=Trunc(tmp.Real);
                         ArrIndex.Add(pInt);
                         while Lexemes^[Pos]._Type<>lxRSBracket
                         do begin
                              Inc(Pos);
                              New(pInt);
                              tmp:=Expr;
                              if (tmp._Type<>tyReal) or (tmp.Real<0)
                              then RunTimeError('Индекс элемента должен быть целым неотрицательным числом');
                              pInt^:=Trunc(tmp.Real);
                              ArrIndex.Add(pInt);
                            end;
                         Inc(Pos);
                       end;
                  Result:=GetVarValue(Vars, Name, ArrIndex);
                end;
         end
    else if Lexemes^[Pos]._Type=lxNumber
         then begin
                Result._Type:=tyReal;
                Result.Real:=Lexemes^[Pos].Value;
                Inc(Pos)
              end
         else if Lexemes^[Pos]._Type in [lxPlus, lxMinus]
              then begin
                     Inc(Pos);
                     case Lexemes^[Pos-1]._Type of
                       lxPlus : Result:=Element;
                       lxMinus: begin
                                  tmp:=Element;
                                  if tmp._Type<>tyReal
                                  then begin
                                         RunTimeError('Недопустимая операция: Отрицательная строка');
                                         Inc(Pos);
                                       end;
                                  Result._Type:=tyReal;
                                  Result.Real:=-tmp.Real;
                                end;
                     end;
                   end
              else if Lexemes^[Pos]._Type=lxString
                   then begin
                          Result._Type:=tyStr;
                          Result.Str:=Lexemes^[Pos].Value;
                          Inc(Pos);
                        end
                   else if Lexemes^[Pos]._Type=lxLBracket
                        then begin
                               Inc(Pos);
                               Result:=Expr;
                               Inc(Pos)
                             end
                        else if Lexemes^[Pos]._Type=lxAmpersand
                             then begin
                                    Inc(Pos);
                                    Result._Type:=tyStr;
                                    Result.Str:=Lexemes^[Pos].Value;
                                    Inc(Pos);
                                  end;

  end;

  function Power: TValue;//Вычисление выражений со степенями
  var
    tmp: TValue;

  begin
    Result:=Element;
    while Lexemes^[Pos]._Type = lxPower
    do begin
         Inc(Pos);
         tmp:=Element;
         if (Result._Type<>tyReal) or (tmp._Type<>tyReal)
         then RunTimeError('Операция возведения в степень над строками недопустима');
{         x:=Result.Real; y:=tmp.Real;

         r:=0;
         if x>0
         then r:=Exp(Ln(x)*y)
         else if x=0
              then if y>0
                   then r:=0
                   else RunTimeError('Нельзя возводить ноль в неположительную степень')
              else if Frac(y)=0
                   then r:=IfThen(Trunc(Abs(y)) mod 2 =0, Exp(Ln(Abs(x))*y), -Exp(Ln(Abs(x))*y))
                   else RunTimeError('Нельзя возводить отрицательное число в нецелую степень');
         Result.Real:=r;}
         Result.Real:=Math.Power(Result.Real, tmp.Real);
       end;
  end;

  function Term: TValue;// Вычисление произведений
  var
    tmp: TValue;
    Op: TLexeme;

  begin
    Result:=Power;
    while Lexemes^[Pos]._Type in [lxAsterisk, lxSlash, lxDiv, lxMod]
    do begin
         Op:=Lexemes^[Pos]._Type;
         Inc(Pos);
         tmp:=Power;
         if (Result._Type<>tyReal) or (tmp._Type<>tyReal)
         then RunTimeError('Недопустимая операция: Умножение/Деление строк');
         case Op of
           lxAsterisk: Result.Real:=Result.Real*tmp.Real;
              lxSlash: Result.Real:=Result.Real/tmp.Real;
                lxDiv: Result.Real:=Trunc(Result.Real) div Trunc(tmp.Real);
                lxMod: Result.Real:=Trunc(Result.Real) mod Trunc(tmp.Real);
         end;
         Result._Type:=tyReal;
       end;
  end;

  function SimpleExpr: TValue;// Вычисление прост. выр. (без сравнений)
  var
    tmp: TValue;

  begin
    Result:=Term;
    while Lexemes^[Pos]._Type in [lxPlus, lxMinus]
    do begin
         Inc(Pos);
         case Lexemes^[Pos-1]._Type of
            lxPlus: begin
                      tmp:=Term;
                      if tmp._Type<>Result._Type
                      then begin
                             RunTimeError('Недопустимая операция: Сложение значений разных типов!');
                             Inc(Pos);
                           end;
                      Result.Str:=Result.Str+tmp.Str;
                      Result.Real:=Result.Real+tmp.Real;
                    end;
           lxMinus: begin
                      tmp:=Term;
                      if (tmp._Type<>tyReal) or (Result._Type<>tyReal)
                      then begin
                             RunTimeError('Вычитания над строками недопустимы');
                             Inc(Pos);
                           end;
                      Result.Real:=Result.Real-tmp.Real;
                      Result._Type:=tyReal;
                    end;
         end;
       end;
  end;

  function IfExpr: TValue;// Вычисление выражения с условием
  var
    tmp: TValue;
    Op: TLexeme;

  begin
    Result:=SimpleExpr;
    if Lexemes^[Pos]._Type in [lxLess, lxLessOrEqual, lxGreat, lxGreatOrEqual, lxEqual, lxNotEqual]
    then begin
           Op:=Lexemes^[Pos]._Type;
           Inc(Pos);
           tmp:=SimpleExpr;

           if Result._Type<>tmp._Type
           then begin
                  RunTimeError('Недопустимая операция: Сравнение разных типов');
                  Inc(Pos);
                end;

           if Result._Type=tyReal
           then case Op of
                          lxLess: if Result.Real<tmp.Real
                                  then Result.Real:=1
                                  else Result.Real:=0;
                   lxLessOrEqual: if Result.Real<=tmp.Real
                                  then Result.Real:=1
                                  else Result.Real:=0;
                         lxGreat: if Result.Real>tmp.Real
                                  then Result.Real:=1
                                  else Result.Real:=0;
                  lxGreatOrEqual: if Result.Real>=tmp.Real
                                  then Result.Real:=1
                                  else Result.Real:=0;
                         lxEqual: if Result.Real=tmp.Real
                                  then Result.Real:=1
                                  else Result.Real:=0;
                      lxNotEqual: if Result.Real<>tmp.Real
                                  then Result.Real:=1
                                  else Result.Real:=0;
                 end
           else case Op of
                         lxLess: if Result.Str<tmp.Str
                                 then Result.Real:=1
                                 else Result.Real:=0;
                  lxLessOrEqual: if Result.Str<=tmp.Str
                                 then Result.Real:=1
                                 else Result.Real:=0;
                        lxGreat: if Result.Str>tmp.Str
                                 then Result.Real:=1
                                 else Result.Real:=0;
                 lxGreatOrEqual: if Result.Str>=tmp.Str
                                 then Result.Real:=1
                                 else Result.Real:=0;
                        lxEqual: if Result.Str=tmp.Str
                                 then Result.Real:=1
                                 else Result.Real:=0;
                     lxNotEqual: if Result.Str<>tmp.Str
                                 then Result.Real:=1
                                 else Result.Real:=0;
                end;
           Result._Type:=tyReal;
         end;
  end;

  function notExpr: TValue;// Вычисление IfExpr+not
  begin
    if Lexemes^[Pos]._Type=lxNot
    then begin
           Inc(Pos);
           if Result._Type<>tyReal
           then begin
                  RunTimeError('Операции And, Or, Xor, Not над строками недопустимы');
                  Inc(Pos);
                end;
           if IfExpr.Real=0
           then Result.Real:=1
           else Result.Real:=0;
           Result._Type:=tyReal;
         end
    else Result:=IfExpr;
  end;

  function andExpr: TValue;// Вычисление notExpr+and
  var
    tmp: TValue;

  begin
    Result:=notExpr;
    while Lexemes^[Pos]._Type=lxAnd
    do begin
         Inc(Pos);
         tmp:=notExpr;
         if (Result._Type<>tyReal) or (tmp._Type<>tyReal)
         then begin
                RunTimeError('Операции And, Or, Xor, Not над строками недопустимы');
                Inc(Pos);
              end;
         if (Result.Real<>0) and (tmp.Real<>0)
         then Result.Real:=1
         else Result.Real:=0;
         Result._Type:=tyReal;
       end;
  end;

  function Expr: TValue;// Вычисление andExpr+or+xor
  var
    tmp: TValue;
    Op: TLexeme;

  begin
    Result:=andExpr;
    while Lexemes^[Pos]._Type in [lxOr, lxXor]
    do begin
         Inc(Pos);
         Op:=Lexemes^[Pos-1]._Type;
         tmp:=andExpr;
         if (Result._Type<>tyReal) or (tmp._Type<>tyReal)
         then begin
                RunTimeError('Операции And, Or, Xor, Not над строками недопустимы');
                Inc(Pos);
              end;
         case Op of
            lxOr: if (Result.Real<>0) or (tmp.Real<>0)
                  then Result.Real:=1
                  else Result.Real:=0;
           lxXor: if (Result.Real<>0) xor (tmp.Real<>0)
                  then Result.Real:=1
                  else Result.Real:=0;
         end;
         Result._Type:=tyReal;
       end;
  end;

begin
  Result:=Expr;
end;

function CheckOperator(Lexemes: PLexemes): boolean; // Проверка списка операторов
var
  Bracket: TLexeme;

  procedure Arr; // Проверка декларации массива
  begin
    Inc(Pos);
    if Lexemes^[Pos]._Type<>lxName
    then CheckError(true, 'имя массива', Lex2Str[Lexemes^[Pos]._Type])
    else begin
           Inc(Pos);
           if Lexemes^[Pos]._Type<>lxLSBracket
           then CheckError(true, '[', Lex2Str[Lexemes^[Pos]._Type])
           else begin
                  Inc(Pos);
                  CheckExpr(Lexemes);
                  while Lexemes^[Pos]._Type<>lxRSBracket
                  do begin
                       if Lexemes^[Pos]._Type<>lxComma
                       then CheckError(true, 'запятая', Lex2Str[Lexemes^[Pos]._type]);
                       Inc(Pos);
                       CheckExpr(Lexemes);
                     end;
                  Inc(Pos);
                end;
         end;
  end;

  procedure Oper; // Проверка одного оператора
  begin
    if Lexemes^[Pos]._Type in [lxUndef, lxSemicolon]
    then begin
           Inc(Pos);
           Exit;
         end;

    if Lexemes^[Pos]._Type=lxArr
    then Arr
    else if Lexemes^[Pos]._Type<>lxName
         then begin
                CheckError(true, 'имя', Lex2Str[Lexemes^[Pos]._Type]);
                Exit;
              end
         else begin
                Inc(Pos);
                if Lexemes^[Pos]._Type in [lxLBracket, lxLSBracket]
                then begin
                       if Lexemes^[Pos]._Type=lxLBracket
                       then Bracket:=lxRBracket
                       else Bracket:=lxRSBracket;
                       while Lexemes^[Pos]._Type<>Bracket
                       do begin
                            Inc(Pos);
                            CheckExpr(Lexemes);
                            if not (Lexemes^[Pos]._Type in [lxComma, Bracket])
                            then CheckError(true, 'запятая или скобка', Lex2Str[Lexemes^[Pos]._Type]);
                          end;
                       Inc(Pos);
                     end;
                if Bracket=lxRBracket
                then Exit;
                if Lexemes^[Pos]._Type<>lxAssignment
                then begin
                       CheckError(true, 'присваивание', Lex2Str[Lexemes^[Pos]._Type]);
                     end;
                Inc(Pos);
                CheckExpr(Lexemes);
              end;
  end;

  procedure Opers; // Проверка списка операторов
  begin
    Oper;
    while Lexemes^[Pos]._Type=lxSemicolon
    do begin
         Inc(Pos);
         Oper;
       end;
    if Lexemes^[Pos]._Type<>lxUndef
    then CheckError(false, 'Не хватает ; после оператора');
  end;

begin
  Pos:=1;
  AlreadyError:=false;
  Opers;
  Result:=not AlreadyError;
end;

procedure ExecOperator(Lexemes: PLexemes; Vars: TVars); // Обработка списка операторов

  procedure Arr; // Обработка декларации массива
  var
    Name: string;
    VarNo: LongInt;
    myVar: PVar;
    tmpExpr: TValue;
    pInt: ^Integer;
    pVal: PValue;
    i, MultSizes: LongInt;

  begin
    Inc(Pos);
    Name:=Lexemes^[Pos].Value;
    Inc(Pos);
    VarNo:=0;
    if Vars.Count=0
    then VarNo:=-1
    else while UpperCase(TVar(Vars[VarNo]^).Name)<>UpperCase(Name)
         do begin
              Inc(VarNo);
              if VarNo=Vars.Count
              then begin
                     VarNo:=-1;
                     Break;
                   end;
            end;
    if VarNo<>-1
    then begin
           myVar:=Vars[VarNo];
           myVar.Sizes.Clear;
           for i:=0 to myVar.Arr.Count-1
           do Dispose(PValue(myVar.Arr[i]));
           myVar.Arr.Clear;
         end
    else begin
           New(myVar);
           myVar^.Name:=Name;
           myVar^.Sizes:=TList.Create;
           myVar^.Arr:=TList.Create;
           Vars.Add(myVar);
         end;

    Inc(Pos);
    MultSizes:=1;

    tmpExpr:=ExecExpr(Lexemes, Vars);
    if (tmpExpr._Type<>tyReal) or (tmpExpr.Real<0)
    then begin
           RunTimeError('Индекс массива должен быть целым неотрицательным числом');
           Exit;
         end;
    New(pInt);
    pInt^:=Trunc(tmpExpr.Real);
    myVar.Sizes.Add(pInt);
    MultSizes:=MultSizes*pInt^;
    while Lexemes^[Pos]._Type<>lxRSBracket
    do begin
         Inc(Pos);
         New(pInt);
         tmpExpr:=ExecExpr(Lexemes, Vars);
         if (tmpExpr._Type<>tyReal) or (tmpExpr.Real<0)
         then begin
                RunTimeError('Индекс массива должен быть целым неотрицательным числом');
                Exit;
              end;
         pInt^:=Trunc(tmpExpr.Real);
         myVar.Sizes.Add(pInt);
         MultSizes:=MultSizes*pInt^;
       end;
    Inc(Pos);

    myVar.Arr.Clear;
    for i:=1 to MultSizes
    do begin
         New(pVal);
         pVal^._Type:=tyReal;
         pVal^.Str:='';
         pVal^.Real:=0;
         myVar.Arr.Add(pVal)
       end;
  end;

  procedure Oper; // Обработка одного оператора
  var
    Name: string;
    ArrIndex: TList;
    Value: TValue;
    pInt: ^Integer;
    tmp: TValue;
    FirstPos: Cardinal;

  begin
    FirstPos:=Pos;
    
    if Lexemes^[Pos]._Type in [lxUndef, lxSemicolon]
    then begin
           Inc(Pos);     
           Exit;
         end;

    if Lexemes^[Pos]._Type=lxArr
    then Arr
    else begin
           Name:=Lexemes^[Pos].Value;
           Inc(Pos);
           if Lexemes^[Pos]._Type=lxLBracket
           then begin
                  Pos:=FirstPos;
                  ExecExpr(Lexemes, Vars);
                  Exit;
                end;
           ArrIndex:=TList.Create;
           if Lexemes^[Pos]._Type=lxLSBracket
           then begin
                  Inc(Pos);
                  ArrIndex.Clear;
                  New(pInt);
                  tmp:=ExecExpr(Lexemes, Vars);
                  if (tmp._Type<>tyReal) or (tmp.Real<0)
                  then begin
                         RunTimeError('Индекс массива должен быть целым неотрицательным числом');
                         Exit;
                       end;
                  pInt^:=Trunc(tmp.Real);
                  ArrIndex.Add(pInt);
                  while Lexemes^[Pos]._Type<>lxRSBracket
                  do begin
                       Inc(Pos);
                       New(pInt);
                       tmp:=ExecExpr(Lexemes, Vars);
                       if (tmp._Type<>tyReal) or (tmp.Real<0)
                       then begin
                              RunTimeError('Индекс массива должен быть целым неотрицательным числом');
                              Exit;
                            end;
                       pInt^:=Trunc(tmp.Real);
                       ArrIndex.Add(pInt);
                     end;
                  Inc(Pos);
                end;
           Inc(Pos);
           Value:=ExecExpr(Lexemes, Vars);
           SetVarValue(Vars, Name, ArrIndex, Value);
           ArrIndex.Free;
         end;
  end;

begin
  Pos:=1;
  Oper;
  while Lexemes^[Pos]._Type=lxSemicolon
  do begin
       Inc(Pos);
       Oper;
     end;
end;

function GetFuncResult(Vars: TVars; Name: string; Params: TList): TValue;
type FuncType=(ftMath, ftString, ftOther);
     Func=record
            Name: string;
            _Type: FuncType;
          end;
const Funcs: array [1..42] of Func=
      ((Name: 'Sin';  _Type: ftMath),
       (Name: 'Cos';  _Type: ftMath),
       (Name: 'Tan'; _Type: ftMath),
       (Name: 'ArcSin'; _Type: ftMath),
       (Name: 'ArcCos'; _Type: ftMath),
       (Name: 'ArcTan'; _Type: ftMath),
       (Name: 'Sqr';  _Type: ftMath),
       (Name: 'Sqrt'; _Type: ftMath),
       (Name: 'Abs'; _Type: ftMath),    // ADDED IN VERSION 3.4
       (Name: 'Sign'; _Type: ftMath),    // ADDED IN VERSION 3.4

       (Name: 'Round'; _Type: ftMath),  //
       (Name: 'Int'; _Type: ftMath),    //
       (Name: 'Floor'; _Type: ftMath),  //
       (Name: 'Ceil'; _Type: ftMath),   // ADDED IN VERSION 3.2a
       (Name: 'Char'; _Type: ftOther),  //
       (Name: 'Order'; _Type: ftOther), //

       (Name: 'pi'; _Type: ftOther),
       (Name: 'Exp'; _Type: ftMath),
       (Name: 'Ln'; _Type: ftMath),
       (Name: 'Log'; _Type: ftOther),

       (Name: 'Random'; _Type: ftOther),

       (Name: 'Length'; _Type: ftOther),
       (Name: 'Pos';  _Type: ftOther),
       (Name: 'UpCase';  _Type: ftString),
       (Name: 'DownCase'; _Type: ftString),
       (Name: 'Message'; _Type: ftString),
       (Name: 'Insert'; _Type: ftOther),
       (Name: 'Delete'; _Type: ftOther),
       (Name: 'Copy';   _Type: ftOther),
       (Name: 'Str';   _Type: ftOther),
       (Name: 'Val';   _Type: ftOther),

       (Name: 'Calc';  _Type: ftOther),
       (Name: 'Exec';  _Type: ftString),

       (Name: 'Open'; _Type: ftOther),
       (Name: 'Close'; _Type: ftMath),
       (Name: 'Read'; _Type: ftOther),
       (Name: 'EOF'; _Type: ftMath),
       (Name: 'Write'; _Type: ftOther),
       (Name: 'WriteOver'; _Type: ftOther),
       (Name: 'Seek'; _Type: ftOther),
       (Name: 'FileSize'; _Type: ftMath),
       (Name: 'FilePos'; _Type: ftMath));

var
  i, j: integer;
  s: string;
  n: string;
  P: array [1..100] of TValue;
  Lines: TStringList;
  Lexs: PLexemes;
  XVars: TVars;
  tmpPos: Cardinal;

  File_Rec: PFile_Rec;

  function MakeVal(s: string): TValue; overload;
  begin
    Result._Type:=tyStr;
    Result.Str:=s;
  end;
  function MakeVal(r: TReal): TValue; overload;
  begin
    Result._Type:=tyReal;
    Result.Real:=r;
  end;

  procedure Check(count: integer; types: array of TValType);
  var
    f: boolean;
    i: integer;

  begin
    f:=true;
    if Params.Count<>count
    then f:=false;
    i:=0;
    while f and (i<count)
    do begin
         if (P[i+1]._Type<>types[i])
         then f:=false;
         Inc(i);
       end;  
    if not f
    then RunTimeError('Неправильный список параметров функции '+Name);
  end;

  procedure CheckFileName(Path: string);
  const Space=[#32, #9, #13, #10];
  var
    Depth: integer;
    Cur: integer;
    s: string;

    procedure Error;
    begin
      RunTimeError('Неверное имя файла или ошибка доступа');
    end;

    procedure Skip;
    begin
      while CharInSet(Path[Cur], Space) and (Cur<Length(Path))
      do Inc(Cur);
    end;

    function GetNextDir: string;
    begin
      Result:='';
      Skip;
      while (Cur<=Length(Path)) and (Path[Cur]<>'\')
      do begin
           Result:=Result+Path[Cur];
           Inc(Cur);
         end;
      Inc(Cur);
      while CharInSet(Result[Length(Result)], Space)
      do Delete(Result, Length(Result), 1);
    end;

  begin
    if System.Pos(':', Path)>0
    then Error;
    Cur:=1;
    Skip;
    if Path[Cur]='\'
    then Error;
    Depth:=0;
    while Cur<=Length(Path)
    do begin
         s:=GetNextDir;
         if s<>'.'
         then if s<>'..'
              then Inc(Depth)
              else Dec(Depth);
         if Depth<0
         then Break;
       end;
    if Depth<1
    then Error;
  end;

begin
  for i:=Low(Funcs) to High(Funcs) 
  do if UpperCase(Name)=UpperCase(Funcs[i].Name)
     then Break;

  if i>High(Funcs)
  then begin
         RunTimeError('Неизвестная функция: '+Name);
         Exit;
       end;

  for j:=0 to Params.Count-1
  do P[j+1]:=TValue(Params[j]^);

  case Funcs[i]._Type of
    ftMath  : Check(1, [tyReal]);
    ftString: Check(1, [tyStr]);
  end;

  n:=LowerCase(Name);
  if n='sin'
  then Result:=MakeVal(Sin(P[1].Real*pi/180));
  if n='cos'
  then Result:=MakeVal(Cos(P[1].Real*pi/180));
  if n='tan'
  then Result:=MakeVal(Tan(P[1].Real*pi/180));
  if n='arcsin'
  then Result:=MakeVal(arcSin(P[1].Real)*180/pi);
  if n='arccos'
  then Result:=MakeVal(arcCos(P[1].Real)*180/pi);
  if n='arctan'
  then Result:=MakeVal(arcTan(P[1].Real)*180/pi);
  if n='sqr'
  then Result:=MakeVal(Sqr(P[1].Real));
  if n='sqrt'
  then Result:=MakeVal(Sqrt(P[1].Real));
  if n='abs'
  then Result:=MakeVal(Abs(P[1].Real));
  if n='sign'
  then Result:=MakeVal(Sign(P[1].Real));
  if n='pos'
  then begin
         Check(2, [tyStr, tyStr]);
         Result:=MakeVal(System.Pos(P[1].Str, P[2].Str));
       end;
  if n='upcase'
  then Result:=MakeVal(AnsiUpperCase(P[1].Str));
  if n='downcase'
  then Result:=MakeVal(AnsiLowerCase(P[1].Str));
  if n='message'
  then begin
         AutoPause;
         MessageBox(MainForm.Handle, PChar(P[1].Str), 'Конструктор блок-схем', MB_ICONINFORMATION);
         AutoResume;
         Result:=MakeVal(P[1].Str);
       end;
  if n='insert'
  then begin
         Check(3, [tyStr, tyStr, tyReal]);
         s:=P[2].Str;
         Insert(P[1].Str, s, Trunc(P[3].Real));
         Result:=MakeVal(s);
       end;
  if n='delete'
  then begin
         Check(3, [tyStr, tyReal, tyReal]);
         s:=P[1].Str;
         Delete(s, Trunc(P[2].Real), Trunc(P[3].Real));
         Result:=MakeVal(s);
       end;
  if n='copy'
  then begin
         Check(3, [tyStr, tyReal, tyReal]);
         s:=P[1].Str;
         s:=Copy(s, Trunc(P[2].Real), Trunc(P[3].Real));
         Result:=MakeVal(s);
       end;
  if n='str'
  then begin
         Check(1, [tyReal]);
         s:=FloatToStr(P[1].Real);
         Result:=MakeVal(s);
       end;
  if n='length'
  then begin
         Check(1, [tyStr]);
         Result:=MakeVal(Length(P[1].Str));
       end;
  if n='val'
  then begin
         Check(1, [tyStr]);
         try
           Result:=MakeVal(StrToFloat(P[1].Str));
         except
           on EConvertError
           do RunTimeError('Строка '''+P[1].Str+''' не переводится в число');
         end;
       end;

  if n='random'
  then begin
         if Params.Count=0
         then begin
                Result:=MakeVal(Random);
                Exit;
              end;
         if Params.Count=1
         then begin
                Check(1, [tyReal]);
                Result:=MakeVal(Random(Trunc(P[1].Real)));
                Exit;
              end;
         Check(0, []);
       end;

  if n='calc'
  then begin
         if not (Params.Count in [1, 2]) or (P[1]._Type<>tyStr)
         then RunTimeError('Неправильный список параметров функции Calc');
         Lines:=TStringList.Create;
         New(Lexs);
         XVars:=TVars.Create;
         tmpPos:=Pos;
         try
           if Params.Count = 2
           then SetVarValue(XVars, 'x', nil, P[2]);

           Lines.Add(P[1].Str);
           ReadBlock(Lines, Lexs);
           Pos:=1;
           CheckExpr(Lexs);
           Pos:=1;
           Result:=ExecExpr(Lexs, XVars);
         finally
           Pos:=tmpPos;
           XVars.Free;
           Dispose(Lexs);
           Lines.Free;
         end;
       end;
  if n='exec'
  then begin
         Lines:=TStringList.Create;
         New(Lexs);
         tmpPos:=Pos;
         try
           Lines.Add(P[1].Str);
           ReadBlock(Lines, Lexs);
           Pos:=1;
           CheckExpr(Lexs);
           Pos:=1;
           ExecOperator(Lexs, Vars);
         finally
           Pos:=tmpPos;
           Dispose(Lexs);
           Lines.Free;
           Result:=MakeVal(0);
         end;
       end;

  if n='open'
  then begin
         try
           Check(1, [tyStr]);
         except
           try
             Check(2, [tyStr, tyReal]);
           except
             RunTimeError('Неправильный список аргументоф функции Open');
           end;
         end;

         CheckFileName(P[1].Str);

         // Параметр 2:  0=reset   1=rewrite   2=append
         if Params.Count=1
         then P[2]:=MakeVal(0);

         New(File_Rec);
         File_Rec.Strings:=TStringList.Create;

         try
           if Trunc(P[2].Real) in [0, 2]
           then File_Rec.Strings.LoadFromFile(P[1].Str);
         except
           RuntimeError('Ошибка при открытии файла');
         end;

         File_Rec.Write:=not (P[2].Real=0);
         File_Rec.FileName:=P[1].Str;
         File_Rec.Pos:=IfThen(Trunc(P[2].Real)=2, File_Rec.Strings.Count, 0);
         File_Rec.ID:=CurFile;
         Inc(CurFile);

         Files.Add(File_Rec);

         Result:=MakeVal(File_Rec.ID);
       end;
  if n='close'
  then begin
         try
           i:=0;
           j:=0;
           while i<Files.Count
           do begin
                File_Rec:=Files[i];
                if File_Rec.ID=P[1].Real
                then begin
                       if File_Rec.Write
                       then File_Rec.Strings.SaveToFile(File_Rec.FileName);
                       File_Rec.Strings.Free;       
                       Files.Delete(i);
                       Inc(j);
                     end
                else Inc(i);
              end;
           Result:=MakeVal(j);
         except
           RunTimeError('Ошибка при закрытии файла');
         end;
       end;
  if n='read'
  then begin
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then begin
                   Result:=MakeVal(PFile_Rec(Files[i]).Strings[PFile_Rec(Files[i]).Pos]);
                   Inc(PFile_Rec(Files[i]).Pos);
                 end;
       end;
  if n='eof'
  then begin
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then Result:=MakeVal(IfThen(PFile_Rec(Files[i]).Pos>=PFile_Rec(Files[i]).Strings.Count, 1, 0));
       end;
  if n='write'
  then begin
         if (Params.Count<1) or (P[1]._Type<>tyReal)
         then RunTimeError('Неправильный список параметров функции Write');
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then begin
                   File_Rec:=Files[i];
                   s:='';
                   for j:=2 to Params.Count
                   do if P[j]._Type=tyStr
                      then s:=s+P[j].Str
                      else s:=s+FloatToStr(P[j].Real);
                   File_Rec.Strings.Insert(File_Rec.Pos, s);
                   Inc(File_Rec.Pos);
                 end;
         Result:=MakeVal(0);
       end;
  if n='writeover'
  then begin
         if (Params.Count<1) or (P[1]._Type<>tyReal)
         then RunTimeError('Неправильный список параметров функции WriteOver');
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then begin
                   File_Rec:=Files[i];
                   s:='';
                   for j:=2 to Params.Count
                   do if P[j]._Type=tyStr
                      then s:=s+P[j].Str
                      else s:=s+FloatToStr(P[j].Real);
//                   File_Rec.Strings.Insert(File_Rec.Pos, s);
                   if File_Rec.Pos<File_Rec.Strings.Count
                   then File_Rec.Strings[File_Rec.Pos]:=s
                   else File_Rec.Strings.Add(s);
                   Inc(File_Rec.Pos);
                 end;
         Result:=MakeVal(0);
       end;
  if n='seek'
  then begin
         Check(2, [tyReal, tyReal]);
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then PFile_Rec(Files[i]).Pos:=min(Trunc(P[2].Real), PFile_Rec(Files[i]).Strings.Count);
         Result:=MakeVal(0);
       end;
  if n='filesize'
  then begin
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then Result:=MakeVal(PFile_Rec(Files[i]).Strings.Count);
       end;
  if n='filepos'
  then begin
         for i:=0 to Files.Count-1
         do if PFile_Rec(Files[i]).ID=P[1].Real
            then Result:=MakeVal(PFile_Rec(Files[i]).Pos);
       end;

  if n='pi'
  then begin
         Check(0, []);
         Result:=MakeVal(pi);
       end;
  if n='exp'
  then Result:=MakeVal(Exp(P[1].Real));
  if n='ln'
  then Result:=MakeVal(Ln(P[1].Real));
  if n='log'
  then begin
         Check(2, [tyReal, tyReal]);
         Result:=MakeVal(LogN(P[1].Real, P[2].Real));
       end;

  if n='round'
  then Result:=MakeVal(Round(P[1].Real));
  if n='int'
  then Result:=MakeVal(Int(P[1].Real));
  if n='floor'
  then Result:=MakeVal(Floor(P[1].Real));
  if n='ceil'
  then Result:=MakeVal(Ceil(P[1].Real));

  if n='char'
  then begin
         Check(1, [tyReal]);
         Result:=MakeVal(char(Trunc(P[1].Real)));
       end;

  if n='order'
  then begin
         Check(1, [tyStr]);
         if Length(P[1].Str) < 1
         then RunTimeError('Аргумент функции Order не может быть пустой строкой');
         Result:=MakeVal(Ord(P[1].Str[1]));
       end;
end;

end.

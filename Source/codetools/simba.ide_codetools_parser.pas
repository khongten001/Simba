{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.ide_codetools_parser;

{$i simba.inc}

interface

uses
  SysUtils, Classes,
  mPasLexTypes, mPasLex, mSimplePasPar,
  Generics.Collections, Generics.Defaults;

type
  TDeclaration = class;
  TDeclarationArray = array of TDeclaration;
  TDeclarationClass = class of TDeclaration;

  TDeclarationStack = specialize TStack<TDeclaration>;

  TDeclarationList = class(specialize TList<TDeclaration>)
  public
    function GetByClassAndName(AClass: TDeclarationClass; AName: String; SubSearch: Boolean = False): TDeclarationArray;

    function GetItemsOfClass(AClass: TDeclarationClass; SubSearch: Boolean = False): TDeclarationArray;
    function GetFirstItemOfClass(AClass: TDeclarationClass; SubSearch: Boolean = False): TDeclaration;
    function GetItemInPosition(Position: Integer): TDeclaration;

    function GetTextOfClass(AClass: TDeclarationClass): String;
    function GetTextOfClassNoComments(AClass: TDeclarationClass): String;
    function GetTextOfClassNoCommentsSingleLine(AClass: TDeclarationClass): String;
  end;

  {$IFDEF PARSER_LEAK_CHECKS}
  TLeakChecker = class(TObject)
  public
  class var
    Creates: Integer;
    Destroys: Integer;
  public
    class procedure PrintLeaks;

    constructor Create; virtual;
    destructor Destroy; override;
  end;
  {$ENDIF}

  TDeclaration = class({$IFDEF PARSER_LEAK_CHECKS}TLeakChecker{$ELSE}TObject{$ENDIF})
  protected
    FOwner: TDeclaration;
    FStartPos: Integer;
    FEndPos: Integer;
    FItems: TDeclarationList;
    FName: String;
    FLine: Integer;
    FLexer: TmwPasLex;

    FText: String;
    FTextNoComments: String;
    FTextNoCommentsSingleLine: String;

    function GetText: String;
    function GetTextNoComments: String;
    function GetTextNoCommentsSingleLine: String;

    function GetName: string; virtual;
  public
    function Dump: String; virtual;

    function IsName(const Value: String): Boolean; inline;

    property Lexer: TmwPasLex read FLexer;
    property Owner: TDeclaration read FOwner write FOwner;

    property StartPos: Integer read FStartPos write FStartPos;
    property EndPos: Integer read FEndPos write FEndPos;
    property Items: TDeclarationList read FItems;
    property Name: String read GetName write FName;
    property Line: Integer read FLine;

    property Text: String read GetText;
    property TextNoComments: String read GetTextNoComments;
    property TextNoCommentsSingleLine: String read GetTextNoCommentsSingleLine;

    constructor Create; {$IFDEF PARSER_LEAK_CHECKS}override{$ELSE}virtual; overload{$ENDIF};
    constructor Create(ALexer: TmwPasLex; AOwner: TDeclaration; AStart: Integer; AEnd: Integer); virtual; overload;
    destructor Destroy; override;
  end;

  TciCompoundStatement = class(TDeclaration);
  TciWithStatement = class(TDeclaration);
  TciSimpleStatement = class(TDeclaration);
  TciVariable = class(TDeclaration);
  TciExpression = class(TDeclaration);

  TDeclaration_Stub = class(TDeclaration);
  TDeclaration_TypeStub = class(TDeclaration_Stub)
  public
    TempName: String;
  end;
  TDeclaration_VarStub = class(TDeclaration_Stub)
  public
    TempNames: TStringArray;
  end;
  TDeclaration_ParamStub = class(TDeclaration_VarStub)
  public
    ParamType: TptTokenKind;
  end;
  TDeclaration_ParamList = class(TDeclaration);
  TDeclaration_ParamGroup = class(TDeclaration);

  TDeclaration_ParentType = class(TDeclaration);
  TDeclaration_Identifier = class(TDeclaration);
  TDeclaration_OrdinalType = class(TDeclaration);

  TDeclaration_Type = class(TDeclaration);

  TDeclaration_TypeRecord = class(TDeclaration_Type)
  public
    function Parent: TDeclaration;
    function Fields: TDeclarationArray;
  end;

  TDeclaration_TypeUnion = class(TDeclaration_Type);
  TDeclaration_TypeArray = class(TDeclaration_Type)
  public
    function Dump: String; override;
    function DimCount: Integer;
    function VarType: TDeclaration;
  end;

  TDeclaration_TypePointer = class(TDeclaration_Type)
  public
    function VarType: TDeclaration;
  end;

  TDeclaration_TypeCopy = class(TDeclaration_Type)
  public
    function VarType: TDeclaration;
  end;

  TDeclaration_TypeAlias = class(TDeclaration_Type)
  public
    function VarType: TDeclaration;
  end;

  TDeclaration_TypeSet = class(TDeclaration_Type);
  TDeclaration_TypeRange = class(TDeclaration_Type);
  TDeclaration_TypeNativeMethod = class(TDeclaration_Type);

  TDeclaration_EnumElement = class(TDeclaration)
  public
    function GetName: string; override;
  end;

  TDeclaration_EnumElementName = class(TDeclaration)
  protected
    function GetName: string; override;
  end;

  TDeclaration_TypeEnum = class(TDeclaration_Type)
  public
    function Elements: TDeclarationArray;
  end;

  TDeclaration_TypeEnumScoped = class(TDeclaration_Type);

  TDeclaration_VarType = class(TDeclaration);
  TDeclaration_VarDefault = class(TDeclaration);
  TDeclaration_Var = class(TDeclaration)
  protected
    FVarTypeString: String;
    FVarDefaultString: String;
  public
    function VarType: TDeclaration;
    function VarTypeString: String;
    function VarDefault: TDeclaration;
    function VarDefaultString: String;

    constructor Create; override;
  end;

  TDeclaration_Const = class(TDeclaration_Var);
  TDeclaration_Field = class(TDeclaration_Var);

  EMethodType = (mtProcedure, mtFunction, mtObjectProcedure, mtObjectFunction, mtOperator);
  EMethodDirectives = TptTokenSet;

  TDeclaration_Method = class(TDeclaration)
  protected
    FParamString: String;
    FResultString: String;
  public
    ObjectName: String;
    MethodType: EMethodType;
    Directives: EMethodDirectives;

    function IsOverride: Boolean;

    function ResultType: TDeclaration;
    function Dump: String; override;

    function ParamString: String;
    function ResultString: String;

    constructor Create; override;
  end;

  TDeclaration_TypeMethod = class(TDeclaration_Method);

  TDeclaration_MethodResult = class(TDeclaration);
  TDeclaration_Parameter = class(TDeclaration)
  public
    ParamType: TptTokenKind;

    function VarTypeString: String;
    function DefaultValueString: String;
    function Dump: String; override;
  end;


  TOnFindInclude = function(Sender: TmwBasePasLex; var FileName: string): Boolean of object;
  TOnInclude = procedure(Sender: TmwBasePasLex; FileName: String; var Handled: Boolean) of object;

  TOnFindLibrary = function(Sender: TmwBasePasLex; var FileName: String): Boolean of object;
  TOnLoadLibrary = procedure(Sender: TmwBasePasLex; FileName: String; var Contents: String) of object;
  TOnLibrary = procedure(Sender: TmwBasePasLex; FileName: String; var Handled: Boolean) of object;

  TDeclarationMap = specialize TDictionary<String, TDeclarationList>;

  TCodeParser = class(TmwSimplePasPar)
  protected
    FRoot: TDeclaration;
    FItems: TDeclarationList;
    FStack: TDeclarationStack;
    FOnFindInclude: TOnFindInclude;
    FOnInclude: TOnInclude;
    FOnFindLibrary: TOnFindInclude;
    FOnLoadLibrary: TOnLoadLibrary;
    FOnLibrary: TOnLibrary;

    FGlobals: TDeclarationList;
    FGlobalMap: TDeclarationMap;
    FTypeMethodMap: TDeclarationMap;

    procedure AddToMap(Map: TDeclarationMap; Name: String; Decl: TDeclaration);

    procedure AddGlobal(Decl: TDeclaration);
    procedure AddTypeMethod(Decl: TDeclaration_Method);

    function GetCaretPos: Integer;
    function GetMaxPos: Integer;
    procedure SetCaretPos(const Value: Integer);
    procedure SetMaxPos(const Value: Integer);

    function InDeclaration(AClass: TDeclarationClass): Boolean;
    function InDeclarations(AClassArray: array of TDeclarationClass): Boolean;
    function PushStack(AClass: TDeclarationClass): TDeclaration;
    procedure PopStack;

    procedure ParseFile; override;
    procedure OnLibraryDirect(Sender: TmwBasePasLex); override;
    procedure OnIncludeDirect(Sender: TmwBasePasLex); override;                 //Includes

    procedure CompoundStatement; override;                                      //Begin-End
    procedure WithStatement; override;                                          //With
    procedure SimpleStatement; override;                                        //Begin-End + With
    procedure Variable; override;                                               //With

    procedure ConstantType; override;
    procedure ConstantValue; override;
    procedure ConstantExpression; override;
    procedure TypeKind; override;                                               //Var + Const + Array + Record
    procedure ProceduralType; override;                                         //Var + Procedure/Function Parameters

    procedure TypeAlias; override;                                              //Type
    procedure TypeIdentifer; override;                                          //Type
    procedure TypeDeclaration; override;                                        //Type
    procedure TypeName; override;                                               //Type
    procedure ExplicitType; override;                                           //Type
    procedure PointerType; override;

    procedure VarDeclaration; override;                                         //Var
    procedure VarName; override;                                                //Var


    procedure ConstantDeclaration; override;                                    //Const
    procedure ConstantName; override;                                           //Const

    procedure ProceduralDirective; override;                                    //Procedure/Function directives
    procedure ProcedureDeclarationSection; override;                            //Procedure/Function
    procedure FunctionProcedureName; override;                                  //Procedure/Function
    procedure ObjectNameOfMethod; override;                                     //Class Procedure/Function
    procedure ReturnType; override;                                             //Function Result
    procedure ConstRefParameter; override;                                      //Procedure/Function Parameters
    procedure ConstParameter; override;                                         //Procedure/Function Parameters
    procedure OutParameter; override;                                           //Procedure/Function Parameters
    procedure NormalParameter; override;                                        //Procedure/Function Parameters
    procedure VarParameter; override;                                           //Procedure/Function Parameters
    procedure ParameterName; override;                                          //Procedure/Function Parameters
    procedure ParameterVarType; override;                                       //Procedure/Function Parameters
    procedure FormalParameterSection; override;
    procedure FormalParameterList; override;
    procedure ArrayType; override;                                              //Array

    procedure NativeType; override;                                             //Lape Native Method

    procedure RecordType; override;                                             //Record
    procedure UnionType; override;                                              //Union
    procedure ClassField; override;                                             //Record + Class
    procedure FieldName; override;                                              //Record + Class

    procedure AncestorId; override;                                             //Class

    procedure SetType; override;                                                //Set
    procedure OrdinalType; override;                                            //Set + Array Range

    procedure EnumeratedType; override;                                         //Enum
    procedure EnumeratedScopedType; override;                                   //Enum
    procedure EnumeratedTypeItem; override;                                     //Enum Element
    procedure QualifiedIdentifier; override;                                    //Enum Element Name
  public
    property Items: TDeclarationList read FItems;
    property Globals: TDeclarationList read FGlobals;

    property OnFindInclude: TOnFindInclude read FOnFindInclude write FOnFindInclude;
    property OnInclude: TOnInclude read FOnInclude write FOnInclude;

    property OnFindLibrary: TOnFindInclude read FOnFindLibrary write FOnFindLibrary;
    property OnLoadLibrary: TOnLoadLibrary read FOnLoadLibrary write FOnLoadLibrary;
    property OnLibrary: TOnLibrary read FOnLibrary write FOnLibrary;

    property CaretPos: Integer read GetCaretPos write SetCaretPos;
    property MaxPos: Integer read GetMaxPos write SetMaxPos;

    procedure Reset; override;
    procedure Run; override;

    function GetGlobal(AName: String): TDeclaration;
    function GetMethodsOfType(ATypeName: String): TDeclarationArray;

    function DebugTree: String;
    function DebugGlobals: String;

    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

uses
  LazFileUtils,
  simba.mufasatypes;

function TDeclaration_EnumElement.GetName: string;
begin
  if (FName = #0) then
    FName := Items.GetTextOfClass(TDeclaration_EnumElementName);

  Result := inherited;
end;

function TDeclaration_TypeAlias.VarType: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_VarType);
end;

function TDeclaration_TypeCopy.VarType: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_VarType);
end;

function TDeclaration_TypePointer.VarType: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_VarType);
end;

function TDeclaration_TypeArray.Dump: String;
begin
  Result := inherited + ' [' + IntToStr(DimCount) + ']';
end;

function TDeclaration_TypeArray.DimCount: Integer;
var
  Decl: TDeclaration;
begin
  Result := 1;

  Decl := Items.GetFirstItemOfClass(TDeclaration_TypeArray);
  while (Decl <> nil) and (Decl.Owner is TDeclaration_TypeArray) do
  begin
    Decl := Decl.Items.GetFirstItemOfClass(TDeclaration_TypeArray);

    Inc(Result);
  end;
end;

function TDeclaration_TypeArray.VarType: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_VarType);
end;

function TDeclaration_TypeRecord.Parent: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_ParentType);
  if (Result <> nil) then
    Result := Result.Items.GetFirstItemOfClass(TDeclaration_VarType);
end;

function TDeclaration_TypeRecord.Fields: TDeclarationArray;
begin
  Result := Items.GetItemsOfClass(TDeclaration_Field);
end;

function TDeclaration_Var.VarType: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_VarType);
end;

function TDeclaration_Var.VarTypeString: String;
begin
  if (FVarTypeString = #0) then
  begin
    FVarTypeString := Items.GetTextOfClassNoCommentsSingleLine(TDeclaration_VarType);
    if (FVarTypeString <> '') then
      FVarTypeString := ': ' + FVarTypeString;
  end;

  Result := FVarTypeString;
end;

function TDeclaration_Var.VarDefault: TDeclaration;
begin
  Result := Items.GetFirstItemOfClass(TDeclaration_VarDefault);
end;

function TDeclaration_Var.VarDefaultString: String;
begin
  if (FVarDefaultString = #0) then
  begin
    FVarDefaultString := Items.GetTextOfClassNoCommentsSingleLine(TDeclaration_VarDefault);
    if (FVarDefaultString <> '') then
      FVarDefaultString := ' = ' + FVarDefaultString;
  end;

  Result := FVarDefaultString;
end;

constructor TDeclaration_Var.Create;
begin
  inherited Create();

  FVarDefaultString := #0;
  FVarTypeString := #0;
end;

function TDeclaration_EnumElementName.GetName: string;
begin
  if (FName = #0) then
    FName := Text;

  Result := FName;
end;

function TDeclaration_TypeEnum.Elements: TDeclarationArray;
begin
  Result := Items.GetItemsOfClass(TDeclaration_EnumElement);
end;

function TDeclaration_Method.IsOverride: Boolean;
begin
  Result := tokOverride in Directives;
end;

function TDeclaration_Method.ResultType: TDeclaration;
begin
  if (MethodType in [mtFunction, mtObjectFunction]) then
  begin
    Result := Items.GetFirstItemOfClass(TDeclaration_MethodResult);
    if (Result <> nil) then
      Result := Result.Items.GetFirstItemOfClass(TDeclaration_VarType);
  end else
    Result := nil;
end;

function TDeclaration_Method.Dump: String;
begin
  Result := inherited;

  case MethodType of
    mtProcedure:       Result := Result + ' [procedure]';
    mtFunction:        Result := Result + ' [function]';
    mtObjectProcedure: Result := Result + ' [procedure of object]';
    mtObjectFunction:  Result := Result + ' [function of object]';
    mtOperator:        Result := Result + ' [operator]';
  end;

  if (Directives <> []) then
    Result := Result + ' ' + TokenNames(Directives);
end;

function TDeclaration_Method.ParamString: String;
begin
  if (FParamString = #0) then
    FParamString := FItems.GetTextOfClassNoCommentsSingleLine(TDeclaration_ParamList);

  Result := FParamString;
end;

function TDeclaration_Method.ResultString: String;
begin
  if (FResultString = #0) then
  begin
    FResultString := FItems.GetTextOfClassNoCommentsSingleLine(TDeclaration_MethodResult);
    if (FResultString <> '') then
      FResultString := ': ' + FResultString;
  end;

  Result := FResultString;
end;

constructor TDeclaration_Method.Create;
begin
  inherited;

  FResultString := #0;
  FParamString := #0;
end;

function TDeclaration_Parameter.VarTypeString: String;
begin
  Result := FItems.GetTextOfClassNoCommentsSingleLine(TDeclaration_VarType);
end;

function TDeclaration_Parameter.DefaultValueString: String;
begin
  Result := FItems.GetTextOfClassNoCommentsSingleLine(TDeclaration_VarDefault);
end;

function TDeclaration_Parameter.Dump: String;
begin
  Result := inherited;

  case ParamType of
    tokConst:    Result := Result + ' [const]';
    tokConstRef: Result := Result + ' [constref]';
    tokVar:      Result := Result + ' [var]';
    tokOut:      Result := Result + ' [out]';
    tokUnknown:  Result := Result + ' [normal]';
  end;
end;

{$IFDEF PARSER_LEAK_CHECKS}
class procedure TLeakChecker.PrintLeaks;
begin
  DebugLn('TLeakChecker.PrintLeaks: ' + IntToStr(TLeakChecker.Creates - TLeakChecker.Destroys) + ' (should be zero)');
  DebugLn('Press enter to close...');
  ReadLn();
end;

constructor TLeakChecker.Create;
begin
  inherited Create();

  Inc(Creates);
end;

destructor TLeakChecker.Destroy;
begin
  Inc(Destroys);

  inherited Destroy();
end;
{$ENDIF}

function TDeclarationList.GetByClassAndName(AClass: TDeclarationClass; AName: String; SubSearch: Boolean): TDeclarationArray;
var
  Size: Integer;

  procedure DoSearch(const Item: TDeclaration);
  var
    I: Integer;
  begin
    if (Item is AClass) and (Item.IsName(AName)) then
    begin
      if (Size = Length(Result)) then
        SetLength(Result, Length(Result) * 2);
      Result[Size] := Item;
      Inc(Size);
    end;

    if SubSearch then
      for I := 0 to Item.Items.Count - 1 do
        DoSearch(Item.Items[I]);
  end;

var
  I: Integer;
begin
  SetLength(Result, 16);

  Size := 0;
  for I := 0 to FLength - 1 do
    DoSearch(FItems[I]);

  SetLength(Result, Size);
end;

function TDeclarationList.GetItemsOfClass(AClass: TDeclarationClass; SubSearch: Boolean = False): TDeclarationArray;
var
  Size: Integer;

  procedure DoSearch(const Item: TDeclaration);
  var
    I: Integer;
  begin
    if (Item is AClass) then
    begin
      if (Size = Length(Result)) then
        SetLength(Result, Length(Result) * 2);
      Result[Size] := Item;
      Inc(Size);
    end;

    if SubSearch then
      for I := 0 to Item.Items.Count - 1 do
        DoSearch(Item.Items[I]);
  end;

var
  I: Integer;
begin
  SetLength(Result, 16);

  Size := 0;
  for I := 0 to FLength - 1 do
    DoSearch(FItems[I]);

  SetLength(Result, Size);
end;

function TDeclarationList.GetFirstItemOfClass(AClass: TDeclarationClass; SubSearch: Boolean = False): TDeclaration;

  function SearchItem(AClass: TDeclarationClass; SubSearch: Boolean; Item: TDeclaration; out Res: TDeclaration): Boolean;
  var
    i: Integer;
  begin
    Res := nil;
    Result := False;
    if ((Item = nil) and (AClass = nil)) or (Item is AClass) then
    begin
      Res := Item;
      Result := True;
      Exit;
    end;
    if SubSearch then
      for i := 0 to Item.Items.Count - 1 do
        if SearchItem(AClass, SubSearch, Item.Items[i], Res) then
        begin
          Result := True;
          Break;
        end;
  end;

var
  i: Integer;
begin
  Result := nil;

  for i := 0 to FLength - 1 do
    if SearchItem(AClass, SubSearch, FItems[i], Result) then
      Exit;
end;

function TDeclarationList.GetItemInPosition(Position: Integer): TDeclaration;

  procedure Search(Declaration: TDeclaration; var Result: TDeclaration);
  var
    I: Integer;
  begin
    if (Position >= Declaration.StartPos) and (Position <= Declaration.EndPos) then
    begin
      Result := Declaration;

      for I := 0 to Declaration.Items.Count - 1 do
        Search(Declaration.Items[I], Result);
    end;
  end;

var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FLength - 1 do
    if (Position >= FItems[I].StartPos) and (Position <= FItems[I].EndPos) then
      Search(FItems[I], Result);
end;

function TDeclarationList.GetTextOfClass(AClass: TDeclarationClass): String;
var
  Declaration: TDeclaration;
begin
  Result := '';

  Declaration := GetFirstItemOfClass(AClass);
  if Declaration <> nil then
    Result := Declaration.GetText();
end;

function TDeclarationList.GetTextOfClassNoComments(AClass: TDeclarationClass): String;
var
  Declaration: TDeclaration;
begin
  Result := '';

  Declaration := GetFirstItemOfClass(AClass);
  if Declaration <> nil then
    Result := Declaration.GetTextNoComments();
end;

function TDeclarationList.GetTextOfClassNoCommentsSingleLine(AClass: TDeclarationClass): String;
var
  Declaration: TDeclaration;
begin
  Result := '';

  Declaration := GetFirstItemOfClass(AClass);
  if Declaration <> nil then
    Result := Declaration.GetTextNoCommentsSingleLine();
end;

function TDeclaration.GetName: string;
begin
  if (FName = #0) then
    Result := ''
  else
    Result := FName;
end;

function TDeclaration.Dump: String;
begin
  if (Name = '') then
    Result := ClassName
  else
    Result := ClassName + ' (' + Name + ')';
end;

function TDeclaration.GetText: String;
begin
  if (FText = #0) then
    FText := FLexer.CopyDoc(FStartPos, FEndPos);

  Result := FText;
end;

function TDeclaration.GetTextNoComments: String;

  function Filter(const Text: String): String;
  var
    Builder: TStringBuilder;
    Lexer: TmwPasLex;
  begin
    Builder := nil;

    Lexer := TmwPasLex.Create(Text);
    Lexer.Next();
    while (Lexer.TokenID <> tokNull) do
    begin
      if (not (Lexer.TokenID in [tokSlashesComment, tokAnsiComment, tokBorComment])) then
      begin
        if (Builder = nil) then
          Builder := TStringBuilder.Create(Length(Text));

        Builder.Append(Lexer.Token);
      end;
      Lexer.Next();
    end;
    Lexer.Free();

    if (Builder <> nil) then
    begin
      Result := Builder.ToString();

      Builder.Free();
    end else
      Result := Text;
  end;

begin
  if (FTextNoComments = #0) then
    FTextNoComments := Filter(FLexer.CopyDoc(FStartPos, FEndPos));

  Result := FTextNoComments;
end;

function TDeclaration.GetTextNoCommentsSingleLine: String;

  function Filter(const Text: String): String;
  var
    Builder: TStringBuilder;
    Lexer: TmwPasLex;
  begin
    Builder := nil;

    Lexer := TmwPasLex.Create(Text);
    Lexer.Next();
    while (Lexer.TokenID <> tokNull) do
    begin
      if (Lexer.TokenID in [tokCRLF, tokCRLFCo]) then
      begin
        if (Builder = nil) then
          Builder := TStringBuilder.Create(Length(Text));

        Builder.Append(' ');
      end;

      if (not (Lexer.TokenID in [tokSlashesComment, tokAnsiComment, tokBorComment, tokCRLF, tokCRLFCo])) then
      begin
        if (Builder = nil) then
          Builder := TStringBuilder.Create(Length(Text));

        Builder.Append(Lexer.Token);
      end;
      Lexer.Next();
    end;
    Lexer.Free();

    if (Builder <> nil) then
    begin
      Result := Builder.ToString();

      Builder.Free();
    end else
      Result := Text;

    Result := Result.Replace('  ', '');
  end;

begin
  if (FTextNoCommentsSingleLine = #0) then
    FTextNoCommentsSingleLine := Filter(FLexer.CopyDoc(FStartPos, FEndPos));

  Result := FTextNoCommentsSingleLine;
end;

function TDeclaration.IsName(const Value: String): Boolean;
begin
  Result := SameText(Name, Value);
end;

constructor TDeclaration.Create;
begin
  inherited Create();

  FItems := TDeclarationList.Create();

  FText := #0;
  FTextNoComments := #0;
  FTextNoCommentsSingleLine := #0;

  FName := #0;
end;

constructor TDeclaration.Create(ALexer: TmwPasLex; AOwner: TDeclaration; AStart: Integer; AEnd: Integer);
begin
  Create();

  FLexer := ALexer;
  FLine := FLexer.LineNumber;
  FOwner := AOwner;
  FStartPos := AStart;
  FEndPos := AEnd;
end;

destructor TDeclaration.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if (FItems[I].Owner = Self) then
      FItems[I].Free();
  FItems.Free();

  inherited Destroy();
end;

function TCodeParser.InDeclaration(AClass: TDeclarationClass): Boolean;
begin
  if (AClass = nil) then
    Result := (FStack.Count = 1)
  else
    Result := (FStack.Count > 0) and (FStack.Peek() is AClass);
end;

function TCodeParser.InDeclarations(AClassArray: array of TDeclarationClass): Boolean;
var
  AClass: TDeclarationClass;
begin
  Result := False;

  for AClass in AClassArray do
    if InDeclaration(AClass) then
    begin
      Result := True;

      Exit;
    end;
end;

function TCodeParser.PushStack(AClass: TDeclarationClass): TDeclaration;
begin
  Result := AClass.Create(FLexer, FStack.Peek(), FLexer.TokenPos, FLexer.TokenPos);

  FStack.Peek().Items.Add(Result);
  FStack.Push(Result);
end;

procedure TCodeParser.PopStack();
begin
  FStack.Pop().EndPos := fLastNoJunkPos;
end;

procedure TCodeParser.AddToMap(Map: TDeclarationMap; Name: String; Decl: TDeclaration);
var
  List: TDeclarationList;
begin
  Name := Name.ToUpper();

  if Map.TryGetValue(Name, List) then
    List.Add(Decl)
  else
  begin
    List := TDeclarationList.Create();
    List.Add(Decl);

    Map.Add(Name, List);
  end;
end;

procedure TCodeParser.AddGlobal(Decl: TDeclaration);
begin
  FGlobals.Add(Decl);

  AddToMap(FGlobalMap, Decl.Name, Decl);

  if (Decl is TDeclaration_TypeEnum) then
    for Decl in TDeclaration_TypeEnum(Decl).Elements do
    begin
      FGlobals.Add(Decl);
      AddToMap(FGlobalMap, Decl.Name, Decl);
    end;
end;

procedure TCodeParser.AddTypeMethod(Decl: TDeclaration_Method);
begin
  AddToMap(FTypeMethodMap, Decl.ObjectName, Decl);
end;

function TCodeParser.GetCaretPos: Integer;
begin
  if (fLexer = nil) then
    Result := -1
  else
    Result := fLexer.CaretPos;
end;

function TCodeParser.GetMaxPos: Integer;
begin
  if (fLexer = nil) then
    Result := -1
  else
    Result := fLexer.MaxPos;
end;

procedure TCodeParser.SetCaretPos(const Value: Integer);
begin
  if (fLexer <> nil) then
    fLexer.CaretPos := Value;
end;

procedure TCodeParser.SetMaxPos(const Value: Integer);
begin
  if (fLexer <> nil) then
    fLexer.MaxPos := Value;
end;

constructor TCodeParser.Create;
begin
  inherited Create();

  FRoot := TDeclaration.Create();
  FItems := FRoot.Items;
  FStack := TDeclarationStack.Create();
  FStack.Push(FRoot);
  FGlobalMap := TDeclarationMap.Create();
  FTypeMethodMap := TDeclarationMap.Create();
  FGlobals := TDeclarationList.Create();
end;

destructor TCodeParser.Destroy;
begin
  Reset();

  FRoot.Free();
  FStack.Free();
  FGlobalMap.Free();
  FTypeMethodMap.Free();
  FGlobals.Free();

  inherited Destroy();
end;

procedure TCodeParser.ParseFile;
begin
  Lexer.Next();

  SkipJunk();
  if (Lexer.TokenID = tokProgram) then
  begin
    NextToken();
    Expected(tokIdentifier);
    SemiColon();
  end;

  while (Lexer.TokenID in [tokBegin, tokConst, tokFunction, tokOperator, tokLabel, tokProcedure, tokType, tokVar]) do
  begin
    if (Lexer.TokenID = tokBegin) then
    begin
      CompoundStatement();
      if (Lexer.TokenID = tokSemiColon) then
        Expected(tokSemiColon);
    end else
      DeclarationSection();

    if (Lexer.TokenID = tok_DONE) then
      Break;
  end;
end;

procedure TCodeParser.OnLibraryDirect(Sender: TmwBasePasLex);
var
  FileName, Contents: String;
  Handled: Boolean;
begin
  Contents := '';

  //if (not Sender.IsJunk) then
  //try
  //  FileName := SetDirSeparators(Sender.DirectiveParamOriginal);
  //
  //  if (FOnFindLibrary <> nil) then
  //  begin
  //    if FOnFindLibrary(Self, FileName) then
  //    begin
  //      Handled := False;
  //
  //      if (FOnLibrary <> nil) then
  //        FOnLibrary(Self, FileName, Handled);
  //
  //      if not Handled then
  //      begin
  //        if (FOnLoadLibrary <> nil) then
  //        begin
  //          FOnLoadLibrary(Self, FileName, Contents);
  //
  //          PushLexer(TmwPasLex.Create(Contents, FileName));
  //
  //          FLexer.IsLibrary := True;
  //          //FLexer.FileName := FileName;
  //          //FLexer.Script := Contents;
  //          //FLexer.Next();
  //        end;
  //      end;
  //    end else
  //      DebugLn('Library "' + FileName + '" not found');
  //  end;
  //except
  //  on E: Exception do
  //    OnErrorMessage(fLexer, E.Message);
  //end;
end;

procedure TCodeParser.OnIncludeDirect(Sender: TmwBasePasLex);
var
  FileName: String;
begin
  if Sender.IsJunk or (FOnFindInclude = nil) then
    Exit;

  FileName := GetForcedPathDelims(Sender.DirectiveParamOriginal);
  if (Sender.TokenID = tokIncludeOnceDirect) and HasFile(FileName) then
    Exit;

  if FOnFindInclude(Sender, FileName) then
  begin
    PushLexer(TmwPasLex.CreateFromFile(FileName));

    Exit;
  end;

  DebugLn('Include "' + Sender.DirectiveParamOriginal + '" not found');
end;

procedure TCodeParser.CompoundStatement;
begin
  if (not InDeclarations([nil, TDeclaration_Method, TciWithStatement])) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TciCompoundStatement);
  inherited;
  PopStack();
end;

procedure TCodeParser.WithStatement;
begin
  if (not InDeclarations([TDeclaration_Method, TciCompoundStatement])) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TciWithStatement);
  inherited;
  PopStack();
end;

procedure TCodeParser.SimpleStatement;
begin
  if (not InDeclaration(TciWithStatement)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TciSimpleStatement);
  inherited;
  PopStack();
end;

procedure TCodeParser.Variable;
begin
  if (not InDeclaration(TciWithStatement)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TciVariable);
  inherited;
  PopStack();
end;

procedure TCodeParser.ConstantType;
begin
  if (not InDeclaration(TDeclaration_VarStub)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_VarType);
  inherited;
  PopStack();
end;

procedure TCodeParser.ConstantValue;
begin
  if (not InDeclaration(TDeclaration_VarStub)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_VarDefault);
  inherited;
  PopStack();
end;

procedure TCodeParser.ConstantExpression;
begin
  if (not InDeclaration(TDeclaration_ParamStub)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_VarDefault);
  inherited;
  PopStack();
end;

procedure TCodeParser.TypeKind;
begin
  if (not InDeclarations([TDeclaration_VarStub, TDeclaration_TypeArray, TDeclaration_MethodResult])) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_VarType);
  inherited;
  PopStack();
end;

procedure TCodeParser.ProceduralType;
begin
  if (not InDeclarations([TDeclaration_TypeStub, TDeclaration_VarType])) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_TypeMethod);
  inherited;
  PopStack();
end;

procedure TCodeParser.ProceduralDirective;
begin
  if InDeclaration(TDeclaration_Method) then
    Include(TDeclaration_Method(FStack.Peek).Directives, Lexer.ExID);
  inherited;
end;

procedure TCodeParser.TypeAlias;
begin
  PushStack(TDeclaration_TypeAlias);
  PushStack(TDeclaration_VarType);
  inherited;
  PopStack();
  PopStack();
end;

procedure TCodeParser.TypeIdentifer;
begin
  PushStack(TDeclaration_Identifier).Name := Lexer.Token;
  inherited;
  PopStack();
end;

procedure TCodeParser.TypeDeclaration;
var
  Decl, NewDecl: TDeclaration;
begin
  Decl := PushStack(TDeclaration_TypeStub);
  inherited;
  PopStack();

  if (Decl.Items.Count > 0) then
  begin
    NewDecl := Decl.Items.First;
    NewDecl.Name := TDeclaration_TypeStub(Decl).TempName;

    FStack.Peek.Items.Add(NewDecl);
  end else
    OnErrorMessage(Lexer, 'Invalid type declaration');
end;

procedure TCodeParser.TypeName;
begin
  if InDeclaration(TDeclaration_TypeStub) then
    TDeclaration_TypeStub(FStack.Peek()).TempName := Lexer.Token;

  inherited;
end;

procedure TCodeParser.ExplicitType;
begin
  PushStack(TDeclaration_TypeCopy);
  PushStack(TDeclaration_VarType);
  inherited;
  PopStack();
  PopStack();
end;

procedure TCodeParser.PointerType;
begin
  PushStack(TDeclaration_TypePointer);
  PushStack(TDeclaration_VarType);
  inherited PointerType();
  PopStack();
  PopStack();
end;

procedure TCodeParser.VarDeclaration;
var
  Decl: TDeclaration;
  TempName: String;
  VarDecl, VarType, VarDefault: TDeclaration;
begin
  Decl := PushStack(TDeclaration_VarStub);
  inherited;
  PopStack();

  VarType := Decl.Items.GetFirstItemOfClass(TDeclaration_VarType);
  VarDefault := Decl.Items.GetFirstItemOfClass(TDeclaration_VarDefault);

  for TempName in TDeclaration_VarStub(Decl).TempNames do
  begin
    VarDecl := PushStack(TDeclaration_Var);
    VarDecl.Name := TempName;
    if (VarType <> nil) then
      VarDecl.Items.Add(VarType);
    if (VarDefault <> nil) then
      VarDecl.Items.Add(VarDefault);

    PopStack();
  end;
end;

procedure TCodeParser.VarName;
begin
  if InDeclaration(TDeclaration_VarStub) then
    TDeclaration_VarStub(FStack.Peek).TempNames += [Lexer.Token];

  inherited;
end;

procedure TCodeParser.ConstantDeclaration;
var
  Decl: TDeclaration;
  TempName: String;
  VarDecl, VarType, VarDefault: TDeclaration;
begin
  Decl := PushStack(TDeclaration_VarStub);
  inherited;
  PopStack();

  VarType := Decl.Items.GetFirstItemOfClass(TDeclaration_VarType);
  VarDefault := Decl.Items.GetFirstItemOfClass(TDeclaration_VarDefault);

  for TempName in TDeclaration_VarStub(Decl).TempNames do
  begin
    VarDecl := PushStack(TDeclaration_Const);
    VarDecl.Name := TempName;
    if (VarType <> nil) then
      VarDecl.Items.Add(VarType);
    if (VarDefault <> nil) then
      VarDecl.Items.Add(VarDefault);

    PopStack();
  end;
end;

procedure TCodeParser.ConstantName;
begin
  VarName();
end;

procedure TCodeParser.ProcedureDeclarationSection;
var
  Decl: TDeclaration_Method;
begin
  Decl := TDeclaration_Method(PushStack(TDeclaration_Method));
  case Lexer.TokenID of
    tokFunction:  Decl.MethodType := mtFunction;
    tokProcedure: Decl.MethodType := mtProcedure;
    tokOperator:  Decl.MethodType := mtOperator;
  end;

  inherited;
  PopStack();
end;

procedure TCodeParser.FunctionProcedureName;
begin
  if InDeclaration(TDeclaration_Method) then
    TDeclaration_Method(FStack.Peek).Name := Lexer.Token;
  inherited;
end;

procedure TCodeParser.ObjectNameOfMethod;
var
  Decl: TDeclaration_Method;
begin
  if InDeclaration(TDeclaration_Method) then
  begin
    Decl := TDeclaration_Method(FStack.Peek);
    Decl.ObjectName := Lexer.Token;

    case Decl.MethodType of
      mtFunction:  Decl.MethodType := mtObjectFunction;
      mtProcedure: Decl.MethodType := mtObjectProcedure;
    end;
  end;
  inherited;
end;

procedure TCodeParser.ReturnType;
begin
  if (not InDeclaration(TDeclaration_Method)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_MethodResult);
  TypeKind();
  PopStack();
end;

procedure TCodeParser.ConstRefParameter;
begin
  if InDeclaration(TDeclaration_ParamStub) then
   TDeclaration_ParamStub(FStack.Peek).ParamType := tokConstRef;

  inherited;
end;

procedure TCodeParser.ConstParameter;
begin
  if InDeclaration(TDeclaration_ParamStub) then
   TDeclaration_ParamStub(FStack.Peek).ParamType := tokConst;

  inherited;
end;

procedure TCodeParser.OutParameter;
begin
  if InDeclaration(TDeclaration_ParamStub) then
    TDeclaration_ParamStub(FStack.Peek).ParamType := tokOut;

  inherited;
end;

procedure TCodeParser.NormalParameter;
begin
  if InDeclaration(TDeclaration_ParamStub) then
    TDeclaration_ParamStub(FStack.Peek).ParamType := tokUnknown;

  inherited;
end;

procedure TCodeParser.VarParameter;
begin
  if InDeclaration(TDeclaration_ParamStub) then
    TDeclaration_ParamStub(FStack.Peek).ParamType := tokVar;

  inherited;
end;

procedure TCodeParser.ParameterName;
begin
  VarName();
end;

procedure TCodeParser.ParameterVarType;
begin
  PushStack(TDeclaration_VarType);
  inherited;
  PopStack();
end;

procedure TCodeParser.FormalParameterSection;
var
  Decl, ParamDecl, VarType, VarDef: TDeclaration;
  TempName: String;
begin
  Decl := PushStack(TDeclaration_ParamStub);
  inherited;
  PopStack();

  PushStack(TDeclaration_ParamGroup);
  VarType := Decl.Items.GetFirstItemOfClass(TDeclaration_VarType);
  VarDef := Decl.Items.GetFirstItemOfClass(TDeclaration_VarDefault);
  for TempName in TDeclaration_VarStub(Decl).TempNames do
  begin
    ParamDecl := PushStack(TDeclaration_Parameter);
    ParamDecl.Name := TempName;
    TDeclaration_Parameter(ParamDecl).ParamType := TDeclaration_ParamStub(Decl).ParamType;
    if (VarType <> nil) then
      ParamDecl.Items.Add(VarType);
    if (VarDef <> nil) then
      ParamDecl.Items.Add(VarDef);
    PopStack();
  end;
  PopStack();
end;

procedure TCodeParser.FormalParameterList;
begin
  PushStack(TDeclaration_ParamList);
  inherited;
  PopStack();
end;

procedure TCodeParser.ArrayType;
begin
  PushStack(TDeclaration_TypeArray);
  inherited;
  PopStack();
end;

procedure TCodeParser.NativeType;
begin
  PushStack(TDeclaration_TypeNativeMethod);
  inherited;
  PopStack();
end;

procedure TCodeParser.RecordType;
begin
  PushStack(TDeclaration_TypeRecord);
  inherited;
  PopStack();
end;

procedure TCodeParser.UnionType;
begin
  PushStack(TDeclaration_TypeUnion);
  inherited;
  PopStack();
end;

procedure TCodeParser.ClassField;
var
  Decl, FieldDecl, VarType: TDeclaration;
  TempName: String;
begin
  if (not InDeclarations([TDeclaration_TypeRecord, TDeclaration_TypeUnion])) then
  begin
    inherited;
    Exit;
  end;

  Decl := PushStack(TDeclaration_VarStub);
  inherited;
  PopStack();

  VarType := Decl.Items.GetFirstItemOfClass(TDeclaration_VarType);
  for TempName in TDeclaration_VarStub(Decl).TempNames do
  begin
    FieldDecl := PushStack(TDeclaration_Field);
    FieldDecl.Name := TempName;
    if (VarType <> nil) then
      FieldDecl.Items.Add(VarType);

    PopStack();
  end;
end;

procedure TCodeParser.FieldName;
begin
  VarName();
end;

procedure TCodeParser.AncestorId;
begin
  if (not InDeclarations([TDeclaration_TypeRecord, TDeclaration_TypeNativeMethod])) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_ParentType);
  PushStack(TDeclaration_VarType);
  PushStack(TDeclaration_Identifier);
  inherited;
  PopStack();
  PopStack();
  PopStack();
end;

procedure TCodeParser.SetType;
begin
  PushStack(TDeclaration_TypeSet);
  inherited;
  PopStack();
end;

procedure TCodeParser.OrdinalType;
begin
  if (not InDeclarations([TDeclaration_TypeSet, TDeclaration_TypeArray, TDeclaration_TypeStub])) then
  begin
    inherited;
    Exit;
  end;

  if InDeclaration(TDeclaration_TypeStub) then
    PushStack(TDeclaration_TypeRange);

  PushStack(TDeclaration_OrdinalType);
  inherited;
  PopStack();

  if InDeclaration(TDeclaration_TypeRange) then
    PopStack();
end;

procedure TCodeParser.EnumeratedType;
begin
  if Lexer.IsDefined('!SCOPEDENUMS') then
    PushStack(TDeclaration_TypeEnumScoped)
  else
    PushStack(TDeclaration_TypeEnum);
  inherited;
  PopStack();
end;

procedure TCodeParser.EnumeratedScopedType;
begin
  PushStack(TDeclaration_TypeEnumScoped);
  inherited;
  PopStack();
end;

procedure TCodeParser.EnumeratedTypeItem;
begin
  if (not InDeclarations([TDeclaration_TypeEnum, TDeclaration_TypeEnumScoped])) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_EnumElement);
  inherited;
  PopStack();
end;

procedure TCodeParser.QualifiedIdentifier;
begin
  if (not InDeclaration(TDeclaration_EnumElement)) then
  begin
    inherited;
    Exit;
  end;

  PushStack(TDeclaration_EnumElementName);
  inherited;
  PopStack();
end;

procedure TCodeParser.Reset;
var
  List: TDeclarationList;
begin
  inherited Reset();

  for List in FGlobalMap.Values do
    List.Free();
  for List in FTypeMethodMap.Values do
    List.Free();

  FGlobals.Clear();
  FGlobalMap.Clear();
  FTypeMethodMap.Clear();

  FRoot.Free();
  FRoot := TDeclaration.Create();
  FStack.Clear();
  FStack.Push(FRoot);
end;

procedure TCodeParser.Run;
var
  Decl: TDeclaration;
  I: Integer;
begin
  inherited Run();

  for I := 0 to FItems.Count - 1 do
  begin
    Decl := FItems[I];
    if (Decl.Name = '') then
      Continue;

    if (Decl is TDeclaration_Method) and (TDeclaration_Method(Decl).MethodType in [mtObjectFunction, mtObjectProcedure]) then
      AddTypeMethod(Decl as TDeclaration_Method)
    else
      AddGlobal(Decl);
  end;
end;

function TCodeParser.GetGlobal(AName: String): TDeclaration;
var
  List: TDeclarationList;
begin
  AName := AName.ToUpper();
  if FGlobalMap.TryGetValue(AName, List) then
    Result := List.First()
  else
    Result := nil;
end;

function TCodeParser.GetMethodsOfType(ATypeName: String): TDeclarationArray;
var
  List: TDeclarationList;
begin
  ATypeName := ATypeName.ToUpper();
  if (ATypeName <> '') and FTypeMethodMap.TryGetValue(ATypeName, List) then
    Result := List.ToArray
  else
    Result := nil;
end;

function TCodeParser.DebugTree: String;
var
  Builder: TAnsiStringBuilder;
  Depth: Integer = 1;

  procedure Dump(Decl: TDeclaration);
  var
    I: Integer;
  begin
    if (Decl is TDeclaration_Stub) then
      Exit;
    Builder.AppendLine(StringOfChar('-', Depth*2) + ' ' + Decl.Dump());

    Inc(Depth);
    for I := 0 to Decl.Items.Count - 1 do
      Dump(Decl.Items[I]);
    Dec(Depth);

    if (Decl.Items.Count > 0) then
      Builder.AppendLine(StringOfChar('-', Depth*2) + ' ' + Decl.Dump());
  end;

var
  I, Count: Integer;
begin
  Builder := TAnsiStringBuilder.Create();

  Count := 0;
  for I := 0 to Items.Count - 1 do
  begin
    if (Items[I] is TDeclaration_Stub) then
      Continue;

    Builder.AppendLine(IntToStr(Count) + ')');
    Dump(Items[I]);
    Inc(Count);
  end;

  Result := Builder.ToString().Trim();

  Builder.Free();
end;

function TCodeParser.DebugGlobals: String;
var
  Builder: TAnsiStringBuilder;
  List: TDeclarationList;
  Decl: TDeclaration;
begin
  Builder := TAnsiStringBuilder.Create();

  for List in FGlobalMap.Values do
    for Decl in List do
      Builder.AppendLine(Decl.ClassName + ' -> ' + Decl.Name);
  Result := Builder.ToString().Trim();

  Builder.Free();
end;

end.
program siecprzeplywowa;

uses
  SysUtils;

const
  INFINITY = High(integer);
  INPUT_FILE_FLAG = '-i';
  OUTPUT_FILE_FLAG = '-o';
  START_NODE_FLAG = '-s';
  END_NODE_FLAG = '-k';

var
  i: integer;

type
  arrayOfString = array of string;

  NodePointer = ^Node;

  Edge = record
    endNode: NodePointer;
    distanceToEndNode: integer;
  end;

  Node = record
    id: integer;
    edges: array of Edge;
  end;

  NodesLinkedListPointer = ^NodesLinkedList;

  NodesLinkedList = record
    node: NodePointer;
    nextElement: NodesLinkedListPointer;
  end;

  function createNode(id: integer; edgesCount: integer): NodePointer;
  begin
    new(createNode);
    createNode^.id := id;
    SetLength(createNode^.edges, edgesCount);
  end;

  procedure appendNodesLinkedList(var nodesLinkedListHead: NodesLinkedListPointer; nodeToBeAdded: NodePointer);
  var
    nodesLinkedListElement: NodesLinkedListPointer = nil;
  begin
    new(nodesLinkedListElement);
    nodesLinkedListElement^.node := nodeToBeAdded;
    nodesLinkedListElement^.nextElement := nodesLinkedListHead;
    nodesLinkedListHead := nodesLinkedListElement;
  end;

  function hasNextNode(listOfNodes: NodesLinkedListPointer): boolean;
  begin
    hasNextNode := listOfNodes^.nextElement^.node <> nil;
  end;

  function hasExpectedCommandLineOptionsCount(): boolean;
  const
    EXPECTED_FLAGS_COUNT = 4;
    EXPECTED_FLAGS_ARGUMENTS_COUNT = 4;
    EXPECTED_OPTIONS_COUNT = EXPECTED_FLAGS_COUNT + EXPECTED_FLAGS_ARGUMENTS_COUNT;
  begin
    hasExpectedCommandLineOptionsCount := Paramcount = EXPECTED_OPTIONS_COUNT;
  end;

  function getArgumentByFlag(flag: string): string;
  begin
    for i := 1 to Paramcount - 1 do
      if flag = ParamStr(i) then
      begin
        getArgumentByFlag := ParamStr(i + 1);
        break;
      end;
  end;

  function getValueOf(anyString: string): integer;
  begin
    val(anyString, getValueOf);
  end;

  function getStartNodeId(): integer;
  begin
    getStartNodeId := getValueOf(getArgumentByFlag(START_NODE_FLAG));
  end;

  function getEndNodeId(): integer;
  begin
    getEndNodeId := getValueOf(getArgumentByFlag(END_NODE_FLAG));
  end;

  function getInputFilePath(): string;
  begin
    getInputFilePath := getArgumentByFlag(INPUT_FILE_FLAG);
  end;

  function getOutputFileName(): string;
  begin
    getOutputFileName := getArgumentByFlag(OUTPUT_FILE_FLAG);
  end;

  function getCommandLineOptionsAsString(): string;
  begin
    for i := 1 to Paramcount do
      getCommandLineOptionsAsString := getCommandLineOptionsAsString + ' ' + ParamStr(i);
  end;

  function containsCharInString(suspect: char; container: string): boolean;
  begin
    containsCharInString := pos(suspect, container) <> 0;
  end;

  function containsCharInStringCaseInsensitively(suspect: char; container: string): boolean;
  begin
    containsCharInStringCaseInsensitively := containsCharInString(LowerCase(suspect), LowerCase(container));
  end;

  function hasExpectedCommandLineFlags(): boolean;
  var
    commandLineOptions: string;
    expectedFlags: array[1..4] of char = ('i', 'o', 's', 'k');
  begin
    hasExpectedCommandLineFlags := True;
    commandLineOptions := getCommandLineOptionsAsString();
    for i := 1 to High(expectedFlags) do
      if not containsCharInStringCaseInsensitively(expectedFlags[i], commandLineOptions) then
      begin
        hasExpectedCommandLineFlags := False;
        break;
      end;
  end;

  function isAnExistingFile(filePath: string): boolean;
  begin
    isAnExistingFile := FileExists(filePath);
  end;

  function isValidFilename(filename: string): boolean;
  var
    illegalCharacters: array[1..9] of char = ('*', ':', '?', '"', '<', '>', '|', '/', '\');
  begin
    isValidFilename := True;
    for i := 1 to High(illegalCharacters) do
      if containsCharInString(illegalCharacters[i], filename) then
      begin
        isValidFilename := False;
        break;
      end;
  end;

  function countFileLines(filePath: string): integer;
  var
    fileContent: Text;
  begin
    countFileLines := 0;
    Assign(fileContent, filePath);
    Reset(fileContent);
    repeat
      ReadLn(fileContent);
      Inc(countFileLines);
    until EOF(fileContent);
    Close(fileContent);
  end;

  function getNodesCount(): integer;
  begin
    getNodesCount := countFileLines(getInputFilePath());
  end;

  function isPointingToAnExistingNode(nodeId: integer): boolean;
  begin
    isPointingToAnExistingNode := nodeId <= getNodesCount();
  end;

  function hasCommandLineFlagsArgumentsSetCorrectly(): boolean;
  begin
    hasCommandLineFlagsArgumentsSetCorrectly := False;
    if not isAnExistingFile(getInputFilePath()) then
      writeln('Podana sciezka "', getInputFilePath(), '" wskazuje na nieistniejacy plik.')
    else if not isValidFilename(getOutputFileName()) then
      writeln('Podana nazwa "', getOutputFileName(), '" nie moze byc uzyta jako nazwa pliku.')
    else if not isPointingToAnExistingNode(getStartNodeId()) then
      writeln('Wezel numer ', getStartNodeId(), ' nie moze byc uzyty jako startowy, bo nie istnieje.')
    else if not isPointingToAnExistingNode(getEndNodeId()) then
      writeln('Wezel numer ', getEndNodeId(), ' nie moze byc uzyty jako koncowy, bo nie istnieje.')
    else
      hasCommandLineFlagsArgumentsSetCorrectly := True;
  end;

  function hasCommandLineOptionsSetCorrectly(): boolean;
  begin
    hasCommandLineOptionsSetCorrectly := False;
    if not hasExpectedCommandLineOptionsCount() then
      writeln('Przerwano. Nieoczekiwana ilosc lub bledna skladnia parametrow.')
    else if not hasExpectedCommandLineFlags() then
      writeln('Przerwano. Nie uzyto wszystkich oczekiwanych przelacznikow.')
    else if not hasCommandLineFlagsArgumentsSetCorrectly() then
      writeln('Przerwano. Bledne ustawienie wartosci przelacznikow.')
    else
      hasCommandLineOptionsSetCorrectly := True;
  end;

  function deleteCharFromString(suspect: char; container: string): string;
  begin
    while containsCharInString(suspect, container) do
      Delete(container, pos(suspect, container), 1);
    deleteCharFromString := container;
  end;

  function countCharOccurrencesInString(suspect: char; container: string): integer;
  var
    c: char;
  begin
    countCharOccurrencesInString := 0;
    for c in container do
      if c = suspect then
        Inc(countCharOccurrencesInString);
  end;

  function splitStringByChar(separator: char; chain: string): arrayOfString;
  var
    letter: char;
  begin
    i := 0;
    SetLength(splitStringByChar, countCharOccurrencesInString(separator, chain) + 1);
    for letter in chain do
    begin
      if letter = separator then
        Inc(i)
      else
      begin
        splitStringByChar[i] := splitStringByChar[i] + letter;
      end;
    end;
  end;

  function isEmpty(aString: string): boolean;
  begin
    isEmpty := Length(aString) = 0;
  end;

  function countEmptyStringOccurrences(anArrayOfString: arrayOfString): integer;
  var
    aString: string;
  begin
    countEmptyStringOccurrences := 0;
    for aString in anArrayOfString do
      if isEmpty(aString) then
        Inc(countEmptyStringOccurrences);
  end;

  function removeEmptyStrings(anArrayOfString: arrayOfString): arrayOfString;
  var
    aString: string;
  begin
    i := 0;
    SetLength(removeEmptyStrings, Length(anArrayOfString) - countEmptyStringOccurrences(anArrayOfString));
    for aString in anArrayOfString do
      if not isEmpty(aString) then
      begin
        removeEmptyStrings[i] := aString;
      end;
  end;

var
  nodesLinkedListHead: NodesLinkedListPointer;

begin
  writeln('Nacisnij enter aby zakonczyc.');
  readln();
end.

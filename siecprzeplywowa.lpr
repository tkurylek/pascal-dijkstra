program siecprzeplywowa;

uses
  SysUtils;

const
  INFINITY = High(integer);

  INPUT_FILE_FLAG = '-i';
  OUTPUT_FILE_FLAG = '-o';
  START_NODE_FLAG = '-s';
  END_NODE_FLAG = '-k';

  SPACE = ' ';
  DOUBLE_SPACE = SPACE + SPACE;
  SEMICOLON = ';';
  SEMICOLON_WITH_SPACE = SEMICOLON + SPACE;

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

  function getValueOf(aString: string): integer;
  begin
    val(aString, getValueOf);
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

  function containsSubstringInString(aSubstring: string; aString: string): boolean;
  begin
    containsSubstringInString := pos(aSubstring, aString) <> 0;
  end;

  function containsSubstringInStringCaseInsensitively(aSubstring: string; aString: string): boolean;
  begin
    containsSubstringInStringCaseInsensitively := containsSubstringInString(LowerCase(aSubstring), LowerCase(aString));
  end;

  function hasExpectedCommandLineFlags(): boolean;
  var
    commandLineOptions: string;
    expectedFlags: array[1..4] of string = (INPUT_FILE_FLAG, OUTPUT_FILE_FLAG, START_NODE_FLAG, END_NODE_FLAG);
  begin
    hasExpectedCommandLineFlags := True;
    commandLineOptions := getCommandLineOptionsAsString();
    for i := 1 to High(expectedFlags) do
      if not containsSubstringInStringCaseInsensitively(expectedFlags[i] + SPACE, commandLineOptions) then
      begin
        writeln('Przelacznik "', expectedFlags[i], '" nie zostal uzyty.');
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
      if containsSubstringInString(illegalCharacters[i], filename) then
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
      writeln('Wezel numer ', getStartNodeId(), ' nie moze byc uzyty jako startowy, bo nie zostal zadeklarowany.')
    else if not isPointingToAnExistingNode(getEndNodeId()) then
      writeln('Wezel numer ', getEndNodeId(), ' nie moze byc uzyty jako koncowy, bo nie zostal zadeklarowany.')
    else
      hasCommandLineFlagsArgumentsSetCorrectly := True;
  end;

  function hasCommandLineOptionsSetCorrectly(): boolean;
  begin
    hasCommandLineOptionsSetCorrectly := False;
    if not hasExpectedCommandLineOptionsCount() then
      writeln('Przerwano. Nieoczekiwana ilosc parametrow.')
    else if not hasExpectedCommandLineFlags() then
      writeln('Przerwano. Nie uzyto wszystkich oczekiwanych przelacznikow.')
    else if not hasCommandLineFlagsArgumentsSetCorrectly() then
      writeln('Przerwano. Bledne ustawienie wartosci przelacznikow.')
    else
      hasCommandLineOptionsSetCorrectly := True;
  end;

  function removeSubstringFromString(aSubstring: string; aString: string): string;
  begin
    while containsSubstringInString(aSubstring, aString) do
      Delete(aString, pos(aSubstring, aString), Length(aSubstring));
    removeSubstringFromString := aString;
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
    SetLength(removeEmptyStrings, Length(anArrayOfString) - countEmptyStringOccurrences(anArrayOfString));
    i := 0;
    for aString in anArrayOfString do
      if not isEmpty(aString) then
      begin
        removeEmptyStrings[i] := aString;
        Inc(i);
      end;
  end;

  function getNodesDefinitions(): arrayOfString;
  var
    fileContent: Text;
  begin
    SetLength(getNodesDefinitions, getNodesCount());
    Assign(fileContent, getInputFilePath());
    Reset(fileContent);
    i := 0;
    repeat
      ReadLn(fileContent, getNodesDefinitions[i]);
      Inc(i);
    until EOF(fileContent);
    Close(fileContent);
  end;

  function replaceAll(aString, replacedSubstring, replacingSubstring: string): string;
  begin
    replaceAll := StringReplace(aString, replacedSubstring, replacingSubstring, [rfReplaceAll, rfIgnoreCase]);
  end;

  function removeMultipleSpaces(aString: string): string;
  begin
    while containsSubstringInString(DOUBLE_SPACE, aString) do
      aString := replaceAll(aString, DOUBLE_SPACE, SPACE);
    removeMultipleSpaces := aString;
  end;

  function removeSpacesAfterSemicolons(aString: string): string;
  begin
    removeSpacesAfterSemicolons := replaceAll(aString, SEMICOLON_WITH_SPACE, SEMICOLON);
  end;

  function trimNodeDefinition(aString: string): string;
  begin
    trimNodeDefinition := removeSpacesAfterSemicolons(removeMultipleSpaces(aString));
  end;

  function isInteger(aString: string): boolean;
  var
    errorCode: integer;
    integerValue: integer;
  begin
    val(aString, integerValue, errorCode);
    isInteger := errorCode = 0;
  end;

  function isUnderstandableNodeDefinition(nodeDefinition: string): boolean;
  var
    nodeConnection: string;
    nodeConnections: arrayOfString;
    nodeConnectionData: arrayOfString;
    nodeId: integer = 1;
  begin
    isUnderstandableNodeDefinition := True;
    nodeConnections := removeEmptyStrings(splitStringByChar(SEMICOLON, nodeDefinition));
    for nodeConnection in nodeConnections do
    begin
      nodeConnectionData := removeEmptyStrings(splitStringByChar(SPACE, nodeConnection));
      if length(nodeConnectionData) <> 2 then
        writeln('Niezrozumiale polaczenie ', nodeId, ' wezla: "',
          nodeConnection, '". Czy zapomniales srednika?')
      else if not isInteger(nodeConnectionData[0]) then
        writeln('Wezel ', nodeId, ' nie moze zostac polaczony z wezlem "', nodeConnectionData[0],
          '". Identyfikatory wezlow musza byc liczba calkowita!')
      else if not isInteger(nodeConnectionData[1]) then
        writeln('Wezel ', nodeId, ' nie moze zostac polaczony z wezlem ', nodeConnectionData[0],
          ' dystansem "', nodeConnectionData[1], '". Dystans miedzy wezlami musi byc liczba calkowita!')
      else
        Continue;
      isUnderstandableNodeDefinition := False;
      break;
    end;
  end;

var
  nodesLinkedListHead: NodesLinkedListPointer;
  nodeDefinition: string;
  nodeConnections: arrayOfString;

begin
  if hasCommandLineOptionsSetCorrectly() then
  begin
    for nodeDefinition in getNodesDefinitions() do
    begin
      nodeDefinition := trimNodeDefinition(nodeDefinition);
      if not isUnderstandableNodeDefinition(nodeDefinition) then
      begin
        writeln('Przerwano. Niezrozumiala definicja wezla: "', nodeDefinition, '"');
        break;
      end;
      nodeConnections := removeEmptyStrings(splitStringByChar(SEMICOLON, nodeDefinition));
    end;
  end;
  writeln();
  writeln('Nacisnij enter aby zakonczyc.');
  readln();
end.

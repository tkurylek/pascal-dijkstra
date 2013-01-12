program siecprzeplywowa;

uses
  SysUtils;

const
  INPUT_FILE_FLAG = '-i';
  OUTPUT_FILE_FLAG = '-o';
  START_NODE_FLAG = '-s';
  END_NODE_FLAG = '-k';

  INFINITY = High(integer);
  SPACE = ' ';
  DOUBLE_SPACE = SPACE + SPACE;
  SEMICOLON = ';';
  SEMICOLON_WITH_SPACE = SEMICOLON + SPACE;

type
  arrayOfString = array of string;

  NodePointer = ^Node;

  Edge = record
    endNode: NodePointer;
    distanceToEndNode: integer;
  end;

  Node = record
    id: integer;
    distance: integer;
    edges: array of Edge;
  end;

  NodesListPointer = ^NodesList;

  NodesList = record
    node: NodePointer;
    nextElement: NodesListPointer;
  end;

var
  i: integer;
  nodesListHead: NodesListPointer = nil;

  function createNode(id: integer; edgesCount: integer): NodePointer;
  begin
    new(createNode);
    createNode^.id := id;
    SetLength(createNode^.edges, edgesCount);
  end;

  function hasNextNode(listOfNodes: NodesListPointer): boolean;
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

  function containsSubstringInString(aSubstring: string; aString: string): boolean;
  begin
    containsSubstringInString := pos(aSubstring, aString) <> 0;
  end;

  function containsSubstringInStringCaseInsensitively(aSubstring: string; aString: string): boolean;
  begin
    containsSubstringInStringCaseInsensitively := containsSubstringInString(LowerCase(aSubstring), LowerCase(aString));
  end;

  function getCommandLineOptionsAsString(): string;
  begin
    for i := 1 to Paramcount do
      getCommandLineOptionsAsString := getCommandLineOptionsAsString + ' ' + ParamStr(i);
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

  function trimArray(anArrayOfString: arrayOfString): arrayOfString;
  var
    aString: string;
  begin
    SetLength(trimArray, Length(anArrayOfString) - countEmptyStringOccurrences(anArrayOfString));
    i := 0;
    for aString in anArrayOfString do
      if not isEmpty(aString) then
      begin
        trimArray[i] := aString;
        Inc(i);
      end;
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
      getNodesDefinitions[i] := trimNodeDefinition(getNodesDefinitions[i]);
      Inc(i);
    until EOF(fileContent);
    Close(fileContent);
  end;

  function isAnInteger(aString: string): boolean;
  var
    errorCode: integer;
    assignedButNeverUsedIntegerValue: integer;
  begin
    val(aString, assignedButNeverUsedIntegerValue, errorCode);
    isAnInteger := errorCode = 0;
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

  function splitStringByChar(separator: char; aString: string): arrayOfString;
  var
    letter: char;
  begin
    i := 0;
    SetLength(splitStringByChar, countCharOccurrencesInString(separator, aString) + 1);
    for letter in aString do
      if letter = separator then
        Inc(i)
      else
        splitStringByChar[i] := splitStringByChar[i] + letter;
  end;

  function getNodeConnections(nodeDefinition: string): arrayOfString;
  begin
    getNodeConnections := trimArray(splitStringByChar(SEMICOLON, nodeDefinition));
  end;

  function getNodeConnectionData(nodeConnection: string): arrayOfString;
  begin
    getNodeConnectionData := trimArray(splitStringByChar(SPACE, nodeConnection));
  end;

  function isUnderstandableNodeDefinition(nodeDefinition: string): boolean;
  var
    nodeConnection: string;
    nodeConnectionData: arrayOfString;
    endNodeIdString: string;
    distanceToEndNodeString: string;
    nodeId: integer = 1;
  begin
    isUnderstandableNodeDefinition := True;
    for nodeConnection in getNodeConnections(nodeDefinition) do
    begin
      nodeConnectionData := getNodeConnectionData(nodeConnection);
      endNodeIdString := nodeConnectionData[0];
      distanceToEndNodeString := nodeConnectionData[1];
      if length(nodeConnectionData) <> 2 then
        writeln('Niezrozumiale polaczenie ', nodeId, ' wezla: "',
          nodeConnection, '". Niepoprawna ilosc parametrow.')
      else if not isAnInteger(endNodeIdString) then
        writeln('Wezel ', nodeId, ' nie moze zostac polaczony z wezlem "', endNodeIdString,
          '". Identyfikatory wezlow musza byc liczba calkowita!')
      else if not isAnInteger(distanceToEndNodeString) then
        writeln('Wezel ', nodeId, ' nie moze zostac polaczony z wezlem ', endNodeIdString,
          ' dystansem "', distanceToEndNodeString, '". Dystans miedzy wezlami musi byc liczba calkowita!')
      else
        Continue;
      isUnderstandableNodeDefinition := False;
      break;
    end;
  end;

  function areUnderstandableNodesDefinitions(nodesDefinitions: arrayOfString): boolean;
  var
    nodeDefinition: string;
  begin
    areUnderstandableNodesDefinitions := True;
    for nodeDefinition in nodesDefinitions do
    begin
      if not isUnderstandableNodeDefinition(nodeDefinition) then
      begin
        writeln('Przerwano. Niezrozumiala definicja wezla: "', nodeDefinition, '"');
        areUnderstandableNodesDefinitions := False;
        break;
      end;
    end;
  end;

  function createNodeByDefinition(nodeId: integer; nodeDefinition: string): NodePointer;
  var
    edgesSize: integer;
  begin
    edgesSize := Length(getNodeConnections(nodeDefinition));
    createNodeByDefinition := createNode(nodeId, edgesSize);
  end;

  procedure appendNodesList(var nodesListHead: NodesListPointer; nodeToBeAdded: NodePointer);
  var
    nodesListElement: NodesListPointer = nil;
  begin
    new(nodesListElement);
    nodesListElement^.node := nodeToBeAdded;
    nodesListElement^.nextElement := nodesListHead;
    nodesListHead := nodesListElement;
  end;

  procedure createNodesInNodesListByTheirDefinitions(var nodesListHead: NodesListPointer;
    nodesDefinitions: arrayOfString);
  var
    nodeDefinition: string;
    nodeId: integer = 1;
  begin
    for nodeDefinition in nodesDefinitions do
    begin
      appendNodesList(nodesListHead, createNodeByDefinition(nodeId, nodeDefinition));
      Inc(nodeId);
    end;
  end;

  function isEndOfList(nodesList: NodesListPointer): boolean;
  begin
    isEndOfList := nodesList = nil;
  end;

  function findNodeInNodesListById(nodesList: NodesListPointer; nodeId: integer): NodePointer;
  begin
    findNodeInNodesListById := nil;
    while not isEndOfList(nodesList) do
    begin
      if nodesList^.node^.id = nodeId then
      begin
        findNodeInNodesListById := nodesList^.node;
        break;
      end;
      nodesList := nodesList^.nextElement;
    end;
  end;

  function getConnectionEndNodeId(nodeConnection: string): integer;
  begin
    getConnectionEndNodeId := getValueOf(getNodeConnectionData(nodeConnection)[0]);
  end;

  function getConnectionDistanceToEndNode(nodeConnection: string): integer;
  begin
    getConnectionDistanceToEndNode := getValueOf(getNodeConnectionData(nodeConnection)[1]);
  end;

  procedure establishConnectionsForNode(aNode: NodePointer; nodeConnections: arrayOfString);
  var
    edgesIndex: integer;
    nodeConnection: string;
    distanceToEndNode: integer;
    endNodeId: integer;
  begin
    edgesIndex := 0;
    for nodeConnection in nodeConnections do
    begin
      endNodeId := getConnectionEndNodeId(nodeConnection);
      distanceToEndNode := getConnectionDistanceToEndNode(nodeConnection);
      aNode^.edges[edgesIndex].endNode := findNodeInNodesListById(nodesListHead, endNodeId);
      aNode^.edges[edgesIndex].distanceToEndNode := distanceToEndNode;
      Inc(edgesIndex);
    end;
  end;

  procedure establishConnectionsForNodesInNodesListByDefinitions(nodesList: NodesListPointer;
    nodesDefinitions: arrayOfString);
  var
    nodeConnections: arrayOfString;
    aNode: NodePointer;
    nodeDefinition: string;
  begin
    while not isEndOfList(nodesList) do
    begin
      aNode := nodesList^.node;
      nodeDefinition := nodesDefinitions[aNode^.id - 1];
      nodeConnections := getNodeConnections(nodeDefinition);
      establishConnectionsForNode(aNode, nodeConnections);
      nodesList := nodesList^.nextElement;
    end;
  end;

  function findNodeWithLowestDistanceInNodesList(nodesList: NodesListPointer): NodePointer;
  var
    aNode: NodePointer;
    lowestDistance: integer;
  begin
    lowestDistance := nodesList^.node^.distance;
    findNodeWithLowestDistanceInNodesList := nodesList^.node;
    while not isEndOfList(nodesList) do
    begin
      aNode := nodesList^.node;
      if lowestDistance > aNode^.distance then
      begin
        lowestDistance := aNode^.distance;
        findNodeWithLowestDistanceInNodesList := aNode;
      end;
      nodesList := nodesList^.nextElement;
    end;
  end;

  procedure setInfinityDistanceForEachNodeInNodesList(nodesList: NodesListPointer);
  begin
    while not isEndOfList(nodesList) do
    begin
      nodesList^.node^.distance := INFINITY;
      nodesList := nodesList^.nextElement;
    end;
  end;

  procedure removeFromNodesList(var nodesList: NodesListPointer; nodeToBeRemoved: NodePointer);
  var
    nodesListCopy: NodesListPointer;
    previousNodesListElement: NodesListPointer = nil;
  begin
    nodesListCopy := nodesList;
    while not isEndOfList(nodesList) do
    begin
      if nodesList^.node^.id = nodeToBeRemoved^.id then
      begin
        if previousNodesListElement = nil then
        begin
          nodesList := nil;
          break;
        end;
        previousNodesListElement^.nextElement := nodesList^.nextElement;
        nodesList := nodesListCopy;
        break;
      end;
      previousNodesListElement := nodesList;
      nodesList := nodesList^.nextElement;
    end;
  end;

var
  nodesDefinitions: arrayOfString;
  startNode: NodePointer;
  evaluationNode: NodePointer;
  unvisitedNodes: NodesListPointer;
  anEdge: Edge;
  totalDistanceToEndNode: integer = 0;

begin
  if hasCommandLineOptionsSetCorrectly() then
  begin
    nodesDefinitions := getNodesDefinitions();
    if areUnderstandableNodesDefinitions(nodesDefinitions) then
    begin
      createNodesInNodesListByTheirDefinitions(nodesListHead, nodesDefinitions);
      establishConnectionsForNodesInNodesListByDefinitions(nodesListHead, nodesDefinitions);

      // TODO: extract the following code to a function
      setInfinityDistanceForEachNodeInNodesList(nodesListHead);
      unvisitedNodes := nil;
      startNode := findNodeInNodesListById(nodesListHead, getStartNodeId());
      startNode^.distance := 0;
      appendNodesList(unvisitedNodes, startNode);

      while not isEndOfList(unvisitedNodes) do
      begin
        evaluationNode := findNodeWithLowestDistanceInNodesList(unvisitedNodes);
        if evaluationNode^.id = getEndNodeId() then
        begin
          writeln(evaluationNode^.id);
          break;
        end;
        removeFromNodesList(unvisitedNodes, evaluationNode);
        for anEdge in evaluationNode^.edges do
        begin
          totalDistanceToEndNode := evaluationNode^.distance + anEdge.distanceToEndNode;
          if anEdge.endNode^.distance > totalDistanceToEndNode then
          begin
            anEdge.endNode^.distance := totalDistanceToEndNode;
            appendNodesList(unvisitedNodes, anEdge.endNode);
          end;
        end;
      end;
    end;
  end;

  writeln();
  writeln('Nacisnij enter aby zakonczyc.');
  readln();
end.

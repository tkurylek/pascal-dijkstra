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
  var
    buildedNode: Node;
  begin
    new(createNode);
    createNode^.id := id;
    SetLength(createNode^.edges, edgesCount);
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

  function containsCharInString(suspect: char; container: string): boolean;
  begin
    containsCharInString := pos(suspect, container) <> 0;
  end;

  function containsCharInStringCaseInsensitively(suspect: char; container: string): boolean;
  begin
    containsCharInStringCaseInsensitively := containsCharInString(LowerCase(suspect), LowerCase(container));
  end;

  function getCommandLineOptionsAsString(): string;
  begin
    for i := 1 to Paramcount do
      getCommandLineOptionsAsString := getCommandLineOptionsAsString + ' ' + ParamStr(i);
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
    hasCommandLineFlagsArgumentsSetCorrectly :=
      isAnExistingFile(getInputFilePath()) and isValidFilename(getOutputFileName()) and
      isPointingToAnExistingNode(getStartNodeId()) and isPointingToAnExistingNode(getEndNodeId());
  end;

  function hasCommandLineOptionsSetCorrectly(): boolean;
  begin
    hasCommandLineOptionsSetCorrectly :=
      hasExpectedCommandLineOptionsCount() and hasExpectedCommandLineFlags() and
      hasCommandLineFlagsArgumentsSetCorrectly();
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

begin
  writeln('hasCommandLineOptionsSetCorrectly() : ', hasCommandLineOptionsSetCorrectly());
  writeln;
  writeln('Hit Enter to exit.');
  readln();
end.

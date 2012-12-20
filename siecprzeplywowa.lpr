program siecprzeplywowa;

uses
  SysUtils;

const
  INFINITY = High(integer);

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

  function createNode(id: integer; edgesCount: integer): NodePointer;
  var
    buildedNode: Node;
  begin
    buildedNode.id := id;
    SetLength(buildedNode.edges, edgesCount);
    createNode := @buildedNode;
  end;

type
  NodesList = record
    currentNode: NodePointer;
    nextNode: NodePointer;
  end;

  function hasNextNode(listOfNodes: NodesList): boolean;
  begin
    hasNextNode := listOfNodes.nextNode <> nil;
  end;

  function getValueOfParameter(parameter: string): string;
  var
    i: integer;
  begin
    for i := 1 to Paramcount - 1 do
      if parameter = ParamStr(i) then
      begin
        getValueOfParameter := ParamStr(i + 1);
        break;
      end;
  end;

  function getParametrizedInputFilePath(): string;
  begin
    getParametrizedInputFilePath := getValueOfParameter('-i');
  end;

  function getParametrizedOutputFileName(): string;
  begin
    getParametrizedOutputFileName := getValueOfParameter('-o');
  end;

  function getParametrizedStartNode(): string;
  begin
    getParametrizedStartNode := getValueOfParameter('-s');
  end;

  function getParametrizedEndNode(): string;
  begin
    getParametrizedEndNode := getValueOfParameter('-k');
  end;

  function isValidFilename(filename: string): boolean;
  var
    i: integer;
    illeagalCharacters: array[1..9] of char = ('*', ':', '?', '"', '<', '>', '|', '/', '\');
  begin
    isValidFilename := True;
    for i := 1 to High(illeagalCharacters) do
      if containsCharInString(illeagalCharacters[i], filename) then
      begin
        isValidFilename := False;
        break;
      end;
  end;

  function isAnExistingFile(filePath: string): boolean;
  begin
    isAnExistingFile := FileExists(filePath);
  end;

  function areParametrizedValuesSetCorrectly(): boolean;
  begin
    areParametrizedValuesSetCorrectly := isAnExistingFile(getParametrizedInputFilePath()) and
      isValidFilename(getParametrizedOutputFileName());
  end;

  function containsExpectedParametersCount(): boolean;
  const
    EXPECTED_PARAMETERS_COUNT = 8;
  begin
    containsExpectedParametersCount := Paramcount = EXPECTED_PARAMETERS_COUNT;
  end;

  function getParametersAsString(): string;
  var
    parametersAsString: string = '';
    i: integer;
  begin
    for i := 1 to Paramcount do
    begin
      parametersAsString := parametersAsString + ' ' + ParamStr(i);
    end;
    getParametersAsString := parametersAsString;
  end;

  function containsCharInString(suspect: char; container: string): boolean;
  begin
    containsCharInString := (pos(suspect, container) <> 0);
  end;

  function hasExpectedSwitches(): boolean;
  var
    i: integer;
    parametersString: string;
    expectedSwitches: array[1..4] of char = ('i', 'o', 's', 'k');
    containsAllSwitches: boolean = True;
  begin
    parametersString := getParametersAsString();
    for i := 1 to High(expectedSwitches) do
      if not containsCharInString(expectedSwitches[i], parametersString) then
      begin
        containsAllSwitches := False;
        break;
      end;
    hasExpectedSwitches := containsAllSwitches;
  end;

  function areParametersSetCorrectly(): boolean;
  begin
    areParametersSetCorrectly := containsExpectedParametersCount() and hasExpectedSwitches() and
      areParametrizedValuesSetCorrectly();
  end;

begin
  writeln('TESTS RESULTS:');
  writeln('containsExpectedParametersCount() resulted: ', containsExpectedParametersCount());
  writeln('hasExpectedSwitches() resulted: ', hasExpectedSwitches());
  writeln('areParametersSettedCorrectly() resulted: ', areParametersSetCorrectly());
  writeln('valuesAreSetCorrectly() resulted: ', areParametrizedValuesSetCorrectly());
  writeln('isAnExistingFile(getParametrizedInputFilePath()) resulted: ', isAnExistingFile(
    getParametrizedInputFilePath()));
  writeln('isValidFilename(getParametrizedOutputFileName()) resulted: ', isValidFilename(
    getParametrizedOutputFileName()));
  writeln;
  writeln('Hit Enter to exit.');
  readln();
end.

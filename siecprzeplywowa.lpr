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
    containsCharInString := (pos(suspect, container) = 0);
  end;

  function hasExpectedSwitches(): boolean;
  var
    i: integer;
    parametersString: string;
    expectedSwitchs: array[1..4] of char = ('i', 'o', 's', 'k');
    containsAllSwitches: boolean = True;
  begin
    parametersString := getParametersAsString();
    for i := 1 to High(expectedSwitchs) do
    begin
      if containsCharInString(expectedSwitchs[i], parametersString) then
      begin
        containsAllSwitches := False;
        break;
      end;
    end;
    hasExpectedSwitches := containsAllSwitches;
  end;

  function valuesAreSetCorrectly(): boolean;
  begin
  end;

  function areParametersSettedCorrectly(): boolean;
  begin
    areParametersSettedCorrectly := containsExpectedParametersCount() and hasExpectedSwitches() and
      valuesAreSetCorrectly();
  end;

begin
  writeln('TESTS RESULTS:');
  writeln('containsExpectedParametersCount() resuled: ', containsExpectedParametersCount());
  writeln('hasExpectedSwitches() resuled: ', hasExpectedSwitches());
  writeln('Hit Enter to exit.');
  readln();
end.

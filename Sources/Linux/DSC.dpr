program DSC;

{$APPTYPE CONSOLE}

uses
  Classes, SysUtils, Types;

const
  TOOL_PARAM_SEPARATOR = '-';
  TOOL_PARAM_VALUE_SEPARATOR = ',';
  TOOL_CONVERTION_FORMAT = 'dsc';
  TOOL_CONVERTION_STRING_DUCKY_COMMAND = 'STRING';

var
  Params: TStringList;

procedure displayHelp();
begin
  WriteLn;
  WriteLn('[USB Rubber Ducky Script - String Converter]');
  WriteLn;
  WriteLn('List of availables commands');
  WriteLn;
  WriteLn(TOOL_PARAM_SEPARATOR + 'h : Display this message');
  WriteLn(TOOL_PARAM_SEPARATOR +
    'v : Display convertion information (verbose mode)');
  WriteLn(TOOL_PARAM_SEPARATOR +
    'a (optional) : Append command after each line [example : enter' +
    TOOL_PARAM_VALUE_SEPARATOR + 'delay' + TOOL_PARAM_VALUE_SEPARATOR + 'escape'
    + TOOL_PARAM_VALUE_SEPARATOR + 'etc...]');
  WriteLn(TOOL_PARAM_SEPARATOR + 'i : Plain text file to convert');
  WriteLn(TOOL_PARAM_SEPARATOR + 'o (optional) : Output file');
  WriteLn;
end;

procedure displayParamsError();
var
  _path: String;
begin
  _path := ParamStr(0);
  WriteLn;
  WriteLn('[ERROR] Please check parameters and retry ! Type ' +
    StringReplace(ExtractFileName(_path), ExtractFileExt(_path), '',
    [rfReplaceAll]) + ' -h for more information.');
end;

procedure displayRunAlert();
begin
  WriteLn('Please run this tool in DOS , if you''re already in DOS please check your parameters, press ENTER to close this window.');
end;

procedure displayConvertionAlert();
begin
  WriteLn;
  WriteLn('[ERROR] The input file you entered is invalid !');
end;

procedure displayConvertionError();
begin
  WriteLn('[ERROR] Unable to convert the select file ! Press ENTER to close the program.');
end;

procedure displayConvertionProgress();
begin
  WriteLn;
  WriteLn('[*] Please wait your file is being converted ....');
end;

procedure displayConvertionSuccess();
begin
  WriteLn('[SUCCESS] File has been converted into DUCKY STRING FORMAT ! Press ENTER to close the program.');
end;

procedure displayHeader();
begin
  WriteLn('  _____   _____  _____ ');
  WriteLn(' |  __ \ / ____|/ ____|');
  WriteLn(' | |  | | (___ | |     ');
  WriteLn(' | |  | |\___ \| |     ');
  WriteLn(' | |__| |____) | |____ ');
  WriteLn(' |_____/|_____/ \_____|');
  WriteLn;
  WriteLn('      Version 1.0      ');
  WriteLn;
end;

// Function to check if given entry is a parameter separator
function _paramIsParamSeparator(Entry: String): Boolean;
begin
  Result := False;
  if (Length(Trim(Entry)) < 1) then
    Exit;
  Result := (Entry[1] = TOOL_PARAM_SEPARATOR);
end;

function _paramGetAppends: TStringList;
var
  _aIndex, _aLastIndex, _aPresent: Integer;
  _paramANValue, _paramAValue: String;
begin
  // Init list
  Result := TStringList.Create;
  Result.Clear;
  // Check if append parameter is present
  _aPresent := (Params.IndexOf('-a'));
  if (_aPresent = -1) then
    Exit;
  // Get append parameter value
  _paramAValue := Params[_aPresent + 1];
  // Get append parameter extra values (avoid spaces)
  for _aIndex := (_aPresent + 2) to Pred(Params.Count) do
  begin
    if (Params[_aIndex][1] <> TOOL_PARAM_SEPARATOR) then
      _paramAValue := _paramAValue + ' ' + Params[_aIndex]
    else
      break;
  end;
  // Init variables
  _aLastIndex := 1;
  // Adding appends to result
  for _aIndex := 1 to Length(_paramAValue) do
  begin
    if (_paramAValue[_aIndex] = TOOL_PARAM_VALUE_SEPARATOR) then
    begin
      // Get new param string
      _paramANValue := Copy(_paramAValue, _aLastIndex,
        Length(_paramAValue) - _aLastIndex);
      // Add param value to result
      Result.Add(Copy(_paramAValue, _aLastIndex,
        AnsiPos(TOOL_PARAM_VALUE_SEPARATOR, _paramANValue) - 1));
      // Set last index
      _aLastIndex := _aIndex + 1;
    end;
  end;
  // Add last append to result (separator is missing at last char)
  Result.Add(Copy(_paramAValue, _aLastIndex, Length(_paramAValue) -
    (_aLastIndex - 1)));
end;

function _paramCheckToolParams: Boolean;
var
  // Param variables
  _ParamIndex, _ParamNextIndex: Integer;
begin
  // Init result
  Result := True;
  // Checking required parameters
  if (Params.IndexOf(TOOL_PARAM_SEPARATOR + 'i') = -1) then
  begin
    // One of required parameter is missing
    Result := False;
    Exit;
  end;
  // Checking parameters values
  for _ParamIndex := 0 to Pred(Params.Count) do
  begin
    // Read only parameters
    if (Params[_ParamIndex] = TOOL_PARAM_SEPARATOR + 'v') then
      Continue;
    // Check if current parameter is a separator
    if (_paramIsParamSeparator(Params[_ParamIndex])) then
    begin
      // Get parameter value
      _ParamNextIndex := _ParamIndex + 1;
      // Check if parameter is not getting out of bound AND if parameter is not followed of another one instead of it's value
      if (_ParamNextIndex > Pred(Params.Count)) OR
        ((_paramIsParamSeparator(Params[_ParamNextIndex]))) then
      begin
        // Parameter format is invalid
        Result := False;
        break;
      end;
    end;
  end;
end;

procedure convertFile(fPath: String; Appends: TStringList; fOut: String;
  Verbose: Boolean = False);
var
  fFile, fNewFile: TextFile;
  lBuffer: String;
  _A: String;
begin
  // Check if file exists
  if NOT FileExists(fPath) then
    Exit;
  // Check if out file already exists
  if FileExists(fOut) then
    DeleteFile(fOut);
  // Get appends as string
  _A := Appends.Text;
  // Delete last line of string (blank line)
  _A := Copy(_A, 1, Length(_A) - 2);
  // Load files
  AssignFile(fFile, fPath);
  AssignFile(fNewFile, fOut);
  // Open file for reading
  Reset(fFile);
  // Open file for writing
  ReWrite(fNewFile);
  // Read file line by line
  while NOT Eof(fFile) do
  begin
    // Read data from the first file
    ReadLn(fFile, lBuffer);
    // Verbose mode
    if (Verbose) then
    begin
      WriteLn('[CONVERT] ' + TOOL_CONVERTION_STRING_DUCKY_COMMAND + ' '
        + lBuffer);
      WriteLn('[COMMAND] ' + UpperCase(Appends.Text));
    end;
    // Write converted line
    WriteLn(fNewFile, TOOL_CONVERTION_STRING_DUCKY_COMMAND + ' ' + lBuffer);
    // Write commands after each lines
    WriteLn(fNewFile, UpperCase(_A));
  end;
  // Closing files both reading/writing
  CloseFile(fFile);
  CloseFile(fNewFile);
end;

// -------------------Main Program-------------------\\
var
  _lIn, _outFilePresent: Integer;
  _inFile, _outFile: String;
  _inAppends: TStringList;
  _cVerbose: Boolean;

begin
  // Display header
  displayHeader;
  // Check if program is running with no parameters
  if (ParamCount = 0) then
  begin
    // Display help
    displayHelp();
    // Alert
    displayRunAlert;
    // Pause
    ReadLn;
    // Close program
    Halt(0);
  end;
  // Init params list instance
  Params := TStringList.Create;
  // Exploring parameters
  for _lIn := 1 to (ParamCount) do
    // Adding parameters with universal case
    Params.Add(LowerCase(ParamStr(_lIn)));
  // Checking help request
  if (Params.IndexOf(TOOL_PARAM_SEPARATOR + 'h') <> -1) then
    displayHelp()
    // Checking parameters
  else if (_paramCheckToolParams) then
  begin
    // Get input file
    _inFile := Params[Params.IndexOf(TOOL_PARAM_SEPARATOR + 'i') + 1];
    // Check input file
    if (LowerCase(ExtractFileExt(_inFile)) = '.' + TOOL_CONVERTION_FORMAT) OR
      (NOT FileExists(_inFile)) then
    begin
      // Alert
      displayConvertionAlert;
      // Close program
      Halt(0);
    end;
    // Get output file (optional)
    _outFilePresent := Params.IndexOf(TOOL_PARAM_SEPARATOR + 'o');
    if (_outFilePresent <> -1) then
      _outFile := Params[_outFilePresent + 1];
    // Check output file
    if (Length(Trim(_outFile)) < 1) then
      _outFile := _inFile + '.' + TOOL_CONVERTION_FORMAT;
    // Get appends
    _inAppends := _paramGetAppends;
    // Progress
    displayConvertionProgress;
    Try
      // Verbose mode
      _cVerbose := (Params.IndexOf(TOOL_PARAM_SEPARATOR + 'v') <> -1);
      // Try to convert file
      convertFile(_inFile, _inAppends, _outFile, _cVerbose);
    Except
      // Error while converting
      displayConvertionError;
      // Close program
      Halt(0);
    End;
    // Success
    displayConvertionSuccess;
    // Close program
    Halt(0);
  end
  else
    // Parameters are invalid
    displayParamsError();

end.

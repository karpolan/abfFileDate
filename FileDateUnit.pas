{*******************************************************************************

  FileDate project. Main unit.

  Author: KARPOLAN
  E-Mail: info@ABFsoftware.com
  WEB:    http://www.ABFsoftware.com
  Copyright (c) 2000, 2001 ABF software, Inc.
  All rights reserved.

********************************************************************************
  History:
    06 mar 2000 - Version 1.0
    12 may 2000 - Version 1.1
    06 jun 2001 - Version 1.2
*******************************************************************************}
unit FileDateUnit;

{I abf.inc}

interface

procedure Execute;

{******************************************************************************}
implementation
{******************************************************************************}

uses
  SysUtils, abfConsts, abfSysUtils;

//==============================================================================
// Messages and string consts
//==============================================================================

const
  SVersion = '1.2';
  SRecursive = '/R';
  SDateFormat = 'MM/DD/YY';
  STimeFormat = 'HH-MM-SS';
  SMsgAppInfo =
'FileDate - file date and time tool, Version ' + SVersion + CRLF +
SabfCopyrightTxt + ' ' + SabfAllRightsReserved + '.' + CRLF +
'  Web:    ' + SabfWeb + CRLF +
'  E-mail: ' + SabfEmail_Info + CRLF;
  SMsgUsage1 =
'Sets specified date and time to files matched given mask' + CRLF +
'Usage:   FileDate.exe [Mask] [Date] [Time] [/r]' + CRLF +
'Example: FileDate.exe c:\progs\*.exe 03/26/01 01-35-00 /r' + CRLF;
  SMsgUsage2 =
'  Mask - the mask that files should match ("*.*" by default)' + CRLF +
'  Date - date to set, format is "' + SDateFormat + '"' + CRLF +
'  Time - time to set, format is "' + STimeFormat + '"' + CRLF +
'  /r   - option for process subfolders' + CRLF;
  SMsgTotal = CRLF + 'Total: %d files.';
  SMsgDone = CRLF + 'Done... ';

//==============================================================================
// Routines
//==============================================================================

var
  SMsgUsage : string;
  SMsgError : string;
  FileMask: string;
  DateTime, Date, Time: TDateTime;
  SubFolders: Boolean;
  FileCount: Integer;

//------------------------------------------------------------------------------
// Exits program with option of waiting

procedure ExitProgram(AMsg: string; Wait: Boolean);
begin
  WriteLn(AMsg);
  if Wait then
  begin
    WriteLn;
    WriteLn('Press "Enter" to continue...');
    ReadLn;
  end;
  Halt(0);
end;

//------------------------------------------------------------------------------
// Loads command line parameters

procedure LoadCMDParams;
var
  i, Exclude, Exclude2, Exclude3: Integer;
  S: string;
begin
// Check for "?" param
  if (Pos('?', ParamStr(1)) <> 0) then
    ExitProgram(SMsgUsage, True);

// Get Date parameter
  Date := Now;
  Exclude2 := 0;
  for i := ParamCount downto 1 do
    if (Pos('/', ParamStr(i)) > 1) then
    begin
      Date := StrToDate(ParamStr(i));
      Exclude2 := i;
      Break;
    end;

// Get Time parameter
  Time := Now;
  Exclude3 := 0;
  for i := ParamCount downto 1 do
    if (Pos('-', ParamStr(i)) > 0) then
    begin
      Time := StrToTime(ParamStr(i));
      Exclude3 := i;
      Break;
    end;

// Get SubFolders state
  SubFolders := False;
  Exclude := 0;
  for i := ParamCount downto 1 do
    if (Pos(SRecursive, AnsiUpperCase(ParamStr(i))) = 1) then
    begin
      SubFolders := True;
      Exclude := i;
      Break;
    end;

// Get File Mask 
  FileMask := abfAddSlash(abfSmartExpandRelativePath('')) + '*.*';
  for i := ParamCount downto 1 do
    if (i <> Exclude) and (i <> Exclude2) and (i <> Exclude3) then
    begin
      S := ExtractFileName(ParamStr(i));
      FileMask := abfAddSlash(
        abfSmartExpandRelativePath(ExtractFilePath(ParamStr(i)))) + S;
      Break;
    end;

/// Glue DateTime
  ReplaceDate(DateTime, Date);
  ReplaceTime(DateTime, Time);
end;{procedure LoadCMDParams}

//------------------------------------------------------------------------------
// Processes files

procedure _FilesCallback(const APath: string; const ASearchRec: TSearchRec;
  var AContinue: Boolean);
var
  FileName: string;
begin
  AContinue := True;

// Set FileName and show info
  FileName := abfAddSlash(APath) + ASearchRec.Name;
  WriteLn(Format('Setting date and time to "%s"', [FileName]));

// Change file's data and time
  abfSetFileDateTime(FileName, DateTime);
  Inc(FileCount);
end;

procedure SetDateTimeToFiles;
begin
  abfForEachFile(FileMask, faOnlyFiles, SubFolders, _FilesCallback);
end;

//------------------------------------------------------------------------------
// Main execution

procedure Execute;
begin
  DateSeparator   := SDateFormat[3];
  ShortDateFormat := SDateFormat;
  TimeSeparator  := STimeFormat[3];
  LongTimeFormat := STimeFormat;
// Run application
  try
    WriteLn(SMsgAppInfo);
    LoadCMDParams;
    SetDateTimeToFiles;
    if FileCount > 1 then WriteLn(Format(SMsgTotal, [FileCount]));
    ExitProgram(SMsgDone, False);
  except
    ExitProgram(CRLF + 'Fatal error: Maybe some files are locked.', False);
  end;
end;


{******************************************************************************}
initialization
{******************************************************************************}

  SMsgUsage := SMsgUsage1 + SMsgUsage2;
  SMsgError := SMsgUsage + CRLF + 'Error: ';


end{unit FileDateUnit}.

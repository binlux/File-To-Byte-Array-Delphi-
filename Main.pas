unit Main;
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, sBitBtn, sGauge, sDialogs, WinSkinData;

type
  TForm1 = class(TForm)
    edtFile: TEdit;
    btnFile: TButton;
    sgFile: TsGauge;
    btnConvert: TsBitBtn;
    odlg1: TsOpenDialog;
    skndt1: TSkinData;
    procedure btnConvertClick(Sender: TObject);
    function ConvertFile(sFile: string; dFile: string): Boolean;
    procedure btnFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED}
{$STRINGCHECKS OFF} // For Delphi 2009

function TForm1.ConvertFile(sFile: string; dFile: string): Boolean;
var
  S: TStringBuilder;
  List: TStringList;
  EFile, i, c, BytesRead: Cardinal;
  FBytes: array of Byte;
  HFile: THandle;
begin
  Result := True;
  HFile := CreateFileW(PWideChar(sFile), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if HFile = INVALID_HANDLE_VALUE then
  begin
    MessageBoxA(Self.Handle, PAnsiChar('File does not exist'),
      PAnsiChar('me&delphi'), MB_OK + MB_ICONERROR);
    Result := False;
    Exit;
  end;
  S := TStringBuilder.Create;
  List := TStringList.Create;
  with S do
  begin
    try
      c := 0;
      btnFile.Enabled := False;
      btnConvert.Enabled := False;
      EFile := GetFileSize(HFile, nil);
      SetLength(FBytes, EFile);
      // SetFilePointer(HFile, 0, nil, FILE_BEGIN);
      ReadFile(HFile, Pointer(FBytes)^, EFile, BytesRead, nil);
      // ReadFile(HFile, FBytes[0], EFile, BytesRead, nil);
      Append(' const XM : array[1..');
      Append(EFile);
      Append('] of Byte = (');
      AppendLine;
      EFile := High(FBytes);
      sgFile.MinValue := 0;
      sgFile.MaxValue := EFile; // Error here if big file
      for i := 0 to EFile do
      begin
        Inc(c, 1);
        if (c = 16) then
        begin
          if (i = EFile) then
          begin
            Append('$');
            Append(IntToHex(FBytes[i], 2));
            AppendLine;
          end
          else
          begin
            Append('$');
            Append(IntToHex(FBytes[i], 2));
            Append(',');
            AppendLine;
          end;
          c := 0;
        end
        else if (i = EFile) then
        begin
          Append('$');
          Append(IntToHex(FBytes[i], 2));
          AppendLine;
        end
        else
        begin
          Append('$');
          Append(IntToHex(FBytes[i], 2));
          Append(', ');
        end;
        sgFile.Progress := i; // Error here if big file
        // Application.ProcessMessages;
      end;
      Append(');');
      List.Add(ToString);
      MessageBoxA(Self.Handle,
        PAnsiChar('File successfully converted and now copying it to disk '),
        PAnsiChar('me&delphi'), MB_OK + MB_ICONINFORMATION);
      CloseHandle(HFile);
      List.SaveToFile(dFile);
    finally
      Free;
      List.Free;
    end;
  end;
end;

procedure TForm1.btnConvertClick(Sender: TObject);
begin
  if ConvertFile(edtFile.Text, ExtractFilePath(Application.ExeName) +
    'DumpedFile.dmp') then
    MessageBoxA(Self.Handle, PAnsiChar('File copied and ready to use'),
      PAnsiChar('me&delphi'), MB_OK + MB_ICONINFORMATION);
  btnConvert.Enabled := True;
  btnFile.Enabled := True;
end;

procedure TForm1.btnFileClick(Sender: TObject);
begin
  if odlg1.Execute then
    edtFile.Text := odlg1.FileName;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  sgFile.Progress := 0;
end;

end.

program OpusToWav;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Windows,
  MMSystem,
  uLibOpusFile in 'uLibOpusFile.pas',
  uLibOpus in 'uLibOpus.pas';

procedure WriteWavHeader(Stream: TStream; rate, channels: Integer; DataSize: Cardinal);
const
  FOURCC_WAVE = $45564157;   { 'WAVE' }
  FOURCC_fmt = $20746D66;    { 'fmt ' }
  FOURCC_bext = $74786562;   { 'bext' }
  FOURCC_data = $61746164;   { 'data' }
  {*$IFNDEF  FOURCC_RIFF}
  FOURCC_RIFF = $46464952;   { 'RIFF' }
  FOURCC_LIST = $5453494C;   { 'LIST' }
  {*$ENDIF}
type
  Tck_Header=  packed record
                 ckId: FOURCC;
                 ckSize: DWORD;
               end;
  TPCM_Header= packed record
                 FormatTag: WORD;
                 nChannels: WORD;
                 nSamplesPerSec: DWORD;
                 nAvgBytesPerSec: DWORD;
                 nBlockAlign: WORD;
                 nBitsPerSample: WORD;
               end;
var
  stdFMTChunk:
    packed Record
      fmtChunk: Tck_Header;
      WAVE_Header: TPCM_Header;
    end;
  Data: Cardinal;
  DataChunk: Tck_Header;
begin
  Stream.Position := 0;
  Data := FOURCC_RIFF;
  Stream.WriteBuffer(Data, SizeOf(Data));
  Data := DataSize + SizeOf(stdFMTChunk) + SizeOf(Tck_Header) + SizeOf(FOURCC_WAVE);
  Stream.WriteBuffer(Data, SizeOf(Data));
  Data := FOURCC_WAVE;
  Stream.WriteBuffer(Data, SizeOf(Data));
  stdFMTChunk.fmtChunk.ckId := FOURCC_fmt;
  stdFMTChunk.fmtChunk.ckSize := SizeOf(TPCM_Header);
  with stdFMTChunk.WAVE_Header do
  begin
    FormatTag := 1;
    nChannels := channels;
    nSamplesPerSec := rate;
    nAvgBytesPerSec := rate * channels * 2;
    nBlockAlign := channels * 2;
    nBitsPerSample := 16;
  end;
  Stream.WriteBuffer(stdFMTChunk, SizeOf(stdFMTChunk));
  DataChunk.ckId := FOURCC_data;
  DataChunk.ckSize := DataSize;
  Stream.WriteBuffer(DataChunk, SizeOf(DataChunk));
end;

{$IF not declared(RawByteString)}
type
  RawByteString = AnsiString;
{$IFEND}

function AnsiToOEM(const S: String): AnsiString;
var
  Len: Integer;
begin
  Len := Length(S);
  SetLength(Result, Len);
  CharToOemBuff(PChar(S), Pointer(Result), Len);
end;

var
  vf: TOggOpusFile;
  OpusTag: POpusTags;
  LComment: PPAnsiChar;
  LcommentLength: PInteger;
  s: UTF8String;
  j: Integer;
  ChannelNumber: Integer;
  Outfile: TFileStream;
  UTF8Filename: UTF8String;
  buffer: Pointer;
  buffersize: Integer;
  samples_read: Integer;
  Error: Integer;
begin
  try
    LoadLibOpus;
    WriteLn(AnsiToOEM(Format('LibOpus Version %s', [UTF8ToAnsi(opus_get_version_string)])));
    LoadLibOpusFile;
    UTF8Filename := AnsiToUtf8(ParamStr(1));
    vf := op_test_file(Pointer(UTF8Filename), Error);
    if Error=0
    then begin
      try
        Error := op_test_open(vf);
        if (Error=0) and (op_link_count(vf)=1)
        then begin
          OpusTag := op_tags(vf, 0);
          if OpusTag<>nil
          then begin
            if OpusTag.comments>0
            then begin
              WriteLn(AnsiToOEM(Format('OpusTag.comments = %d', [OpusTag.comments])));
              LComment := OpusTag.user_comments;
              LcommentLength := OpusTag.comment_lengths;
              for j := 0 to OpusTag.comments - 1 do
              begin
                SetLength(s, LcommentLength^);
                move(Pointer(LComment^)^, Pointer(s)^, LcommentLength^);
                WriteLn(AnsiToOEM(Format('Comment %d: "%s"', [j+1, UTF8ToAnsi(s)])));
                inc(LComment);
                inc(LcommentLength);
              end;
            end;
            WriteLn(AnsiToOEM(Format('OpusTag.vendor = %s', [UTF8ToAnsi(OpusTag.vendor)])));
          end;
          ChannelNumber := op_channel_count(vf, 0);
          WriteLn(AnsiToOEM(Format('Channels = %d', [ChannelNumber])));
          WriteLn(AnsiToOEM(Format('op_pcm_total = %d', [op_pcm_total(vf, 0)])));
          WriteLn(AnsiToOEM(Format('op_bitrate = %d', [op_bitrate(vf, 0)])));
          buffer := nil;
          Outfile := TFileStream.Create(ParamStr(2), fmCreate);
          try
            WriteWavHeader(Outfile, 48000, ChannelNumber, op_pcm_total(vf, 0) * ChannelNumber * SizeOf(SmallInt));
            buffersize := 5760 * ChannelNumber;
            GetMem(buffer, buffersize * SizeOf(SmallInt));
            repeat
              samples_read := op_read(vf, buffer^, buffersize, nil);
              Outfile.Write(buffer^, samples_read * ChannelNumber * SizeOf(SmallInt));
            until samples_read<=0;
          finally
            Outfile.Free;
            FreeMem(buffer);
          end;
        end;
      finally
        op_free(vf);
      end;
    end;
    FreeLibOpusFile;
    FreeLibOpus;
  except
    on E:Exception do
      WriteLn(E.Classname, ': ', AnsiToOEM(E.Message));
  end;
end.

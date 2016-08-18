program opus_trivial_example;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  uLibOpus in 'uLibOpus.pas';

const
  cFRAME_SIZE = 960;
  cSAMPLE_RATE = 48000;
  cCHANNELS = 2;
  cAPPLICATION = OPUS_APPLICATION_AUDIO;
  cBITRATE = 64000;
  cMAX_FRAME_SIZE = 6 * 960;
  cMAX_PACKET_SIZE = 3 * 1276;

var
  inFile: String;
  outFile: String;
  fin: TFileStream;
  fout: TFileStream;
  PCMIn: array [0..cFRAME_SIZE * cCHANNELS - 1] of SmallInt;
  PCMOut: array [0..cMAX_FRAME_SIZE * cCHANNELS - 1] of SmallInt;
  cbits: array [0..cMAX_PACKET_SIZE - 1] of Byte;
  nbBytes: Integer;
  nSamples: Integer;
  encoder: TOpusEncoder;
  decoder: TOpusDecoder;
  err: Integer;

  pcm_bytes: array [0..cMAX_FRAME_SIZE * cCHANNELS * SizeOf(SmallInt) - 1] of Byte;
  i: Integer;
  frame_size: Integer;

begin
  try
    ExitCode := 1;
    if ParamCount<>2
    then begin
      WriteLn('usage: opus_trivial_example input.pcm output.pcm');
      WriteLn('input and output are 16-bit little-endian raw files');
      exit;
    end;
    fin := nil;
    fout := nil;
    decoder := nil;
    LoadLibOpus;
    // Create a new encoder state
    encoder := opus_encoder_create(cSAMPLE_RATE, cCHANNELS, cAPPLICATION, err);
    try
      if (err<0)
      then begin
        WriteLn(Format('failed to create an encoder: %s', [opus_strerror(err)]));
        exit;
      end;
      err := opus_encoder_ctl(encoder, OPUS_SET_BITRATE(cBITRATE));
      if (err<0)
      then begin
        WriteLn(Format('failed to set bitrate: %s', [opus_strerror(err)]));
        exit;
      end;
      inFile := ParamStr(1);
      fin := TFileStream.Create(inFile, fmOpenRead);
      // Create a new decoder state.
      decoder := opus_decoder_create(cSAMPLE_RATE, cCHANNELS, err);
      if (err<0)
      then begin
        WriteLn(Format('failed to create decoder: %s', [opus_strerror(err)]));
        exit;
      end;
      outFile := ParamStr(2);
      fout := TFileStream.Create(outFile, fmCreate);
      while true do
      begin
        // Read a 16 bits/sample audio frame.
        nbBytes := fin.Read(pcm_bytes, cFRAME_SIZE * cCHANNELS * SizeOf(SmallInt));
        if nbBytes=0
        then
          break;
        nSamples := nbBytes div SizeOf(SmallInt);
        // Convert from little-endian ordering.
        for i := 0 to nSamples-1 do
          PCMIn[i] := (pcm_bytes[2*i+1] shl 8) or pcm_bytes[2*i];
        frame_size := nSamples div cChannels;
        if frame_size<cFRAME_SIZE
        then begin
          // pad frame to cFRAME_SIZE
          for i := nSamples to cFRAME_SIZE * cCHANNELS - 1 do
            PCMIn[i] := 0;
        end;
        // Encode the frame (native-endian ordering).
        nbBytes := opus_encode(encoder, PCMIn, cFRAME_SIZE, cbits, cMAX_PACKET_SIZE);
        if (nbBytes<0)
        then begin
          WriteLn(Format('encode failed: %s', [opus_strerror(nbBytes)]));
          exit;
        end;
        // Decode the data (native-endian ordering).
        frame_size := opus_decode(decoder, cbits, nbBytes, PCMOut, cMAX_FRAME_SIZE, 0);
        if (frame_size<0)
        then begin
          WriteLn(Format('decoder failed: %s', [opus_strerror(frame_size)]));
          exit;
        end;
        nSamples := frame_size * cChannels;
        // Convert to little-endian ordering
        for i := 0 to nSamples - 1 do
        begin
          pcm_bytes[2*i] := Lo(PCMOut[i]);
          pcm_bytes[2*i+1] := Hi(PCMOut[i]);
        end;
        nbBytes := nSamples * SizeOf(SmallInt);
        fout.WriteBuffer(pcm_bytes, nbBytes);
      end;
      ExitCode := 0;
    finally
      fin.Free;
      fout.Free;
      opus_encoder_destroy(encoder);
      opus_decoder_destroy(decoder);
    end;
  except
    on E:Exception do
    begin
      Writeln(E.Classname, ': ', E.Message);
    end;
  end;
end.

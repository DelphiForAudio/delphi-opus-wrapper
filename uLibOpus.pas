unit uLibOpus;

interface

{.$Define AD}

const
  OPUS_OK = 0;
  OPUS_BAD_ARG = -1;
  OPUS_BUFFER_TOO_SMALL = -2;
  OPUS_INTERNAL_ERROR = -3;
  OPUS_INVALID_PACKET = -4;
  OPUS_UNIMPLEMENTED = -5;
  OPUS_INVALID_STATE = -6;
  OPUS_ALLOC_FAIL = -7;

  OPUS_APPLICATION_VOIP = 2048;
  OPUS_APPLICATION_AUDIO = 2049;
  OPUS_APPLICATION_RESTRICTED_LOWDELAY = 2051;

  OPUS_SIGNAL_VOICE = 3001; // Signal being encoded is voice
  OPUS_SIGNAL_MUSIC = 3002; // Signal being encoded is music

  OPUS_BANDWIDTH_NARROWBAND = 1101; // 4 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_MEDIUMBAND = 1102; // 6 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_WIDEBAND = 1103;  // 8 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_SUPERWIDEBAND = 1104; // 12 kHz bandpass @hideinitializer
  OPUS_BANDWIDTH_FULLBAND = 1105; // 20 kHz bandpass @hideinitializer

  OPUS_FRAMESIZE_ARG = 5000; // Select frame size from the argument (default)
  OPUS_FRAMESIZE_2_5_MS = 5001; // Use 2.5 ms frames
  OPUS_FRAMESIZE_5_MS = 5002; // Use 5 ms frames
  OPUS_FRAMESIZE_10_MS = 5003; // Use 10 ms frames
  OPUS_FRAMESIZE_20_MS = 5004; // Use 20 ms frames
  OPUS_FRAMESIZE_40_MS = 5005; // Use 40 ms frames
  OPUS_FRAMESIZE_60_MS = 5006; // Use 60 ms frames
  OPUS_FRAMESIZE_80_MS = 5007; // Use 80 ms frames
  OPUS_FRAMESIZE_100_MS = 5008; // Use 100 ms frames
  OPUS_FRAMESIZE_120_MS = 5009; // Use 120 ms frames

const
  OPUS_SET_APPLICATION_REQUEST = 4000;
  OPUS_GET_APPLICATION_REQUEST = 4001;
  OPUS_SET_BITRATE_REQUEST = 4002;
  OPUS_GET_BITRATE_REQUEST = 4003;
  OPUS_SET_MAX_BANDWIDTH_REQUEST = 4004;
  OPUS_GET_MAX_BANDWIDTH_REQUEST = 4005;
  OPUS_SET_VBR_REQUEST = 4006;
  OPUS_GET_VBR_REQUEST = 4007;
  OPUS_SET_BANDWIDTH_REQUEST = 4008;
  OPUS_GET_BANDWIDTH_REQUEST = 4009;
  OPUS_SET_COMPLEXITY_REQUEST = 4010;
  OPUS_GET_COMPLEXITY_REQUEST = 4011;
  OPUS_SET_INBAND_FEC_REQUEST = 4012;
  OPUS_GET_INBAND_FEC_REQUEST = 4013;
  OPUS_SET_PACKET_LOSS_PERC_REQUEST = 4014;
  OPUS_GET_PACKET_LOSS_PERC_REQUEST = 4015;
  OPUS_SET_DTX_REQUEST = 4016;
  OPUS_GET_DTX_REQUEST = 4017;
  OPUS_SET_VBR_CONSTRAINT_REQUEST = 4020;
  OPUS_GET_VBR_CONSTRAINT_REQUEST = 4021;
  OPUS_SET_FORCE_CHANNELS_REQUEST = 4022;
  OPUS_GET_FORCE_CHANNELS_REQUEST = 4023;
  OPUS_SET_SIGNAL_REQUEST = 4024;
  OPUS_GET_SIGNAL_REQUEST = 4025;
  OPUS_GET_LOOKAHEAD_REQUEST = 4027;
  OPUS_RESET_STATE_REQUEST = 4028;
  OPUS_GET_SAMPLE_RATE_REQUEST = 4029;
  OPUS_GET_FINAL_RANGE_REQUEST = 4031;
  OPUS_GET_PITCH_REQUEST = 4033;
  OPUS_SET_GAIN_REQUEST = 4034;
  OPUS_GET_GAIN_REQUEST = 4045;
  OPUS_SET_LSB_DEPTH_REQUEST = 4036;
  OPUS_GET_LSB_DEPTH_REQUEST = 4037;
  OPUS_GET_LAST_PACKET_DURATION_REQUEST = 4039;
  OPUS_SET_EXPERT_FRAME_DURATION_REQUEST = 4040;
  OPUS_GET_EXPERT_FRAME_DURATION_REQUEST = 4041;
  OPUS_SET_PREDICTION_DISABLED_REQUEST = 4042;
  OPUS_GET_PREDICTION_DISABLED_REQUEST = 4043;
  OPUS_SET_PHASE_INVERSION_DISABLED_REQUEST = 4046;
  OPUS_GET_PHASE_INVERSION_DISABLED_REQUEST = 4047;
  OPUS_MULTISTREAM_GET_ENCODER_STATE_REQUEST = 5120;
  OPUS_MULTISTREAM_GET_DECODER_STATE_REQUEST = 5122;

function opus_get_version_string: PAnsiChar;
function opus_strerror(error: Integer): PAnsiChar;

type
  TOpusEncoder = Pointer;
  TOpusDecoder = Pointer;
  TOpusRepacketizer = Pointer;
  TOpusMSDecoder = pointer;
  TOpusMSEncoder = pointer;

  TOpusFrames = array [0..47] of Pointer;
//  POpusFrames = ^TOpusFrames;
  TOpusFrameSizes = array [0..47] of Integer;

type
  TRequestValueType = (orPointer, orInteger, orXY, orNoValue);
  TOpusCTLRequestRecord = record
    Request: Word;
    case ReqType: TRequestValueType of
      orPointer: (PtrValue: Pointer);
      orInteger: (IntValue: Integer);
      orXY: (XValue: Integer; YValue: Pointer);
  end;

function opus_encode(st: TOpusEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
function opus_encode_float(st: TOpusEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
function opus_encoder_create(Fs: Integer; channels, application: Integer; out error: Integer): TOpusEncoder;
function opus_encoder_ctl(st: TOpusEncoder; const req: TOpusCTLRequestRecord): Integer;
procedure opus_encoder_destroy(st: TOpusEncoder);
function opus_encoder_get_size(channels: Integer): Integer;
function opus_encoder_init(st: TOpusEncoder; Fs: Integer; channels, application: Integer): Integer;

function opus_decode(st: TOpusDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
function opus_decode_float(st: TOpusDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
function opus_decoder_create(fs: Integer; channels: Integer; out error: Integer): TOpusDecoder;
function opus_decoder_ctl(st: TOpusDecoder; const req: TOpusCTLRequestRecord): Integer;
procedure opus_decoder_destroy(st: TOpusDecoder);
function opus_decoder_get_nb_samples(st: TOpusDecoder; const packet; len: Integer): Integer;
function opus_decoder_get_size(channels: Integer): Integer;
function opus_decoder_init(st: TOpusDecoder; Fs: Integer; channels: Integer): Integer;
function opus_packet_get_bandwidth(const packet): Integer;
function opus_packet_get_nb_channels(const packet): Integer;
function opus_packet_get_nb_frames(const packet; len: Integer): Integer;
function opus_packet_get_nb_samples(const packet; len, fs: Integer): Integer;
function opus_packet_get_samples_per_frame(const packet; fs: Integer): Integer;
function opus_packet_parse(const packet; var out_toc: Pointer; var frames: TOpusFrames; var size: TOpusFrameSizes; var payload_offset: Integer): Integer;
procedure opus_pcm_soft_clip(const pcm; frame_size, channels: Integer; var softclip_mem: Double);

function opus_multistream_packet_pad(var data; len, new_len, nb_streams: Integer): Integer;
function opus_multistream_packet_unpad(var data; len, nb_streams: Integer): Integer;
function opus_packet_pad(var data; len, new_len: Integer): Integer;
function opus_packet_unpad(var data; len: Integer): Integer;
function opus_repacketizer_cat(rp: TOpusRepacketizer; const data; len: Integer): Integer;
function opus_repacketizer_create: TOpusRepacketizer;
procedure opus_repacketizer_destroy(rp: TOpusRepacketizer);
function opus_repacketizer_get_nb_frames(rp: TOpusRepacketizer): Integer;
function opus_repacketizer_get_size: Integer;
function opus_repacketizer_init(rp: TOpusRepacketizer): TOpusRepacketizer;
function opus_repacketizer_out(rp: TOpusRepacketizer; var data; maxlen: Integer): Integer;
function opus_repacketizer_out_range(rp: TOpusRepacketizer; var data; maxlen: Integer): Integer;

function opus_multistream_decode(st: TOpusMSDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
function opus_multistream_decode_float(st: TOpusMSDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
function opus_multistream_decoder_create(fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; out error: Integer): TOpusMSDecoder;
function opus_multistream_decoder_ctl(st: TOpusMSDecoder; const req: TOpusCTLRequestRecord): Integer;
procedure opus_multistream_decoder_destroy(st: TOpusMSDecoder);
function opus_multistream_decoder_get_size(streams, coupled_streams: Integer): Integer;
function opus_multistream_decoder_init(st: TOpusMSDecoder; fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte): Integer;

function opus_multistream_encode(st: TOpusMSEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
function opus_multistream_encode_float(st: TOpusMSEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
function opus_multistream_encoder_create(Fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer; out error: Integer): TOpusMSEncoder;
function opus_multistream_encoder_ctl(st: TOpusMSEncoder; const req: TOpusCTLRequestRecord): Integer;
procedure opus_multistream_encoder_destroy(st: TOpusMSEncoder);
function opus_multistream_encoder_get_size(streams, coupled_streams: Integer): Integer;
function opus_multistream_encoder_init(st: TOpusMSEncoder; fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer): Integer;

function opus_multistream_surround_encoder_create(Fs: Integer; channels, mapping_family, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer; out error: Integer): TOpusMSEncoder;
function opus_multistream_surround_encoder_get_size(channels, mapping_family: Integer): Integer;
function opus_multistream_surround_encoder_init(st: TOpusMSEncoder; fs: Integer; channels, mapping_family, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer): Integer;

// These are convenience macros for use with the opus_encode_ctl interface.
function OPUS_GET_APPLICATION(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_BITRATE(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_COMPLEXITY(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_DTX(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_EXPERT_FRAME_DURATION(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_FORCE_CHANNELS(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_LOOKAHEAD(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_LSB_DEPTH(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_MAX_BANDWIDTH(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_PACKET_LOSS_PERC(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_PREDICTION_DISABLED(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_SIGNAL(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_VBR(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_VBR_CONSTRAINT(var x: Integer): TOpusCTLRequestRecord; inline;

function OPUS_SET_APPLICATION(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_BANDWIDTH(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_BITRATE(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_COMPLEXITY(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_DTX(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_EXPERT_FRAME_DURATION(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_FORCE_CHANNELS(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_INBAND_FEC(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_LSB_DEPTH(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_MAX_BANDWIDTH(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_PACKET_LOSS_PERC(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_PREDICTION_DISABLED(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_SIGNAL(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_VBR(x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_VBR_CONSTRAINT(x: Integer): TOpusCTLRequestRecord; inline;

// These macros are used with the opus_decoder_ctl and opus_encoder_ctl calls to generate a particular request.
function OPUS_GET_BANDWIDTH(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_FINAL_RANGE(var x: Cardinal): TOpusCTLRequestRecord; inline;
function OPUS_GET_SAMPLE_RATE(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_RESET_STATE: TOpusCTLRequestRecord; inline;
function OPUS_GET_PHASE_INVERSION_DISABLED(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_PHASE_INVERSION_DISABLED(x: Integer): TOpusCTLRequestRecord; inline;

// These are convenience macros for use with the opus_decode_ctl interface.
function OPUS_GET_GAIN(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_LAST_PACKET_DURATION(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_GET_PITCH(var x: Integer): TOpusCTLRequestRecord; inline;
function OPUS_SET_GAIN(x: Integer): TOpusCTLRequestRecord; inline;

function OPUS_MULTISTREAM_GET_DECODER_STATE(x: Integer; var y: Integer): TOpusCTLRequestRecord; inline;
function OPUS_MULTISTREAM_GET_ENCODER_STATE(x: Integer; var y: Integer): TOpusCTLRequestRecord; inline;

function FreeLibOpus: Boolean;
procedure LoadLibOpus(LibName: PChar=nil);               //raise exception
function SilentLibOpus(LibName: PChar=nil): Boolean;

implementation

uses
  {$IFDEF AD}
  uadConsts,
  {$ENDIF}
  Windows, SysUtils;

const
  StrLibName = 'libopus-0.dll';
  Lib_Undefined = StrLibName + ' not loaded';

{$IFNDEF AD}
resourcestring
  EProcNotFound = 'Procedure "%1:s"  not found in library "%0:s"';
  ELibraryNotFound = 'The error "Library not found" occurred during loading of "%s"';
{$ENDIF}

var
  hlib: THandle;
  lib_UnInit: array of pointer;

function FreeLibOpus: Boolean;
var
  i: Integer;
begin
  Result := FreeLibrary(hlib);
  if Result
  then begin
    hlib := 0;
    for i:=Length(lib_UnInit)-1 downto 0 do
    begin
      pointer(lib_UnInit[i]^) := nil;
    end;
    lib_UnInit := nil;
  end;
end;

procedure LoadLibOpus(LibName: PChar=nil);               //Laden mit Exception
var
  err: DWORD;
begin
  if hlib=0
  then begin
    if LibName=''
    then
      LibName := StrLibName;
    hlib := LoadLibrary(LibName);
    if hlib=0
    then begin
      err := GetLastError;
      if err=ERROR_MOD_NOT_FOUND
      then
        raise Exception.CreateFmt(ELibraryNotFound, [String(LibName)])
      else
        raise Exception.CreateFmt('%s - %s', [SysErrorMessage(err), String(LibName)]);
    end;
  end;
end;

function SilentLibOpus(LibName: PChar=nil): Boolean;
begin
  if hlib=0
  then begin
    if LibName=''
    then
      LibName := StrLibName;
    hlib := LoadLibrary(LibName);
  end;
  Result := hlib<>0;
end;

procedure LoadProcAddress(var proc: FARPROC; name: PAnsiChar);
var
  Index: Integer;
  TempModuleName: String;
begin
  proc := GetProcAddress(hlib, name);
  if proc = nil
  then begin
    if hlib=0
    then
      raise Exception.Create(Lib_Undefined);
    SetLength(TempModuleName, MAX_PATH+1);
    SetLength(TempModuleName, GetModuleFileName(hlib, Pointer(TempModuleName), Length(TempModuleName)));
    raise Exception.CreateFmt(EProcNotFound, [TempModuleName, String(name)]);
  end;
  Index := Length(lib_UnInit);
  SetLength(lib_UnInit, Index+1);
  lib_UnInit[Index] := @proc;
end;


var
  _opus_get_version_string: function(): PAnsiChar; cdecl;

function opus_get_version_string(): PAnsiChar;
begin
  if @_opus_get_version_string = nil
  then
    LoadProcAddress(@_opus_get_version_string, 'opus_get_version_string');
  Result := _opus_get_version_string();
end;

var
  _opus_strerror: function(error: Integer): PAnsiChar; cdecl;

function opus_strerror(error: Integer): PAnsiChar;
begin
  if @_opus_strerror = nil
  then
    LoadProcAddress(@_opus_strerror, 'opus_strerror');
  Result := _opus_strerror(error);
end;

var
  _opus_encode: function(st: TOpusEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer; cdecl;

function opus_encode(st: TOpusEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
begin
  if @_opus_encode = nil
  then
    LoadProcAddress(@_opus_encode, 'opus_encode');
  Result := _opus_encode(st, pcm, frame_size, data, max_data_bytes);
end;

var
  _opus_encode_float: function(st: TOpusEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer; cdecl;

function opus_encode_float(st: TOpusEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
begin
  if @_opus_encode_float = nil
  then
    LoadProcAddress(@_opus_encode_float, 'opus_encode_float');
  Result := _opus_encode_float(st, pcm, frame_size, data, max_data_bytes);
end;

var
  _opus_encoder_create: function(Fs: Integer; channels, application: Integer; out error: Integer): TOpusEncoder; cdecl;

function opus_encoder_create(Fs: Integer; channels, application: Integer; out error: Integer): TOpusEncoder;
begin
  if @_opus_encoder_create = nil
  then
    LoadProcAddress(@_opus_encoder_create, 'opus_encoder_create');
  Result := _opus_encoder_create(Fs, channels, application, error);
end;

var
  _opus_encoder_destroy: procedure(st: TOpusEncoder); cdecl;

procedure opus_encoder_destroy(st: TOpusEncoder);
begin
  if @_opus_encoder_destroy = nil
  then
    LoadProcAddress(@_opus_encoder_destroy, 'opus_encoder_destroy');
  _opus_encoder_destroy(st);
end;

var
  _opus_encoder_get_size: function(channels: Integer): Integer; cdecl;

function opus_encoder_get_size(channels: Integer): Integer;
begin
  if @_opus_encoder_get_size = nil
  then
    LoadProcAddress(@_opus_encoder_get_size, 'opus_encoder_get_size');
  Result := _opus_encoder_get_size(channels);
end;

var
  _opus_encoder_init: function(st: TOpusEncoder; Fs: Integer; channels, application: Integer): Integer; cdecl;

function opus_encoder_init(st: TOpusEncoder; Fs: Integer; channels, application: Integer): Integer;
begin
  if @_opus_encoder_init = nil
  then
    LoadProcAddress(@_opus_encoder_init, 'opus_encoder_init');
  Result := _opus_encoder_init(st, Fs, channels, application);
end;

var
  _opus_decode: function(st: TOpusDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer; cdecl;

function opus_decode(st: TOpusDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
begin
  if @_opus_decode = nil
  then
    LoadProcAddress(@_opus_decode, 'opus_decode');
  Result := _opus_decode(st, data, len, pcm, frame_size, decode_fec);
end;

var
  _opus_decode_float: function(st: TOpusDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer; cdecl;

function opus_decode_float(st: TOpusDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
begin
  if @_opus_decode_float = nil
  then
    LoadProcAddress(@_opus_decode_float, 'opus_decode_float');
  Result := _opus_decode_float(st, data, len, pcm, frame_size, decode_fec);
end;

var
  _opus_decoder_create: function(fs: Integer; channels: Integer; out error: Integer): TOpusDecoder; cdecl;

function opus_decoder_create(fs: Integer; channels: Integer; out error: Integer): TOpusDecoder;
begin
  if @_opus_decoder_create = nil
  then
    LoadProcAddress(@_opus_decoder_create, 'opus_decoder_create');
  Result := _opus_decoder_create(fs, channels, error);
end;

var
  _opus_decoder_destroy: procedure(st: TOpusDecoder); cdecl;

procedure opus_decoder_destroy(st: TOpusDecoder);
begin
  if @_opus_decoder_destroy = nil
  then
    LoadProcAddress(@_opus_decoder_destroy, 'opus_decoder_destroy');
  _opus_decoder_destroy(st);
end;

var
  _opus_decoder_get_nb_samples: function(st: TOpusDecoder; const packet; len: Integer): Integer; cdecl;

function opus_decoder_get_nb_samples(st: TOpusDecoder; const packet; len: Integer): Integer;
begin
  if @_opus_decoder_get_nb_samples = nil
  then
    LoadProcAddress(@_opus_decoder_get_nb_samples, 'opus_decoder_get_nb_samples');
  Result := _opus_decoder_get_nb_samples(st, packet, len);
end;

var
  _opus_decoder_get_size: function(channels: Integer): Integer; cdecl;

function opus_decoder_get_size(channels: Integer): Integer;
begin
  if @_opus_decoder_get_size = nil
  then
    LoadProcAddress(@_opus_decoder_get_size, 'opus_decoder_get_size');
  Result := _opus_decoder_get_size(channels);
end;

var
  _opus_decoder_init: function(st: TOpusDecoder; Fs: Integer; channels: Integer): Integer; cdecl;

function opus_decoder_init(st: TOpusDecoder; Fs: Integer; channels: Integer): Integer;
begin
  if @_opus_decoder_init = nil
  then
    LoadProcAddress(@_opus_decoder_init, 'opus_decoder_init');
  Result := _opus_decoder_init(st, Fs, channels);
end;

var
  _opus_packet_get_bandwidth: function(const packet): Integer; cdecl;

function opus_packet_get_bandwidth(const packet): Integer;
begin
  if @_opus_packet_get_bandwidth = nil
  then
    LoadProcAddress(@_opus_packet_get_bandwidth, 'opus_packet_get_bandwidth');
  Result := _opus_packet_get_bandwidth(packet);
end;

var
  _opus_packet_get_nb_channels: function(const packet): Integer; cdecl;

function opus_packet_get_nb_channels(const packet): Integer;
begin
  if @_opus_packet_get_nb_channels = nil
  then
    LoadProcAddress(@_opus_packet_get_nb_channels, 'opus_packet_get_nb_channels');
  Result := _opus_packet_get_nb_channels(packet);
end;

var
  _opus_packet_get_nb_frames: function(const packet; len: Integer): Integer; cdecl;

function opus_packet_get_nb_frames(const packet; len: Integer): Integer;
begin
  if @_opus_packet_get_nb_frames = nil
  then
    LoadProcAddress(@_opus_packet_get_nb_frames, 'opus_packet_get_nb_frames');
  Result := _opus_packet_get_nb_frames(packet, len);
end;

var
  _opus_packet_get_nb_samples: function(const packet; len, fs: Integer): Integer; cdecl;

function opus_packet_get_nb_samples(const packet; len, fs: Integer): Integer;
begin
  if @_opus_packet_get_nb_samples = nil
  then
    LoadProcAddress(@_opus_packet_get_nb_samples, 'opus_packet_get_nb_samples');
  Result := _opus_packet_get_nb_samples(packet, len, fs);
end;

var
  _opus_packet_get_samples_per_frame: function(const packet; fs: Integer): Integer; cdecl;

function opus_packet_get_samples_per_frame(const packet; fs: Integer): Integer;
begin
  if @_opus_packet_get_samples_per_frame = nil
  then
    LoadProcAddress(@_opus_packet_get_samples_per_frame, 'opus_packet_get_samples_per_frame');
  Result := _opus_packet_get_samples_per_frame(packet, fs);
end;

var
  _opus_packet_parse: function(const packet; var out_toc: Pointer; var frames: TOpusFrames; var size: TOpusFrameSizes; var payload_offset: Integer): Integer; cdecl;

function opus_packet_parse(const packet; var out_toc: Pointer; var frames: TOpusFrames; var size: TOpusFrameSizes; var payload_offset: Integer): Integer;
begin
  if @_opus_packet_parse = nil
  then
    LoadProcAddress(@_opus_packet_parse, 'opus_packet_parse');
  Result := _opus_packet_parse(packet, out_toc, frames, size, payload_offset);
end;

var
  _opus_pcm_soft_clip: procedure(const pcm; frame_size, channels: Integer; var softclip_mem: Double); cdecl;

procedure opus_pcm_soft_clip(const pcm; frame_size, channels: Integer; var softclip_mem: Double);
begin
  if @_opus_pcm_soft_clip = nil
  then
    LoadProcAddress(@_opus_pcm_soft_clip, 'opus_pcm_soft_clip');
  _opus_pcm_soft_clip(pcm, frame_size, channels, softclip_mem);
end;

var
  _opus_multistream_packet_pad: function(var data; len, new_len, nb_streams: Integer): Integer; cdecl;

function opus_multistream_packet_pad(var data; len, new_len, nb_streams: Integer): Integer;
begin
  if @_opus_multistream_packet_pad = nil
  then
    LoadProcAddress(@_opus_multistream_packet_pad, 'opus_multistream_packet_pad');
  Result := _opus_multistream_packet_pad(data, len, new_len, nb_streams);
end;

var
  _opus_multistream_packet_unpad: function(var data; len, nb_streams: Integer): Integer; cdecl;

function opus_multistream_packet_unpad(var data; len, nb_streams: Integer): Integer;
begin
  if @_opus_multistream_packet_unpad = nil
  then
    LoadProcAddress(@_opus_multistream_packet_unpad, 'opus_multistream_packet_unpad');
  Result := _opus_multistream_packet_unpad(data, len, nb_streams);
end;

var
  _opus_packet_pad: function(var data; len, new_len: Integer): Integer; cdecl;

function opus_packet_pad(var data; len, new_len: Integer): Integer;
begin
  if @_opus_packet_pad = nil
  then
    LoadProcAddress(@_opus_packet_pad, 'opus_packet_pad');
  Result := _opus_packet_pad(data, len, new_len);
end;

var
  _opus_packet_unpad: function(var data; len: Integer): Integer; cdecl;

function opus_packet_unpad(var data; len: Integer): Integer;
begin
  if @_opus_packet_unpad = nil
  then
    LoadProcAddress(@_opus_packet_unpad, 'opus_packet_unpad');
  Result := _opus_packet_unpad(data, len);
end;

var
  _opus_repacketizer_cat: function(rp: TOpusRepacketizer; const data; len: Integer): Integer; cdecl;

function opus_repacketizer_cat(rp: TOpusRepacketizer; const data; len: Integer): Integer;
begin
  if @_opus_repacketizer_cat = nil
  then
    LoadProcAddress(@_opus_repacketizer_cat, 'opus_repacketizer_cat');
  Result := _opus_repacketizer_cat(rp, data, len);
end;

var
  _opus_repacketizer_create: function(): TOpusRepacketizer; cdecl;

function opus_repacketizer_create(): TOpusRepacketizer;
begin
  if @_opus_repacketizer_create = nil
  then
    LoadProcAddress(@_opus_repacketizer_create, 'opus_repacketizer_create');
  Result := _opus_repacketizer_create();
end;

var
  _opus_repacketizer_destroy: procedure(rp: TOpusRepacketizer); cdecl;

procedure opus_repacketizer_destroy(rp: TOpusRepacketizer);
begin
  if @_opus_repacketizer_destroy = nil
  then
    LoadProcAddress(@_opus_repacketizer_destroy, 'opus_repacketizer_destroy');
  _opus_repacketizer_destroy(rp);
end;

var
  _opus_repacketizer_get_nb_frames: function(rp: TOpusRepacketizer): Integer; cdecl;

function opus_repacketizer_get_nb_frames(rp: TOpusRepacketizer): Integer;
begin
  if @_opus_repacketizer_get_nb_frames = nil
  then
    LoadProcAddress(@_opus_repacketizer_get_nb_frames, 'opus_repacketizer_get_nb_frames');
  Result := _opus_repacketizer_get_nb_frames(rp);
end;

var
  _opus_repacketizer_get_size: function(): Integer; cdecl;

function opus_repacketizer_get_size(): Integer;
begin
  if @_opus_repacketizer_get_size = nil
  then
    LoadProcAddress(@_opus_repacketizer_get_size, 'opus_repacketizer_get_size');
  Result := _opus_repacketizer_get_size();
end;

var
  _opus_repacketizer_init: function(rp: TOpusRepacketizer): TOpusRepacketizer; cdecl;

function opus_repacketizer_init(rp: TOpusRepacketizer): TOpusRepacketizer;
begin
  if @_opus_repacketizer_init = nil
  then
    LoadProcAddress(@_opus_repacketizer_init, 'opus_repacketizer_init');
  Result := _opus_repacketizer_init(rp);
end;

var
  _opus_repacketizer_out: function(rp: TOpusRepacketizer; var data; maxlen: Integer): Integer; cdecl;

function opus_repacketizer_out(rp: TOpusRepacketizer; var data; maxlen: Integer): Integer;
begin
  if @_opus_repacketizer_out = nil
  then
    LoadProcAddress(@_opus_repacketizer_out, 'opus_repacketizer_out');
  Result := _opus_repacketizer_out(rp, data, maxlen);
end;

var
  _opus_repacketizer_out_range: function(rp: TOpusRepacketizer; var data; maxlen: Integer): Integer; cdecl;

function opus_repacketizer_out_range(rp: TOpusRepacketizer; var data; maxlen: Integer): Integer;
begin
  if @_opus_repacketizer_out_range = nil
  then
    LoadProcAddress(@_opus_repacketizer_out_range, 'opus_repacketizer_out_range');
  Result := _opus_repacketizer_out_range(rp, data, maxlen);
end;

var
  _opus_multistream_decode: function(st: TOpusMSDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer; cdecl;

function opus_multistream_decode(st: TOpusMSDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
begin
  if @_opus_multistream_decode = nil
  then
    LoadProcAddress(@_opus_multistream_decode, 'opus_multistream_decode');
  Result := _opus_multistream_decode(st, data, len, pcm, frame_size, decode_fec);
end;

var
  _opus_multistream_decode_float: function(st: TOpusMSDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer; cdecl;

function opus_multistream_decode_float(st: TOpusMSDecoder; const data; len: Integer; var pcm; frame_size, decode_fec: Integer): Integer;
begin
  if @_opus_multistream_decode_float = nil
  then
    LoadProcAddress(@_opus_multistream_decode_float, 'opus_multistream_decode_float');
  Result := _opus_multistream_decode_float(st, data, len, pcm, frame_size, decode_fec);
end;

var
  _opus_multistream_decoder_create: function(fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; out error: Integer): TOpusMSDecoder; cdecl;

function opus_multistream_decoder_create(fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; out error: Integer): TOpusMSDecoder;
begin
  if @_opus_multistream_decoder_create = nil
  then
    LoadProcAddress(@_opus_multistream_decoder_create, 'opus_multistream_decoder_create');
  Result := _opus_multistream_decoder_create(fs, channels, streams, coupled_streams, mapping, error);
end;

var
  _opus_multistream_decoder_destroy: procedure(st: TOpusMSDecoder); cdecl;

procedure opus_multistream_decoder_destroy(st: TOpusMSDecoder);
begin
  if @_opus_multistream_decoder_destroy = nil
  then
    LoadProcAddress(@_opus_multistream_decoder_destroy, 'opus_multistream_decoder_destroy');
  _opus_multistream_decoder_destroy(st);
end;

var
  _opus_multistream_decoder_get_size: function(streams, coupled_streams: Integer): Integer; cdecl;

function opus_multistream_decoder_get_size(streams, coupled_streams: Integer): Integer;
begin
  if @_opus_multistream_decoder_get_size = nil
  then
    LoadProcAddress(@_opus_multistream_decoder_get_size, 'opus_multistream_decoder_get_size');
  Result := _opus_multistream_decoder_get_size(streams, coupled_streams);
end;

var
  _opus_multistream_decoder_init: function(st: TOpusMSDecoder; fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte): Integer; cdecl;

function opus_multistream_decoder_init(st: TOpusMSDecoder; fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte): Integer;
begin
  if @_opus_multistream_decoder_init = nil
  then
    LoadProcAddress(@_opus_multistream_decoder_init, 'opus_multistream_decoder_init');
  Result := _opus_multistream_decoder_init(st, fs, channels, streams, coupled_streams, mapping);
end;

var
  _opus_multistream_encode: function(st: TOpusMSEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer; cdecl;

function opus_multistream_encode(st: TOpusMSEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
begin
  if @_opus_multistream_encode = nil
  then
    LoadProcAddress(@_opus_multistream_encode, 'opus_multistream_encode');
  Result := _opus_multistream_encode(st, pcm, frame_size, data, max_data_bytes);
end;

var
  _opus_multistream_encode_float: function(st: TOpusMSEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer; cdecl;

function opus_multistream_encode_float(st: TOpusMSEncoder; const pcm; frame_size: Integer; var data; max_data_bytes: Integer): Integer;
begin
  if @_opus_multistream_encode_float = nil
  then
    LoadProcAddress(@_opus_multistream_encode_float, 'opus_multistream_encode_float');
  Result := _opus_multistream_encode_float(st, pcm, frame_size, data, max_data_bytes);
end;

var
  _opus_multistream_encoder_create: function(Fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer; out error: Integer): TOpusMSEncoder; cdecl;

function opus_multistream_encoder_create(Fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer; out error: Integer): TOpusMSEncoder;
begin
  if @_opus_multistream_encoder_create = nil
  then
    LoadProcAddress(@_opus_multistream_encoder_create, 'opus_multistream_encoder_create');
  Result := _opus_multistream_encoder_create(Fs, channels, streams, coupled_streams, mapping, application, error);
end;

var
  _opus_multistream_encoder_destroy: procedure(st: TOpusMSEncoder); cdecl;

procedure opus_multistream_encoder_destroy(st: TOpusMSEncoder);
begin
  if @_opus_multistream_encoder_destroy = nil
  then
    LoadProcAddress(@_opus_multistream_encoder_destroy, 'opus_multistream_encoder_destroy');
  _opus_multistream_encoder_destroy(st);
end;

var
  _opus_multistream_encoder_get_size: function(streams, coupled_streams: Integer): Integer; cdecl;

function opus_multistream_encoder_get_size(streams, coupled_streams: Integer): Integer;
begin
  if @_opus_multistream_encoder_get_size = nil
  then
    LoadProcAddress(@_opus_multistream_encoder_get_size, 'opus_multistream_encoder_get_size');
  Result := _opus_multistream_encoder_get_size(streams, coupled_streams);
end;

var
  _opus_multistream_encoder_init: function(st: TOpusMSEncoder; fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer): Integer; cdecl;

function opus_multistream_encoder_init(st: TOpusMSEncoder; fs: Integer; channels, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer): Integer;
begin
  if @_opus_multistream_encoder_init = nil
  then
    LoadProcAddress(@_opus_multistream_encoder_init, 'opus_multistream_encoder_init');
  Result := _opus_multistream_encoder_init(st, fs, channels, streams, coupled_streams, mapping, application);
end;

var
  _opus_multistream_surround_encoder_create: function(Fs: Integer; channels, mapping_family, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer; out error: Integer): TOpusMSEncoder; cdecl;

function opus_multistream_surround_encoder_create(Fs: Integer; channels, mapping_family, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer; out error: Integer): TOpusMSEncoder;
begin
  if @_opus_multistream_surround_encoder_create = nil
  then
    LoadProcAddress(@_opus_multistream_surround_encoder_create, 'opus_multistream_surround_encoder_create');
  Result := _opus_multistream_surround_encoder_create(Fs, channels, mapping_family, streams, coupled_streams, mapping, application, error);
end;

var
  _opus_multistream_surround_encoder_get_size: function(channels, mapping_family: Integer): Integer; cdecl;

function opus_multistream_surround_encoder_get_size(channels, mapping_family: Integer): Integer;
begin
  if @_opus_multistream_surround_encoder_get_size = nil
  then
    LoadProcAddress(@_opus_multistream_surround_encoder_get_size, 'opus_multistream_surround_encoder_get_size');
  Result := _opus_multistream_surround_encoder_get_size(channels, mapping_family);
end;

var
  _opus_multistream_surround_encoder_init: function(st: TOpusMSEncoder; fs: Integer; channels, mapping_family, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer): Integer; cdecl;

function opus_multistream_surround_encoder_init(st: TOpusMSEncoder; fs: Integer; channels, mapping_family, streams, coupled_streams: Integer; const mapping: array of Byte; application: Integer): Integer;
begin
  if @_opus_multistream_surround_encoder_init = nil
  then
    LoadProcAddress(@_opus_multistream_surround_encoder_init, 'opus_multistream_surround_encoder_init');
  Result := _opus_multistream_surround_encoder_init(st, fs, channels, mapping_family, streams, coupled_streams, mapping, application);
end;

var
  _opus_encoder_ctl: function(st: TOpusEncoder; req: Integer): Integer; cdecl varargs;

function opus_encoder_ctl(st: TOpusEncoder; const req: TOpusCTLRequestRecord): Integer;
begin
  if @_opus_encoder_ctl = nil
  then
    LoadProcAddress(@_opus_encoder_ctl, 'opus_encoder_ctl');
  case req.ReqType of
    orPointer: Result := _opus_encoder_ctl(st, req.Request, req.PtrValue);
    orInteger: Result := _opus_encoder_ctl(st, req.Request, req.IntValue);
    orXY: Result := _opus_encoder_ctl(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := _opus_encoder_ctl(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

var
  _opus_decoder_ctl: function(st: TOpusDecoder; req: Integer): Integer; cdecl varargs;

function opus_decoder_ctl(st: TOpusDecoder; const req: TOpusCTLRequestRecord): Integer;
begin
  if @_opus_decoder_ctl = nil
  then
    LoadProcAddress(@_opus_decoder_ctl, 'opus_decoder_ctl');
  case req.ReqType of
    orPointer: Result := _opus_decoder_ctl(st, req.Request, req.PtrValue);
    orInteger: Result := _opus_decoder_ctl(st, req.Request, req.IntValue);
    orXY: Result := _opus_decoder_ctl(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := _opus_decoder_ctl(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

var
  _opus_multistream_decoder_ctl: function(st: TOpusMSDecoder; req: Integer): Integer; cdecl varargs;

function opus_multistream_decoder_ctl(st: TOpusMSDecoder; const req: TOpusCTLRequestRecord): Integer;
begin
  if @_opus_multistream_decoder_ctl = nil
  then
    LoadProcAddress(@_opus_multistream_decoder_ctl, 'opus_multistream_decoder_ctl');
  case req.ReqType of
    orPointer: Result := _opus_multistream_decoder_ctl(st, req.Request, req.PtrValue);
    orInteger: Result := _opus_multistream_decoder_ctl(st, req.Request, req.IntValue);
    orXY: Result := _opus_multistream_decoder_ctl(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := _opus_multistream_decoder_ctl(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

var
  _opus_multistream_encoder_ctl: function(st: TOpusMSEncoder; req: Integer): Integer; cdecl varargs;

function opus_multistream_encoder_ctl(st: TOpusMSEncoder; const req: TOpusCTLRequestRecord): Integer;
begin
  if @_opus_multistream_encoder_ctl = nil
  then
    LoadProcAddress(@_opus_multistream_encoder_ctl, 'opus_multistream_encoder_ctl');
  case req.ReqType of
    orPointer: Result := _opus_multistream_encoder_ctl(st, req.Request, req.PtrValue);
    orInteger: Result := _opus_multistream_encoder_ctl(st, req.Request, req.IntValue);
    orXY: Result := _opus_multistream_encoder_ctl(st, req.Request, req.XValue, req.YValue);
    orNoValue: Result := _opus_multistream_encoder_ctl(st, req.Request);
  else
    Result := OPUS_BAD_ARG;
  end;
end;

function OPUS_GET_APPLICATION(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_APPLICATION_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_BITRATE(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BITRATE_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_COMPLEXITY(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_COMPLEXITY_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_DTX(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_DTX_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_EXPERT_FRAME_DURATION(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_EXPERT_FRAME_DURATION_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_FORCE_CHANNELS(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_FORCE_CHANNELS_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_LOOKAHEAD(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_LOOKAHEAD_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_LSB_DEPTH(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_LSB_DEPTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_MAX_BANDWIDTH(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_MAX_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PACKET_LOSS_PERC(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PACKET_LOSS_PERC_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PREDICTION_DISABLED(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PREDICTION_DISABLED_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_SIGNAL(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_SIGNAL_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_VBR(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_VBR_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_VBR_CONSTRAINT(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_VBR_CONSTRAINT_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PHASE_INVERSION_DISABLED(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PHASE_INVERSION_DISABLED_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_SET_APPLICATION(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_APPLICATION_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_BANDWIDTH(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_BANDWIDTH_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_BITRATE(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_BITRATE_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_COMPLEXITY(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_COMPLEXITY_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_DTX(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_DTX_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_EXPERT_FRAME_DURATION(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_EXPERT_FRAME_DURATION_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_FORCE_CHANNELS(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_FORCE_CHANNELS_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_INBAND_FEC(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_INBAND_FEC_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_LSB_DEPTH(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_LSB_DEPTH_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_MAX_BANDWIDTH(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_MAX_BANDWIDTH_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_PACKET_LOSS_PERC(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_PACKET_LOSS_PERC_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_PREDICTION_DISABLED(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_PREDICTION_DISABLED_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_SIGNAL(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_SIGNAL_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_VBR(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_VBR_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_VBR_CONSTRAINT(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_VBR_CONSTRAINT_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_SET_PHASE_INVERSION_DISABLED(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_PHASE_INVERSION_DISABLED_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_GET_BANDWIDTH(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_FINAL_RANGE(var x: Cardinal): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_SAMPLE_RATE(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_BANDWIDTH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_RESET_STATE: TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_RESET_STATE_REQUEST;
  Result.ReqType := orNoValue;
end;

function OPUS_GET_GAIN(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_GAIN_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_LAST_PACKET_DURATION(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_LAST_PACKET_DURATION_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_GET_PITCH(var x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_GET_PITCH_REQUEST;
  Result.ReqType := orPointer;
  Result.PtrValue := @x;
end;

function OPUS_SET_GAIN(x: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_SET_GAIN_REQUEST;
  Result.ReqType := orInteger;
  Result.IntValue := x;
end;

function OPUS_MULTISTREAM_GET_DECODER_STATE(x: Integer; var y: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_MULTISTREAM_GET_DECODER_STATE_REQUEST;
  Result.ReqType := orXY;
  Result.XValue := x;
  Result.YValue := @y;
end;

function OPUS_MULTISTREAM_GET_ENCODER_STATE(x: Integer; var y: Integer): TOpusCTLRequestRecord; inline;
begin
  Result.Request := OPUS_MULTISTREAM_GET_ENCODER_STATE_REQUEST;
  Result.ReqType := orXY;
  Result.XValue := x;
  Result.YValue := @y;
end;


end.

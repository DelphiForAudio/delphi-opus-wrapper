unit uLibOpusFile;

interface

{.$define AD}
{ C-Runtime 2013 needed }
uses
  Windows;

{$if not defined(FPC) and (CompilerVersion<20.00))}
type
  NativeInt = type Integer;     //Override NativeInt -> Wrong size of NativeInt in Delphi2007
  NativeUInt = type Cardinal;   //Override NativeUInt -> Wrong size of NativeUInt in Delphi2007
{$IFEND}

// Error Codes
const
  OP_FALSE = -1;
  OP_HOLE = -3;
  OP_EREAD = -128;
  OP_EFAULT = -129;
  OP_EIMPL = -130;
  OP_EINVAL = -131;
  OP_ENOTVORBIS = -132;
  OP_EBADHEADER = -133;
  OP_EVERSION = -134;
  OP_ENOTAUDIO = -135;
  OP_EBADPACKET = -136;
  OP_EBADLINK = -137;
  OP_ENOSEEK = -138;
  OP_EBADTIMESTAMP = -139;

type
  TOP_PIC_FORMAT = (OP_PIC_FORMAT_UNKNOWN = -1, OP_PIC_FORMAT_URL, OP_PIC_FORMAT_JPEG,
                    OP_PIC_FORMAT_PNG, OP_PIC_FORMAT_GIF);
type
  TOpusHead = THandle;
  TOggOpusFile = THandle;
  TOpusStream = THandle;
  {$if not declared(size_t)}
  size_t = NativeUInt;
  {$endif}

  op_read_func = function (stream: Pointer; var buffer; nbytes: Integer): Integer; cdecl;
  op_seek_func = function (stream: Pointer; offset: Int64; whence: Integer): Integer; cdecl;
  op_tell_func = function (stream: Pointer): Int64; cdecl;
  op_close_func = function (stream: Pointer): Integer; cdecl;

  TOpusFileCallbacks = record
    read: op_read_func;
    seek: op_seek_func;
    tell: op_tell_func;
    close: op_close_func;
  end;

function OpusReadCB(stream: Pointer; var buffer; nbytes: Integer): Integer; cdecl;
function OpusSeekCB(stream: Pointer; offset: Int64; whence: Integer): Integer; cdecl;
function OpusTellCB(stream: Pointer): Int64; cdecl;
function OpusCloseCB(stream: Pointer): Integer; cdecl;

const
  op_callbacks: TOpusFileCallbacks = (read: OpusReadCB;
                                      seek: OpusSeekCB;
                                      tell: OpusTellCB;
                                      close: nil);
type
  TOpusMSDecoder = Pointer;
  op_decode_cb_func = function(ctx: Pointer; decoder: TOpusMSDecoder; var pcm; op: Pointer;
                               nsamples, nchannels, format, li: Integer): Integer; cdecl;
  TOpusTags = record
    user_comments: PPAnsiChar; // The array of comment string vectors
    comment_lengths: PInteger; // An array of the corresponding length of each vector, in bytes
    comments: Integer;         // The total number of comment streams
    vendor: PAnsiChar;         // The null-terminated vendor string. This identifies the software used to encode the stream.
  end;
  POpusTags = ^TOpusTags;

  TOpusPictureTag = record
    Pic_Type: Integer; { The picture type according to the ID3v2 APIC frame:
                         <ol start="0">
                         <li>Other</li>
                         <li>32x32 pixels 'file icon' (PNG only)</li>
                         <li>Other file icon</li>
                         <li>Cover (front)</li>
                         <li>Cover (back)</li>
                         <li>Leaflet page</li>
                         <li>Media (e.g. label side of CD)</li>
                         <li>Lead artist/lead performer/soloist</li>
                         <li>Artist/performer</li>
                         <li>Conductor</li>
                         <li>Band/Orchestra</li>
                         <li>Composer</li>
                         <li>Lyricist/text writer</li>
                         <li>Recording Location</li>
                         <li>During recording</li>
                         <li>During performance</li>
                         <li>Movie/video screen capture</li>
                         <li>A bright colored fish</li>
                         <li>Illustration</li>
                         <li>Band/artist logotype</li>
                         <li>Publisher/Studio logotype</li>
                         </ol> }
    mime_type: PAnsiChar; // The MIME type of the picture, in printable ASCII characters 0x20-0x7E.
    description: PAnsiChar;  // The description of the picture, in UTF-8
    width: Cardinal;
    height: Cardinal;
    depth: Cardinal;  // The color depth of the picture in bits-per-pixel
    colors: Cardinal; // For indexed-color pictures (e.g., GIF), the number of colors used, or 0
    data_length: Cardinal;
    data: Pointer;
    format: TOP_PIC_FORMAT; // The format of the picture data, if known. OP_PIC_FORMAT_UNKNOWN..OP_PIC_FORMAT_GIF
  end;

{
"r"   read: Open file for input operations. The file must exist.
"w"   write: Create an empty file for output operations. If a file with the same name already exists,
      its contents are discarded and the file is treated as a new empty file.
"a"   append: Open file for output at the end of a file. Output operations always write data at the
      end of the file, expanding it. Repositioning operations (fseek, fsetpos, rewind) are ignored.
      The file is created if it does not exist.
"r+"  read/update: Open a file for update (both for input and output). The file must exist.
"w+"  write/update: Create an empty file and open it for update (both for input and output). If a
      file with the same name already exists its contents are discarded and the file is treated as
      a new empty file.
"a+"  append/update: Open a file for update (both for input and output) with all output operations
      writing data at the end of the file. Repositioning operations (fseek, fsetpos, rewind)
      affects the next input operations, but output operations move the position back to the end of
      file. The file is created if it does not exist.

  With the mode specifiers above the file is open as a text file. In order to open a file as a binary
  file, a "b" character has to be included in the mode string. This additional "b" character can
  either be appended at the end of the string (thus making the following compound modes:
  "rb", "wb", "ab", "r+b", "w+b", "a+b") or be inserted between the letter and the "+" sign for the
  mixed modes ("rb+", "wb+", "ab+").

  The new C standard (C2011, which is not part of C++) adds a new standard subspecifier ("x"), that can
  be appended to any "w" specifier (to form "wx", "wbx", "w+x" or "w+bx"/"wb+x"). This subspecifier
  forces the function to fail if the file exists, instead of overwriting it.

  If additional characters follow the sequence, the behavior depends on the library implementation: some
  implementations may ignore additional characters so that for example an additional "t" (sometimes used
  to explicitly state a text file) is accepted.
}

function op_fopen(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar): TOpusStream;
function op_freopen(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar; stream: TOpusStream): TOpusStream;
function op_mem_stream_create(out cb: TOpusFileCallbacks; const data; size: size_t): TOpusStream;

function opus_head_parse(head: TOpusHead; const data; len: size_t): Integer;
function opus_granule_sample(head: TOpusHead; gp: Int64): Int64;
function opus_tags_parse(out tags: TOpusTags; const data; len: size_t): Integer;
function opus_tags_copy(var dst: TOpusTags; const src: TOpusTags): Integer;
procedure opus_tags_init(var tags: TOpusTags);
function opus_tags_add(var dst: TOpusTags; tag, value: PAnsiChar): Integer;
function opus_tags_add_comment(var dst: TOpusTags; comment: PAnsiChar): Integer;
function opus_tags_set_binary_suffix(var tags: TOpusTags; const data; len: Integer): Integer;
function opus_tags_query(const tags: TOpusTags; tag: PAnsiChar; count: Integer): Integer;
function opus_tags_query_count(const tags: TOpusTags; tag: PAnsiChar): Integer;
function opus_tags_get_binary_suffix(const tags: TOpusTags; out len: Integer): Integer;
function opus_tags_get_album_gain(const tags: TOpusTags; out gain_q8: Integer): Integer;
function opus_tags_get_track_gain(const tags: TOpusTags; out gain_q8: Integer): Integer;
procedure opus_tags_clear(var tags: TOpusTags);
function opus_tagcompare(tag_name, comment: PAnsiChar): Integer;
function opus_tagncompare(tag_name: PAnsiChar; tag_len: Integer; comment: PAnsiChar): Integer;
function opus_picture_tag_parse(out pic: TOpusPictureTag; tag: PAnsiChar): Integer;
procedure opus_picture_tag_init(var pic: TOpusPictureTag);
procedure opus_picture_tag_clear(var pic: TOpusPictureTag);

function op_test(head: TOpusHead; const initial_data; initial_bytes: size_t): Integer;
function op_open_file(path: PAnsiChar; out error: Integer): TOggOpusFile;
function op_open_memory(const data; const _size: size_t; out error: Integer): TOggOpusFile;
function op_open_callbacks(const source; const cb: TOpusFileCallbacks;
  const initial_data; initial_bytes: size_t; out error: Integer): TOggOpusFile;
function op_test_file(path: PAnsiChar; out error: Integer): TOggOpusFile;
function op_test_memory(const _data; const size: size_t; out error: Integer): TOggOpusFile;
function op_test_callbacks(const source; const cb: TOpusFileCallbacks; const initial_data; initial_bytes: size_t;
  out error: Integer): TOggOpusFile;
function op_test_open(OpusFile: TOggOpusFile): Integer;
function op_free(OpusFile: TOggOpusFile): Integer;

function op_seekable(OpusFile: TOggOpusFile): Integer;
function op_link_count(OpusFile: TOggOpusFile): Integer;
function op_serialno(OpusFile: TOggOpusFile; li: Integer): Cardinal;
function op_channel_count(OpusFile: TOggOpusFile; li: Integer): Integer;
function op_raw_total(OpusFile: TOggOpusFile; li: Integer): Int64;
function op_pcm_total(OpusFile: TOggOpusFile; li: Integer): Int64;
function op_head(OpusFile: TOggOpusFile; li: Integer): TOpusHead;
function op_tags(OpusFile: TOggOpusFile; li: Integer): POpusTags;
function op_current_link(OpusFile: TOggOpusFile): Integer;
function op_bitrate(OpusFile: TOggOpusFile; li: Integer): Integer;
function op_bitrate_instant(OpusFile: TOggOpusFile): Integer;
function op_raw_tell(OpusFile: TOggOpusFile): Int64;
function op_pcm_tell(OpusFile: TOggOpusFile): Int64;

function op_raw_seek(OpusFile: TOggOpusFile; byte_offset: Int64): Integer;
function op_pcm_seek(OpusFile: TOggOpusFile; pcm_offset: Int64): Integer;

function op_set_gain_offset(OpusFile: TOggOpusFile; gain_type: Integer; gain_offset_q8: Integer): Integer;
procedure op_set_dither_enabled(OpusFile: TOggOpusFile; enabled: Integer);
function op_read(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer; li: pointer): Integer;
function op_read_float(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer; li: pointer): Integer;
function op_read_stereo(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer): Integer;
function op_read_float_stereo(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer): Integer;

function FreeLibOpusFile: Boolean;
function SilentLibOpusFile(LibName: PChar=nil): Boolean;
procedure LoadLibOpusFile(LibName: PChar=nil);               //raise Exception

implementation

uses
  {$IFDEF AD}
  uadConsts,
  {$ENDIF}
  SysUtils;

const
  StrLibName = 'libopusfile-0.dll';
  Lib_Undefined = StrLibName + ' not loaded';

{$IFNDEF AD}
resourcestring
  EProcNotFound = 'Procedure "%1:s"  not found in library "%0:s"';
  ELibraryNotFound = 'The error "Library not found" occurred during loading of "%s"';
{$ENDIF}

var
  hlib: THandle;
  lib_UnInit: array of pointer;

function FreeLibOpusFile: Boolean;
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

procedure LoadLibOpusFile(LibName: PChar=nil);
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

function SilentLibOpusFile(LibName: PChar=nil): Boolean;
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

function OpusReadCB(stream: Pointer; var buffer; nbytes: Integer): Integer; cdecl;
begin
  if nbytes<>0
  then
    result := FileRead(THandle(stream^), Buffer, nbytes)
  else
    result := 0;
end;

function OpusSeekCB(stream: Pointer; offset: Int64; whence: Integer): Integer; cdecl;
var
  Seek_Result: Int64;
begin
  Seek_Result := FileSeek(THandle(stream^), offset, whence);
  if Seek_Result=-1
  then
    Result := -1
  else
    Result := 0;
end;

function OpusTellCB(stream: Pointer): Int64; cdecl;
begin
  Result := FileSeek(THandle(stream^), 0, 1);
end;

function OpusCloseCB(stream: Pointer): Integer; cdecl;
begin
  FileClose(THandle(stream^));
  Result := 0;
end;

var
  _op_fopen: function(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar): TOpusStream; cdecl;

function op_fopen(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar): TOpusStream;
begin
  if @_op_fopen = nil
  then
    LoadProcAddress(@_op_fopen, 'op_fopen');
  Result := _op_fopen(cb, path, mode);
end;

var
  _op_freopen: function(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar; stream: TOpusStream): TOpusStream; cdecl;

function op_freopen(out cb: TOpusFileCallbacks; path: PAnsiChar; mode: PAnsiChar; stream: TOpusStream): TOpusStream;
begin
  if @_op_freopen = nil
  then
    LoadProcAddress(@_op_freopen, 'op_freopen');
  Result := _op_freopen(cb, path, mode, stream);
end;

var
  _op_mem_stream_create: function(out cb: TOpusFileCallbacks; const data; size: size_t): TOpusStream; cdecl;

function op_mem_stream_create(out cb: TOpusFileCallbacks; const data; size: size_t): TOpusStream;
begin
  if @_op_mem_stream_create = nil
  then
    LoadProcAddress(@_op_mem_stream_create, 'op_mem_stream_create');
  Result := _op_mem_stream_create(cb, data, size);
end;

var
  _opus_head_parse: function(head: TOpusHead; const data; len: size_t): Integer; cdecl;

function opus_head_parse(head: TOpusHead; const data; len: size_t): Integer;
begin
  if @_opus_head_parse = nil
  then
    LoadProcAddress(@_opus_head_parse, 'opus_head_parse');
  Result := _opus_head_parse(head, data, len);
end;

var
  _opus_granule_sample: function(head: TOpusHead; gp: Int64): Int64; cdecl;

function opus_granule_sample(head: TOpusHead; gp: Int64): Int64;
begin
  if @_opus_granule_sample = nil
  then
    LoadProcAddress(@_opus_granule_sample, 'opus_granule_sample');
  Result := _opus_granule_sample(head, gp);
end;

var
  _opus_tags_parse: function(out tags: TOpusTags; const data; len: size_t): Integer; cdecl;

function opus_tags_parse(out tags: TOpusTags; const data; len: size_t): Integer;
begin
  if @_opus_tags_parse = nil
  then
    LoadProcAddress(@_opus_tags_parse, 'opus_tags_parse');
  Result := _opus_tags_parse(tags, data, len);
end;

var
  _opus_tags_copy: function(var dst: TOpusTags; const src: TOpusTags): Integer; cdecl;

function opus_tags_copy(var dst: TOpusTags; const src: TOpusTags): Integer;
begin
  if @_opus_tags_copy = nil
  then
    LoadProcAddress(@_opus_tags_copy, 'opus_tags_copy');
  Result := _opus_tags_copy(dst, src);
end;

var
  _opus_tags_init: procedure(var tags: TOpusTags); cdecl;

procedure opus_tags_init(var tags: TOpusTags);
begin
  if @_opus_tags_init = nil
  then
    LoadProcAddress(@_opus_tags_init, 'opus_tags_init');
  _opus_tags_init(tags);
end;

var
  _opus_tags_add: function(var dst: TOpusTags; tag, value: PAnsiChar): Integer; cdecl;

function opus_tags_add(var dst: TOpusTags; tag, value: PAnsiChar): Integer;
begin
  if @_opus_tags_add = nil
  then
    LoadProcAddress(@_opus_tags_add, 'opus_tags_add');
  Result := _opus_tags_add(dst, tag, value);
end;

var
  _opus_tags_add_comment: function(var dst: TOpusTags; comment: PAnsiChar): Integer; cdecl;

function opus_tags_add_comment(var dst: TOpusTags; comment: PAnsiChar): Integer;
begin
  if @_opus_tags_add_comment = nil
  then
    LoadProcAddress(@_opus_tags_add_comment, 'opus_tags_add_comment');
  Result := _opus_tags_add_comment(dst, comment);
end;

var
  _opus_tags_set_binary_suffix: function(var tags: TOpusTags; const data; len: Integer): Integer; cdecl;

function opus_tags_set_binary_suffix(var tags: TOpusTags; const data; len: Integer): Integer;
begin
  if @_opus_tags_set_binary_suffix = nil
  then
    LoadProcAddress(@_opus_tags_set_binary_suffix, 'opus_tags_set_binary_suffix');
  Result := _opus_tags_set_binary_suffix(tags, data, len);
end;

var
  _opus_tags_query: function(const tags: TOpusTags; tag: PAnsiChar; count: Integer): Integer; cdecl;

function opus_tags_query(const tags: TOpusTags; tag: PAnsiChar; count: Integer): Integer;
begin
  if @_opus_tags_query = nil
  then
    LoadProcAddress(@_opus_tags_query, 'opus_tags_query');
  Result := _opus_tags_query(tags, tag, count);
end;

var
  _opus_tags_query_count: function(const tags: TOpusTags; tag: PAnsiChar): Integer; cdecl;

function opus_tags_query_count(const tags: TOpusTags; tag: PAnsiChar): Integer;
begin
  if @_opus_tags_query_count = nil
  then
    LoadProcAddress(@_opus_tags_query_count, 'opus_tags_query_count');
  Result := _opus_tags_query_count(tags, tag);
end;

var
  _opus_tags_get_binary_suffix: function(const tags: TOpusTags; out len: Integer): Integer; cdecl;

function opus_tags_get_binary_suffix(const tags: TOpusTags; out len: Integer): Integer;
begin
  if @_opus_tags_get_binary_suffix = nil
  then
    LoadProcAddress(@_opus_tags_get_binary_suffix, 'opus_tags_get_binary_suffix');
  Result := _opus_tags_get_binary_suffix(tags, len);
end;

var
  _opus_tags_get_album_gain: function(const tags: TOpusTags; out gain_q8: Integer): Integer; cdecl;

function opus_tags_get_album_gain(const tags: TOpusTags; out gain_q8: Integer): Integer;
begin
  if @_opus_tags_get_album_gain = nil
  then
    LoadProcAddress(@_opus_tags_get_album_gain, 'opus_tags_get_album_gain');
  Result := _opus_tags_get_album_gain(tags, gain_q8);
end;

var
  _opus_tags_get_track_gain: function(const tags: TOpusTags; out gain_q8: Integer): Integer; cdecl;

function opus_tags_get_track_gain(const tags: TOpusTags; out gain_q8: Integer): Integer;
begin
  if @_opus_tags_get_track_gain = nil
  then
    LoadProcAddress(@_opus_tags_get_track_gain, 'opus_tags_get_track_gain');
  Result := _opus_tags_get_track_gain(tags, gain_q8);
end;

var
  _opus_tags_clear: procedure(var tags: TOpusTags); cdecl;

procedure opus_tags_clear(var tags: TOpusTags);
begin
  if @_opus_tags_clear = nil
  then
    LoadProcAddress(@_opus_tags_clear, 'opus_tags_clear');
  _opus_tags_clear(tags);
end;

var
  _opus_tagcompare: function(tag_name, comment: PAnsiChar): Integer; cdecl;

function opus_tagcompare(tag_name, comment: PAnsiChar): Integer;
begin
  if @_opus_tagcompare = nil
  then
    LoadProcAddress(@_opus_tagcompare, 'opus_tagcompare');
  Result := _opus_tagcompare(tag_name, comment);
end;

var
  _opus_tagncompare: function(tag_name: PAnsiChar; tag_len: Integer; comment: PAnsiChar): Integer; cdecl;

function opus_tagncompare(tag_name: PAnsiChar; tag_len: Integer; comment: PAnsiChar): Integer;
begin
  if @_opus_tagncompare = nil
  then
    LoadProcAddress(@_opus_tagncompare, 'opus_tagncompare');
  Result := _opus_tagncompare(tag_name, tag_len, comment);
end;

var
  _opus_picture_tag_parse: function(out pic: TOpusPictureTag; tag: PAnsiChar): Integer; cdecl;

function opus_picture_tag_parse(out pic: TOpusPictureTag; tag: PAnsiChar): Integer;
begin
  if @_opus_picture_tag_parse = nil
  then
    LoadProcAddress(@_opus_picture_tag_parse, 'opus_picture_tag_parse');
  Result := _opus_picture_tag_parse(pic, tag);
end;

var
  _opus_picture_tag_init: procedure(var pic: TOpusPictureTag); cdecl;

procedure opus_picture_tag_init(var pic: TOpusPictureTag);
begin
  if @_opus_picture_tag_init = nil
  then
    LoadProcAddress(@_opus_picture_tag_init, 'opus_picture_tag_init');
  _opus_picture_tag_init(pic);
end;

var
  _opus_picture_tag_clear: procedure(var pic: TOpusPictureTag); cdecl;

procedure opus_picture_tag_clear(var pic: TOpusPictureTag);
begin
  if @_opus_picture_tag_clear = nil
  then
    LoadProcAddress(@_opus_picture_tag_clear, 'opus_picture_tag_clear');
  _opus_picture_tag_clear(pic);
end;

var
  _op_test: function(head: TOpusHead; const initial_data; initial_bytes: size_t): Integer; cdecl;

function op_test(head: TOpusHead; const initial_data; initial_bytes: size_t): Integer;
begin
  if @_op_test = nil
  then
    LoadProcAddress(@_op_test, 'op_test');
  Result := _op_test(head, initial_data, initial_bytes);
end;

var
  _op_open_file: function(path: PAnsiChar; out error: Integer): TOggOpusFile; cdecl;

function op_open_file(path: PAnsiChar; out error: Integer): TOggOpusFile;
begin
  if @_op_open_file = nil
  then
    LoadProcAddress(@_op_open_file, 'op_open_file');
  Result := _op_open_file(path, error);
end;

var
  _op_open_memory: function(const data; const _size: size_t; out error: Integer): TOggOpusFile; cdecl;

function op_open_memory(const data; const _size: size_t; out error: Integer): TOggOpusFile;
begin
  if @_op_open_memory = nil
  then
    LoadProcAddress(@_op_open_memory, 'op_open_memory');
  Result := _op_open_memory(data, _size, error);
end;

var
  _op_open_callbacks: function(const source; const cb: TOpusFileCallbacks; const initial_data; initial_bytes: size_t; out error: Integer): TOggOpusFile; cdecl;

function op_open_callbacks(const source; const cb: TOpusFileCallbacks; const initial_data; initial_bytes: size_t; out error: Integer): TOggOpusFile;
begin
  if @_op_open_callbacks = nil
  then
    LoadProcAddress(@_op_open_callbacks, 'op_open_callbacks');
  Result := _op_open_callbacks(source, cb, initial_data, initial_bytes, error);
end;

var
  _op_test_file: function(path: PAnsiChar; out error: Integer): TOggOpusFile; cdecl;

function op_test_file(path: PAnsiChar; out error: Integer): TOggOpusFile;
begin
  if @_op_test_file = nil
  then
    LoadProcAddress(@_op_test_file, 'op_test_file');
  Result := _op_test_file(path, error);
end;

var
  _op_test_memory: function(const _data; const size: size_t; out error: Integer): TOggOpusFile; cdecl;

function op_test_memory(const _data; const size: size_t; out error: Integer): TOggOpusFile;
begin
  if @_op_test_memory = nil
  then
    LoadProcAddress(@_op_test_memory, 'op_test_memory');
  Result := _op_test_memory(_data, size, error);
end;

var
  _op_test_callbacks: function(const source; const cb: TOpusFileCallbacks; const initial_data; initial_bytes: size_t; out error: Integer): TOggOpusFile; cdecl;

function op_test_callbacks(const source; const cb: TOpusFileCallbacks; const initial_data; initial_bytes: size_t; out error: Integer): TOggOpusFile;
begin
  if @_op_test_callbacks = nil
  then
    LoadProcAddress(@_op_test_callbacks, 'op_test_callbacks');
  Result := _op_test_callbacks(source, cb, initial_data, initial_bytes, error);
end;

var
  _op_test_open: function(OpusFile: TOggOpusFile): Integer; cdecl;

function op_test_open(OpusFile: TOggOpusFile): Integer;
begin
  if @_op_test_open = nil
  then
    LoadProcAddress(@_op_test_open, 'op_test_open');
  Result := _op_test_open(OpusFile);
end;

var
  _op_free: function(OpusFile: TOggOpusFile): Integer; cdecl;

function op_free(OpusFile: TOggOpusFile): Integer;
begin
  if @_op_free = nil
  then
    LoadProcAddress(@_op_free, 'op_free');
  Result := _op_free(OpusFile);
end;

var
  _op_seekable: function(OpusFile: TOggOpusFile): Integer; cdecl;

function op_seekable(OpusFile: TOggOpusFile): Integer;
begin
  if @_op_seekable = nil
  then
    LoadProcAddress(@_op_seekable, 'op_seekable');
  Result := _op_seekable(OpusFile);
end;

var
  _op_link_count: function(OpusFile: TOggOpusFile): Integer; cdecl;

function op_link_count(OpusFile: TOggOpusFile): Integer;
begin
  if @_op_link_count = nil
  then
    LoadProcAddress(@_op_link_count, 'op_link_count');
  Result := _op_link_count(OpusFile);
end;

var
  _op_serialno: function(OpusFile: TOggOpusFile; li: Integer): Cardinal; cdecl;

function op_serialno(OpusFile: TOggOpusFile; li: Integer): Cardinal;
begin
  if @_op_serialno = nil
  then
    LoadProcAddress(@_op_serialno, 'op_serialno');
  Result := _op_serialno(OpusFile, li);
end;

var
  _op_channel_count: function(OpusFile: TOggOpusFile; li: Integer): Integer; cdecl;

function op_channel_count(OpusFile: TOggOpusFile; li: Integer): Integer;
begin
  if @_op_channel_count = nil
  then
    LoadProcAddress(@_op_channel_count, 'op_channel_count');
  Result := _op_channel_count(OpusFile, li);
end;

var
  _op_raw_total: function(OpusFile: TOggOpusFile; li: Integer): Int64; cdecl;

function op_raw_total(OpusFile: TOggOpusFile; li: Integer): Int64;
begin
  if @_op_raw_total = nil
  then
    LoadProcAddress(@_op_raw_total, 'op_raw_total');
  Result := _op_raw_total(OpusFile, li);
end;

var
  _op_pcm_total: function(OpusFile: TOggOpusFile; li: Integer): Int64; cdecl;

function op_pcm_total(OpusFile: TOggOpusFile; li: Integer): Int64;
begin
  if @_op_pcm_total = nil
  then
    LoadProcAddress(@_op_pcm_total, 'op_pcm_total');
  Result := _op_pcm_total(OpusFile, li);
end;

var
  _op_head: function(OpusFile: TOggOpusFile; li: Integer): TOpusHead; cdecl;

function op_head(OpusFile: TOggOpusFile; li: Integer): TOpusHead;
begin
  if @_op_head = nil
  then
    LoadProcAddress(@_op_head, 'op_head');
  Result := _op_head(OpusFile, li);
end;

var
  _op_tags: function(OpusFile: TOggOpusFile; li: Integer): POpusTags; cdecl;

function op_tags(OpusFile: TOggOpusFile; li: Integer): POpusTags;
begin
  if @_op_tags = nil
  then
    LoadProcAddress(@_op_tags, 'op_tags');
  Result := _op_tags(OpusFile, li);
end;

var
  _op_current_link: function(OpusFile: TOggOpusFile): Integer; cdecl;

function op_current_link(OpusFile: TOggOpusFile): Integer;
begin
  if @_op_current_link = nil
  then
    LoadProcAddress(@_op_current_link, 'op_current_link');
  Result := _op_current_link(OpusFile);
end;

var
  _op_bitrate: function(OpusFile: TOggOpusFile; li: Integer): Integer; cdecl;

function op_bitrate(OpusFile: TOggOpusFile; li: Integer): Integer;
begin
  if @_op_bitrate = nil
  then
    LoadProcAddress(@_op_bitrate, 'op_bitrate');
  Result := _op_bitrate(OpusFile, li);
end;

var
  _op_bitrate_instant: function(OpusFile: TOggOpusFile): Integer; cdecl;

function op_bitrate_instant(OpusFile: TOggOpusFile): Integer;
begin
  if @_op_bitrate_instant = nil
  then
    LoadProcAddress(@_op_bitrate_instant, 'op_bitrate_instant');
  Result := _op_bitrate_instant(OpusFile);
end;

var
  _op_raw_tell: function(OpusFile: TOggOpusFile): Int64; cdecl;

function op_raw_tell(OpusFile: TOggOpusFile): Int64;
begin
  if @_op_raw_tell = nil
  then
    LoadProcAddress(@_op_raw_tell, 'op_raw_tell');
  Result := _op_raw_tell(OpusFile);
end;

var
  _op_pcm_tell: function(OpusFile: TOggOpusFile): Int64; cdecl;

function op_pcm_tell(OpusFile: TOggOpusFile): Int64;
begin
  if @_op_pcm_tell = nil
  then
    LoadProcAddress(@_op_pcm_tell, 'op_pcm_tell');
  Result := _op_pcm_tell(OpusFile);
end;

var
  _op_raw_seek: function(OpusFile: TOggOpusFile; byte_offset: Int64): Integer; cdecl;

function op_raw_seek(OpusFile: TOggOpusFile; byte_offset: Int64): Integer;
begin
  if @_op_raw_seek = nil
  then
    LoadProcAddress(@_op_raw_seek, 'op_raw_seek');
  Result := _op_raw_seek(OpusFile, byte_offset);
end;

var
  _op_pcm_seek: function(OpusFile: TOggOpusFile; pcm_offset: Int64): Integer; cdecl;

function op_pcm_seek(OpusFile: TOggOpusFile; pcm_offset: Int64): Integer;
begin
  if @_op_pcm_seek = nil
  then
    LoadProcAddress(@_op_pcm_seek, 'op_pcm_seek');
  Result := _op_pcm_seek(OpusFile, pcm_offset);
end;

var
  _op_set_gain_offset: function(OpusFile: TOggOpusFile; gain_type: Integer; gain_offset_q8: Integer): Integer; cdecl;

function op_set_gain_offset(OpusFile: TOggOpusFile; gain_type: Integer; gain_offset_q8: Integer): Integer;
begin
  if @_op_set_gain_offset = nil
  then
    LoadProcAddress(@_op_set_gain_offset, 'op_set_gain_offset');
  Result := _op_set_gain_offset(OpusFile, gain_type, gain_offset_q8);
end;

var
  _op_set_dither_enabled: procedure(OpusFile: TOggOpusFile; enabled: Integer); cdecl;

procedure op_set_dither_enabled(OpusFile: TOggOpusFile; enabled: Integer);
begin
  if @_op_set_dither_enabled = nil
  then
    LoadProcAddress(@_op_set_dither_enabled, 'op_set_dither_enabled');
  _op_set_dither_enabled(OpusFile, enabled);
end;

var
  _op_read: function(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer; li: pointer): Integer; cdecl;

function op_read(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer; li: pointer): Integer;
begin
  if @_op_read = nil
  then
    LoadProcAddress(@_op_read, 'op_read');
  Result := _op_read(OpusFile, pcm, SampleCount, li);
end;

var
  _op_read_float: function(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer; li: pointer): Integer; cdecl;

function op_read_float(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer; li: pointer): Integer;
begin
  if @_op_read_float = nil
  then
    LoadProcAddress(@_op_read_float, 'op_read_float');
  Result := _op_read_float(OpusFile, pcm, SampleCount, li);
end;

var
  _op_read_stereo: function(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer): Integer; cdecl;

function op_read_stereo(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer): Integer;
begin
  if @_op_read_stereo = nil
  then
    LoadProcAddress(@_op_read_stereo, 'op_read_stereo');
  Result := _op_read_stereo(OpusFile, pcm, SampleCount);
end;

var
  _op_read_float_stereo: function(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer): Integer; cdecl;

function op_read_float_stereo(OpusFile: TOggOpusFile; var pcm; SampleCount: Integer): Integer;
begin
  if @_op_read_float_stereo = nil
  then
    LoadProcAddress(@_op_read_float_stereo, 'op_read_float_stereo');
  Result := _op_read_float_stereo(OpusFile, pcm, SampleCount);
end;

end.

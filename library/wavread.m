function [y,Fs,bits]=wavread(file,ext)
%WAVREAD Read Microsoft WAVE (".wav") sound file.
%   Y=WAVREAD(FILE) reads a WAVE file specified by the string FILE,
%   returning the sampled data in Y. The ".wav" extension is appended
%   if no extension is given.  Amplitude values are in the range [-1,+1].
%
%   [Y,FS,BITS]=WAVREAD(FILE) returns the sample rate (FS) in Hertz
%   and the number of bits per sample (BITS) used to encode the
%   data in the file.
%
%   [...]=WAVREAD(FILE,N) returns only the first N samples from each
%       channel in the file.
%   [...]=WAVREAD(FILE,[N1 N2]) returns only samples N1 through N2 from
%       each channel in the file.
%   SIZ=WAVREAD(FILE,'size') returns the size of the audio data contained
%       in the file in place of the actual audio data, returning the
%       vector SIZ=[samples channels].
%
%   Supports multi-channel data, with up to 16 bits per sample.
%
%   See also WAVWRITE, AUREAD.

% NOTE: This file reader only supports Microsoft PCM data format.
%       It also does not support wave-list data.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.9 $  $Date: 1997/11/21 23:24:12 $

%   D. Orofino, 11/95

% Parse input arguments:
nargchk(1,2,nargin);
if nargin<2, ext=[]; end    % Default - read all samples
exts = prod(size(ext));     % length of extent info
if ~strncmp(lower(ext),'size',exts) & (exts > 2),
   error('Index range must be specified as a scalar or 2-element vector.');
end
if ~ischar(ext) & exts==1,
   if ext==0,
      ext='size';           % synonym for size
   else
      ext=[1 ext];          % Prepend start sample index
   end
end

% Open WAV file:
[fid,msg] = open_wav(file);
error(msg);

% Find the first RIFF chunk:
[riffck,msg] = find_cktype(fid,'RIFF');
error(msg);

% Verify that RIFF file is WAVE data type:
[rifftype,msg] = find_rifftype(fid,'WAVE');
error(msg);

% Find optional chunks, and don't stop till <data-ck> found:
found_fmt  = 0;
found_data = 0;

while(~found_data),
   [ck,msg] = find_cktype(fid);
   error(msg);

   switch ck.ID   
   case 'fact'
      % Optional <fact-ck> found:
      [factdata,msg] = read_factck(fid, ck);
      error(msg);

   case 'fmt'
      % <fmt-ck> found      
      found_fmt = 1;
      fmtck = ck;
      [wavefmt,msg] = read_wavefmt(fid,fmtck);
      error(msg);

   case 'data'
      % <data-ck> found:
      datack = ck;
      found_data = 1;
      if ~found_fmt,
         error('Corrupt WAV file: found data before format information.');
      end
      
      if strncmp(lower(ext),'size',exts) | ...
            (~isempty(ext) & all(ext==0)),
         % Caller doesn't want data - just data size:
         [samples,msg] = read_wavedat(datack,wavefmt,-1);
         fclose(fid);
         error(msg);
         y = [samples wavefmt.nChannels];
         
      else
         % Read <wave-data>:
         [datack,msg] = read_wavedat(datack,wavefmt,ext);
         fclose(fid);
         error(msg);
         y = datack.Data;
         
      end
      
   otherwise
      % Skip over data in unprocessed chunks:
      if(fseek(fid,ck.Size,0)==-1),
         error('Incorrect chunk size information in RIFF file.');
      end
   end
end

% Parse structure info for return to user:
Fs = wavefmt.nSamplesPerSec;
if wavefmt.wFormatTag == 1,
   bits = wavefmt.nBitsPerSample;
else
   bits = [];  % Unknown
end

% end of wavread()


% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------

% ---------------------------------------------
% OPEN_WAV: Open a WAV file for reading
% ---------------------------------------------
function [fid,msg] = open_wav(file)
% Append .wav extension if it's missing:
if isempty(findstr(file,'.')),
  file=[file '.wav'];
end
[fid,msg] = fopen(file,'rb','l');   % Little-endian
if fid == -1,
   if isempty(msg),
      msg = 'Cannot open specified WAV file for input.';
   end
   error(msg);
end
return

% ---------------------------------------------
% READ_CKINFO: Reads next RIFF chunk, but not the chunk data.
%   If optional sflg is set to nonzero, reads SUBchunk info instead.
%   Expects an open FID pointing to first byte of chunk header.
%   Returns a new chunk structure.
% ---------------------------------------------
function [ck,msg] = read_ckinfo(fid)

msg     = '';
ck.fid  = fid;
ck.Data = [];

[s,cnt] = fread(fid,4,'char');
if cnt~=4,
   msg = 'Truncated chunk header found - possibly not a WAV file.';
   return; 
end

ck.ID = deblank(setstr(s'));
% Read chunk size (skip if subchunk):
[sz,cnt] = fread(fid,1,'ulong');
if cnt~=1,
   msg = 'Truncated chunk data found - possibly not a WAV file.';
   return
end
ck.Size = sz;
return

% ---------------------------------------------
% FIND_CKTYPE: Finds a chunk with appropriate type.
%   Searches from current file position specified by fid.
%   Leaves file positions to data of desired chunk.
%   If optional sflg is set to nonzero, finds a SUBchunk instead.
% ---------------------------------------------
function [ck,msg] = find_cktype(fid,type)

msg = '';
if nargin<2, type = ''; end

[ck,msg] = read_ckinfo(fid);
if ~isempty(msg), return; end

% Was a required chunk type specified?
if ~isempty(type) & ~strcmp(lower(ck.ID),lower(type)),
   msg = ['<' ftype '-ck> did not appear as expected'];
end
return


% ---------------------------------------------
% FIND_RIFFTYPE: Finds the RIFF data type.
%   Searches from current file position specified by fid.
%   Leaves file positions to data of desired chunk.
% ---------------------------------------------
function [rifftype,msg] = find_rifftype(fid,type)
msg = '';
[rifftype,cnt] = fread(fid,4,'char');
dtype = lower(setstr(rifftype)');

if cnt~=4,
   msg = 'Truncated RIFF data type - possibly not a WAV file.';
elseif ~strcmp(dtype,lower(type)),
   msg = 'Not a WAV file.';
end

return


% ---------------------------------------------
% READ_FACTCK: Read the FACT chunk:
% ---------------------------------------------
function [factdata,msg] = read_factck(fid,ck)

orig_pos    = ftell(fid);
total_bytes = ck.Size; % # bytes in subchunk
nbytes      = 4;       % # of required bytes in <fact-ck> header
msg = '';

if total_bytes < nbytes,
   msg = 'Error reading <fact-ck> chunk.';
   return
end

% Read standard <fact-ck> data:
factdata.dwFileSize  = fread(fid,1,'ulong');  % Samples per second

% Skip over any unprocessed data:
rbytes = total_bytes - (ftell(fid) - orig_pos);
if rbytes,
   if(fseek(fid,rbytes,'cof')==-1),
      msg = 'Error reading <fact-ck> chunk.';
   end
end
return


% ---------------------------------------------
% READ_WAVEFMT: Read WAVE format chunk.
%   Assumes fid points to the <wave-fmt> subchunk.
%   Requires chunk structure to be passed, indicating
%   the length of the chunk in case we don't recognize
%   the format tag.
% ---------------------------------------------
function [fmt,msg] = read_wavefmt(fid,ck)

orig_pos    = ftell(fid);
total_bytes = ck.Size; % # bytes in subchunk
nbytes      = 14;  % # of required bytes in <wave-format> header
msg = '';

if total_bytes < nbytes,
   msg = 'Error reading <wave-fmt> chunk.';
   return
end

% Read standard <wave-format> data:
fmt.wFormatTag      = fread(fid,1,'ushort'); % Data encoding format
fmt.nChannels       = fread(fid,1,'ushort'); % Number of channels
fmt.nSamplesPerSec  = fread(fid,1,'ulong');  % Samples per second
fmt.nAvgBytesPerSec = fread(fid,1,'ulong');  % Avg transfer rate
fmt.nBlockAlign     = fread(fid,1,'ushort'); % Block alignment

% Read format-specific info:
switch fmt.wFormatTag
case 1
   % PCM Format:
   [fmt, msg] = read_fmt_pcm(fid, ck, fmt);
end

% Skip over any unprocessed fmt-specific data:
rbytes = total_bytes - (ftell(fid) - orig_pos);
if rbytes,
   if(fseek(fid,rbytes,'cof')==-1),
      msg = 'Error reading <wave-fmt> chunk.';
   end
end

return


% ---------------------------------------------
% READ_FMT_PCM: Read <PCM-format-specific> info
% ---------------------------------------------
function [fmt,msg] = read_fmt_pcm(fid, ck, fmt)

% There had better be a bits/sample field:
total_bytes = ck.Size; % # bytes in subchunk
nbytes      = 14;  % # of bytes already read in <wave-format> header
msg = '';

if (total_bytes < nbytes+2),
   msg = 'Error reading <wave-fmt> chunk.';
   return
end
[bits,cnt] = fread(fid,1,'ushort');
nbytes=nbytes+2;
if (cnt~=1),
   msg = 'Error reading PCM <wave-fmt> chunk.';
   return
end 
fmt.nBitsPerSample=bits;

% Are there any additional fields present?
if (total_bytes > nbytes),
   % See if the "cbSize" field is present.  If so, grab the data:
   if (total_bytes >= nbytes+2),
      % we have the cbSize ushort in the file:
      [cbSize,cnt]=fread(fid,1,'ushort');
      nbytes=nbytes+2;
      if (cnt~=1),
         msg = 'Error reading PCM <wave-fmt> chunk.';
         return
      end
      fmt.cbSize = cbSize;
   end
   
   % Check for anything else:
   if (total_bytes > nbytes),
      % Simply skip remaining stuff - we don't know what it is:
      if (fseek(fid,total_bytes-nbytes,0) == -1);
         msg = 'Error reading PCM <wave-fmt> chunk.';
         return
      end
   end    
end
return

  
% ---------------------------------------------
% READ_WAVEDAT: Read WAVE data chunk
%   Assumes fid points to the wave-data chunk
%   Requires <data-ck> and <wave-format> structures to be passed.
%   Requires extraction range to be specified.
%   Setting ext=[] forces ALL samples to be read.  Otherwise,
%       ext should be a 2-element vector specifying the first
%       and last samples (per channel) to be extracted.
%   Setting ext=-1 returns the number of samples per channel,
%       skipping over the sample data.
% ---------------------------------------------
function [dat,msg] = read_wavedat(datack,wavefmt,ext)

% In case of unsupported data compression format:
dat     = [];
fmt_msg = '';

switch wavefmt.wFormatTag
case 1
   % PCM Format:
   [dat,msg] = read_dat_pcm(datack,wavefmt,ext);
case 2
   fmt_msg = 'Microsoft ADPCM';
case 6
   fmt_msg = 'CCITT a-law';
case 7
   fmt_msg = 'CCITT mu-law';
case 17
   fmt_msg = 'IMA ADPCM';   
case 34
   fmt_msg = 'DSP Group TrueSpeech TM';
case 49
   fmt_msg = 'GSM 6.10';
case 50
   fmt_msg = 'MSN Audio';
case 257
   fmt_msg = 'IBM Mu-law';
case 258
   fmt_msg = 'IBM A-law';
case 259
   fmt_msg = 'IBM AVC Adaptive Differential';
otherwise
   fmt_msg = ['Format #' num2str(wavefmt.wFormatTag)];
end
if ~isempty(fmt_msg),
   msg = ['Data compression format (' fmt_msg ') is not supported.'];
end
return


% ---------------------------------------------
% READ_DAT_PCM: Read PCM format data from <wave-data> chunk.
%   Assumes fid points to the wave-data chunk
%   Requires <data-ck> and <wave-format> structures to be passed.
%   Requires extraction range to be specified.
%   Setting ext=[] forces ALL samples to be read.  Otherwise,
%       ext should be a 2-element vector specifying the first
%       and last samples (per channel) to be extracted.
%   Setting ext=-1 returns the number of samples per channel,
%       skipping over the sample data.
% ---------------------------------------------
function [dat,msg] = read_dat_pcm(datack,wavefmt,ext)

dat = [];
msg = '';

% Determine # bytes/sample - format requires rounding
%  to next integer number of bytes:
BytesPerSample = ceil(wavefmt.nBitsPerSample/8);  
if (BytesPerSample == 1),
   dtype='uchar'; % unsigned 8-bit
elseif (BytesPerSample == 2),
   dtype='short'; % signed 16-bit
else
   msg = 'Cannot read PCM file formats with more than 16 bits per sample.';
   return
end

total_bytes       = datack.Size; % # bytes in this chunk
total_samples     = total_bytes / BytesPerSample;
SamplesPerChannel = total_samples / wavefmt.nChannels;
if ~isempty(ext) & ext==-1,
   % Just return the samples per channel, and fseek past data:
   dat = SamplesPerChannel;
   if(fseek(datack.fid,total_bytes,'cof')==-1),
	   msg = 'Error reading PCM file format.';
   end
   return
end

% Determine sample range to read:
if isempty(ext),
   ext = [1 SamplesPerChannel];    % Return all samples
else
   if prod(size(ext))~=2,
      msg = 'Sample limit vector must have 2 elements.';
      return
   end
   if ext(1)<1 | ext(2)>SamplesPerChannel,
      msg = 'Sample limits out of range.';
      return
   end
   if ext(1)>ext(2),
      msg = 'Sample limits must be given in ascending order.';
      return
   end
end

% Skip over leading samples:
if ext(1)>1,
   % Skip over leading samples, if specified:
   if(fseek(datack.fid, ...
         BytesPerSample*(ext(1)-1)*wavefmt.nChannels,0)==-1),
	   msg = 'Error reading PCM file format.';
      return
   end
end

% Read desired data:
nSPCext    = ext(2)-ext(1)+1; % # samples per channel in extraction range
dat        = datack;  % Copy input structure to output
extSamples = wavefmt.nChannels*nSPCext;
dat.Data   = fread(datack.fid, [wavefmt.nChannels nSPCext], dtype);

% if cnt~=extSamples, dat='Error reading file.'; return; end
% Skip over trailing samples:
if(fseek(datack.fid, BytesPerSample * ...
      (SamplesPerChannel-ext(2))*wavefmt.nChannels, 0)==-1),
   msg = 'Error reading PCM file format.';
   return
end

% Determine if a pad-byte is appended to data chunk,
%   skipping over it if present:
if rem(datack.Size,2),
   fseek(datack.fid, 1, 'cof');
end
% Rearrange data into a matrix with one channel per column:
dat.Data = dat.Data';
% Normalize data range: min will hit -1, max will not quite hit +1.
if BytesPerSample==1,
   dat.Data = (dat.Data-128)/128;  % [-1,1)
else
   dat.Data = dat.Data/32768;  % [-1,1)
end

return

% end of wavread.m
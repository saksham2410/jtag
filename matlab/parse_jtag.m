function s = parse_jtag(file)
% PARSE_JTAG    Reads the contents of the jtag file passed into a structure
%               array.
%
%   Attempts to validate and open FILE passed, reading its header and selection
%   information into fields of structure S as follows:
%
%     s.jtag_file  -> the full path and name to the .jtag file used to create s
%     s.img_file   -> the full path and name to the associated image file
%     s.rects      -> n x 4 matrix listing the 4 position values L,T,R,B of
%                     each of the n selection rectangles made for this image
%     s.class_id   -> n x 1 matrix listing the number of the class belonging
%                     to the associated selection rectangle in s.rects
%     s.class_name -> column vector whose entries represent the string name of
%                     the class associated with that row number (note that
%                     these entries may be padded with trailing blanks to keep
%                     the matrix rectangular).
%
%   If there is a problem at any point during file parsing or structure
%   creation, an appropriate error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: parse_jtag.m,v 1.2 2003-07-24 19:12:49 scottl Exp $
% 
% REVISION HISTORY:
% $Log: parse_jtag.m,v $
% Revision 1.2  2003-07-24 19:12:49  scottl
% Changed structure to be easier to manipulate.
%
% Revision 1.1  2003/07/23 16:23:01  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% jtag file specifics (update these as the jtag file spec. changes)
separator = '---';  % used to denote the start of a selection
img_prefix = 'img'; % used to denote the path and name of the image file
                    % associated with this jtag file

% first do some argument sanity checking on the argument passed
error(nargchk(1,1,nargin));

if iscell(file) | ~ ischar(file) | size(file,1) ~= 1
    error('FILE must contain a single string.');
end

% attempt open the arg and read in its header information
fid = fopen(file);

if fid == -1
    error('unable to open FILE.');
end

s.jtag_file = file;

while ~ feof(fid)

    line = parse_line(fgetl(fid));

    if isempty(line)
        continue;
    elseif strcmp(deblank(line(1,:)), separator)
        break;
    elseif strcmp(deblank(line(1,:)), img_prefix)
        s.img_file = deblank(line(2,:));
    end

end

% now loop to parse and add each of the selections, should be in multiples
% of 3 (4 including the separator)
s.rects      = [];
s.class_id   = [];
s.class_name = [];
while ~ feof(fid)

    class_line = parse_line(fgetl(fid));
    pos_line = parse_line(fgetl(fid));
    mode_line = parse_line(fgetl(fid));

    class_name = deblank(class_line(2,:));
    data = str2num([pos_line(2:5,:)]);
    data = data';

    found = false;
    for i=1:size(s.class_name,1)
        if strcmp(deblank(s.class_name(i,:)), class_name)
            id = i;
            found = true;
            break;
        end
    end

    if ~ found
        % add the new entry
        id = size(s.class_name,1) + 1;
        s.class_name = strvcat(s.class_name, class_name);
    end

    % add this selection's data to the arrays
    s.class_id(size(s.rects,1) + 1, :) = id;
    s.rects(size(s.rects,1) + 1, :) = data;

    % next line must be a separator (if more lines exist)
    fgetl(fid);

end

% close the file
fclose(fid);



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = parse_line(in)
% PARSE_LINE subfunction that takes a single line, strips its comments,
%            removes the '=' character if it exists, and returns all of its 
%            remaining non-whitespace elements as elemnts of a column array (or 
%            the empty string if IN is blank).

if ~ ischar(in)
    error('IN is not a string.');
end

if isempty(in)
    res = in;
    return;
else
    res = [];
end

% strip all characters after (and including) the comment char
commentpos = regexp(in, '#', 'once');
if ~ isempty(commentpos)
    if commentpos > 1
       in = ddeblank(in(1 : commentpos - 1));
    else
       return;
    end
end

% loop over each whitespace delimited token, adding it to res (drop the '=')
% though
[curr, rest] = strtok(in);
while ~ isempty(rest)
    if ~ strcmp(ddeblank(curr), '=')
        res = strvcat(res, curr);
    end
    [curr, rest] = strtok(rest);
end
if ~ strcmp(ddeblank(curr), '=')
    res = strvcat(res, curr);
end

function m = xycut(img_file, varargin)
% XYCUT    Decompose the image passed into a set of subrectangle segments
%          using the top-down X-Y cut page segmentation algorithm.
%
%   M = XYCUT(IMG_FILE, {H_THRESH, V_THRESH})  splits the page specified by
%   IMG_FILE into segments recursively by making cuts into the most prominent
%   valley in the horizontal and vertical directions at each step.  This 
%   process bottoms out when the valleys are less than H_THRESH and V_THRESH 
%   pixels in length.
%   
%   The nx4 matrix M returned lists the left,top,bottom,right co-ordinated of
%   each of the n segments created.
%
%   H_THRESH and V_THRESH are optional, and if left unspecified H_THRESH
%   defaults to: 50 and V_THRESH defaults to: 50
%
%   If there is a problem at any point, an error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: xycut.m,v 1.1 2003-08-01 22:01:36 scottl Exp $
% 
% REVISION HISTORY:
% $Log: xycut.m,v $
% Revision 1.1  2003-08-01 22:01:36  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

ht = 50;  % default horizontal threshold (if not passed above)
vt = 50;  % default vertical threshold (if not passed above)


% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));

if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
    error('IMG_FILE must contain a single string.');
end

if nargin >= 2
    ht = varargin{1};
    if nargin == 3
        vt = varargin{2};
    end
end

% attempt open the file and read in its pixel data
p = imread(img_file);

% determine the initial page bounding box co-ords
x1 = 1;
y1 = 1;
x2 = size(p,2);
y2 = size(p,1);

% recursively segment the bounding box to create the list of segments
m = segment(p, x1, y1, x2, y2, ht, vt);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = segment(p, x1, y1, x2, y2, ht, vt)
% SEGMENT  Recursive subfunction that segments the rectangle passed into
%          smaller pieces using the XY cut algorithm.

% start by determining the sum of all non-background pixels in the horizontal
% and vertical directions within the co-ord box passed -- note we must use 1-
% pixel value since background pixels are 1
hsums = sum(1 - p(y1:y2, x1:x2));
vsums = sum(1 - p(y1:y2, x1:x2), 2);

% determine the longest background valley (sum value = 0) run in both
% directions
[hrunlength, hrunpos] = long_valley(hsums);
[vrunlength, vrunpos] = long_valley(vsums);

if vrunlength > vt & vrunlength >= hrunlength
    % make a horizontal cut along the vertical midpoint
    res = [segment(p, x1, y1, x2, (y1 + vrunpos), ht, vt); ...
           segment(p, x1, (y1 + vrunpos), x2, y2, ht, vt)];

elseif hrunlength > ht & hrunlength >= vrunlength
    % make a vertical cut along the horizontal midpoint
    res = [segment(p, x1, y1, (x1 + hrunpos), y2, ht, vt); ...
           segment(p, (x1 + hrunpos), y1, x2, y2, ht, vt)];
else
    % non-recursive case, don't split anything
    res = [x1, y1, x2, y2];
end


function [longlength, mid] = long_valley(sums)
% LONG_VALLEY  Subfunction that determines the length and midpoint position of
%              the longest background valley (sums value =0) run in the vector
%              passed.  If the vector is all non-zero, a length of 0 is
%              returned and the mid is undefiend (NaN).

s = 1;
e = length(sums);
currlength = 0;
longlength = 0;
mid = nan;

% strip the leading and trailing 0 runs from sums (since we want a full valley
% for our run count).
while sums(s) == 0
    s = s + 1;
end
while sums(e) == 0
    e = e - 1;
end

if s >= e
    return;
end

for i = s:e

    if sums(i) == 0
        currlength = currlength + 1;
        if currlength > longlength
            longlength = currlength;
            mid = i - floor(longlength / 2);
        end
    else
        currlength = 0;
    end
end
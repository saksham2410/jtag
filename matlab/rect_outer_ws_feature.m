function dists = rect_outer_ws_feature(rect, pixels, varargin)
% RECT_OUTER_WS_FEATURE   Returns the distance (in pixels) from the edges of 
%                         the RECT passed, out to the nearest amounts of 
%                         substantial ink on each of the 4 sides outside RECT.
%
%  DISTS = RECT_OUTER_WS_FEATURE(RECT, PAGE, {THRESHOLD})  This feature 
%  returns a 4 element row vector containing the pixel distance to the left, 
%  top, right, and bottom areas of substantial non-background ink inside PAGE.
%  Substantial is determined by the percentage THRESHOLD passed, and defaults
%  to 2 if not specified.  Note that if there is only whitespace between a
%  side of RECT and the edge of the page, the distance returned for that side
%  is the distance to the edge of the PAGE.  Also note that to determine
%  whitespace above and below the selection it looks at the entire width of
%  the page.  To determine whitespace to the left or right, it only looks out
%  at the same height as the selection (not above or below it).


% CVS INFO %
%%%%%%%%%%%%
% $Id: rect_outer_ws_feature.m,v 1.3 2003-07-24 19:49:59 scottl Exp $
% 
% REVISION HISTORY:
% $Log: rect_outer_ws_feature.m,v $
% Revision 1.3  2003-07-24 19:49:59  scottl
% Changed algorithm to detect whitespace by scanning the entire width of the
% page for top and bottom whitespace checks, and only scan the height of the
% selection for the left and right checks.
% Also changed the return value so that an actual row vector is returned.
%
% Revision 1.2  2003/07/23 22:28:33  scottl
% Small bugfix for when pixel location begins at 1,1.
%
% Revision 1.1  2003/07/23 21:31:57  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02;  % default threshold to use if not passed above
bg = 1;           % default value for background pixels


% first do some argument sanity checking on the arguments passed
error(nargchk(2,3,nargin));

[r, c] = size(pixels);

if ndims(rect) > 2 | size(rect) ~= 4
    error('RECT passed must have exactly 4 elements');
elseif rect(1) < 1 | rect(2) < 1 | rect(3) > c | rect(4) > r
    error('RECT passed exceeds PAGE boundaries');
end

if nargin == 3 
    if varargin{1} < 0 | varargin{1} > 100 
        error('THRESHOLD passed must be a percentage (between 0 and 1)'); 
    end
    threshold = varargin{1};
end

left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);

l_done = false;
t_done = false;
r_done = false;
b_done = false;

while ~ (l_done & t_done & r_done & b_done)

    if ~ l_done
        left = left - 1;
        if left <= 1
            left = 1;
            l_done = true;
        else
            count = 0;
            for i = rect(2):rect(4)
                if pixels(i, left) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * (rect(4) - rect(2) + 1))
                l_done = true;
            end
        end
    end
    
    if ~ t_done
        top = top - 1;
        if top <= 1
            top = 1;
            t_done = true;
        else
            count = 0;
            for i = 1:c
                if pixels(top,i) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * c)
                t_done = true;
            end
        end
    end
    
    if ~ r_done
        right = right + 1;
        if right >= c
            right = c;
            r_done = true;
        else
            count = 0;
            for i = rect(2):rect(4)
                if pixels(i, right) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * (rect(4) - rect(2) + 1))
                r_done = true;
            end
        end
    end

    if ~ b_done
        bottom = bottom + 1;
        if bottom >= r
            bottom = r;
            b_done = true;
        else
            count = 0;
            for i = 1:c
                if pixels(bottom, i) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * c)
                b_done = true;
            end
        end
    end
    
end  %end while loop

dists = [left, top, right, bottom];

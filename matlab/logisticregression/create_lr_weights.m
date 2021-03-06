function w = create_lr_weights(data, sigma, maxevals, outfile)
% CREATE_LR_WEIGHTS    Builds up a struct containing coefficient weights for
%                      use in a logistical regression classifier.
%
%   W = CREATE_LR_WEIGHTS(DATA, [SIGMA, ITERATIONS])  Attempts to build up and
%   optomize a set of coefficient weights for use in a logistic regression
%   classifier.  The DATA pased should either be a struct like that returned
%   from CREATE_TRAINING_DATA, or it can be a list of files like that passed
%   into CREATE_TRAINING_DATA.  This data will contain a list of features and
%   selections used to determine the weights.  The optional arguments that can
%   be specified include SIGMA, the inverse variance of the gaussian weight
%   prior (defaults to 1e-3), and ITERATIONS which specifies the maximum
%   number of evaluations performed during optomization (defaults to 1e4). 
%   The struct w returned has the following structure:
%
%     w.class_names -> cell array whose entries represent the string name of
%                      the class associated with that entry number.
%     w.weights -> MxN matrix of floating point numbers, where each M (row)
%                  represents a class (size(M) == size(w.class_names)), and
%                  each of the N columns corresponds to a weight value 
%                  (coefficient) for that feature.


% CVS INFO %
%%%%%%%%%%%%
% $Id: create_lr_weights.m,v 1.6 2006-02-19 18:32:13 scottl Exp $
% 
% REVISION HISTORY:
% $Log: create_lr_weights.m,v $
% Revision 1.6  2006-02-19 18:32:13  scottl
% Removed unused calls, cleaned up some diagnostic messages.
%
% Revision 1.5  2004/12/04 22:12:22  klaven
% *** empty log message ***
%
% Revision 1.4  2004/08/04 20:51:19  klaven
% Assorted debugging has been done.  As of this version, I was able to train and test all methods successfully.  I have not yet tried using them all in the jtag software yet.
%
% Revision 1.3  2004/07/29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.2  2004/07/01 16:45:50  klaven
% Changed the code so that we only need to extract the features once.  All testing functions work only with the extracted features now.
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.6  2004/06/18 21:58:30  klaven
% Added a few more items to what is stored in the lr_weights.
%
% Revision 1.5  2004/06/14 20:20:06  klaven
% Changed the load and save routines for lr weights to be more general, allowing me to add more fields to the weights data structure.  Also added a record of the log likelihood progress to the weights data structure.
%
% Revision 1.4  2004/06/09 19:20:17  klaven
% Started working on marks-based features.
%
% Revision 1.3  2004/04/22 16:51:03  klaven
% Assorted changes made while testing lr and knn on larger samples
%
% Revision 1.2  2004/01/19 01:44:57  klaven
% Updated the changes made over the last couple of months to the CVS.  I really should have learned how to do this earlier.
%
% Revision 1.1  2003/09/22 20:50:04  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%
global class_names;

% first do some argument sanity checking on the argument passed
error(nargchk(1,4,nargin));
if(nargin < 2) sigma = 1e-3; end
if(nargin < 3) maxevals = 1e4; end

if ~ isstruct(data)
    if ~ iscellstr(data)
        error('DATA must either be a list of files or a struct ala CREATE_TD');
    else
        % convert list to training data struct
        data = create_training_data(data);
    end
end

% initialize output struct and fields
w.class_names = data.class_names;
w.weights = [];
w.feature_names = data.feat_names;

norms = find_norms(data);
data = normalize_td(data,norms);
w.norm_add = data.norm_add;
w.norm_div = data.norm_div;

% cc is the list of all selections class id's
cc = [];
% ff is the list of all selections feature values
ff = [];
for i = 1:data.num_pages
    if (min(data.pg{i}.cid) <= 0);
        error('ERROR - invalid cid in page %i', i);
    end;
    cc = [cc; reshape(data.pg{i}.cid,length(data.pg{i}.cid),1)];
    ff = [ff, data.pg{i}.features'];
end

C = length(class_names);
[M,N] = size(ff);

fprintf('C=%i, M=%i, N=%i\n',C,M,N);
[weightmatrix,llprogress,iterations] = ...
     minimize(sqrt(sigma)*randn((M+1)*C,1),'mefun',maxevals,cc,ff,sigma);

w.loglikelihoods = llprogress;
w.weights = reshape(weightmatrix(:),M+1,C);

if (nargin == 4);
    dump_lr_weights(w,outfile);
end;


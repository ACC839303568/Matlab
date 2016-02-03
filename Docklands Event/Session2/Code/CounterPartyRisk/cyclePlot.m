function cyclePlot(plotFun, pauseDur, varargin)
% cyclePlot(plotFun, pauseDur, data1, dim1, data2, dim2, ...)
if length(varargin) < 2
    error('At least one data set and dimension must be specified');
end
data1 = varargin{1};
dim1 = varargin{2};
numPlots = size(data1, dim1);

figH = clf;

idx = 0;
if isempty(pauseDur)
    fprintf('Press a key to change plot. ');
end
fprintf('Press the escape key to stop animation\n');

while isempty(get(figH,'CurrentCharacter')) || get(figH,'CurrentCharacter') ~= 27
    idx = mod(idx,numPlots)+1;
    inputs = cell(1,length(varargin)/2);
    s = struct('type','()','subs',{''});
    for i = 1:length(inputs)
        inputs{i} = varargin{i*2-1};
        if ~isempty(varargin{i*2}) % Otherwise no need to index into it
            s.subs = repmat({':'},1,ndims(inputs{i}));
            s.subs{varargin{i*2}} = idx;
            inputs{i} = subsref(inputs{i}, s);
            if ndims(inputs{i}) > 2
                inputs{i} = squeeze(inputs{i});
            end
            if iscell(inputs{i}) && numel(inputs{i}) == 1
                inputs{i} = inputs{i}{1};
            end
        end
    end
    plotFun(inputs{:});
    if isempty(pauseDur)
        pause;
    else
        pause(pauseDur);
    end
end
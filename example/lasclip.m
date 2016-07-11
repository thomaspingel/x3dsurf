function [L] = lasclip(L,bb)

fn = fieldnames(L);
len = length(L.X);
idx = L.X>=bb(1) & L.X<=bb(2) & L.Y>=bb(3) & L.Y<=bb(4);

for i = 1:length(fn)
    thisField = eval(['L.',fn{i}]);
    if length(thisField) == len
        eval(['L.',fn{i},'=thisField(idx);']);
    end
end


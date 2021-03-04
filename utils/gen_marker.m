
function marker=gen_marker(curve_idx)

markers={'p','s','v','x','^','o','h','d','+','.','>','*','<'};% OUR 'd'

sel_idx=mod(curve_idx-1, length(markers))+1;
marker=markers{sel_idx};

end

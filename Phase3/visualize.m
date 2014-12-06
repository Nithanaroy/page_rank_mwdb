function visualize(values, nodes)

imagesc(values);

set(0, 'DefaulttextInterpreter', 'none');
for i = 1:size(nodes, 2)
    text(1,i, strcat(num2str(nodes(i)), '.csv'));
end;

end
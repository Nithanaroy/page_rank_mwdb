function heat_map( filetype, G, f )
% Creates a heat map, given the type of epidemic word file, and an epidemic simulation file f.
% Input arguments:
%     filetype - Type of epidemic word file, either 'file', 'avg' or 'diff'
%     G - Connectivity graph in xlsx format
%     f - Epidemic simulation file in csv format


% Parse epidemic file
[ mat, states ] = parsedatafile(f);
[~, f, ~] = fileparts(f);

% Build neighbor list
nblist = neighbor_list( G );

% Initialize mongo
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
if strcmpi(filetype, 'file')
    coll = db.getCollection('word_file'); 
elseif strcmpi(filetype, 'avg') 
    coll = db.getCollection('word_file_avg'); 
elseif strcmpi(filetype, 'diff') 
    coll = db.getCollection('word_file_diff'); 
else
    error('Unknown type of epidemic file');
end

% Draw image background
imagesc(mat');
axis off;
colormap(cool);

% Prepare mongo query
queryf = BasicDBObject();
queryf.put('f', f);

% find highest strength window
cursor = coll.find(queryf).sort(BasicDBObject('str', -1)).limit(1);
docres = cursor.next();
% draw window and text
s = docres.get('s');
t = docres.get('t');
wlist = docres.get('win');
winsize = wlist.size;
si = find(not(cellfun('isempty', strfind(states, s))));
x = t - 0.5;
y = si - 0.5;
w = winsize;
h = 1;
rectangle('Position', [x,y,w,h], 'EdgeColor', 'white');
text(x+0.5,y+0.5, strcat(s,'*'), 'Color', 'white');
% draw neighbors
nbNames = nblist.(s);
numNbs = numel(nbNames);
if numNbs > 0
    for nbi = 1:numNbs
        nbs = char(nbNames(nbi));
        si = find(not(cellfun('isempty', strfind(states, nbs))));
        x = t - 0.5;
        y = si - 0.5;
        w = winsize;
        h = 1;
        rectangle('Position', [x,y,w,h], 'EdgeColor', 'white');
        text(x+0.5,y+0.5, nbs, 'Color', 'white');
    end
end


% find lowest strength window
cursor = coll.find(queryf).sort(BasicDBObject('str', 1)).limit(1);
docres = cursor.next();
% draw window and text
s = docres.get('s');
t = docres.get('t');
wlist = docres.get('win');
winsize = wlist.size;
si = find(not(cellfun('isempty', strfind(states, s))));
x = t - 0.5;
y = si - 0.5;
w = winsize;
h = 1;
rectangle('Position', [x,y,w,h], 'EdgeColor', 'black');
text(x+0.5,y+0.5, strcat(s,'*'), 'Color', 'black');
% draw neighbors
nbNames = nblist.(s);
numNbs = numel(nbNames);
if numNbs > 0
    for nbi = 1:numNbs
        nbs = char(nbNames(nbi));
        si = find(not(cellfun('isempty', strfind(states, nbs))));
        x = t - 0.5;
        y = si - 0.5;
        w = winsize;
        h = 1;
        rectangle('Position', [x,y,w,h], 'EdgeColor', 'black');
        text(x+0.5,y+0.5, nbs, 'Color', 'black');
    end
end

end
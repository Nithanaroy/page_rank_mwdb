function epidemic_word_file = epidemic_words( directory, w, h, r, align )
% Create an epidemic_word_file, given a directory dir, window length w, a shift length h, and a resolution r.
% Input arguments:
%     directory - Directory of csv data files
%     w - Window length
%     h - Shift length
%     r - Quantization resolution/bands
% Output arguments:
%     epidemic_word_file - Struct array of idx-win pairs

% Get all csv files in directory
files = dir(fullfile(directory,'*.csv'));

% Initialize files container
numfiles = numel(files);
filesarray(numfiles).mat = [];
filesarray(numfiles).states = [];
filesarray(numfiles).numstates = 0;
filesarray(numfiles).idxtimes = [];
filesarray(numfiles).numtimes = 0;
filesarray(numfiles).numelems = 0;

% Populate files container
totalnumelems = 0;
for fi = 1:numfiles
    [ mat, states ] = parsedatafile( fullfile(directory, files(fi).name) );
    filesarray(fi).mat = mat;
    filesarray(fi).states = states;
    numstates = numel(states);
    filesarray(fi).numstates = numstates;
    idxtimes = 1:h:size(mat, 1)-(w-1);
    filesarray(fi).idxtimes = idxtimes;
    numtimes = numel(idxtimes);
    filesarray(fi).numtimes = numtimes;
    numelems = numstates*numtimes;
    filesarray(fi).numelems = numelems;
    totalnumelems = totalnumelems + numelems;
end

% Initalize struct array for mat output
epidemic_word_file(totalnumelems).f = '';
epidemic_word_file(totalnumelems).s = '';
epidemic_word_file(totalnumelems).t = 0;
epidemic_word_file(totalnumelems).win = zeros(1, w);

% Initialize mongo
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
coll = db.getCollection('word_file'); 
coll.drop();
builder = coll.initializeUnorderedBulkOperation();

% Processing each file
ei = 1;
for fi = 1:numfiles
    % Compute normalized mat
    normedmat = normmat( filesarray(fi).mat );
    % Compute quantized mat
    quantizedmat = quantmat( normedmat, r, align );
    % For each state and time iteration
    for si = 1:filesarray(fi).numstates
        for ti = filesarray(fi).idxtimes
            [~, f, ~] = fileparts(files(fi).name);
            s = char(filesarray(fi).states(si));
            % Compute current window
            win = transpose(quantizedmat(ti:ti+(w-1), si));
            % Compute strength
            strength = norm(win);
            
            % write to mat
            epidemic_word_file(ei).f = f;
            epidemic_word_file(ei).s = s;
            epidemic_word_file(ei).t = ti;
            epidemic_word_file(ei).win = win;

            % write to mongo
            doc = BasicDBObject();
            doc.put('f', f);
            doc.put('s', s);
            doc.put('t', ti);
            % win values stored as strings, use str2num to reverse this
            doc.put('win', num2str(win));
            doc.put('str', strength);
            builder.insert(doc);
            
            ei = ei + 1;
        end
    end
end

% save to mongo
builder.execute();

% create mongo indexes on fst, strength and win
idxfst = BasicDBObject();
idxfst.put('f', true);
idxfst.put('s', true);
idxfst.put('t', true);
% coll.createIndex(idxfst, BasicDBObject('unique', true));
% coll.createIndex(BasicDBObject('str', true));
idxwinf = BasicDBObject();
idxwinf.put('win', true);
idxwinf.put('f', true);
% coll.createIndex(idxwinf);

close(mongoClient);

end
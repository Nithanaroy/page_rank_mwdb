function epidemic_word_file_diff = win_diff( epidemic_word_file, G )
% Create epidemic_word_file_diff, given a connectivity graph G, and epidemic_word_file.
% Input arguments:
%     epidemic_word_file - Struct array of idx-win pairs
%     G - Connectivity graph in xlsx format
% Output arguments:
%     epidemic_word_file_diff - Struct array of idx-win pairs

% Load epidemic_word_file
totalnumelems = numel(epidemic_word_file);
winsize = numel(epidemic_word_file(1).win);

% build neighbor list
nblist = neighbor_list( G );

% initalize struct array for mat output
epidemic_word_file_diff(totalnumelems).f = '';
epidemic_word_file_diff(totalnumelems).s = '';
epidemic_word_file_diff(totalnumelems).t = 0;
epidemic_word_file_diff(totalnumelems).win = zeros(1, winsize);

% initialize mongo
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
collword = db.getCollection('word_file');
colldiff = db.getCollection('word_file_diff'); 
colldiff.drop();
builder = colldiff.initializeUnorderedBulkOperation();

% process each doc
for ei = 1:totalnumelems
    f = epidemic_word_file(ei).f;
    s = epidemic_word_file(ei).s;
    t = epidemic_word_file(ei).t;
    win = epidemic_word_file(ei).win;
    nbNames = nblist.(s);
    numNbs = numel(nbNames);
    
    % process neighbor windows
    if numNbs > 0
        nbWins = zeros(numNbs, winsize);
        for nbi = 1:numNbs
            query = BasicDBObject();
            query.put('f', f);
            query.put('s', char(nbNames(nbi)));
            query.put('t', t);
            fields = BasicDBObject();
            fields.put('_id', 0);
            fields.put('win', 1);
            resDoc = collword.findOne(query, fields);
            nbWin = resDoc.get('win');
            % Add to array of neighbors' windows
            nbWins(nbi, :) = str2num(nbWin);
        end
        nbavg = mean(nbWins, 1);
        windiff = (win - nbavg)./win;
    else
        windiff = ones(1, numel(win));
    end
    
    % write to mat
    epidemic_word_file_diff(ei).f = f;
    epidemic_word_file_diff(ei).s = s;
    epidemic_word_file_diff(ei).t = t;
    epidemic_word_file_diff(ei).win = windiff;

    % write to mongo
    docdiff = BasicDBObject();
    docdiff.put('f', f);
    docdiff.put('s', s);
    docdiff.put('t', t);
    % win values stored as strings, use str2num to reverse this
    docdiff.put('win', num2str(windiff));
    docdiff.put('str', norm(windiff));
    builder.insert(docdiff);
end

% save to mongo
builder.execute();

% create mongo indexes
idxfst = BasicDBObject();
idxfst.put('f', true);
idxfst.put('s', true);
idxfst.put('t', true);
colldiff.createIndex(idxfst, BasicDBObject('unique', true));
colldiff.createIndex(BasicDBObject('str', true));
idxwinf = BasicDBObject();
idxwinf.put('win', true);
idxwinf.put('f', true);
colldiff.createIndex(idxwinf);

end
function epidemic_word_file_avg = win_avg( epidemic_word_file, G, alpha )
% Create epidemic_word_file_avg, given a connectivity graph G, and epidemic_word_file, and weight, 0 <= a <= 1.
% Input arguments:
%     epidemic_word_file - Struct array of idx-win pairs
%     G - Connectivity graph in xlsx format
%     alpha - Weight
% Output arguments:
%     epidemic_word_file_avg - Struct array of idx-win pairs

% Load epidemic_word_file
totalnumelems = numel(epidemic_word_file);
winsize = numel(epidemic_word_file(1).win);

% build neighbor list
nblist = neighbor_list( G );

% initalize struct array for mat output
epidemic_word_file_avg(totalnumelems).f = '';
epidemic_word_file_avg(totalnumelems).s = '';
epidemic_word_file_avg(totalnumelems).t = 0;
epidemic_word_file_avg(totalnumelems).win = zeros(1, winsize);

% initialize mongo
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
collword = db.getCollection('word_file');
collavg = db.getCollection('word_file_avg'); 
collavg.drop();
builder = collavg.initializeUnorderedBulkOperation();

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
        % For each neighbor
        for nbi = 1:numNbs
            % Prepare mongoDB query 
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
        % Compute average of neighbors' windows
        nbavg = mean(nbWins, 1);
        
        winavg = alpha*win + (1-alpha)*nbavg;
    else
        winavg = alpha*win;
    end
    
    % write to mat
    epidemic_word_file_avg(ei).f = f;
    epidemic_word_file_avg(ei).s = s;
    epidemic_word_file_avg(ei).t = t;
    epidemic_word_file_avg(ei).win = winavg;

    % write to mongo
    docavg = BasicDBObject();
    docavg.put('f', f);
    docavg.put('s', s);
    docavg.put('t', t);
    % win values stored as strings, use str2num to reverse this
    docavg.put('win', num2str(winavg));
    docavg.put('str', norm(winavg));
    builder.insert(docavg);
end

% save to mongo
builder.execute();

% create mongo indexes
idxfst = BasicDBObject();
idxfst.put('f', true);
idxfst.put('s', true);
idxfst.put('t', true);
collavg.createIndex(idxfst, BasicDBObject('unique', true));
collavg.createIndex(BasicDBObject('str', true));
idxwinf = BasicDBObject();
idxwinf.put('win', true);
idxwinf.put('f', true);
collavg.createIndex(idxwinf);

end
function similar_rows = sim(f1, f2, mongo_collection)
% A helper function for computing similarity measures described in tasks
% 1c, 1d, 1e.
%
% Input:
% f1: file 1's name. Eg: 1.csv or 1 in character format
% f2: file 2's name. Eg: 1.csv or 1 in character format
% mongo_collection: name of the mongo db's collection / table to use. the
% wrapper functions which use this function know which collection to use
% for which task.
%
% Output:
% A similarity score between f1 and f2 found using the given mongo table

wins_f1 = get_file_from_db(char(regexp(f1, '^\d*', 'match')));
wins_f2 = get_file_from_db(char(regexp(f2, '^\d*', 'match')));
sorted_unique_w1 = sortrows(unique(wins_f1, 'rows'));
sorted_unique_w2 = sortrows(unique(wins_f2, 'rows'));

    function wins = get_file_from_db(filename)
        javaaddpath('mongo-java-driver-2.12.3.jar');
        import('com.mongodb.*');
        mongoClient = MongoClient();
        db = mongoClient.getDB( 'epidemic' );
        coll = db.getCollection(mongo_collection);
        
        filter = BasicDBObject();
        filter.put('f', filename);
        project = BasicDBObject();
        project.put('win', 1);
        project.put('_id', 0);
        rows = coll.find(filter, project).toArray;
        
        win_size = size(strsplit(rows.get(1).get('win'), ' '), 2);
        wins = zeros(rows.size, win_size);
        temp = zeros(1, win_size);
        for i = 1: rows.size
            row = strsplit(rows.get(i-1).get('win'), ' ');
            for j = 1:win_size
                temp(j) = str2double(row{j});
            end
            wins(i,:) = temp;
        end
        
        mongoClient.close();
    end

%  && (size( sorted_unique_w1(sorted_unique_w1(i,:) >= sorted_unique_w2(j,:)), 2 ) == size( sorted_unique_w1(i,:), 2 ))

similar_rows = 0;
for i=1:size(sorted_unique_w1,1)
    j = 1;
    while (j <= size(sorted_unique_w2, 1))
        if sorted_unique_w1(i,:) == sorted_unique_w2(j,:)
            similar_rows = similar_rows + 1;
            break;
        end
        j = j + 1;
    end
end
end